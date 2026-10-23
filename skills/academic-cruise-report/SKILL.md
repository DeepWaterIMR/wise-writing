---
name: academic-cruise-report
description: Write a cruise or survey report — a metadata report describing how data were collected, the survey design, gear, sampling, and an overview of what was caught, with Word output for the institute web-report system, plus PDF and an HTML working version. Use after a survey, when the user wants to document a cruise rather than analyse its data.
metadata:
  version: "0.1.0"
license: MIT
---

# Cruise report

Load [`../academic-style/SKILL.md`](../academic-style/SKILL.md) and
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md) first.

## What a cruise report is, and is not

**It is a metadata report.** It documents how the data were collected, describes the survey,
and shows enough of the catch to make the data interpretable by someone who was not aboard.

**It is not an analysis of those data.** Some plots and tables are needed to show what was
collected; a model, an index, or a hypothesis test is not. That work belongs in a data report
or a manuscript. Keeping the line clear is the single most useful thing this skill does — the
report is written days after the cruise, and the temptation to start analysing is strong.

The reader is a future user of the data. Write for someone deciding whether these data suit
their question.

## Step 1 — Scaffold

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../cruise-2027", types = "cruise-report")
```

This copies `nettrapport_template.docx`, the IMR LaTeX partials, and the institute artwork
into `docs/assets/`. The skeleton is `docs/cruise-report/cruise-report.qmd`.

## Step 2 — Fetch the data once, render many times

Survey data live in the standardised folder structure on the vessel's servers. **The document
never reads the server.** `R/1_data.R` fetches, and writes one local snapshot per component
into `data/output/`; the document reads only those.

This matters for three reasons: the report is rendered dozens of times while writing, reading
several thousand files across a network takes minutes, and the report has to render ashore
with no connection at all.

Give every snapshot an **empty-shape fallback**, so a component that has not been collected
yet leaves the document renderable:

```r
read_snapshot <- function(name, empty = tibble::tibble()) {
  path <- file.path(output_dir, paste0(name, ".rds"))
  if (file.exists(path)) readRDS(path) else empty
}
```

and render tables through `table_or_status()`, which prints a status line instead of failing
when a data object is empty.

Locating the cruise directory: try the paths in `config.yaml` first, then search the usual
mount points — `/Volumes` on macOS, drive letters on Windows — for a directory named after the
cruise. Never hard-code one machine's path.

## Step 3 — Structure

1. **Summary** — what the survey was, when and where, what was collected, what went wrong.
2. **Introduction** — why the survey was carried out, its objectives, the programme.
3. **Material and methods** — timing and spatial extent, survey design, gear and trawling,
   biological sampling, hydrographic and acoustic sampling, software and reproducibility.
4. **Results** — an overview of what was collected: composition, length distributions,
   station coverage, instrument performance.
5. **Discussion** — what worked, what did not, and what it means for the usability of the
   data. State gear problems, weather losses, and coverage gaps plainly. The next user needs
   to know.
6. **Appendices** — the station list and the total catch. **Long tables belong here**, not in
   the body.

## Output formats

| Format | Purpose |
|---|---|
| `html` | The working version, rendered from the Preview/Render button |
| `docx` | The IMR web-report system. Uses `assets/nettrapport_template.docx` |
| `pdf` | Readable circulation copy, `xelatex` with the IMR cover and closing page |

```bash
Rscript docs/render.R cruise-report
```

The Word post-processing removes Quarto's wrapper tables from around the figures and tables.
Where the template's cover artwork or heading numbering also needs restoring, the extra
helpers in `R/docx_postprocess.R` do it — see
[`../academic-conventions/references/rendering.md`](../academic-conventions/references/rendering.md).

The PDF partials reference `assets/imr-logo.png`, `assets/imr-chevron.png`, and
`assets/imr-cover-gradient.png`. All three ship with this skill; a PDF build fails without
them.

## Cruise-specific settings

Put them in `config.yaml`: the cruise identifier, candidate data paths, gear dimensions,
acoustic categories, and the participant list. The document reads them through `cfg`. A
setting typed into the document is a setting that will be wrong next year.

## Writing it

- **Almost every value is inline R.** A cruise report is rewritten while data are still
  arriving.
- **Give the gear and effort explicitly** — swept area, towing time, distance, soak time — with
  units. See
  [`../academic-style/references/ecology-fisheries.md`](../academic-style/references/ecology-fisheries.md).
- **Say how zero catches and unqualified hauls were treated.** A station with no fish is data.
- **Maps use ggOceanMaps.** Show the stations, the survey area, and the bathymetry.

## Done

Report which sections are drafted, whether the snapshots are current, and what is still
missing from the survey record.
