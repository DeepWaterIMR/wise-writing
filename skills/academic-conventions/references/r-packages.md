# R packages

## Which package for what

| Task | Package |
|---|---|
| Graphs | **ggplot2** |
| Maps | **ggOceanMaps** (with `ggspatial`, `ggnewscale` where needed) |
| Life-history plots — maturity ogives, growth curves, length–weight | **ggFishPlots** |
| sdmTMB diagnostics and index plots | **sdmTMBexperiments** |
| Spatial operations | **sf** |
| Data manipulation | **tidyverse**, particularly **dplyr** |
| Tables | **flextable** for Word, **kableExtra** for HTML and PDF |
| Composing panels | **cowplot** |
| Axis and scale formatting | **scales** |

Default ggplot theme: `theme_bw(base_size = 12)`, set once in `R/0_setup.R`.

## Default set

Declared in each new project and loaded by `R/0_setup.R`, because nearly every document uses
them. They are not installed automatically:

`tidyverse`, `ggplot2`, `sf`, `ggOceanMaps`, `ggspatial`, `ggnewscale`, `here`, `knitr`,
`quarto`, `scales`, `cowplot`, `flextable`, `kableExtra`, `yaml`, `readxl`, `zip`.

## Optional set

Declared in `R/0_setup.R` and attached only when a chunk asks for them with `ensure_packages()`.
If a requested package is missing, the helper reports it without installing by default:

`officer`, `officedown`, `xml2` (Word post-processing) · `jsonlite` · `DBI`, `duckdb`
(database access — see [BAIT](https://github.com/DeepWaterIMR/BAIT)) · `RstoxData`,
`RstoxUtils` · `oce` (hydrography) · `icesAdvice` · `sdmTMB`, `sdmTMBexperiments` (see
[index-wise](https://github.com/DeepWaterIMR/index-wise)) · `spict` · `ggFishPlots` ·
`fishmethods` · `blockCV` · `rprojroot`.

Keeping these out of the default set limits setup to packages a document actually needs.

## Declaring them

One named vector in `R/0_setup.R`. The value is the GitHub repository for anything not on
CRAN, and `NA` for CRAN packages:

```r
packages <- c(
  tidyverse = NA,
  sf = NA,
  ggOceanMaps = "MikkoVihtakari/ggOceanMaps",
  ggFishPlots = "DeepWaterIMR/ggFishPlots"
)
```

`R/package_setup.R` checks the package vector and attaches available packages. Missing packages
are an error by default; only pass `install_missing_packages = TRUE` after the user authorizes
installation. `R_AW_INSTALL_MISSING=false` always blocks helper-driven installs, and projects
with `renv.lock` or an `renv/` directory must use `renv::restore()` instead. Add a package by
adding one line here — never an `install.packages()` call inside a document.

Notes the loader handles, and which are easy to get wrong by hand:

- After installation is authorized, a `Rscript` or Quarto session with no CRAN mirror or
  writable user library is configured before installation.
- `options(install.packages.compile.from.source = "never")` prevents an unattended render
  from hanging on the interactive source-install question.
- `remotes` is installed only when an authorized GitHub package install needs it.
- Some packages must be **attached**, not called with `::`, because they register data or
  methods on the search path. `sdmTMBexperiments` is one.

## Adding a package

1. Add it to `packages` (default) or `optional_packages` (on demand) in `R/0_setup.R`.
2. For an optional one, call `ensure_packages("blockCV")` in the chunk that uses it.
3. Add its citation to `docs/assets/references.bib` from `citation("pkg")` if it influences
   the results, and cite it in Materials and methods.

A package that only formats output does not need citing. A package that changes a number does.

## Sibling packs

The [`r-package-setup`](../../r-package-setup/SKILL.md) skill explains the shared loader and
explicit-install policy. Do not duplicate BAIT's database or index-wise's modelling machinery
here — call their skills instead.
