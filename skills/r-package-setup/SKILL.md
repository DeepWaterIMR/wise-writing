---
name: r-package-setup
description: Set up and load R packages in scripts and Quarto documents with explicit installation consent, including CRAN and GitHub packages. Use when creating or revising package setup or diagnosing a missing package.
metadata:
  version: "0.2.0"
license: MIT
---

# Package setup header for R scripts

Keep one named package vector as the source of truth: names are the R package names and values
are GitHub repositories for non-CRAN packages, or `NA` for CRAN. Do not keep separate install
and load lists.

## wise-writing projects

New projects include `R/package_setup.R`, copied from
[`project-template/R/package_setup.R`](../../project-template/R/package_setup.R). Use it from
`R/0_setup.R` and preserve the public `ensure_packages(...)` helper for optional packages.
Installation is off by default. After the user authorizes package installation, the agent may
pass `install_missing_packages = TRUE` to `package_setup()` for that run. The existing
`R_AW_INSTALL_MISSING=false` environment variable always denies automatic installation.

Missing packages without consent should produce a clear error naming them and explaining how
to proceed. `renv.lock` or an `renv/` directory always disables helper-driven installation;
use `renv::restore()` under the project's instructions instead. Never change an existing
project's package policy or install packages as a side effect of a style-only edit.

## Other projects

Do not assume a project has the wise-writing helper. Inspect its instructions and existing
setup first. If adding setup, keep installation disabled by default, require explicit consent
before calling an installer, and defer package restoration to `renv` where present. Use the
canonical helper above as the reference implementation rather than copying a second evolving
loader into this skill.

## Package list and loading

Keep packages in one named vector and attach from that vector. In wise-writing projects,
`R/0_setup.R` declares required and optional vectors; add packages there and call
`ensure_packages("pkg")` only when an optional dependency is needed. In another project,
follow its existing loader and configuration conventions.

## Extensions

**Non-CRAN, non-GitHub repositories** (Bioconductor, the StoX repo that serves `RstoxData`
and `RstoxFramework`) need their repository configured by the project before the helper runs.
Bioconductor packages need `BiocManager::install()` rather than `install.packages()`; only
add this path when the project uses such packages and installation has been authorized.

**Faster startup.** `requireNamespace()` actually loads each namespace. To only test
whether a package is installed, use `nzchar(system.file(package = package))` in the
`vapply()` instead. Do this if the check is noticeably slow, not by default — a genuinely
broken install is worth surfacing early.

**GitHub rate limits.** Unauthenticated `install_github()` is capped at 60 requests/hour
and fails with HTTP 403. If a user hits it, have them set a `GITHUB_PAT`
(`usethis::create_github_token()`, then `usethis::edit_r_environ()`).

**Compilation on Windows.** Packages with no binary (common right after a CRAN release, and
for most GitHub packages) need **Rtools** matching the R version. If an install fails with
compiler errors, that is the first thing to check — the block cannot work around a missing
toolchain.

## Do not

- Repeat `if (!require(x)) install.packages(x); library(x)` once per package.
- Call `install.packages()` unconditionally at the top of a script — it re-downloads on
  every run and can break a working setup mid-analysis.
- Use `pacman::p_load()` or similar wrappers; they add a dependency to solve the problem
  the block above solves in plain base R.
- Install packages inside a function or loop that runs during the analysis. Installation
  belongs in the header only.
- Silently drop a package that is only used as `pkg::fun()`. It still has to be installed,
  so it still belongs in `packages`; the extra `library()` call is a cheap price for
  having one list.
