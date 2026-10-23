# scaffold.R — create a new academic writing project from project-template/
#
# Copies the project-template/ skeleton into a target directory, keeps only the document
# types you asked for, copies each type's assets (Word reference documents, CSL style,
# LaTeX partials, Lua filters) into docs/assets/, and stamps the {{PLACEHOLDER}} identity
# tokens from a config.yaml.
#
# Identity and path-shaping tokens are stamped here. Everything else — figure widths, the
# citation style, paths — is read at run time by R/0_setup.R, so it can be changed later by
# editing config.yaml rather than by editing the documents.
#
# Usage:
#   source("<wise-writing>/scaffold.R")
#   scaffold_document("config.yaml", "../my-project", types = "manuscript")
#   scaffold_document("config.yaml", "../my-project", types = c("manuscript", "data-report"))
#   scaffold_document("config.yaml", "../my-project", types = "manuscript", dry = TRUE)
#
# Requires: yaml. (install.packages("yaml"))

# --- The document types this pack ships ---------------------------------------------------
# `folder` is the subfolder of project-template/docs/ that holds the skeleton, and the name
# it keeps in the scaffolded project. `skill` is the skill an agent reads for that type; its
# whole assets/ folder is copied into docs/assets/. `extra_assets` names further files to
# copy, as paths relative to skills/, so that a template shared by several document types
# lives in one place rather than being duplicated across skill folders.
DOCUMENT_TYPES <- list(
  "manuscript" = list(
    folder = "manuscript",
    label  = "manuscript",
    skill  = "academic-manuscript"
  ),
  "data-report" = list(
    folder = "data-report",
    label  = "data report",
    skill  = "academic-data-report"
  ),
  "cruise-report" = list(
    folder = "cruise-report",
    label  = "cruise report",
    skill  = "academic-cruise-report"
  ),
  "assessment-report" = list(
    folder = "assessment-report",
    label  = "assessment report",
    skill  = "academic-assessment-report",
    # The internal-IMR route uses the institute's web-report template, which the cruise
    # report skill owns.
    extra_assets = "academic-cruise-report/assets/nettrapport_template.docx"
  ),
  "advice-sheet" = list(
    folder = "advice-sheet",
    label  = "advice sheet",
    skill  = "academic-advice-sheet"
  ),
  "benchmark-report" = list(
    folder = "benchmark-report",
    label  = "benchmark report",
    skill  = "academic-benchmark-report",
    # A benchmark uses the same three templates as an assessment report.
    extra_assets = c(
      "academic-cruise-report/assets/nettrapport_template.docx",
      "academic-assessment-report/assets/jrn_afwg_report_template.docx",
      "academic-assessment-report/assets/ices_scientific_reports_template.docx"
    )
  )
)

# --- Read a YAML file as UTF-8, independent of the R locale --------------------------------
.read_yaml_utf8 <- function(path) {
  txt <- readChar(path, file.info(path)$size, useBytes = TRUE)
  Encoding(txt) <- "UTF-8"
  yaml::yaml.load(txt)
}

# --- Locate the wise-writing repository ----------------------------------------------------
# Order: explicit argument -> ~/.wise-writing/config.json -> legacy config ->
# the folder this script was sourced from -> the working directory -> error.
.find_pack_root <- function(pack = NULL) {
  valid <- function(p) {
    !is.null(p) && dir.exists(file.path(p, "project-template")) &&
      dir.exists(file.path(p, "skills"))
  }
  if (valid(pack)) return(normalizePath(pack))

  cfg_jsons <- path.expand(c("~/.wise-writing/config.json", "~/.academic-writing/config.json"))
  if (requireNamespace("jsonlite", quietly = TRUE)) {
    for (cfg_json in cfg_jsons[file.exists(cfg_jsons)]) {
      p <- tryCatch(jsonlite::read_json(cfg_json)$academic_writing_path, error = function(e) NULL)
      if (valid(p)) return(normalizePath(p))
    }
  }

  for (frame in rev(sys.frames())) {
    f <- frame$ofile
    if (is.character(f) && length(f) && nzchar(f[[1]])) {
      p <- dirname(normalizePath(f[[1]], mustWork = FALSE))
      if (valid(p)) return(p)
    }
  }

  if (valid(getwd())) return(normalizePath(getwd()))

  stop(
    "Cannot locate the wise-writing repository. Pass it explicitly via `pack=`.",
    call. = FALSE
  )
}

