---
name: r-code-style
description: Standardize or review R code in scripts and Quarto documents while preserving behavior. Use for R style, tidyverse conventions, function documentation, formatting, or focused R checks; not for package installation policy.
metadata:
  version: "0.1.0"
license: MIT
---

# R code style

Use this skill when creating or editing R code. Apply the conventions to new or touched code;
do not reformat unrelated files just to make a repository uniform.

- Use tidyverse verbs for data manipulation. Use the native pipe `|>` in new code; preserve a
  surrounding project's established pipe when editing an existing pipeline.
- Give reusable functions clear names, explicit arguments, useful return values, and Roxygen2
  documentation. Keep script order visible with numeric prefixes; leave function libraries
  unnumbered.
- Format with Air when the project already has `air.toml` or its instructions request Air. Use
  the repository's configured formatter and scope formatting to changed files. Do not install
  a formatter or alter its configuration without the user's authorization.
- Keep comments focused on intent, assumptions, and non-obvious behavior. Avoid comments that
  merely restate the next line.
- Preserve APIs, types, missing-value behavior, units, ordering, and scientific meaning while
  formatting or refactoring. Flag an ambiguous behavioral change instead of silently choosing.
- Run focused checks: parse changed R files, validate any affected Quarto code chunks, and run
  relevant project tests. Render only when the document or output change warrants it.

For Quarto structure, package policy, and reproducible project layout, also read
[`academic-conventions`](../academic-conventions/SKILL.md). For package setup, use
[`r-package-setup`](../r-package-setup/SKILL.md).
