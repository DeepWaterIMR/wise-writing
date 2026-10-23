---
name: academic-manuscript
description: Start, structure, and write a scientific manuscript for journal submission in ecology or fisheries science — IMRaD structure, author and affiliation YAML, HTML preview with Word and PDF submission formats, supplementary material, and the technical statements journals require. Use when the user wants to write, draft, restructure, or submit a paper.
metadata:
  version: "0.1.0"
license: MIT
---

# Manuscript

A paper for journal submission. Load
[`../academic-style/SKILL.md`](../academic-style/SKILL.md) and
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md) first — this skill
adds only what is specific to a manuscript.

> The authors are accountable for the paper. Your job is to help them write it, not to
> produce it for them. Never call a draft submission-ready; that is their judgement.

## Step 1 — Agree the argument before writing prose

Do not start drafting. Establish, with the user:

1. **The claim.** One sentence: what does this paper show that was not known?
2. **The evidence for it.** Which analyses, and are they done?
3. **The target journal**, which fixes length, structure, citation style, figure widths, and
   whether the English is American or British.
4. **The authors**, their order, affiliations, ORCIDs, and who corresponds. Settle this now —
   settling it late is how collaborations go wrong.
5. **The figures and tables**, chosen and ordered. They are the skeleton of the Results, and
   choosing them first stops the Results becoming a list of everything measured.

Write that down as an outline and get agreement on it. Restructuring a half-written
manuscript is expensive; agreeing an outline is cheap.

## Step 2 — Scaffold

If the project does not exist yet:

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../my-paper", types = "manuscript")
```

This creates the project layout, copies `custom-reference-doc.docx` and the CSL into
`docs/assets/`, and stamps the author block from `config.yaml`. See
[`../academic-conventions/references/project-structure.md`](../academic-conventions/references/project-structure.md).

The skeleton is `docs/manuscript/manuscript.qmd`.

## Step 3 — Write, in the order that works

**Figures and tables → Materials and methods → Results → Introduction and Discussion together
→ Abstract last.** Section-by-section guidance, including titles, keywords, and the failure
modes of each section, is in
[`../academic-style/references/imrad.md`](../academic-style/references/imrad.md).

Two things this pack insists on:

- **Every number in the prose is inline R.** A manuscript is revised many times against
  changing analyses.
- **The AI disclosure and the software citations go in Materials and methods**, in the same
  subsection. The skeleton has the paragraph; fill in the model, or append yours to a list
  that already exists. See
  [`../academic-style/references/ai-disclosure.md`](../academic-style/references/ai-disclosure.md).

## Output formats

| Format | Purpose |
|---|---|
| `html` | The working preview. Renders from the Preview/Render button, no arguments |
| `docx` | Submission. Uses `assets/custom-reference-doc.docx` |
| `pdf` | Submission or circulation. `linestretch: 2` gives the double spacing most journals ask for |

```bash
Rscript docs/render.R manuscript docx
```

`render.R` renders and then unwraps Quarto's one-cell wrapper tables from around the figures
and tables, which Word otherwise shows with a dashed outline and a move handle.

**Line numbers**, which most journals require, are added by the submission system or by the
`lineno` LaTeX package for PDF. Do not try to fake them in the source.

## Supplementary material

The YAML declares two extra cross-reference kinds, `suppfig` and `supptbl`, which render as
*Figure S1* and *Table S1*. Use them for the supplement, and keep the main sequences clean.

**Long tables belong in the supplement.** Keep a summary in the body and move the full listing
out. This is the most common reason a paper looks padded.

## Technical statements

The skeleton carries the sections journals now expect: acknowledgements, ethics, data
availability, funding, conflict of interest, and author contributions. Two of them are places
where a language model can do real damage:

- **Data availability must be true.** If the analysis is not reproducible from what is
  deposited, say so rather than asserting that it is.
- **Author contributions never include a model.** Use CRediT roles, and list only people.

## The `authors-block` extension

The skeleton's author YAML renders as a journal-style byline in Word and PDF when the
`authors-block` extension is installed. It is not bundled with Quarto:

```bash
quarto add quarto-ext/authors-block
```

Then uncomment the `filters:` lines in the YAML. Without it the document still renders, using
Quarto's own author handling.

## Before submission

Work through
[`../academic-style/references/checklists.md`](../academic-style/references/checklists.md), and
then check the journal's own instructions against the document. The five commonest reasons a
manuscript is returned before review are all formatting, and all avoidable.

## Done

Report which sections are drafted, which are outlined, what could not be verified, and which
scientific decisions are still open. Do not say the manuscript is ready.
