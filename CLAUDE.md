@AGENTS.md

# Claude Code notes

- **Skills** live in `~/.claude/skills/` as `academic-*`, `r-code-style`, `r-package-setup`,
  `quarto-reporting` and `scientific-quarto-review`. `academic-style` and
  `academic-conventions` load together for Quarto work.
- **Plan mode**: agree the document's structure and argument before writing prose.
- **Code review before render**: run `/code-review` on changed chunks, or
  `scientific-quarto-review`, before a long render.
- **Do not push.** Commit locally with the user's git identity; remotes and pushing are the
  user's decisions.
