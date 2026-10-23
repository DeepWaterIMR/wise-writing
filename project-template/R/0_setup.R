# 0_setup.R — shared setup, sourced by every document and script in this project.
#
# Loads packages, reads config.yaml into `cfg`, sets the ggplot theme, and defines the
# figure widths the target journal expects. Keep project-wide settings in config.yaml,
# not here.

`%||%` <- function(a, b) if (is.null(a)) b else a

# --- Packages ---------------------------------------------------------------------------
# Every package the project uses, named ONCE. The value is the GitHub repository for
# packages that are not on CRAN, and NA for the rest.
#
# `here` and `knitr` are deliberately absent: each document calls `here::here()` in its own
# setup chunk *before* sourcing this file, so they must already exist for the source() to
# happen at all. Quarto brings knitr, and here is a dependency of almost everything else.
packages <- c(
  tidyverse = NA,
  sf = NA,
  scales = NA,
  cowplot = NA,
  ggspatial = NA,
  ggnewscale = NA,
  flextable = NA,
  kableExtra = NA,
  readxl = NA,
  yaml = NA,
  zip = NA,
  quarto = NA,
  ggOceanMaps = "MikkoVihtakari/ggOceanMaps"
)

# Needed only on some paths, so not installed until something asks for them. Call
# ensure_packages("oce") in the chunk that needs one.
optional_packages <- c(
  # Word post-processing
  officer = NA,
  officedown = NA,
  xml2 = NA,
  # Data access — see https://github.com/DeepWaterIMR/BAIT
  DBI = NA,
  duckdb = NA,
  jsonlite = NA,
  RstoxData = NA,
  RstoxUtils = "DeepWaterIMR/RstoxUtils",
  # Hydrography, advice tables, life history
  oce = NA,
  icesAdvice = NA,
  fishmethods = NA,
  ggFishPlots = "DeepWaterIMR/ggFishPlots",
  # Spatiotemporal indices — see https://github.com/DeepWaterIMR/index-wise
  sdmTMB = "sdmTMB/sdmTMB",
  sdmTMBexperiments = "DeepWaterIMR/sdmTMBexperiments",
  # Biomass-dynamic stock assessment — see https://github.com/DeepWaterIMR/spict-wise
  # spict compiles a TMB model, so it needs a working compiler toolchain; see the
  # academic-toolchain-setup skill if the install fails.
  spict = "DTUAqua/spict/spict"
)

# Set to FALSE (or export R_AW_INSTALL_MISSING=false) to run against the library as it is.
install_missing_packages <- !identical(
  tolower(Sys.getenv("R_AW_INSTALL_MISSING", unset = "true")), "false"
)

install_packages_if_missing <- function(pkgs) {
  missing <- pkgs[
    !vapply(names(pkgs), requireNamespace, logical(1), quietly = TRUE)
  ]
  if (!length(missing)) return(invisible(NULL))

  # Rscript, knitr and Quarto sessions often start without a CRAN mirror and without a
  # writable user library. Both are needed before installing.
  repos <- getOption("repos")
  if (is.na(repos["CRAN"]) || repos["CRAN"] == "@CRAN@") {
    repos["CRAN"] <- "https://cloud.r-project.org"
    options(repos = repos)
  }

  lib <- strsplit(Sys.getenv("R_LIBS_USER"), .Platform$path.sep)[[1]][1]
  if (!is.na(lib) && nzchar(lib)) {
    if (!dir.exists(lib)) dir.create(lib, recursive = TRUE)
    .libPaths(c(lib, .libPaths()))
  }

  # Never fall into the interactive "install from sources?" question, which hangs
  # unattended renders on macOS and Windows.
  options(install.packages.compile.from.source = "never")

  if (any(!is.na(missing)) && !requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  for (package in names(missing)) {
    message("Installing missing package: ", package)
    if (is.na(missing[[package]])) {
      install.packages(package)
    } else {
      remotes::install_github(missing[[package]], upgrade = "never")
    }
  }

  still_missing <- names(missing)[
    !vapply(names(missing), requireNamespace, logical(1), quietly = TRUE)
  ]
  if (length(still_missing)) {
    stop(
      "Could not install: ", paste(still_missing, collapse = ", "),
      "\nSee the academic-toolchain-setup skill if a compiler toolchain is missing.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

# Install-and-attach an optional package at the point of use, e.g. ensure_packages("oce").
ensure_packages <- function(...) {
  nms <- c(...)
  known <- c(packages, optional_packages)
  unknown <- setdiff(nms, names(known))
  if (length(unknown)) {
    stop(
      "Not listed in `packages` or `optional_packages` in R/0_setup.R: ",
      paste(unknown, collapse = ", ")
    )
  }
  if (isTRUE(install_missing_packages)) install_packages_if_missing(known[nms])
  invisible(lapply(nms, function(package) {
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  }))
}

if (isTRUE(install_missing_packages)) install_packages_if_missing(packages)

invisible(lapply(names(packages), function(package) {
  suppressPackageStartupMessages(library(package, character.only = TRUE))
}))

# --- Config -----------------------------------------------------------------------------
# Documents may be rendered with the working directory at the project root (recommended) or
# at the document's own folder; find config.yaml either way.
.find_config <- function() {
  for (p in c("config.yaml", "../config.yaml", "../../config.yaml", "../../../config.yaml")) {
    if (file.exists(p)) return(normalizePath(p))
  }
  stop("config.yaml not found. Render from the project root, or set the working directory.")
}

# Read as UTF-8 bytes so Scandinavian characters (å/æ/ø) parse regardless of the R locale.
.read_yaml_utf8 <- function(path) {
  txt <- readChar(path, file.info(path)$size, useBytes = TRUE)
  Encoding(txt) <- "UTF-8"
  yaml::yaml.load(txt)
}

.config_path <- .find_config()
cfg <- .read_yaml_utf8(.config_path)
project_root <- dirname(.config_path)

# --- Paths ------------------------------------------------------------------------------
data_dir    <- file.path(project_root, cfg$DATA_DIR    %||% "data")
source_dir  <- file.path(project_root, cfg$SOURCE_DIR  %||% "data/source")
output_dir  <- file.path(project_root, cfg$OUTPUT_DIR  %||% "data/output")
figures_dir <- file.path(project_root, cfg$FIGURES_DIR %||% "figures")
assets_dir  <- file.path(project_root, "docs", "assets")

for (d in c(output_dir, figures_dir)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# --- Figure sizes -----------------------------------------------------------------------
# ICES Journal of Marine Science column widths. Figures are drawn at one width or the
# other; sizes in between are explicitly discouraged by the journal.
#   single column     85 mm = 3.35 in
#   double column    170 mm = 6.69 in
# Set the width in the document YAML and override only fig-height per chunk, choosing a
# height that fills the width without stretching or crowding the panel.
mm_to_in <- function(mm) round(mm / 25.4, 2)

fig_width_single <- mm_to_in(cfg$FIG_WIDTH_SINGLE_MM %||% 85)   # 3.35
fig_width_double <- mm_to_in(cfg$FIG_WIDTH_DOUBLE_MM %||% 170)  # 6.69

# --- Theme ------------------------------------------------------------------------------
theme_set(theme_bw(base_size = cfg$BASE_SIZE %||% 12))