# --- Build the YAML author and affiliation blocks from config.yaml -------------------------
# Emitted at the indentation Quarto expects under `author:` and `affiliations:`. The first
# author is treated as corresponding.

# A person's name is not a YAML-safe token. A colon, a leading quote, a `#`, or a name that
# happens to read as a number all break an unquoted scalar, and the failure is a YAML parse
# error in a document nobody has edited. Everything interpolated from config.yaml is therefore
# emitted as a double-quoted scalar, which needs only backslashes and double quotes escaped.
.yaml_scalar <- function(x) {
  paste0('"', gsub('(["\\\\])', "\\\\\\1", as.character(x)), '"')
}

.author_block <- function(authors) {
  if (is.null(authors) || !length(authors)) {
    stop("config.yaml must list at least one author under AUTHORS.", call. = FALSE)
  }
  lines <- unlist(lapply(seq_along(authors), function(i) {
    a <- authors[[i]]
    if (is.null(a$name) || !nzchar(a$name)) {
      stop("Every entry under AUTHORS needs a name.", call. = FALSE)
    }
    refs <- unlist(a$affiliation %||% "imr", use.names = FALSE)
    out <- c(
      sprintf("  - name: %s", .yaml_scalar(a$name)),
      "    affiliations:",
      sprintf("      - ref: %s", .yaml_scalar(refs)),
      sprintf("    corresponding: %s", if (i == 1L) "true" else "false")
    )
    if (!is.null(a$email) && nzchar(a$email)) {
      out <- c(out, sprintf("    email: %s", .yaml_scalar(a$email)))
    }
    if (!is.null(a$orcid) && nzchar(a$orcid)) {
      out <- c(out, sprintf("    orcid: %s", .yaml_scalar(a$orcid)))
    }
    out
  }))
  paste(lines, collapse = "\n")
}

# Every author has to point at an affiliation that exists. Quarto does not check this: an
# unresolvable `ref:` renders as a missing affiliation, which is the kind of error that
# survives to a submitted manuscript. Fail at scaffold time instead.
.validate_people <- function(authors, affiliations) {
  if (is.null(authors) || !length(authors)) {
    stop("config.yaml must list at least one author under AUTHORS.", call. = FALSE)
  }
  if (is.null(affiliations) || !length(affiliations)) {
    stop("config.yaml must list at least one affiliation under AFFILIATIONS.", call. = FALSE)
  }

  ids <- vapply(affiliations, function(a) as.character(a$id %||% ""), character(1))
  if (any(!nzchar(ids))) stop("Every entry under AFFILIATIONS needs an id.", call. = FALSE)
  if (anyDuplicated(ids)) {
    stop("AFFILIATIONS ids must be unique: ", paste(ids[duplicated(ids)], collapse = ", "),
         call. = FALSE)
  }
  if (any(!vapply(affiliations, function(a) {
    !is.null(a$name) && nzchar(as.character(a$name))
  }, logical(1)))) {
    stop("Every entry under AFFILIATIONS needs a name.", call. = FALSE)
  }

  for (a in authors) {
    if (is.null(a$name) || !nzchar(a$name)) {
      stop("Every entry under AUTHORS needs a name.", call. = FALSE)
    }
    refs <- unlist(a$affiliation %||% "imr", use.names = FALSE)
    unknown <- setdiff(as.character(refs), ids)
    if (length(unknown)) {
      stop(
        "Author '", a$name, "' references an affiliation that is not in AFFILIATIONS: ",
        paste(unknown, collapse = ", "), ".\nAvailable ids: ", paste(ids, collapse = ", "),
        call. = FALSE
      )
    }
  }
  invisible(TRUE)
}

.affiliation_block <- function(affiliations) {
  if (is.null(affiliations) || !length(affiliations)) {
    stop("config.yaml must list at least one affiliation under AFFILIATIONS.", call. = FALSE)
  }
  paste(unlist(lapply(affiliations, function(a) {
    c(
      sprintf("  - id: %s", .yaml_scalar(a$id)),
      sprintf("    name: %s", .yaml_scalar(a$name))
    )
  })), collapse = "\n")
}

