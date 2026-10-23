---
name: academic-writing-install
description: Install or set up wise-writing on this machine. Use when the user says "install wise-writing", "install https://github.com/DeepWaterIMR/wise-writing", "set up wise-writing", or first asks to write an academic document and the pack is not installed. Clones the repo, installs the skills globally for every agent on the machine, and verifies the toolchain.
metadata:
  version: "0.1.0"
license: MIT
---

# Install wise-writing

Goal: get wise-writing working **once per machine** so it is available in **every**
project — not copied into each repository. Work through the steps in order.

> Trigger: the user prompts *"install https://github.com/DeepWaterIMR/wise-writing"*, or
> asks to write an academic document and the pack is not there.

There is no privacy gate: this pack holds instructions and templates, never data. If the
project also needs IMR Biotic data, install [BAIT](https://github.com/DeepWaterIMR/BAIT),
which does have one.

## Step 1 — Locate or clone

1. **Look for an existing install before cloning.**
   - Read `~/.wise-writing/config.json` first and use its `academic_writing_path`. For
     migration, also check `~/.academic-writing/config.json`; both files use the compatible
     `academic_writing_path` key. Prefer the new file when both exist.
   - A directory containing `AGENTS.md`, `CLAUDE.md`, and
     `skills/academic-writing-install/SKILL.md` is a valid install. Reuse it.
   - Otherwise search the likely places — the home directory, a projects or code folder, any
     path the user has mentioned.
   - If you cloned a second copy during this attempt before finding the configured one, remove
     the duplicate once you have checked it has no uncommitted changes.
2. **If found, reuse it.** Report `git -C "<path>" status --short --branch`, then continue
   from Step 2.
3. **If not found, ask where to clone.** Suggest the user's usual code folder, or
   `~/Documents/wise-writing`.
4. **🔒 Never install at a filesystem root or a system directory.** Refuse `/`, a bare drive
   letter such as `C:\`, `/usr`, `/opt`, `C:\Windows`, `C:\Program Files`. Some users drop
   repositories straight into `C:\`; do not allow it. Propose a location under the home
   directory and explain that it is a permissions and security problem, not a preference.
5. **Clone:**

   ```bash
   git clone https://github.com/DeepWaterIMR/wise-writing "<chosen-path>"
   git -C "<chosen-path>" config core.hooksPath .githooks
   ```

   The second line enables the version-stamping hook, so a user who contributes back gets the
   version bump for free. It is harmless for everyone else.

   If `git` is not installed, run
   [`../academic-toolchain-setup/SKILL.md`](../academic-toolchain-setup/SKILL.md) first.

## Step 2 — Install the skills globally

Copy the skill folders into every user-level skills directory the machine's agents use:

```bash
mkdir -p ~/.claude/skills ~/.agents/skills
cp -R "<path>/skills/." ~/.claude/skills/
cp -R "<path>/skills/." ~/.agents/skills/
```

```powershell
New-Item -ItemType Directory -Force "$HOME/.claude/skills", "$HOME/.agents/skills" | Out-Null
Copy-Item -Recurse -Force "<path>/skills/*" "$HOME/.claude/skills/"
Copy-Item -Recurse -Force "<path>/skills/*" "$HOME/.agents/skills/"
```

Claude Code reads `~/.claude/skills/`; Codex and other supported agents use
`~/.agents/skills/`. Sync only the locations whose agents are installed.

For a project-scoped install, or an agent that reads neither, copy into `.agents/skills/`
inside the project, or point that agent's instructions at `<path>/skills/`.

Each skill carries its own `references/` and `assets/`, so a plain recursive copy is complete.
There is **no shared `knowledge/` directory and nothing to symlink** — deliberately, because
`~/.claude/knowledge` is a single global slot that BAIT already owns.

**Copy only this pack's skills.** Leave BAIT's `biotic-*` and index-wise's `index-*`
skills alone.

## Step 3 — Record the install

Write or merge `~/.wise-writing/config.json`. Existing installs in
`~/.academic-writing/config.json` remain readable during migration; preserve the compatible key:

```json
{
  "academic_writing_path": "<chosen-path>",
  "skills_synced_to": ["~/.claude/skills", "~/.agents/skills"],
  "installed_at": "<YYYY-MM-DD>"
}
```

`scaffold.R` reads this file to find the project template, so a project can be scaffolded from
anywhere on the machine.

## Step 4 — Verify the toolchain

```bash
git --version
R --version
quarto --version
```

Anything missing goes to
[`../academic-toolchain-setup/SKILL.md`](../academic-toolchain-setup/SKILL.md). A LaTeX
distribution is needed only for PDF output.

Then confirm the pack itself works, from the clone:

```r
source("<path>/scaffold.R")
scaffold_document("<path>/examples/config.yaml", tempfile("aw-check"), types = "manuscript")
```

It should report that it stamped the tokens and left no placeholders.

## Step 5 — Report

Tell the user:

- where the pack is installed, and its version from `<path>/VERSION`;
- which skills are now available, and which skills folders they were synced to;
- what the toolchain check found;
- how to start: *"Let's write a manuscript about … using wise-writing"*, or
  `/academic-manuscript`.

## Done

If anything failed, say which step and what the user has to do — an installer needing
administrator rights, a `PATH` that needs a new terminal, or a decision about where to clone.
