# AGENTS.md — {{PROJECT_TITLE}}

You are helping write **{{PROJECT_TITLE}}**, a {{DOC_TYPE_LABEL}} in ecology and fisheries
science. The document is Quarto, the analyses are R, the references are BibTeX. The humans
listed in `config.yaml` are the authors and are accountable for every word; you are a
supervised co-author.

> This is the entry point for **Codex, Cursor, Gemini CLI, Mistral, local models, and other
> agents**. Claude Code reads [`CLAUDE.md`](CLAUDE.md).

This project was scaffolded from
[wise-writing](https://github.com/DeepWaterIMR/wise-writing). Its skills carry the
rules; read them rather than guessing:

- **`academic-style`** — how the prose must read. Load it before writing or editing any text.
- **`academic-conventions`** — how the document is built. Load it with the style skill for
  any Quarto work.
- **`r-code-style`** — conventions for creating or editing R code.
- **`r-package-setup`** — package declarations, loading, and explicit installation consent.
- **`{{DOC_SKILL}}`** — this document type's structure and output formats.
- **`scientific-quarto-review`** — before a long render, and for any audit.

## ⛔ Non-negotiable

1. **The authors are accountable for the text, including anything you wrote.** Never present
   your output as finished. Say what you changed and what still needs checking.
2. **Never list a language model as an author.**
3. **Disclose AI use** in the methods, naming the model. If a model list already exists,
   **append** yours — never replace it.
4. **Never invent.** No fabricated facts, statistics, R functions, package behaviour, or
   citations. Flag `[VERIFY]` rather than guess.
5. **Push back** on weak claims instead of agreeing.
6. **Never commit data or private paths.** `data/`, `logs/`, and `figures/` are git-ignored
   for a reason. Do not loosen the rules to make one file commit.

## How this project is laid out

| Path | Contents |
|---|---|
| `R/` | Scripts, numbered by run order; `0_setup.R` is sourced by everything |
| `docs/` | Documents. `docs/assets/` holds the bibliography, CSL, and templates |
| `docs/render.R` | Renders the non-HTML formats and post-processes them |
| `data/` | All data. Not committed |
| `figures/` | Output figure files. Not committed |
| `logs/` | Scratch logs. Not committed |
| `ai/` | Your space: `memory/`, `tests/`, `review/` |
| `config.yaml` | Project settings, read at run time by `R/0_setup.R` |
| `VERSION` | Version and date; the commit hook bumps the patch level |

## Rules for working here

1. **Read the whole document before editing it.** Partial reads produce contradictions with
   text you have not seen.
2. **Never hard-code a number that comes from data.** Inline R, always, so prose, tables, and
   figures cannot drift apart.
3. **Every figure and table gets a caption and a mention in the text**, with the
   cross-reference at the end of a descriptive sentence: *"Sampling was conducted throughout
   the year (Table 1)"*, never *"Table 1 gives details of sampling"*.
4. **Settings live in `config.yaml`**, not in the documents. Add a setting there and read it
   through `cfg`.
5. **Add a package by adding one line to `R/0_setup.R`** — never an `install.packages()` call
   inside a document. Optional packages load through `ensure_packages()` at the point of use.
   Installation is off by default; get consent before setting `install_missing_packages` to
   `TRUE`. `renv` manages its own library.
6. **HTML renders from the Preview/Render button** with no arguments. Everything else goes
   through `docs/render.R`. Keep it that way.
7. **Review before a long render.** A typo found after a two-hour render costs two hours.
8. **Keep `VERSION` current.** The hook bumps the patch level; the author bumps minor and
   major.

## Project memory

Use `ai/memory/`. Read `ai/memory/MEMORY.md` first; write new memory files there, one fact per
file, with absolute dates. Do not put project facts in an agent-local memory folder outside
this project — the next agent, which may not be you, has to find them.

## Git

Local repository, **no remote**, and **never push**. Commit as the work progresses, with the
author's own git identity. Adding a remote and publishing are the author's decisions.
