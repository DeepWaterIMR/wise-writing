---
name: academic-advice-sheet
description: Write a fishing-opportunities advice sheet for ICES or the Institute of Marine Research — the short standardised public document carrying catch advice to managers, with the fixed section order, catch scenarios, reference points, and advice history, in the IMR or ICES Word template. Use when the user needs to produce or update catch advice.
metadata:
  version: "0.2.0"
license: MIT
---

# Advice sheet

Load [`../academic-style/SKILL.md`](../academic-style/SKILL.md) and
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md) first.

An advice sheet is the short public document that carries catch advice to managers. It is read
by fisheries managers, industry, and journalists, and quoted directly. **Three properties
follow from that:** the structure is fixed and readers navigate by it, every number must be
correct because an error here is a public one, and the sheet is regenerated each year against a
new assessment, so anything typed rather than derived goes stale silently.

## Step 1 — Scaffold

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../stock-advice-2027", types = "advice-sheet")
```

The skeleton is `docs/advice-sheet/advice-sheet.qmd`. Both Word templates ship with it.

For a **SPiCT** assessment, use
[spict-wise](https://github.com/DeepWaterIMR/spict-wise) alongside this skill: it
scaffolds this document already wired to a saved assessment summary, and its
`R/advice_tables.R` is a worked implementation of the table idiom in
[`references/tables.md`](references/tables.md).

## Step 2 — Pick the template

| Body | Template | Filter |
|---|---|---|
| Institute of Marine Research | `assets/advice_template_imr.docx` | `assets/normal-style.lua` |
| ICES | `assets/advice_template_ices.docx` | none |

The IMR template expects body text in Word's *Normal* style; the Lua filter puts it there.
Remove the filter when rendering against the ICES template, or every paragraph is forced into
a style that template does not use.

The ICES sheet also carries a masthead — ecoregion, publication line, and the stock heading —
which is emitted from R rather than typed, because the wording is standardised and the
publication date changes at release. Where that is needed, leave `title:` empty and write the
masthead in a `#| results: asis` chunk.

## Step 3 — The section order

Do not reorder or rename these. Readers, and the advice database, navigate by them.

1. Advice on fishing opportunities
2. *(ICES)* Non-fisheries conservation considerations
3. Stock development over time
4. Catch scenarios
5. Basis of the advice
6. Quality of the assessment
7. Issues relevant for the advice
8. Reference points
9. Basis of the assessment
10. History of the advice, catch, and management
11. Summary of the assessment
12. Sources and references

**The advice goes in the first sentence of section 1**, with its basis named — MSY approach,
precautionary approach, or a management plan:

> Based on the MSY approach, catches in `` `r params$advice_year` `` should be no more than
> `` `r fmt(advice)` `` tonnes.

Where the assessment behind the sheet is **exploratory** — a supplement to an official
assessment rather than the official one — open the document with a callout saying so and
naming the official model. Treat that callout as load-bearing: an exploratory sheet mistaken
for official advice is the worst failure this document type has, and a tidying pass is exactly
how one gets dropped.

## Step 4 — Every number is inline R

Without exception. Derive the advised catch, the stock status against each reference point, the
change from last year's advice, and the whole catch-scenario table in one chunk from the
assessment output.

Habits that prevent the errors this document type actually suffers:

- **`params:`** carry the assessment year, the advice year, the previous advice, and the most
  recent agreed TAC. Everything else derives from them.
- **Look scenarios up by name, not by row position.** The advice-rule row is not necessarily
  row 1, and will not stay row 1 the first time a scenario is added.
- **Derive the status sentence in code**, not in prose:

  ```r
  b_status <- dplyr::case_when(
    bbmsy < blim ~ "below B~lim~",
    bbmsy < btrigger ~ "below MSY B~trigger~ but above B~lim~",
    .default = "above MSY B~trigger~"
  )
  ```

  Written this way, the sentence cannot contradict the table beside it.
- **Build parameterised captions as string objects** and reference them with
  `#| tbl-cap: !expr cap_catch_scenarios`, rather than calling `sprintf()` inline where a
  literal `%` has to be doubled. A `!expr` caption is evaluated even when its chunk has
  `eval: false`, so the object must already exist.
- **Round with `icesAdvice::icesRound()`** for every ratio the framework rounds, so the sheet
  matches what goes into the advice database. Use a plain thousands formatter for tonnages.
- **Read from a saved assessment summary**, not from the fitted model object. A small summary
  written by the assessment document keeps the sheet fast, and guarantees that the sheet, the
  assessment report, and the assessment itself quote the same numbers.

Values that change at release — the publication line, the advice DOI, the download URL — sit in
a clearly marked block near the top, so the annual edit is one place. Leave them as visible
placeholders until they are supplied: a plausible-looking DOI that resolves to nothing is worse
than an obvious blank.

## Step 5 — The tables

Advice-sheet tables carry real subscripts, merged group rows, and footnotes, and Word **clips**
a table wider than the text column rather than reflowing it. Build them with flextable and fit
them to the page explicitly.

**Read [`references/tables.md`](references/tables.md)** for the house style, the page-fitting
helper, the subscript idiom, the grouped catch-scenario table, and the annual-update trap in
the advice-history table. That last one is the error this document type actually makes: the
advice text is a historical record that cannot be derived, so it is hard-coded, and when the
assessment year advances past its last entry every row shifts by one unless the table is keyed
by year.

## Writing it

- **Say whether the stock is above or below each reference point**, using the framework's own
  terms, and say what that implies for the advice.
- **State the basis of the advice explicitly.** A reader must be able to tell an MSY advice from
  a precautionary one without inferring it.
- **Say whether the reference points are absolute or relative.** A model that estimates only
  B/B~MSY~ and F/F~MSY~ supplies no absolute points; where B~lim~ and MSY B~trigger~ are
  conventions from the framework rather than estimates, say so.
- **Quality of the assessment** is where the honest caveats go. If the assessment failed a
  diagnostic and was carried forward anyway, say which, by how much, and what it means for the
  confidence the advised catch carries. Do not soften it; managers are entitled to know.
- **Distinguish landings, catch, and removals**, and say whether discards and recreational catch
  are included.
- **Add the AI disclosure** under *Basis of the assessment*. Advice sheets have historically
  carried none. See
  [`../academic-style/references/ai-disclosure.md`](../academic-style/references/ai-disclosure.md).

## Rendering

```bash
Rscript docs/render.R advice-sheet docx
```

HTML previews from the Preview/Render button, styled with `assets/ices_advice.css`. The Word
post-processing unwraps Quarto's wrapper tables so the floats sit inline — which is why Word
goes through the script and not the button.

## Before it goes out

- Every number traces to the assessment output; nothing is typed.
- The advised catch matches the assessment report.
- The advice-history table covers every year through the advice year.
- No table runs off the page in the rendered `.docx`.
- Release-time values are filled, or obviously marked as pending.
- The AI disclosure names the actual models and roles, appended to any existing list.

## Related

The assessment behind the advice is an
[`../academic-assessment-report/SKILL.md`](../academic-assessment-report/SKILL.md). For a SPiCT
biomass-dynamic assessment, the model, its diagnostics, and the wiring from the assessment to
this sheet come from [spict-wise](https://github.com/DeepWaterIMR/spict-wise).

## Done

Report which sections are drafted, whether the numbers come from the current assessment run,
which release-time values — publication date, DOI, download URL — still need filling in, and
any diagnostic the assessment failed, since that is what *Quality of the assessment* has to
carry.
