# render.R — render the documents in docs/ and post-process the Word output.
#
# HOW TO USE THIS FILE
#
#   Source it, or run it from a shell:
#
#     Rscript docs/render.R                    # every document, every configured format
#     Rscript docs/render.R manuscript         # one document, every configured format
#     Rscript docs/render.R manuscript docx    # one document, one format
#
# HTML does not need this script. `quarto render`, or the Preview button in Positron and the
# Render button in RStudio, produces the HTML preview directly. This script exists for the
# formats that need post-processing afterwards.

`%||%` <- function(a, b) if (is.null(a)) b else a

# --- Read a document's YAML front matter ---------------------------------------------------
# Only the fenced block at the top of the file, read as UTF-8 so Scandinavian characters in
# titles and author names survive whatever the R locale is.
read_front_matter <- function(qmd) {
  lines <- readLines(qmd, encoding = "UTF-8", warn = FALSE)
  fences <- which(trimws(lines) == "---")
  if (length(fences) < 2 || fences[1] != 1) return(list())
  yaml::yaml.load(paste(lines[(fences[1] + 1):(fences[2] - 1)], collapse = "\n"), eval.expr = FALSE)
}

# --- Find the project root ---------------------------------------------------------------
# Sourcing can happen from anywhere, and the working directory is often not the project
# root, so the path of this file is used whenever it can be worked out.
find_project_root <- function() {
  looks_like_root <- function(path) {
    file.exists(file.path(path, "config.yaml")) || file.exists(file.path(path, ".here"))
  }

  folder_of <- function(path) {
    if (!is.character(path) || !length(path)) return(NULL)
    path <- path[[1]]
    if (is.na(path) || !nzchar(path)) return(NULL)
    dirname(normalizePath(path, winslash = "/", mustWork = FALSE))
  }

  walk_up <- function(path) {
    if (is.null(path)) return(NULL)
    path <- normalizePath(path, winslash = "/", mustWork = FALSE)
    repeat {
      if (looks_like_root(path)) return(path)
      parent <- dirname(path)
      if (identical(parent, path)) return(NULL)
      path <- parent
    }
  }

  candidates <- list()

  # source() records the path of the file it is reading, which covers both source() from the
  # console and the Source button. The innermost source() is the relevant one.
  for (frame in rev(sys.frames())) candidates <- c(candidates, list(folder_of(frame$ofile)))

  # Rscript docs/render.R
  file_argument <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(file_argument)) {
    candidates <- c(candidates, list(folder_of(sub("^--file=", "", file_argument[[1]]))))
  }

  # The file open in the editor, for running lines by hand rather than sourcing.
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
        isTRUE(tryCatch(rstudioapi::isAvailable(), error = function(e) FALSE))) {
    candidates <- c(candidates, list(folder_of(tryCatch(
      rstudioapi::getSourceEditorContext()$path, error = function(e) NULL
    ))))
  }

  candidates <- c(candidates, list(getwd()))

  for (candidate in candidates) {
    found <- walk_up(candidate)
    if (!is.null(found)) return(found)
  }

  stop(
    "Could not find the project root (config.yaml or .here).\n",
    "Set the working directory to the project folder and try again.",
    call. = FALSE
  )
}

# --- Render one document in one format -----------------------------------------------------
# Quarto deletes its intermediate _files folder after each render. On a network share or a
# synced folder that delete can fail even though the document itself was written correctly,
# which would otherwise abort the whole build. The render is therefore judged by whether it
# produced an up-to-date output file, and the leftover folder is removed here instead.
render_one <- function(qmd, format) {
  output <- sub("[.]qmd$", paste0(".", format), qmd)
  started <- Sys.time()

  failure <- tryCatch(
    {
      quarto::quarto_render(qmd, output_format = format, as_job = FALSE)
      NULL
    },
    error = function(e) e
  )

  wrote_output <- file.exists(output) &&
    file.info(output)$mtime >= started &&
    file.size(output) > 0

  if (!is.null(failure) && !wrote_output) {
    stop("Rendering ", format, " failed:\n", conditionMessage(failure), call. = FALSE)
  }
  if (!is.null(failure)) {
    message("  (Quarto could not tidy up its temporary files; the ", format, " itself is fine.)")
  }

  unlink(sub("[.]qmd$", "_files", qmd), recursive = TRUE, force = TRUE)
  output
}

# --- Render everything asked for ------------------------------------------------------------
render_documents <- function(documents = NULL, formats = NULL) {
  root <- find_project_root()
  previous <- setwd(root)
  on.exit(setwd(previous), add = TRUE)

  source(file.path(root, "R", "0_setup.R"))

  # Which documents. Each subfolder of docs/ that holds a .qmd is one document.
  qmds <- list.files(
    file.path(root, "docs"), pattern = "[.]qmd$", recursive = TRUE, full.names = TRUE
  )
  qmds <- qmds[!grepl("/assets/", qmds, fixed = TRUE)]
  if (!length(qmds)) stop("No .qmd files found under docs/.", call. = FALSE)

  if (!is.null(documents)) {
    keep <- vapply(qmds, function(f) any(grepl(paste(documents, collapse = "|"), f)), logical(1))
    qmds <- qmds[keep]
    if (!length(qmds)) {
      stop("No document matched: ", paste(documents, collapse = ", "), call. = FALSE)
    }
  }

  # Which formats. Default to every non-HTML format the document declares, because HTML
  # renders straight from the editor and needs nothing from this script.
  outputs <- character()
  for (qmd in qmds) {
    declared <- names(read_front_matter(qmd)$format)
    wanted <- formats %||% setdiff(declared, "html")
    wanted <- intersect(wanted, declared)
    if (!length(wanted)) {
      message("Nothing to render for ", basename(qmd), " (HTML only).")
      next
    }

    for (format in wanted) {
      message("Rendering ", basename(qmd), " -> ", format, " ...")
      out <- render_one(qmd, format)

      if (identical(format, "docx")) {
        message("  Removing Quarto's float wrappers ...")
        ensure_packages("xml2", "zip")
        source(file.path(root, "R", "docx_postprocess.R"))
        unwrap_float_tables(out)
      }

      outputs <- c(outputs, out)
    }
  }

  missing <- outputs[!file.exists(outputs)]
  if (length(missing)) stop("Not written: ", paste(missing, collapse = ", "), call. = FALSE)

  if (length(outputs)) {
    message("\nDone. Written to ", root, ":\n  ",
            paste(sub(paste0("^", root, "/"), "", outputs), collapse = "\n  "))
  }
  invisible(outputs)
}

# --- Run ------------------------------------------------------------------------------------
# Command-line arguments: the first is a document name, the second a format. Both optional.
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  render_documents(
    documents = if (length(args) >= 1) args[1] else NULL,
    formats   = if (length(args) >= 2) args[2] else NULL
  )
}
