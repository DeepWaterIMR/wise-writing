---
name: academic-assessment-report
description: Write a stock assessment report chapter for ICES, AFWG, JRN-AFWG, or an internal IMR assessment — status of the fisheries, data used, model settings and diagnostics, results, reference points, and management advice, in the working group's Word template. Use when the user is writing up an annual assessment.
metadata:
  version: "0.2.1"
license: MIT
---

# Assessment report

Load [`../academic-style/SKILL.md`](../academic-style/SKILL.md) and
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md) first.

An assessment report chapter documents one stock's annual assessment for a working group. It
is a **chapter of a larger report**, not a standalone document, and the group's conventions
override this pack's defaults wherever they differ.

> **Check the current year's guidance before you start.** ICES, AFWG, and JRN-AFWG revise the
> template, the section list, and the float numbering. The structure below is stable in
> outline and unreliable in detail. This skill will be refined at each assessment round.

## Step 1 — Scaffold

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../stock-assessment-2027", types = "assessment-report")
```

The skeleton is `docs/assessment-report/assessment-report.qmd`.

Three Word templates are copied into `docs/assets/`. Pick the one for the body this chapter
reports to, in the YAML:

| Body | Template |
|---|---|
| JRN-AFWG | `../assets/jrn_afwg_report_template.docx` |
| ICES | `../assets/ices_scientific_reports_template.docx` |
| Internal IMR | `../assets/nettrapport_template.docx` |

**ICES and the working groups reissue their templates.** Check that the shipped one is still
current before you rely on it; if the group has issued a newer one, put that in `docs/assets/`
and point `reference-doc:` at it instead.

## Step 2 — Three conventions that differ from other documents

**No YAML `title:`.** The chapter heading in the markdown is the title. A YAML title would put
a second one above it.

**`number-sections: false`, and float numbers written into the caption.** The working group
assigns the numbers — *Table 6.8*, *Figure 6.23* — and other chapters cross-reference them. So
the caption carries the assigned number as text, and the label slug mirrors it:

````
```{r}
#| label: tbl-6-8
#| tbl-cap: "Table 6.8. Catch numbers-at-age 6 to 18 and 19+. Values are in thousands."
```
````

Never renumber the floats to match your text.

**All floats at the end**, collected under `## Tables and figures` in the group's order, not
interleaved with the prose. The text refers to them by their assigned number.

## Step 3 — Sections

Follow the group's list. In outline:

1. **Status of the fisheries** — catches, fleets, management measures in recent years.
2. **Data used in the assessment** — catch, survey, and biological data, with what changed
   since last year and why.
3. **Assessment** — model settings, diagnostics, results.
4. **Comments to the assessment** — what the model does not capture, and how much confidence
   it deserves. Write this honestly; it is what the reviewers read first.
5. **Biological reference points.**
6. **Management advice.**
7. **Future development of the assessment** — specific enough to become the next benchmark's
   issue list.
8. **Software and reproducibility** — package citations and the AI disclosure.
9. **References**, in the group's format.

## Writing it

- **For a SPiCT assessment, use [spict-wise](https://github.com/DeepWaterIMR/spict-wise)
  alongside this skill.** That template owns the biomass-dynamic model inputs, fitting, and
  diagnostics; this skill owns the working-group chapter. Derive the chapter's settings,
  estimates, diagnostics, and reference-point statements from the selected SPiCT run rather
  than recreating the model code in the report.
- **Every headline number is inline R** — SSB, F, recruitment, the advice. The chapter is
  rewritten each year against a new model run, and a stale number is the classic error in this
  document type. Derive them all in one chunk from the model output.
- **`params:`** hold the assessment year, the advice year, and the previous advice year.
  Everything else derives from them, so a new year is one edit.
- **State whether each index is relative or absolute**, and what effort denominator it uses.
  See
  [`../academic-style/references/ecology-fisheries.md`](../academic-style/references/ecology-fisheries.md).
- **Use the reference points as the framework defines them.** Do not invent an intermediate.
- **Distinguish assessment year, advice year, survey year, and year class** in every table
  header.
- **Add the AI disclosure.** Assessment chapters have historically carried none; if a model
  worked on the text or the analysis, disclose it. See
  [`../academic-style/references/ai-disclosure.md`](../academic-style/references/ai-disclosure.md).

## Rendering

```bash
Rscript docs/render.R assessment-report docx
```

HTML previews from the Preview/Render button. The Word post-processing unwraps Quarto's
wrapper tables so the floats sit inline the way the group's template expects.

## Related

The advice that follows from this assessment goes in an
[`../academic-advice-sheet/SKILL.md`](../academic-advice-sheet/SKILL.md). A full revision of
the assessment method is a
[`../academic-benchmark-report/SKILL.md`](../academic-benchmark-report/SKILL.md).

## Done

Report which sections are drafted, whether the numbers come from the current model run, and
what the working group still has to supply — template, float numbers, or reference points.
