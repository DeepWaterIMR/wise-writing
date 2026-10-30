---
name: academic-toolchain-setup
description: Detect and install the tools an academic writing project needs — Git, R, Quarto, a LaTeX distribution, and the compiler toolchain (Rtools on Windows, Xcode command line tools on macOS). Use when a render or a git command fails because something is not installed, when the user says "install Git" or "install Quarto", or before scaffolding a project on a fresh machine.
metadata:
  version: "0.1.0"
license: MIT
---

<!-- pack-resources:start -->
**Pack resources:** the `wise-writing` root is `~/.wise-writing/config.json` → `academic_writing_path`, else `~/.fiskwise/config.json` →
`components.wise-writing.path`, else the checkout containing this skill. Paths such as `knowledge/`
and `project-template/` are relative to that root, never `../../` from a skills folder; resolve
links that leave this skill's folder against the source skill there. Use absolute paths.
<!-- pack-resources:end -->


# Toolchain setup

Get a machine ready to write and render. **Most users of this pack are on Windows**, so
Windows comes first in every section; macOS and Linux follow.

> Never install anything without saying what you are about to install and getting a yes. An
> installer that needs administrator rights is the user's to run, not yours.

## Step 1 — Find out what is missing

```bash
git --version
R --version
quarto --version
```

On Windows PowerShell the same three commands work; if one reports that the command is not
recognised, that tool is missing or not on `PATH`.

From inside R:

```r
Sys.which("git")
Sys.which("quarto")
tinytex::is_tinytex()          # if tinytex is installed
pkgbuild::has_build_tools()    # Rtools on Windows, CLT on macOS
```

Report what is present and what is not before installing anything. Often only one piece is
missing, and a full walkthrough would waste the user's time.

## Step 2 — Git

Needed for version control in every project. It is not installed by default on Windows.

**Windows**

1. Download **Git for Windows** from <https://git-scm.com/download/win>. Run the installer.
2. Accept the defaults, with two choices worth making deliberately:
   - editor: whatever the user actually uses, not Vim;
   - line endings: **"Checkout Windows-style, commit Unix-style"** (the default).
3. Close and reopen the terminal, then check `git --version`.

If the user has `winget`, this is one command and no dialogs:

```powershell
winget install --id Git.Git -e
```

**macOS**

```bash
git --version
```

runs the command line tools installer on first use, or:

```bash
xcode-select --install
```

**Linux** — `sudo apt install git`, `sudo dnf install git`, or the distribution's equivalent.

**Then set the identity**, once per machine. Use the user's own name and address; ask if you
do not know them, and never substitute your own:

```bash
git config --global user.name "Their Name"
git config --global user.email "their.address@example.org"
```

Check with `git config --global --list`.

## Step 3 — R

<https://cloud.r-project.org> for every platform. Install the current release unless the
project pins an older one.

Then the compiler toolchain, needed to install packages that build from source:

- **Windows** — **Rtools**, from <https://cran.r-project.org/bin/windows/Rtools/>. The Rtools
  version must match the R version (Rtools44 for R 4.4, and so on). Verify with
  `pkgbuild::has_build_tools()`.
- **macOS** — `xcode-select --install`. Packages needing gfortran also want the CRAN tools
  from <https://mac.r-project.org/tools/>.
- **Linux** — `build-essential` and the `-dev` packages for anything spatial (`libgdal-dev`,
  `libproj-dev`, `libgeos-dev`, `libudunits2-dev`).

Most package installation problems on Windows are a missing or mismatched Rtools. Check that
before anything else.

## Step 4 — Quarto

<https://quarto.org/docs/get-started/>. Positron and recent RStudio bundle a copy, but a
standalone install is more predictable and is what `quarto --version` at a shell will find.

```powershell
winget install --id Posit.Quarto -e
```

```bash
brew install --cask quarto
```

Verify with `quarto check`, which tests the whole chain — Quarto, R, knitr, and LaTeX — and
names what is broken.

## Step 5 — LaTeX, only for PDF output

HTML and Word need no LaTeX. For PDF, TinyTeX is enough and installs without administrator
rights:

```bash
quarto install tinytex
```

or from R:

```r
quarto::quarto_install_tinytex()
```

A full TeX Live or MiKTeX installation also works; do not install one alongside TinyTeX.

The templates in this pack use **xelatex** and system fonts. If a PDF build fails on a missing
font, either install the font or change `mainfont:` in the YAML.

## Step 6 — Editor

Either works, and the pack targets both:

- **Positron** — <https://positron.posit.co>. The **Preview** button renders the document.
- **RStudio** — <https://posit.co/download/rstudio-desktop/>. The **Render** button does.

Both need Quarto and R on `PATH`. Neither is required: `quarto render` at a shell is enough.

## Step 7 — Confirm

```bash
git --version && R --version && quarto --version && quarto check
```

Then render something small. A document that renders is the only proof that matters.

## Done

Report which tools were already present, which you installed, which the user installed
themselves, and anything still outstanding — a pending restart, a `PATH` that needs a new
terminal, or an administrator step they have to take. Then return to whatever asked for the
toolchain.
