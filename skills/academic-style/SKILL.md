---
name: academic-style
description: Write, revise, or correct academic and scientific prose in ecology and fisheries science — accountability and AI-disclosure rules, tense, epistemic calibration, numbers, units, species names, and figure and table wording. Use whenever writing or editing a manuscript, report, advice sheet, abstract, or any scientific text, in any editor including MS Word; also use to pull non-academic AI writing back into scientific register.
metadata:
  version: "0.1.2"
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


# Academic writing style

For scientific prose in **ecology and fisheries science**. Editor-independent: it applies in
Quarto, Word, LaTeX, or a plain text box. For Quarto mechanics — YAML, chunks,
cross-references, rendering — load [`../academic-conventions/SKILL.md`](../academic-conventions/SKILL.md)
as well.

Priority when rules conflict: **scientific accuracy → precision → logical structure →
concision → readability → elegance**, in that order.

## The rules

### 1. Accountability

The authors are responsible for every word, including what you wrote. Never present your
output as finished; say what you changed and what still needs checking.

- **Never list a language model as an author** — not in the byline, not in the YAML, not in
  the acknowledgements.
- **Disclose AI use in Materials and Methods**, naming the model. Acknowledgements only if the
  model did nothing but correct language, which is rare.
- If a model list is already there, **append** your model. Never replace it.
- Full wording and placement: [`references/ai-disclosure.md`](references/ai-disclosure.md).

### 2. Never invent

No fabricated facts, statistics, R functions, package behaviour, or citations. When you do not
know, write the gap down and flag it. A plausible-looking guess in a scientific document is
worse than an admitted gap.

Every citation needs a **resolvable DOI or URL to the primary source**, and you must confirm
the reference exists in the form written — not just author and year. If you cannot verify it,
mark it `[VERIFY]` and tell the author.

### 3. Push back

Challenge claims that are factually or methodologically weak, over-general, or unsupported by
the evidence at hand. Agreement is not helpfulness. Say what is wrong and what would fix it.

### 4. Language

Consistent scientific **American English**, unless the target journal or the project specifies
otherwise; then British English, applied consistently. Correct grammar and non-native
constructions silently — except where the correction would change a scientific claim, a causal
reading, a temporal relation, or a referent. Those get flagged, not fixed.

### 5. Voice and tense

Prefer passive voice when the document lists fewer than two human authors, especially for
study actions in Methods and Results. Do not use “we” to mean a human author plus an AI
assistant: AI systems are not authors. With two or more authors, first-person plural may be
used naturally. Preserve any explicit project or author voice preference. Direct statements
such as “Catches declined” remain preferable to unnecessary passive constructions.

Tense:

- **Past** for Materials and Methods, Results, study-specific observations, and tentative
  interpretations. *"Sampling was conducted throughout the year."*
- **Present** for definitions, established knowledge, and interpretations presented as fact.
  *"Beaked redfish is a deep-water species."*
- Tense must never make a study-specific result sound universally established.

### 6. Epistemic calibration

Match the verb to the strength of the evidence:

| Evidence | Verb |
|---|---|
| Direct, robust | show, demonstrate |
| Supported inference | indicate, suggest |
| Plausible but unresolved | may, might, could, likely |
| Testable interpretation | hypothesize, propose |

Never strengthen an association into causation. Never strengthen a source's hedge when citing
it — turning "suggests" into "reported that" is how myths are made. Keep hedging that changes
the interpretation; delete hedging that is empty or repeated.

### 7. Numbers and units

- **Never begin a sentence with a numeral or an abbreviation.** Write "Sixty-six stations…",
  or recast the sentence.
- Integers below 11 as words — *one, ten* — **except** beside a unit: *"eight fish and 8 kg"*.
- Leading zero on decimals below one: *0.05*, not *.05*.
- SI units. Abbreviate only beside a numeral (*5 m*), otherwise spell out (*a few metres*).
  No plural forms, no periods.
- Superscripts, not slashes: `g m⁻²`, not `g/m²`.

### 8. Figures and tables

- **Every figure and table gets a caption, and every one is referred to in the text.**
- **Put the cross-reference at the end of a short descriptive sentence.** Write *"Sampling was
  conducted throughout the year (Table 1)"*. Never *"Table 1 gives details of sampling"*.
- The caption states the **point**, not the topic, and stands alone: it carries sample sizes,
  the meaning of error bars, and every symbol and abbreviation used.
- Never present the same data as both a figure and a table.
- **Long tables belong in the supplement.** Keep a summary in the body and move the full
  listing to supplementary material, or to a collapsed appendix in an HTML report.
- Detail, including what a fitted line asserts:
  [`references/figures-tables.md`](references/figures-tables.md).

### 9. Concision is information density, not brevity

Maximise information per word. A longer sentence carrying more retrievable information beats a
vague short one. Cut filler, repeated mini-conclusions, promotional phrasing, vague nouns
(*factors, aspects, patterns*), and explanations of concepts the audience already has.

Do not leave interpretation to the reader. *"Fish fed diets B and C grew faster than those fed
A and D (Table 1)"*, not *"growth differed among diets (Table 1)"*.

### 10. Cite the software

Base R and every package that influenced the results are cited in narrative prose in Materials
and Methods, in the same section as the AI disclosure. Get the citation from
`citation("pkg")` — never write one from memory — and put the resulting entries in the
bibliography. Report versions with inline code, not typed numbers. Never dump formatted
`citation()` output into the body as a replacement for citations and a reference list.

## Depth

Load one of these only when the task needs it.

| File | When |
|---|---|
| [`references/imrad.md`](references/imrad.md) | Structuring a document: title, keywords, abstract, and each IMRaD section |
| [`references/sentences.md`](references/sentences.md) | Sentence-level revision, voice, word choice, grammar policy |
| [`references/distinctions.md`](references/distinctions.md) | Terms that must not be blurred |
| [`references/citations.md`](references/citations.md) | Citing and building a reference list |
| [`references/figures-tables.md`](references/figures-tables.md) | Designing or captioning a float |
| [`references/ecology-fisheries.md`](references/ecology-fisheries.md) | Species names, stocks, surveys, field conventions |
| [`references/ai-disclosure.md`](references/ai-disclosure.md) | Writing or updating the AI-use statement |
| [`references/checklists.md`](references/checklists.md) | Reviewing a draft before submission |

## Done

Report what you changed, what you could not verify, and which scientific decisions remain with
the author. Never claim a document is ready for submission — that is the author's call.
