#!/usr/bin/env Rscript

# Exercise package install policy with mocked availability/install/load callbacks.
# No package installation or user-library mutation occurs.

script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script <- normalizePath(sub("^--file=", "", script_arg[[1]]))
repo <- normalizePath(file.path(dirname(script), ".."))
helper <- file.path(repo, "project-template", "R", "package_setup.R")
source(helper)

main <- function() {
root <- tempfile("package-setup-test-")
dir.create(root)
on.exit(unlink(root, recursive = TRUE), add = TRUE)

installed <- character()
attempts <- list()
loaded <- character()
available <- function(package) package %in% installed
installer <- function(packages) {
  attempts[[length(attempts) + 1L]] <<- packages
  installed <<- c(installed, names(packages))
}
attach <- function(packages) {
  loaded <<- packages
  invisible(packages)
}
pkgs <- c(alpha = NA_character_, beta = "org/beta")

# Missing packages fail closed by default and call no installer.
err <- try(package_setup(pkgs, project_root = root, package_available = available,
                         installer = installer, attach = attach), silent = TRUE)
stopifnot(inherits(err, "try-error"), length(attempts) == 0L)

# Explicit consent permits only the missing packages and attaches them afterward.
package_setup(pkgs, install_missing_packages = TRUE, project_root = root,
              package_available = available, installer = installer, attach = attach)
stopifnot(length(attempts) == 1L,
          identical(names(attempts[[1]]), c("alpha", "beta")),
          identical(loaded, c("alpha", "beta")))

# The legacy environment variable is a hard deny, even if this call requests installation.
installed <- character()
loaded <- character()
Sys.setenv(R_AW_INSTALL_MISSING = "false")
err <- try(package_setup(pkgs, install_missing_packages = TRUE, project_root = root,
                         package_available = available, installer = installer,
                         attach = attach), silent = TRUE)
Sys.unsetenv("R_AW_INSTALL_MISSING")
stopifnot(inherits(err, "try-error"), length(attempts) == 1L,
          length(loaded) == 0L)

# renv always blocks helper-driven installs, whether represented by a lockfile or directory.
installed <- character()
file.create(file.path(root, "renv.lock"))
err <- try(package_setup(pkgs, install_missing_packages = TRUE, project_root = root,
                         package_available = available, installer = installer,
                         attach = attach), silent = TRUE)
stopifnot(inherits(err, "try-error"), length(attempts) == 1L,
          grepl("renv", as.character(err), ignore.case = TRUE))
unlink(file.path(root, "renv.lock"))
dir.create(file.path(root, "renv"))
err <- try(package_setup(pkgs, install_missing_packages = TRUE, project_root = root,
                         package_available = available, installer = installer,
                         attach = attach), silent = TRUE)
stopifnot(inherits(err, "try-error"), length(attempts) == 1L)

# Installed packages still load without consent; preserve ensure_packages-style attach use.
installed <- c("alpha", "beta")
package_setup(pkgs, project_root = root, package_available = available,
              installer = installer, attach = attach)
stopifnot(identical(loaded, c("alpha", "beta")), length(attempts) == 1L)

# Scaffold a real, isolated project and verify the helper arrives with the public wrapper.
source(file.path(repo, "scaffold.R"))
target <- file.path(root, "scaffolded")
scaffold_document(file.path(repo, "examples", "config.yaml"), target,
                  types = "manuscript", pack = repo)
stopifnot(file.exists(file.path(target, "R", "package_setup.R")))
scaffold_setup <- readLines(file.path(target, "R", "0_setup.R"), warn = FALSE)
stopifnot(any(grepl('source("R/package_setup.R")', scaffold_setup, fixed = TRUE)),
          any(grepl("ensure_packages <- function", scaffold_setup, fixed = TRUE)))

# Also validate the source template's public wrapper and fail-closed default.
setup <- readLines(file.path(repo, "project-template", "R", "0_setup.R"), warn = FALSE)
stopifnot(any(grepl('source("R/package_setup.R")', setup, fixed = TRUE)),
          any(grepl("ensure_packages <- function", setup, fixed = TRUE)),
          any(grepl("install_missing_packages <- FALSE", setup, fixed = TRUE)))

cat("test-package-setup.R: default-deny, explicit consent, legacy deny, renv, loading, and scaffold integration passed.\n")
}

main()

# Legacy callers retain their function signature and use the shared consent policy.
setup_expressions <- parse(file = file.path(repo, "project-template", "R", "0_setup.R"))
legacy_definition <- Filter(function(expr) is.call(expr) && identical(expr[[1L]], as.name("<-")) &&
  identical(expr[[2L]], as.name("install_packages_if_missing")), as.list(setup_expressions))[[1L]]
legacy <- new.env(parent = baseenv())
legacy$package_setup <- function(packages, install_missing_packages, project_root, attach) {
  stopifnot(identical(packages, c(example = NA_character_)))
  install_missing_packages
}
eval(legacy_definition, envir = legacy)
legacy$install_missing_packages <- FALSE
stopifnot(!legacy$install_packages_if_missing(c(example = NA_character_)))
legacy$install_missing_packages <- TRUE
stopifnot(legacy$install_packages_if_missing(c(example = NA_character_)))
cat("Legacy package setup entry point preserved.\n")
