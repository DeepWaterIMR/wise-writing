#!/usr/bin/env Rscript
# validate-skills.R — structural checks for the skills in this repository.
#
# Run before committing, and in CI:
#   Rscript config/validate-skills.R
#
# It checks that every SKILL.md parses, that its frontmatter is complete and its `name`
# matches the folder, that every relative link resolves, and that no private path or personal
# identifier has crept into a public repository.
#
# Requires: yaml. Exits non-zero on any failure.

problems <- character()
note <- function(...) problems <<- c(problems, paste0(...))

repo <- normalizePath(file.path(dirname(sub("^--file=", "",
  grep("^--file=", commandArgs(), value = TRUE)[1] %||% "config/x")), ".."), mustWork = FALSE)
if (!dir.exists(file.path(repo, "skills"))) repo <- normalizePath(getwd())
`%||%` <- function(a, b) if (is.null(a)) b else a

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("The 'yaml' package is required: install.packages('yaml')", call. = FALSE)
}

# --- 1. Every skill folder has a SKILL.md, and every SKILL.md is in a skill folder ---------
skill_dirs <- list.dirs(file.path(repo, "skills"), recursive = FALSE)
if (!length(skill_dirs)) note("No skills found under skills/.")

for (d in skill_dirs) {
  skill <- basename(d)
  path <- file.path(d, "SKILL.md")

  if (!file.exists(path)) {
    note(skill, ": no SKILL.md")
    next
  }

  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)

  # --- 2. Frontmatter ---------------------------------------------------------------------
  fences <- which(trimws(lines) == "---")
  if (length(fences) < 2 || fences[1] != 1) {
    note(skill, ": SKILL.md has no YAML frontmatter at the top")
    next
  }
  fm <- tryCatch(
    yaml::yaml.load(paste(lines[(fences[1] + 1):(fences[2] - 1)], collapse = "\n"), eval.expr = FALSE),
    error = function(e) NULL
  )
  if (is.null(fm)) {
    note(skill, ": frontmatter does not parse as YAML")
    next
  }

  for (field in c("name", "description", "license")) {
    if (is.null(fm[[field]]) || !nzchar(as.character(fm[[field]]))) {
      note(skill, ": frontmatter is missing '", field, "'")
    }
  }
  if (is.null(fm$metadata$version)) {
    note(skill, ": frontmatter is missing 'metadata.version'")
  } else if (!grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", as.character(fm$metadata$version))) {
    note(skill, ": metadata.version is not x.y.z: ", fm$metadata$version)
  }
  if (!identical(as.character(fm$name), skill)) {
    note(skill, ": frontmatter name '", fm$name, "' does not match the folder name")
  }

  # A description is what an agent matches on, so an empty or terse one makes the skill
  # unreachable. Anything under 80 characters is almost certainly too short to trigger.
  if (!is.null(fm$description) && nchar(fm$description) < 80) {
    note(skill, ": description is very short (", nchar(fm$description), " characters)")
  }

  # --- 3. Relative links resolve ----------------------------------------------------------
  body <- paste(lines, collapse = "\n")
  links <- regmatches(body, gregexpr("\\]\\(([^)]+)\\)", body))[[1]]
  links <- sub("^\\]\\(", "", sub("\\)$", "", links))
  links <- links[!grepl("^(https?:|mailto:|#)", links)]
  for (link in links) {
    target <- normalizePath(file.path(d, sub("#.*$", "", link)), mustWork = FALSE)
    if (!file.exists(target)) note(skill, ": broken link -> ", link)
  }

  # --- 4. Skill body length ---------------------------------------------------------------
  # SKILL.md is read in full, often by a model with a small context window. Depth belongs in
  # references/.
  if (length(lines) > 200) {
    note(skill, ": SKILL.md is ", length(lines),
         " lines; move detail into references/ (target: under 150)")
  }
}

# --- 5. No private paths or personal identifiers -------------------------------------------
# This repository is public. The patterns below are the ones that actually leak.
text_files <- list.files(
  repo, recursive = TRUE, full.names = TRUE,
  pattern = "\\.(md|R|r|qmd|yaml|yml|json|bib|tex|lua|css)$"
)
text_files <- text_files[!grepl("/\\.git/", text_files)]
# The validator itself names the patterns it looks for, so it is not scanned.
text_files <- text_files[basename(text_files) != "validate-skills.R"]

# Matched as PATH SHAPES, not as words: the guidance in AGENTS.md and CONTRIBUTING.md names
# these services in prose, and flagging that would make the check useless.
patterns <- c(
  "/Users/[A-Za-z0-9][A-Za-z0-9._-]*" = "an absolute macOS home path",
  "/home/[A-Za-z0-9][A-Za-z0-9._-]*"  = "an absolute Linux home path",
  "[A-Za-z]:\\\\Users\\\\"          = "an absolute Windows home path",
  "OneDrive[-/][A-Za-z0-9]"       = "a OneDrive path",
  "CloudStorage/"                 = "a CloudStorage path",
  "ownCloud/"                     = "an ownCloud path"
)

for (f in text_files) {
  lines <- tryCatch(readLines(f, encoding = "UTF-8", warn = FALSE), error = function(e) character())
  for (i in seq_along(patterns)) {
    hits <- grep(names(patterns)[i], lines)
    for (h in hits) {
      note(sub(paste0("^", repo, "/"), "", f), ":", h, ": ", patterns[[i]])
    }
  }
}

# --- Report --------------------------------------------------------------------------------
if (length(problems)) {
  cat("\nvalidate-skills.R found ", length(problems), " problem",
      if (length(problems) == 1) "" else "s", ":\n\n", sep = "")
  cat(paste0("  - ", problems, collapse = "\n"), "\n\n")
  quit(status = 1)
}

cat("validate-skills.R: ", length(skill_dirs), " skills, all checks passed.\n", sep = "")
