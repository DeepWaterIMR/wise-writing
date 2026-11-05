## Tidy the figure and table layout of a Quarto Word file.
##
## Usage: Rscript docx_tidy.R <file.docx>   (the file is overwritten)
## Or source() it and call docx_tidy("file.docx").
##
## Requires the xml2 and zip packages.

#' Tidy the figure and table layout of a Quarto Word file
#'
#' @description Two fixes that a Lua filter cannot make, because Quarto's Word
#'   writer creates the structures after the filters run:
#'
#'   1. Quarto places every cross-referenced figure and table, with its caption,
#'   inside a borderless one-cell layout table, which Word draws with dashed
#'   gridlines. The content of each outermost one-cell table that holds an
#'   image or a table is moved out and the layout table is deleted. Captions,
#'   bookmarks and cross-references are kept.
#'
#'   2. Column widths of data tables are set from the cell text: the longest
#'   cell (capped at `max_chars`), never narrower than the longest word. A
#'   table wider than the text width of its section (read from the following
#'   `w:sectPr`, so portrait and landscape sections both work) shrinks only the
#'   width above the longest word, down to `min_word_chars` per column so long
#'   code strings can break.
#' @param path Path to the .docx file. The file is overwritten.
#' @param fit_columns Logical. Set column widths from the cell text?
#' @param max_chars Maximum natural column width in characters.
#' @param min_word_chars Narrowest a column may become, in characters.
#' @param char_twips Width of one character in twips (about 115 for 9 pt text).
#' @param pad_twips Cell padding in twips.
#' @return The number of layout tables removed, invisibly.
docx_tidy <- function(path, fit_columns = TRUE, max_chars = 30, min_word_chars = 12,
                      char_twips = 115, pad_twips = 216) {
  tmp_dir <- tempfile("docx")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))

  zip::unzip(path, exdir = tmp_dir)
  doc_file <- file.path(tmp_dir, "word", "document.xml")
  doc <- xml2::read_xml(doc_file)
  ns <- xml2::xml_ns(doc)

  ## 1. Outermost one-row, one-column tables that hold an image or a table

  layout_tables <- xml2::xml_find_all(
    doc,
    paste0(
      "//w:tbl[not(ancestor::w:tbl)]",
      "[count(w:tblGrid/w:gridCol) = 1][count(w:tr) = 1]",
      "[count(w:tr/w:tc) = 1][.//w:drawing or .//w:tbl]"
    ),
    ns
  )

  for (tbl in layout_tables) {
    cell <- xml2::xml_find_first(tbl, "w:tr/w:tc", ns)
    content <- xml2::xml_find_all(cell, "*[not(self::w:tcPr)]", ns)
    for (node in content) {
      xml2::xml_add_sibling(tbl, node, .where = "before")
    }
    xml2::xml_remove(tbl)
  }

  ## 2. Column widths from cell text, scaled to the section text width

  if (fit_columns) {
    data_tables <- xml2::xml_find_all(
      doc,
      "//w:tbl[not(ancestor::w:tbl)][count(w:tblGrid/w:gridCol) > 1]",
      ns
    )

    for (tbl in data_tables) {
      sect <- xml2::xml_find_first(tbl, "following::w:sectPr[1]", ns)
      pg_sz <- xml2::xml_find_first(sect, "w:pgSz", ns)
      mar <- xml2::xml_find_first(sect, "w:pgMar", ns)
      if (inherits(pg_sz, "xml_missing") || inherits(mar, "xml_missing")) next
      text_w <- as.numeric(xml2::xml_attr(pg_sz, "w")) -
        as.numeric(xml2::xml_attr(mar, "left")) -
        as.numeric(xml2::xml_attr(mar, "right"))

      rows <- xml2::xml_find_all(tbl, "w:tr", ns)
      n_col <- length(xml2::xml_find_all(tbl, "w:tblGrid/w:gridCol", ns))
      cell_text <- lapply(rows, function(r) {
        xml2::xml_text(xml2::xml_find_all(r, "w:tc", ns))
      })
      cell_text <- cell_text[lengths(cell_text) == n_col]
      if (!length(cell_text)) next
      cell_text <- do.call(rbind, cell_text)

      full_chars <- apply(nchar(cell_text), 2, max)
      word_chars <- apply(cell_text, 2, function(k) {
        max(nchar(unlist(strsplit(k, "\\s+"))), 1)
      })
      widths <- pmax(pmin(full_chars, max_chars), word_chars) * char_twips + pad_twips
      min_widths <- pmin(word_chars, min_word_chars) * char_twips + pad_twips

      if (sum(widths) > text_w) {
        if (sum(min_widths) < text_w) {
          extra <- widths - min_widths
          widths <- min_widths + extra * (text_w - sum(min_widths)) / sum(extra)
        } else {
          widths <- min_widths * text_w / sum(min_widths)
        }
      }
      widths <- round(widths)

      grid_cols <- xml2::xml_find_all(tbl, "w:tblGrid/w:gridCol", ns)
      xml2::xml_set_attr(grid_cols, "w:w", widths)

      for (r in rows) {
        cells <- xml2::xml_find_all(r, "w:tc", ns)
        if (length(cells) != n_col) next
        for (j in seq_along(cells)) {
          tc_pr <- xml2::xml_find_first(cells[[j]], "w:tcPr", ns)
          if (inherits(tc_pr, "xml_missing")) {
            xml2::xml_add_child(cells[[j]], "w:tcPr", .where = 0)
            tc_pr <- xml2::xml_find_first(cells[[j]], "w:tcPr", ns)
          }
          xml2::xml_remove(xml2::xml_find_all(tc_pr, "w:tcW", ns))
          xml2::xml_add_child(tc_pr, "w:tcW", "w:w" = widths[j], "w:type" = "dxa",
                              .where = 0)
        }
      }

      tbl_pr <- xml2::xml_find_first(tbl, "w:tblPr", ns)
      xml2::xml_remove(xml2::xml_find_all(tbl_pr, "w:tblW|w:tblLayout", ns))
      xml2::xml_add_child(tbl_pr, "w:tblW", "w:w" = sum(widths), "w:type" = "dxa",
                          .where = 1)
    }
  }

  xml2::write_xml(doc, doc_file)

  ## Re-zip with [Content_Types].xml first, as in Word's own files
  files <- list.files(tmp_dir, recursive = TRUE, all.files = TRUE)
  files <- c("[Content_Types].xml", setdiff(files, "[Content_Types].xml"))
  out_file <- normalizePath(path, mustWork = TRUE)
  unlink(out_file)
  zip::zip(out_file, files = files, root = tmp_dir)

  invisible(length(layout_tables))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1) stop("Usage: Rscript docx_tidy.R <file.docx>")
  n <- docx_tidy(args[1])
  message("Removed ", n, " layout tables from ", args[1])
}
