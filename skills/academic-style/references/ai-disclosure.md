# Disclosing the use of AI

The rules here follow the
[ICMJE Recommendations for the Conduct, Reporting, Editing, and Publication of Scholarly Work
in Medical Journals](https://www.icmje.org/icmje-recommendations.pdf), which most ecology and
fisheries journals have aligned with. Check the target journal as well — the wording of the
requirement varies, the substance does not.

## The three rules

1. **A language model is never an author.** Authorship requires accountability, and a model
   cannot be accountable. Do not put a model in the byline, the YAML `author:` field, the
   contributions statement, or the acknowledgements as an author.
2. **The authors are responsible for everything the model produced**, including any error,
   fabrication, or plagiarism in it. They must review, edit, and approve it. The disclosure
   says this explicitly.
3. **Disclose the use, and name the model.** Where the model contributed to the work — drafting
   text, writing or checking code, producing analyses — the disclosure belongs in **Materials
   and methods**, in the same place as the software citations. Where the model did nothing but
   correct language, the acknowledgements are enough; that is rarely the case for work done
   with this pack.

## The standard paragraph

Adapt this. The versions are pulled with inline R so they cannot go stale:

```markdown
This document and the associated analyses were created with researcher-supervised
generative AI ({{MODELS}}). The document is compiled using Quarto
`r quarto::quarto_version()` [@quarto] and rendered by knitr
`r packageVersion("knitr")` [@knitr] under `r R.version.string` [@rcoreteam], and is
reproducible from source data. The authors designed the study, specified and checked the
analyses, and reviewed, edited, and approved all AI-assisted content, for which they take
full responsibility.
```

Rendered, with `{{MODELS}}` filled in, that reads:

> This document and the associated analyses were created with researcher-supervised generative
> AI (Claude Opus 5). The document is compiled using Quarto 1.9.37 (Allaire et al., 2026) and
> rendered by knitr 1.51 (Xie, 2025) under R version 4.6.0 (2026-04-24) (R Core Team, 2026),
> and is reproducible from source data. The authors designed the study, specified and checked
> the analyses, and reviewed, edited, and approved all AI-assisted content, for which they
> take full responsibility.

The software citations for the packages that influenced the results go in the same paragraph
or the one beside it. Take them from `citation("pkg")`; never write a citation from memory.
See [`citations.md`](citations.md).

Use the exact model names recorded by the researcher or exposed by the tool. Do not shorten a
specific model to a generic family name, infer a version, or replace a researcher-supplied
model list. If the model identity cannot be confirmed, leave a visible placeholder for the
author rather than guessing.

## Appending your model — do not overwrite

**If a disclosure already names one or more models, add yours to the list. Never replace what
is there.** A document edited by three models over a year was edited by three models, and the
record has to show that.

> `(Claude Opus 5)` → `(Claude Opus 5, OpenAI GPT-5)`

Order them however the list already runs — chronological is the clearest. If you cannot tell
whether a model in the list did the work you are now doing, leave it and add yours anyway; an
over-inclusive list is honest, a truncated one is not.

If there is no disclosure and AI was used, add one. Silence is not a neutral default.

**Every document needs one — there is no document type without it.** Agents tend to add the
statement to manuscripts and reports and forget it in "minor" documents: background notes,
literature summaries, data documents, method notes, slide decks, one-off analyses. Those need
it too. Check for it before every render.

## Where it goes, by document type

| Document | Placement |
|---|---|
| Manuscript | Materials and methods, final subsection (often *"Software and reproducibility"* or similar) |
| Data report | A *"Software and reproducibility"* section, usually at the end of the methods |
| Cruise report | *"Software and reproducibility"* under Material and methods |
| Assessment report | The methods or *"Basis of the assessment"* section |
| Advice sheet | *"Basis of the assessment"*, or the sources section if the sheet has no methods |
| Benchmark report | The methods section of the relevant stock chapter |
| Background note, literature summary, method note | A *"Software and reproducibility"* or *"Use of generative AI"* section before the references |
| Slide deck | A methods or closing slide |
| Any other document | Where a reader looking for how the work was done would look; never omitted |

Whatever the type, it goes where a reader looking for how the work was done would look.

## What not to claim

- Do not claim the AI "only checked grammar" if it drafted text, wrote code, or ran analyses.
- Do not claim text was "initially written by the authors" if a model drafted it. If that is
  true of the document you are editing, leave the sentence; if it is not, tell the author the
  sentence needs changing rather than editing the claim yourself — it is a statement about
  what the humans did.
- Do not name a model version you cannot confirm. Name the model you are.
- Do not describe the AI as having designed the study or interpreted the results, unless the
  authors say that is what happened — and then be precise, because it changes what the
  disclosure means.

## Related obligations

- **Peer review is confidential.** Do not put a manuscript you are reviewing into a service
  that retains or trains on it, and disclose AI use in a review only where the journal permits
  it at all.
- **Plagiarism rules apply to AI output.** Paraphrasing a source closely without attribution is
  plagiarism whoever typed it. So is re-using your own published text and data without saying
  so.
- **Data and code availability statements** must be true. If the analysis is not reproducible
  from what is deposited, say so rather than asserting that it is.
