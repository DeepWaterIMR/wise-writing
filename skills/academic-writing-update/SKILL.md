---
name: academic-writing-update
description: Update wise-writing to the latest version — git pull the repository and re-sync its skills into the machine's global skills folders. Use when the user says "update wise-writing", "pull the latest wise-writing", or asks for newer writing skills or document templates.
metadata:
  version: "0.1.0"
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

```bash
cp -R "<path>/skills/." ~/.claude/skills/
cp -R "<path>/skills/." ~/.agents/skills/
```

```powershell
Copy-Item -Recurse -Force "<path>/skills/*" "$HOME/.claude/skills/"
Copy-Item -Recurse -Force "<path>/skills/*" "$HOME/.agents/skills/"
```

Sync only the locations listed in `skills_synced_to`, plus any agent installed since. For Codex,
use `~/.agents/skills/`.

**Touch only this pack's skills** — the `academic-*` folders and `scientific-quarto-review`.
Leave BAIT's `biotic-*` and index-wise's `index-*` skills alone.

**Remove a skill that no longer exists upstream.** A copy makes new files appear but never
removes deleted ones, so compare the folder lists and delete the stragglers from the synced
locations.

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
