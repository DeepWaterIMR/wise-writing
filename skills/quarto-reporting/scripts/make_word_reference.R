## Build a Word reference document from Pandoc's default reference.docx with a
## booktabs-like "Table" style (rules above and below the table and below the
## header row, 9 pt text, no paragraph spacing) and A4 pages.
##
## Usage: Rscript make_word_reference.R <out.docx> [margin_cm]   (default 2.2)
##
## Pandoc's default reference document has no page size, so Word falls back to
## US Letter. Pandoc copies the final sectPr of the reference document into the
## output. If *.docx is gitignored, commit the result with `git add -f`.
## Requires Quarto, xml2 and zip.

make_word_reference <- function(out_file, margin_cm = 2.2) {
  out_file <- file.path(normalizePath(dirname(out_file), mustWork = TRUE),
                        basename(out_file))
  tmp_dir <- tempfile("refdoc")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  ref_file <- file.path(tmp_dir, "reference.docx")
  status <- system2("quarto", c("pandoc", "--print-default-data-file", "reference.docx"),
                    stdout = ref_file)
  if (!identical(as.integer(status), 0L)) stop("quarto pandoc failed")

  unzip_dir <- file.path(tmp_dir, "x")
  zip::unzip(ref_file, exdir = unzip_dir)
  w_ns <- 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
  w_node <- function(x) xml2::read_xml(sub("^<(w:[A-Za-z]+)", paste("<\\1", w_ns), x))

  styles_file <- file.path(unzip_dir, "word", "styles.xml")
  styles <- xml2::read_xml(styles_file)
  ns <- xml2::xml_ns(styles)
  table_style <- xml2::xml_find_first(
    styles, "//w:style[@w:type='table'][@w:styleId='Table']", ns
  )
  if (inherits(table_style, "xml_missing")) stop("No 'Table' style in reference.docx")

  ## Table text 9 pt with no paragraph spacing
  xml2::xml_add_child(table_style, w_node('<w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr>'),
                      .where = 5)
  xml2::xml_add_child(table_style, w_node('<w:rPr><w:sz w:val="18"/><w:szCs w:val="18"/></w:rPr>'),
                      .where = 6)

  ## Rules above and below the table
  tbl_pr <- xml2::xml_find_first(table_style, "w:tblPr", ns)
  xml2::xml_add_child(
    tbl_pr,
    w_node(paste0(
      '<w:tblBorders>',
      '<w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/>',
      '<w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/>',
      '</w:tblBorders>'
    )),
    .where = 1
  )

  ## Thin rule below the header row
  header_border <- xml2::xml_find_first(
    table_style, "w:tblStylePr[@w:type='firstRow']/w:tcPr/w:tcBorders/w:bottom", ns
  )
  if (!inherits(header_border, "xml_missing")) {
    xml2::xml_set_attrs(
      header_border,
      c("w:val" = "single", "w:sz" = "4", "w:space" = "0", "w:color" = "000000")
    )
  }
  xml2::write_xml(styles, styles_file)

  ## A4 pages
  mar <- round(margin_cm / 2.54 * 1440)
  doc_file <- file.path(unzip_dir, "word", "document.xml")
  doc <- xml2::read_xml(doc_file)
  sect_pr <- xml2::xml_find_first(doc, "//w:body/w:sectPr", xml2::xml_ns(doc))
  xml2::xml_remove(xml2::xml_find_all(sect_pr, "w:pgSz|w:pgMar", xml2::xml_ns(doc)))
  xml2::xml_add_child(sect_pr, w_node('<w:pgSz w:w="11906" w:h="16838"/>'))
  xml2::xml_add_child(sect_pr, w_node(sprintf(
    '<w:pgMar w:top="%1$d" w:right="%1$d" w:bottom="%1$d" w:left="%1$d" w:header="708" w:footer="708" w:gutter="0"/>',
    mar
  )))
  xml2::write_xml(doc, doc_file)

  files <- list.files(unzip_dir, recursive = TRUE, all.files = TRUE)
  files <- c("[Content_Types].xml", setdiff(files, "[Content_Types].xml"))
  unlink(out_file)
  zip::zip(out_file, files = files, root = unzip_dir)
  invisible(out_file)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) %in% 1:2) stop("Usage: Rscript make_word_reference.R <out.docx> [margin_cm]")
  margin <- if (length(args) == 2) as.numeric(args[2]) else 2.2
  message("Wrote ", make_word_reference(args[1], margin))
}
