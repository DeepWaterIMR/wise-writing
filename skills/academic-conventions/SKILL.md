---
name: academic-conventions
description: Technical conventions for reproducible academic documents written in Quarto with R — project structure, YAML headers, BibTeX and CSL, ICES figure widths, inline R instead of hard-coded numbers, code-folded appendices, package loading, local Git, and rendering to HTML, Word, and PDF. Use whenever creating, editing, or rendering a .qmd document or setting up a writing project.
metadata:
  version: "0.2.0"
license: MIT
---

# Academic writing — technical conventions

The technical half of this pack. Load it together with
[`../academic-style/SKILL.md`](../academic-style/SKILL.md) whenever you create or edit a Quarto
document; style decides what the prose says, this decides how the document is built.

For a specific document type, load its skill too — `academic-manuscript`,
`academic-data-report`, `academic-cruise-report`, `academic-assessment-report`,
`academic-advice-sheet`, or `academic-benchmark-report`. Those own the output formats and
section structure; this owns everything they share.

## The rules

### 1. Human identity and version metadata

The YAML byline names the accountable human author or authors, never the analysis, project,
document type, or AI system. Preserve an existing byline. When revising an older document,
read the project configuration and instructions for the author and affiliation; if they are
not recorded, ask rather than inventing a placeholder. Use `published-title: "Version"` with
the YAML `date:` field, and verify that the rendered title block says **Version**, not
**Published**.

### 2. Quarto, R, BibTeX

Documents are `.qmd`. Analyses are R. References live in a BibTeX file —
`docs/assets/references.bib` by default, unless the project already has one or the user names
another. Software citations come from `citation("pkg")`, never written by hand.

### 3. Citation style

`docs/assets/ices_jms.csl` (ICES Journal of Marine Science) is the default. Swapping it is one
YAML line; users may supply their own. See
[`references/bibliography-and-csl.md`](references/bibliography-and-csl.md).

### 4. HTML is the preview format

Every document type previews as HTML, and **the HTML render must work straight from the
editor's Preview (Positron) or Render (RStudio) button** — no helper script, no arguments. Put
`html` first in the `format:` block. Anything else goes through `docs/render.R`.

### 5. ICES figure widths

- Single column: **85 mm** → `fig-width: 3.35`
- Double column / full page: **170 mm** → `fig-width: 6.69`
- **Never size a figure between the two.**

Set the width once in the YAML `execute:` block and override only `fig-height` per chunk,
choosing a height that fills the width without stretching or crowding. Users may override both.

### 6. Never hard-code a number that comes from data

Every data-derived value in the prose is inline R. The same goes for anything that changes
when the data change — figures, tables, counts, ranges, dates, model estimates. Derive them in
one named chunk and reference the objects, so prose, tables, and figures cannot drift.

### 7. One chunk convention

Anonymous fence plus `#|` options for anything that produces a float:

````
```{r}
#| label: fig-catch-composition
#| fig-cap: "Catch composition by taxon. Bars show the share of total qualified catch; n = 214 hauls."
#| fig-height: 5
```
````

Name the fence only for a compute chunk whose objects the prose uses (`{r summaries}`). Build
a dynamic caption as a string object first and reference it — `#| fig-cap: !expr cap_catch` —
rather than calling `sprintf()` inline, which needs `%%` escaping and breaks quietly.

### 8. Reproducible from source data

All analyses in R, runnable end to end from the source data. Scripts are human-readable and
commented; functions carry Roxygen2 documentation. Number scripts by run order — `0_setup.R`,
`1_data.R`, `2_analysis.R` — and leave function libraries un-numbered.

**In an HTML report, disclose the scripts in an appendix** with code folding:

````
```{r filtering-appendix, code = readLines("R/1_data.R"), eval = FALSE, echo = TRUE}
#| lst-label: lst-data-script
#| lst-cap: "Complete compilation script used to acquire, filter, and compile the data."
#| code-fold: true
#| code-summary: "Show full compiler script"
```
````

Manuscripts and Word or PDF deliverables do not need the appendix.

### 9. Project structure

| Folder | Contents |
|---|---|
| `R/` | scripts and functions, numbered by run order; `0_setup.R` first |
| `docs/` | every document — `.qmd` and rendered output; `docs/assets/` holds `references.bib`, the CSL, Word templates, LaTeX partials, and figures the qmd includes |
| `data/` | all data |
| `figures/` | output figure files |
| `logs/` | scratch logs; non-crucial, temporary |
| `ai/` | agent territory: `ai/memory/`, `ai/tests/`, `ai/review/`. Keep it small |
| `website/` | optional, not scaffolded — create only when the user asks for a project website |
| `config/` | configuration for GitHub, web, and test tooling |
| `VERSION` | `version:` and `date:`, starting at 0.1.0 |

Details, including the `.gitignore` and what belongs where:
[`references/project-structure.md`](references/project-structure.md).

**Agent memory goes in `ai/memory/`**, not in an agent-local folder outside the project.

### 10. Packages

Declare every package once, in `R/0_setup.R`, as a named vector whose value is the GitHub
repository or `NA` for CRAN. New projects include `R/package_setup.R`; missing packages are
reported without installation by default. Install only after explicit user consent, and never
use helper-driven installs when `renv` is present. Keep the default set small and load the rest
on demand with `ensure_packages()`.

Graphs with **ggplot2**, static maps with **ggOceanMaps**, life-history plots with **ggFishPlots**,
sdmTMB diagnostics with **sdmTMBexperiments**, spatial operations with **sf**, data
manipulation with **tidyverse**. Default ggplot theme: `theme_bw(base_size = 12)`. Full list:
[`references/r-packages.md`](references/r-packages.md).

### 11. Local Git, never pushed

Every project is a local Git repository with **no remote by default**. Commit as you go, using
the user's own `git config` identity. Never push, and never add a remote unless the user asks.
See [`references/git.md`](references/git.md).

If Git, Quarto, or R is missing, hand off to
[`../academic-toolchain-setup/SKILL.md`](../academic-toolchain-setup/SKILL.md).

### 12. Rendering

`quarto render` for HTML. Everything else — Word, PDF, and the post-processing that strips
Quarto's wrapper environments from Word floats — goes through `docs/render.R`. See
[`references/rendering.md`](references/rendering.md).

## Depth

| File | When |
|---|---|
| [`references/project-structure.md`](references/project-structure.md) | Setting up or reorganising a project |
| [`references/yaml.md`](references/yaml.md) | Writing or fixing a YAML header |
| [`references/bibliography-and-csl.md`](references/bibliography-and-csl.md) | Bibliography, CSL styles, software citations |
| [`references/r-packages.md`](references/r-packages.md) | Choosing or adding a package |
| [`references/rendering.md`](references/rendering.md) | Rendering, Word post-processing, render failures |
| [`references/git.md`](references/git.md) | Repository setup, `.gitignore`, versioning, commits |

## Done

Say what you built or changed, whether it renders, and what the user still has to decide.
