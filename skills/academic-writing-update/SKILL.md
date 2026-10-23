---
name: academic-writing-update
description: Update wise-writing to the latest version — git pull the repository and re-sync its skills into the machine's global skills folders. Use when the user says "update wise-writing", "pull the latest wise-writing", or asks for newer writing skills or document templates.
metadata:
  version: "0.2.0"
license: MIT
---

# Update wise-writing

## Step 1 — Find the install

Read `academic_writing_path` from `~/.wise-writing/config.json` first. If it is missing or
invalid, check the legacy `~/.academic-writing/config.json`; both use the compatible
`academic_writing_path` key. If neither path resolves, run
[`../academic-writing-install/SKILL.md`](../academic-writing-install/SKILL.md) instead.

Note the current version before pulling, so you can say what changed:

```bash
cat "<path>/VERSION"
```

## Step 2 — Pull

```bash
git -C "<path>" status --short --branch
git -C "<path>" pull --ff-only
```

If the working tree is dirty, **stop and show the user what is uncommitted.** A local edit to
a skill is usually deliberate. Offer to stash it, commit it, or abandon the update — do not
discard it.

If the pull is not a fast-forward, the local branch has diverged. Report that and let the user
decide; do not rebase or merge on their behalf.

## Step 3 — Re-sync the skills

Sync only the locations listed in `skills_synced_to`, plus any agent installed since. For Codex,
use `~/.agents/skills/`. Reconcile this pack's skill folders individually: keep a destination
symlink when it resolves to the matching source skill, and skip any source and destination that
resolve to the same path. Before replacing a differing directory or link, move that entry to a
timestamped backup. Never copy the pack tree onto itself or delete a skills root.

**Touch only skill IDs owned by this repository**: the folders currently under `<path>/skills/`
and obsolete wise-writing skill IDs. That includes the shared `r-code-style`,
`r-package-setup`, and `quarto-reporting` skills now maintained here. Leave BAIT's `biotic-*`
and index-wise's `index-*` skills alone. A BAIT folder marked `metadata.forwarding: true` is
only a compatibility pointer, not a second canonical implementation.

Compare this pack's skill names with each synced location. Remove only obsolete entries owned
by this pack, backing up a differing directory or link first. Leave unrelated skills alone.

## Step 4 — Re-assert the hook

```bash
git -C "<path>" config core.hooksPath .githooks
```

## Step 5 — Report what changed

```bash
cat "<path>/VERSION"
git -C "<path>" log --oneline <old-version-commit>..HEAD
```

Say which version the pack moved from and to, and which skills changed — each `SKILL.md`
carries `metadata.version` in its frontmatter, so a diff of those lines is the useful summary.
Mention any skill that was added or removed.

## Step 6 — Update scaffolded projects, if asked

Updating the pack does **not** change a project that was already scaffolded — the skeleton was
copied, not linked, which is what makes a project self-contained and reproducible.

If the user wants an existing project brought up to date, do it by hand and one file at a
time: show the diff between the project's file and the current template, and let them choose.
Never overwrite a project file with a template.

## Done

Report the old and new versions, the skills that changed, and anything the user has to decide.
