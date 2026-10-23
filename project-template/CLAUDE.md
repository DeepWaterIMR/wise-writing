# CLAUDE.md — {{PROJECT_TITLE}} (Claude Code)

This is the **Claude Code** pointer. The full contract is in [`AGENTS.md`](AGENTS.md) — read
it. This file only adds Claude-specific notes.

## What this project is

**{{PROJECT_TITLE}}** — a {{DOC_TYPE_LABEL}} written in Quarto with R, scaffolded from
[wise-writing](https://github.com/DeepWaterIMR/wise-writing). The authors in
`config.yaml` are accountable for the text.

## Skills to load

- **`academic-style`** before writing or editing any prose.
- **`academic-conventions`** alongside it for anything touching a `.qmd`.
- **`{{DOC_SKILL}}`** for this document's structure and output formats.
- **`scientific-quarto-review`** before a long render, and for audits.
- Data access → BAIT's `biotic-*` skills. sdmTMB indices → index-wise's `index-*` skills.
  This project does not reimplement either.

## Claude-specific notes

- **Project memory, not user memory.** Use `ai/memory/` (read `ai/memory/MEMORY.md` first).
  Do **not** use `~/.claude/projects/.../memory/` for facts about this project.
- **Plan mode** — agree the structure and the argument before writing prose. Restructuring a
  half-written document is expensive; agreeing an outline is cheap.
- **`/code-review`** on changed chunks before starting a render.
- **Do not push.** Commit locally with the author's git identity.

For everything else, see [`AGENTS.md`](AGENTS.md).
