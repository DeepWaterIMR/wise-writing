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

Loaded in every project, because nearly every document uses them:

`tidyverse`, `ggplot2`, `sf`, `ggOceanMaps`, `ggspatial`, `ggnewscale`, `here`, `knitr`,
`quarto`, `scales`, `cowplot`, `flextable`, `kableExtra`, `yaml`, `readxl`, `zip`.

## Optional set

Declared in `R/0_setup.R` but installed and attached only when a chunk asks for them with
`ensure_packages()`:

`officer`, `officedown`, `xml2` (Word post-processing) · `jsonlite` · `DBI`, `duckdb`
(database access — see [BAIT](https://github.com/DeepWaterIMR/BAIT)) · `RstoxData`,
`RstoxUtils` · `oce` (hydrography) · `icesAdvice` · `sdmTMB`, `sdmTMBexperiments` (see
[index-wise](https://github.com/DeepWaterIMR/index-wise)) · `spict` · `ggFishPlots` ·
`fishmethods` · `blockCV` · `rprojroot`.

Keeping these out of the default set matters: a first run on a new machine that installs
thirty packages, several of which compile, is a bad first impression and a slow one.

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

`0_setup.R` installs anything missing and attaches the rest. Adding a package means adding one
line here — never an `install.packages()` call inside a document.

Notes the loader handles, and which are easy to get wrong by hand:

- A `Rscript` or Quarto session often starts with no CRAN mirror set and no writable user
  library. Both are fixed before installing.
- `options(install.packages.compile.from.source = "never")` stops an unattended render hanging
  on the interactive "install from sources?" question.
- `remotes` is installed first, but only if a GitHub package is actually missing.
- Some packages must be **attached**, not called with `::`, because they register data or
  methods on the search path. `sdmTMBexperiments` is one.

## Adding a package

1. Add it to `packages` (default) or `optional_packages` (on demand) in `R/0_setup.R`.
2. For an optional one, call `ensure_packages("blockCV")` in the chunk that uses it.
3. Add its citation to `docs/assets/references.bib` from `citation("pkg")` if it influences
   the results, and cite it in Materials and methods.

A package that only formats output does not need citing. A package that changes a number does.

## Sibling packs

`r-package-setup` (from [BAIT](https://github.com/DeepWaterIMR/BAIT)) covers the loader
pattern in more depth if you are writing one from scratch. Do not duplicate BAIT's database or
index-wise's modelling machinery here — call their skills instead.
