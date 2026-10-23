# Migration to wise-writing

The repository is now named `wise-writing` at
[github.com/DeepWaterIMR/wise-writing](https://github.com/DeepWaterIMR/wise-writing), as part
of [Fiskwise](https://github.com/DeepWaterIMR/fiskwise), with its [project hub](https://deepwaterimr.github.io/fiskwise/). Skill IDs and folder names such as
`academic-style` and `academic-writing-install` remain stable.

New installs store configuration in `~/.wise-writing/config.json`. The compatible
`academic_writing_path` key remains unchanged. During migration, the installer and scaffold
also read the former `~/.academic-writing/config.json`; the new config takes precedence when
both are present. Clones named `academic-writing` remain usable when sourced directly or via
the path recorded in config.

The shared `r-package-setup` and `quarto-reporting` skills are now maintained in this
repository, alongside the new `r-code-style` skill. BAIT retains the former two paths as
short forwarding pointers; use the wise-writing-owned implementation rather than syncing a
second copy from BAIT.
