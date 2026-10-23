# CLAUDE.md — wise-writing (Claude Code)

This is the **Claude Code** pointer. The full agent contract is in [`AGENTS.md`](AGENTS.md) —
read it. This file only adds Claude-specific notes.

## What this repo is

A **knowledge pack** (like [BAIT](https://github.com/DeepWaterIMR/BAIT)) that teaches an agent
one academic writing style, one set of Quarto/R technical conventions, and six document
templates for ecology and fisheries science. It is installed once per machine; its skills live
in `~/.claude/skills/` as `academic-*` plus `scientific-quarto-review`. It is **public — never
commit data or private paths here.**

## Where things are

- **Skills** — `skills/academic-*/SKILL.md`. Installed globally by
  `skills/academic-writing-install`.
- **Depth** — `skills/<skill>/references/*.md`. Load one only when the task needs it; do not
  read the whole set up front.
- **Assets** — `skills/<skill>/assets/` (CSL styles, Word reference documents, LaTeX partials,
  Lua filters). Copied into a project's `docs/assets/` at scaffold time.
- **Project skeleton** — `project-template/`, copied and stamped by `scaffold.R`.
- **Worked examples** — `examples/`.

## Claude-specific notes

- **Project memory, not user memory.** Inside a scaffolded project, use that project's
  `ai/memory/` folder (read `ai/memory/MEMORY.md` first, write new memory files there). Do
  **not** use `~/.claude/projects/.../memory/` for project facts — that is only for user-level
  preferences and identity.
- **Skills** — when the user types `/academic-...`, or asks to write, revise, review, or start
  any academic document, invoke the matching skill. `academic-style` and
  `academic-conventions` load together for Quarto work.
- **Defer to the sibling packs.** Biotic data access → BAIT's `biotic-*` skills. sdmTMB survey
  indices → index-wise's `index-*` skills. This pack does not duplicate them.
- **Plan mode** — use it to agree the document's structure and argument before writing prose.
  Restructuring a half-written manuscript is expensive; agreeing an outline is cheap.
- **Code review before render** — Quarto renders can be slow. Run `/code-review` on changed
  chunks, or invoke `scientific-quarto-review`, before starting a long render.
- **Do not push.** Commit locally with the user's own git identity; adding a remote and
  pushing are the user's decisions.

For everything else, see [`AGENTS.md`](AGENTS.md).
