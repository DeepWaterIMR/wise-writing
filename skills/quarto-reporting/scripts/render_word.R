## Render a Quarto document to Word and tidy the result with docx_tidy().
## Use this instead of plain `quarto render --to docx`.
##
## Usage: Rscript render_word.R <document.qmd> <output.docx> [extra quarto args]
## <output.docx> is the file Quarto writes (set by output-file in the docx format).

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: Rscript render_word.R <document.qmd> <output.docx> [quarto args]")
qmd <- args[1]
docx <- args[2]

file_arg <- grep("^--file=", commandArgs(), value = TRUE)
# Rscript writes spaces in the script path as "~+~"
script_dir <- dirname(normalizePath(gsub("~+~", " ", sub("^--file=", "", file_arg), fixed = TRUE)))
source(file.path(script_dir, "docx_tidy.R"))

start <- Sys.time()
status <- system2("quarto", c("render", shQuote(qmd), "--to", "docx", args[-(1:2)]))
if (status != 0) stop("quarto render failed with status ", status)
if (!file.exists(docx) || file.mtime(docx) < start) {
  stop(docx, " was not written by this render; check output-file in the docx format")
}
n <- docx_tidy(docx)
message("Removed ", n, " layout tables from ", docx)
