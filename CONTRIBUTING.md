# Contributing to wise-writing

Thanks for helping. This repo is a **knowledge pack**: it contains instructions, templates,
and document assets, and it contains **no data**.

## Before you open a pull request

Run the validator:

```bash
Rscript config/validate-skills.R
```

It checks that every `SKILL.md` parses, that its frontmatter carries `name`, `description`,
`metadata.version`, and `license`, that `name` matches the folder name, that every relative
link resolves, and that no private path or personal identifier has crept in.

Also confirm the privacy grep is clean:

```bash
grep -rIn -e '/Users/' -e 'OneDrive' -e 'CloudStorage' -e 'C:\\Users' .
```

## Conventions

- **One skill per folder**, `skills/<name>/SKILL.md`, kebab-case, prefixed `academic-`.
  `name` in the frontmatter equals the folder name.
- **Keep `SKILL.md` short** — roughly 150 lines. It is read in full, often by a model with a
  small context window. Anything longer belongs in `references/<topic>.md`, linked from the
  skill and loaded on demand.
- **Bump `metadata.version`** in the frontmatter when you change a skill's behaviour, so
  `academic-writing-update` can tell users what moved.
- **Markdown prose is hard-wrapped at ~95 columns.** Prose in `.qmd` and `.Rmd` is never
  hard-wrapped — those are edited in soft-wrapping editors.
- **Links between skills are relative**: `../academic-style/SKILL.md`. Links into a skill's
  own material are relative too: `references/imrad.md`.
- **Assets** (CSL styles, Word reference documents, LaTeX partials, Lua filters) go in
  `skills/<name>/assets/`. The root `.gitignore` blocks binary formats everywhere else, so
  keep them there.
- **Keep `AGENTS.md` and `CLAUDE.md` consistent.** `AGENTS.md` is the full contract;
  `CLAUDE.md` is a thin pointer that adds only Claude-specific notes. Substantive guidance
  goes in `AGENTS.md`.

## Version stamping

The repo stamps `VERSION` and the README version line on every commit. Enable the hook once
per clone:

```bash
git config core.hooksPath .githooks
```

The patch level bumps automatically. To bump the minor or major level, edit `VERSION` by hand
before committing — the hook keeps a hand-set version and only refreshes the date.

## Scope

This pack owns **style, document structure, and reproducible-document conventions**. It does
not own data access or statistical modelling. If your change is about IMR Biotic data, it
belongs in [BAIT](https://github.com/DeepWaterIMR/BAIT); if it is about sdmTMB survey indices,
it belongs in [index-wise](https://github.com/DeepWaterIMR/index-wise).
