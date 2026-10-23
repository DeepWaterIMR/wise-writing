---
name: academic-benchmark-report
description: Write a benchmark report chapter — the full revision of a stock assessment method carried out at an ICES, AFWG, JRN-AFWG, or internal IMR benchmark workshop, covering data revision, candidate models and why each was accepted or rejected, reference points, forecast settings, and the reviewer's report. Use when the user is preparing for or writing up a benchmark.
metadata:
  version: "0.2.0"
license: MIT
---

# Benchmark report

Load [`../academic-style/SKILL.md`](../academic-style/SKILL.md) and
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md) first.

## What a benchmark is

A **benchmark** is a full revision of a stock assessment, carried out at a workshop on a
three-to-five-year cycle and reviewed by invited external experts. Stocks rotate through it;
between benchmarks the assessment is only updated, not redesigned.

The question is not *what is the state of the stock* — that is an
[assessment report](../academic-assessment-report/SKILL.md) — but **is this the right
assessment, and what should replace it**.

The settings the workshop agrees become the **stock annex**, which the annual assessment then
runs from until the next benchmark. Write the chapter so that the annex follows from it.

## What you are writing

**One stock chapter.** A benchmark report is assembled by the workshop chair from:

- an **executive summary** covering every stock;
- an **expert group information** table — group name, cycle, chair, meeting venues and dates;
- **one numbered chapter per stock** (this is yours);
- **Annex 1** list of participants, **Annex 2** resolutions and terms of reference, **Annex 3**
  working documents.

Working documents circulate separately before the meeting and are listed in Annex 3; they are
not part of your chapter.

## Step 1 — Scaffold

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../stock-benchmark-2027", types = "benchmark-report")
```

The skeleton is `docs/benchmark-report/benchmark-report.qmd`. All three Word templates are
copied into `docs/assets/`; pick one in the YAML:

| Body | Template |
|---|---|
| ICES | `../assets/ices_scientific_reports_template.docx` |
| JRN-AFWG | `../assets/jrn_afwg_report_template.docx` |
| Internal IMR | `../assets/nettrapport_template.docx` |

As with an assessment chapter: no YAML `title:` — the chapter heading is the title — and
`number-sections: false`, because the workshop assigns the numbering.

## Step 2 — The chapter sections

This is the ICES benchmark chapter structure, taken from
[WKBWNG 2026](https://doi.org/10.17895/ices.pub.32019630) (ICES Scientific Reports 8:27):

1. **Summary** — what the benchmark changed: the data revised, the model adopted, how its
   diagnostics compare with the previous assessment, how the reference points were
   recalculated, and the name of the final accepted run.
2. **Introduction and stock status** — the assessment history and the stock's perceived state.
3. **Key issues with the current assessment** — why the benchmark was called, each issue tied
   to a term of reference.
4. **Stock identity** — boundaries, mixing, morphs, and the genetic or tagging evidence.
5. **Catch data** — sources of landings and discards, species-identification problems,
   allocation of unidentified catch, national data considerations.
6. **Biological parameters** — age reading, maturity, weight at age, natural mortality.
7. **Indices of abundance** — construction, diagnostics, retrospective and sensitivity
   behaviour, and the index recommended for the assessment.
8. **Assessment method** — *Explorations*, then *Final model settings and diagnostics*.
9. **Biological reference points.**
10. **Short-term forecast settings.**
11. **Recommendations for the future.**
12. **References.**
13. **Reviewer's report.**

**An age-structured and a biomass-dynamic stock diverge after the data sections.** A SPiCT
chapter typically replaces sections 6–8 with *Survey index* (background, data, construction,
diagnostics, retrospective and sensitivity, recommended index) and *Proposed stock assessment*
(data inputs, final configuration, parameter estimates and reference points, diagnostics,
alternative model states, the **SPiCT acceptance checklist**, conclusions, future
perspectives). Follow whichever shape the model calls for; the skeleton carries the
age-structured order with a note.

> **Check the workshop's terms of reference and a recent benchmark report before you start.**
> The outline is stable; the details are revised each round.

## Step 3 — Report what failed

This is what separates a benchmark from an assessment. **A benchmark that reports only the
accepted model is not reviewable.** Report the candidates that were tried and rejected, the
diagnostics that rejected them, and the convergence or estimability problems that made a
formulation unusable.

State the **selection criteria and the order they were applied in** before giving the choice.
A selection justified only afterwards reads as a preference.

Keep one object per candidate model and derive the comparison table, rather than typing it.

Where the framework publishes an **acceptance checklist** — SPiCT has one — work through it
explicitly in the chapter. Reviewers look for it.

## Step 4 — The reviewer's report

Written by the invited external reviewers, not by you. Leave the heading in place and insert
their text when it arrives. **Do not draft it on their behalf**, and do not edit its
substance; it is an independent audit and rewriting it defeats its purpose.

## Writing it

- **Every value derives from the model runs.** A benchmark compares several fits; typed
  numbers go stale between runs faster here than anywhere else.
- **Say whether each index is relative or absolute**, its effort denominator, and how zero
  catches were handled. Revising these is often the whole point. See
  [`../academic-style/references/ecology-fisheries.md`](../academic-style/references/ecology-fisheries.md).
- **Distinguish what the data show from what the model estimates.** See
  [`../academic-style/references/distinctions.md`](../academic-style/references/distinctions.md).
- **Name the final run** in a way that can be found again — the stockassessment.org run name,
  or a commit hash.
- **Add the AI disclosure**, as for every other type.

## Rendering

```bash
Rscript docs/render.R benchmark-report docx
```

## Done

Report which sections are drafted, which model comparisons are complete, whether the reference
points and forecast settings are agreed, and what the workshop still has to supply — the
reviewer's report, the annexes, or the float numbering.