`%||%` <- function(a, b) if (is.null(a)) b else a

#' Scaffold a new academic writing project
#'
#' @param config Path to a filled-in `config.yaml`.
#' @param target Directory to create. Must not exist, or must be empty.
#' @param types One or more document types. See `names(DOCUMENT_TYPES)`.
#' @param pack Path to the wise-writing repository. Located automatically when omitted.
#' @param dry Preview without writing anything.
#' @return The target path, invisibly.
scaffold_document <- function(config, target, types = "manuscript", pack = NULL, dry = FALSE) {

  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("The 'yaml' package is required: install.packages('yaml')", call. = FALSE)
  }

  pack <- .find_pack_root(pack)
  template <- file.path(pack, "project-template")
  msg <- function(...) cat(if (dry) "[dry] " else "", ..., "\n", sep = "")

  # --- Validate the document types ---------------------------------------------------
  unknown <- setdiff(types, names(DOCUMENT_TYPES))
  if (length(unknown)) {
    stop(
      "Unknown document type: ", paste(unknown, collapse = ", "),
      "\nAvailable: ", paste(names(DOCUMENT_TYPES), collapse = ", "),
      call. = FALSE
    )
  }
  chosen <- DOCUMENT_TYPES[types]

  # --- Read and validate the config ---------------------------------------------------
  if (!file.exists(config)) stop("No such config file: ", config, call. = FALSE)
  cfg <- .read_yaml_utf8(config)

  required <- c("PROJECT_TITLE", "PROJECT_SLUG", "AUTHORS", "AFFILIATIONS")
  miss <- setdiff(required, names(cfg))
  if (length(miss)) {
    stop("config.yaml is missing required keys: ", paste(miss, collapse = ", "), call. = FALSE)
  }

  slug <- as.character(cfg$PROJECT_SLUG)
  if (!grepl("^[a-z0-9-]+$", slug)) {
    stop("PROJECT_SLUG must be lower-case kebab-case (a-z, 0-9, -): got '", slug, "'",
         call. = FALSE)
  }

  .validate_people(cfg$AUTHORS, cfg$AFFILIATIONS)

  # Fail on the unedited template rather than scaffolding a project full of placeholders.
  if (grepl("\\{\\{", paste(unlist(cfg), collapse = " "))) {
    stop("config.yaml still contains {{PLACEHOLDER}} values. Fill them in first.",
         call. = FALSE)
  }

  # --- Copy the skeleton --------------------------------------------------------------
  if (dir.exists(target) && length(list.files(target, all.files = TRUE, no.. = TRUE))) {
    stop("Target '", target, "' exists and is not empty. Choose an empty or new directory.",
         call. = FALSE)
  }

  if (!dry) {
    dir.create(target, recursive = TRUE, showWarnings = FALSE)
    file.copy(
      list.files(template, full.names = TRUE, all.files = TRUE, no.. = TRUE),
      target, recursive = TRUE, copy.mode = TRUE
    )
    file.copy(config, file.path(target, "config.yaml"), overwrite = TRUE)
  }
  msg("Copied project-template/ -> ", target)

  # --- Keep only the document types asked for -----------------------------------------
  if (!dry) {
    keep <- vapply(chosen, function(x) x$folder, character(1))
    present <- list.dirs(file.path(target, "docs"), recursive = FALSE, full.names = FALSE)
    for (d in setdiff(present, c(keep, "assets"))) {
      unlink(file.path(target, "docs", d), recursive = TRUE, force = TRUE)
    }
  }
  msg("Kept document type", if (length(types) > 1) "s" else "", ": ",
      paste(types, collapse = ", "))

  # --- Copy each type's assets into docs/assets/ ---------------------------------------
  if (!dry) {
    dest <- file.path(target, "docs", "assets")
    for (x in chosen) {
      src <- file.path(pack, "skills", x$skill, "assets")
      files <- character()
      if (dir.exists(src)) {
        files <- list.files(src, full.names = TRUE, all.files = TRUE, no.. = TRUE)
        files <- files[basename(files) != "README.md"]
      }
      # Templates shared with another document type, named relative to skills/.
      if (!is.null(x$extra_assets)) {
        extra <- file.path(pack, "skills", x$extra_assets)
        missing_extra <- extra[!file.exists(extra)]
        if (length(missing_extra)) {
          warning("Missing shared asset: ", paste(x$extra_assets[!file.exists(extra)],
                                                  collapse = ", "))
        }
        files <- c(files, extra[file.exists(extra)])
      }
      if (length(files)) {
        file.copy(files, dest, overwrite = TRUE, recursive = TRUE)
      }
    }
  }
  msg("Copied document assets into docs/assets/")

  # --- Stamp identity tokens in text files ---------------------------------------------
  tokens <- c(
    "{{PROJECT_TITLE}}"     = as.character(cfg$PROJECT_TITLE),
    "{{PROJECT_SLUG}}"      = slug,
    "{{PROJECT_YEAR}}"      = as.character(cfg$PROJECT_YEAR %||% format(Sys.Date(), "%Y")),
    "{{AUTHOR_BLOCK}}"      = .author_block(cfg$AUTHORS),
    "{{AFFILIATION_BLOCK}}" = .affiliation_block(cfg$AFFILIATIONS),
    "{{LANGUAGE}}"          = as.character(cfg$LANGUAGE %||% "en-US"),
    "{{CSL}}"               = as.character(cfg$CSL %||% "assets/ices_jms.csl"),
    "{{BIBLIOGRAPHY}}"      = as.character(cfg$BIBLIOGRAPHY %||% "assets/references.bib"),
    "{{FIG_WIDTH_DOUBLE}}"  = format(round((cfg$FIG_WIDTH_DOUBLE_MM %||% 170) / 25.4, 2)),
    "{{FIG_WIDTH_SINGLE}}"  = format(round((cfg$FIG_WIDTH_SINGLE_MM %||% 85) / 25.4, 2)),
    "{{DOC_TYPE_LABEL}}"    = paste(vapply(chosen, function(x) x$label, character(1)),
                                    collapse = " and "),
    "{{DOC_SKILL}}"         = paste(vapply(chosen, function(x) x$skill, character(1)),
                                    collapse = "`, `"),
    "{{TODAY}}"             = format(Sys.Date(), "%Y-%m-%d")
  )

  text_ext <- c("qmd", "rmd", "r", "md", "yaml", "yml", "css", "bib", "tex", "lua")
  scan_root <- if (dry) template else target
  files <- list.files(scan_root, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  files <- c(files, list.files(scan_root, pattern = "^VERSION$", recursive = TRUE,
                               full.names = TRUE))
  files <- unique(files[
    tolower(tools::file_ext(files)) %in% text_ext | basename(files) == "VERSION"
  ])

  for (f in files) {
    txt <- tryCatch({
      s <- readChar(f, file.info(f)$size, useBytes = TRUE); Encoding(s) <- "UTF-8"; s
    }, error = function(e) NULL)
    if (is.null(txt)) next
    new <- txt
    for (tok in names(tokens)) new <- gsub(tok, tokens[[tok]], new, fixed = TRUE)
    if (!dry && !identical(new, txt)) writeBin(charToRaw(enc2utf8(new)), f)
  }
  msg("Stamped identity tokens")

  # --- Sanity check: no leftover placeholders ------------------------------------------
  if (!dry) {
    left <- character()
    for (f in files) {
      txt <- tryCatch({
        s <- readChar(f, file.info(f)$size, useBytes = TRUE); Encoding(s) <- "UTF-8"; s
      }, error = function(e) "")
      if (grepl("\\{\\{[A-Z_]+\\}\\}", txt)) left <- c(left, f)
    }
    if (length(left)) {
      warning("Leftover placeholders in:\n  ", paste(left, collapse = "\n  "))
    } else {
      msg("No leftover placeholders.")
    }

    message("\nScaffolded '", cfg$PROJECT_TITLE, "' at: ", normalizePath(target))
    message("Next:")
    message("  1. cd into the project and run: git init")
    message("  2. Add your references to docs/assets/references.bib")
    message("  3. Render the HTML preview from the Preview/Render button")
  }

  invisible(target)
}
