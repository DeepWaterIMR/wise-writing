---
name: scientific-quarto-review
description: Review or revise a scientific Quarto (.qmd) or R Markdown (.Rmd) analysis while preserving executable syntax, scientific meaning, uncertainty, units, citations, and cross-references. Use for co-author edits, analysis audits, and pre-render review of a scientific document.
metadata:
  version: "0.2.0"
license: MIT
---

<!-- pack-resources:start -->
**Pack resources:** resolve `wise-writing` from `~/.wise-writing/config.json` → `academic_writing_path` (or
`~/.fiskwise/config.json` → `components.wise-writing.path`). If neither exists, use the
checkout containing this skill, or locate/obtain the pack through its install instructions.
Paths such as `knowledge/`, `cookbook/`, `config/` and `project-template/` belong to that
repository, not the current research directory. For a copied skill, resolve a link that
leaves this skill's directory against the corresponding source skill under that root;
keep bundled `references/` links relative to the skill. Never assume `../../` from an
agent's global skills folder reaches the repository. Use absolute resolved script paths.
<!-- pack-resources:end -->


# Scientific Quarto review

Treat the document as both an **executable analysis** and a **scientific argument**. Read the
project instructions and the complete source before editing.

**Prose decisions belong to [`../academic-style/SKILL.md`](../academic-style/SKILL.md)** —
tense, hedging, numbers, units, species names, caption and cross-reference wording. Technical
decisions belong to
[`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md). This skill adds the
review procedure and the analysis audit, and does not restate either.

## Review before editing

1. Inspect the working tree and preserve unrelated changes.
2. Identify the document's purpose, audience, estimands, sampling units, data objects, units,
   and deferred analyses.
3. Trace every substantive statement to code, a displayed result, or a cited source. Flag
   unsupported or ambiguous claims rather than inventing support.
4. Separate software defects from scientific choices. Fix mechanical defects when authorised;
   present methodological alternatives for the researcher's judgement.
5. Give a concise proposed-change list first when the user asked for review before
   implementation.

## Edit safely

- Preserve YAML, chunk options, inline R, equations, citations, labels, cross-references, and
  executable syntax unless the task requires a change.
- Replace hard-coded results with inline R.
- Keep terminology and units consistent across prose, equations, tables, captions, legends,
  and code.
- Keep claims proportional to the evidence, and state consequential assumptions and the
  direction of any bias.
- Do not hard-wrap prose in `.qmd` or `.Rmd`.

## Audit the analysis contract

This is the part no style guide covers. Check, where relevant:

- stable identifiers, join cardinality, aggregation level, zero completion, missing-value
  handling, and units;
- whether numerators and denominators are aggregated to the same unit before a rate is
  calculated;
- whether summaries and prose use the same inclusion rules;
- raising or weighting of subsampled observations;
- figure scales, transformations, legends, captions, facet order, and accessibility;
- table denominators, sample sizes, rounding, and cross-references;
- citation availability, and whether each source supports the exact claim made;
- **stale wording left after a method, variable, unit, or figure changed** — the most common
  defect in a document that has been revised more than twice.

For the distinctions this audit turns on — observed against estimated, relative against
absolute, association against causation — see
[`../academic-style/references/distinctions.md`](../academic-style/references/distinctions.md).

## Validate

1. Review the diff before rendering.
2. Run focused tests, or source the changed helpers in a clean session.
3. Render from the documented project root.
4. Treat every warning and error as unresolved until you have classified it.
5. Check the rendered headings, navigation, captions, references, equations, tables, and
   figures. Inspect visually when the layout changed and the environment allows it.
6. Search the rendered output for a literal `@` — a citation whose key is missing from the
   bibliography renders as text rather than failing.

## Done

Report what you verified, what you did not, and which scientific decisions remain with the
author.
