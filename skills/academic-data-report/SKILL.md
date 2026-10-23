---
name: academic-data-report
description: Write an internal data report — a fully reproducible HTML analysis document where every analysis chunk is visible but collapsed, used to derive parameters or prepare data for an assessment, a model, or a manuscript. Use when the user wants to document an analysis internally rather than publish it.
metadata:
  version: "0.1.3"
license: MIT
---

# Data report

An internal, fully reproducible analysis. Load
[`../academic-style/SKILL.md`](../academic-style/SKILL.md) and
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md) first.

A data report answers a specific question — what are the life-history parameters, what does
the filtered data set contain, which values should the assessment use — and its readers are
colleagues who may need to check the arithmetic. **Reproducibility is the point**, so the code
stays in the document.

## What makes it a data report

One YAML difference from every other type in this pack:

```yaml
format:
  html:
    toc: true
    toc-title: "Document title"
    code-fold: true
    code-summary: "Show code"
execute:
  warning: false
  message: false
```

Set `toc-title` to the document's actual title so the HTML sidebar identifies the report
while the reader scrolls. Keep it synchronized when the title changes; the scaffold uses
`{{PROJECT_TITLE}}` for both values. Verify the rendered sidebar heading.

**`echo: false` is absent, deliberately.** Setting it would silence every chunk and
`code-fold` would do nothing. With the fold and no `echo: false`, every analysis step is
present and one click away, and the document doubles as its own methods appendix.

HTML is the only output. A data report that needs to become a Word document is usually a
report for someone else, which means a different type.

Before revising an existing report, enforce the shared metadata and publishing contract:

- preserve or confirm the accountable human author and institutional affiliation;
- add `published-title: "Version"` and verify that the rendered title block uses that label;
- use ggOceanMaps for static maps, retaining project-supplied geometries unchanged;
- cite R and every package that influenced the results in prose, with inline versions and
  BibTeX entries obtained from `citation()`;
- end the body with `# References {.unnumbered}` and an explicit `::: {#refs}` div before any
  appendix.

A generated list of raw `citation()` output does not satisfy the software-citation
requirement. Neither does a generic byline such as “project analysis”.

## Step 1 — Scaffold

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../my-analysis", types = "data-report")
```

The skeleton is `docs/data-report/data-report.qmd`.

## Step 2 — Structure

0. **Key messages** (unnumbered, first) — 3–6 bullets for the reader who will not open a code
   fold. See below.
1. **Purpose** — the question, the reader, and what the output feeds into downstream. Name the
   data source and its version.
2. **Data** — what was read, how many records, over what period and area, what was excluded
   and why. Every count is inline R.
3. **Analysis** — one section per step, each ending in a figure or a table and a sentence
   saying what it shows.
4. **Results and recommendations** — which values should be used downstream, and which are
   provisional. Be explicit: this is what the reader came for.
5. **Software and reproducibility** — narrative package citations with inline versions and
   the exact researcher-confirmed AI model list.
6. **References** — an unnumbered section backed by the document bibliography.
7. **Appendix** — the full scripts.

## Key messages

Data reports are long and most readers want only the conclusions. The report therefore
opens with `# Key messages {.unnumbered}`, a short bullet list placed before **Purpose**:

- **Write it last**, once the analysis and the recommendations are settled.
- **3–6 bullets, one finding each**, as complete sentences that lead with the result, not
  the method.
- **Every number is inline R** from the same objects the body uses, with a cross-reference to
  the figure or table that supports it.
- **The last bullet states what is ready for downstream use and what is provisional.** It
  must agree with *Results and recommendations*.
- **Nothing new.** Every bullet is supported further down; the section summarises, it does
  not argue.

When revising an existing report that lacks this section, add it and check every bullet
against the body.

## Step 3 — The appendix

The appendix is what makes the report auditable. A reader sees not only the chunks in the
document but the pipeline that produced its inputs:

````
```{r compile-appendix, code = readLines(here::here("R", "1_data.R")), eval = FALSE, echo = TRUE}
#| lst-label: lst-compile-script
#| lst-cap: "Complete compilation script used to acquire, filter, and compile the data."
#| code-fold: true
#| code-summary: "Show full compilation script"
```
````

One block per script in `R/`, in run order. Note that `readLines()` runs at render time even
though `eval` is `FALSE` — a missing script breaks the render.

## Writing an analysis document well

- **Derive first, write second.** Put every value the prose quotes in one named chunk and
  reference the objects, so text, tables, and figures cannot drift.
- **Say what each figure shows.** A data report that leaves the reader to interpret its own
  figures has not done its job. One sentence with the cross-reference at the end.
- **Report what you tried and dropped**, not only what worked. The next reader's first
  question is usually "did you consider…".
- **Distinguish observed, estimated, and modelled values** everywhere, including in table
  headers. See
  [`../academic-style/references/distinctions.md`](../academic-style/references/distinctions.md).
- **Cache expensive steps** behind a flag that loads a saved object instead, and flip it back
  once the object exists. Never add `freeze:` or `cache:` silently — a stale cache produces a
  document that disagrees with its own data.

## Useful patterns

Dump captured model output into the narrative:

````
```{r}
#| results: asis
cat(gsub("\n", "  \n", model_summary_text))
```
````

Build a caption that depends on the data:

````
```{r}
#| label: fig-maturity
#| fig-cap: !expr cap_maturity
```
````

with `cap_maturity` built as a string in the preceding chunk.

## Sibling packs

Life-history parameters — maturity ogives, growth curves, length–weight — come from
**ggFishPlots**; IMR Biotic data access comes from BAIT's `biotic-*` skills; sdmTMB survey
indices from index-wise's `index-*` skills. Call those rather than reimplementing them.

## Done

Report what the analysis found, which values are ready for downstream use, what is
provisional, and what you could not verify.
