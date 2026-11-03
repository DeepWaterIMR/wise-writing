# Rendering

## HTML — the preview format

```bash
quarto render docs/manuscript/manuscript.qmd
```

or the editor's **Preview** button in Positron, **Render** in RStudio. This has to work with
no arguments and no helper script, which is why `html` comes first in the `format:` block. If
it does not, that is a bug in the document, not something for the user to work around.

## Everything else — `docs/render.R`

Word and PDF need post-processing, so they go through the script:

```bash
Rscript docs/render.R                       # every configured format
Rscript docs/render.R manuscript docx       # one document, one format
```

`render.R` finds the project root by walking up for a sentinel file, renders each requested
format, runs the Word post-processing, and reports where the outputs went. Source it from the
editor if you prefer a button; it works either way.

### Why the render is judged by its output

Quarto deletes its intermediate `_files` folder after each render. On a network share or a
synced folder that delete can fail even though the document itself was written correctly, and
the error would otherwise abort the whole build. `render.R` therefore checks whether an
up-to-date output file exists and only treats the render as failed when it does not, cleaning
up the leftover folder itself.

## Word post-processing

**Quarto wraps every cross-referenced figure and table in a one-cell table.** Word accepts the
nesting, but the result shows a dashed table outline and a move handle around each figure, and
LibreOffice may linearise the cells. `R/docx_postprocess.R` unwraps them.

```r
source("R/docx_postprocess.R")
unwrap_float_tables("docs/manuscript/manuscript.docx")
```

It unzips the `.docx`, edits `word/document.xml` with **xml2**, and rezips with
`zip::zipr(mode = "mirror")`. The two things it looks for are a body-level `w:tbl` containing
another `w:tbl` (a wrapped table) and a one-row, one-cell `w:tbl` containing a drawing and a
paragraph starting "Figure" (a wrapped figure). In both cases the cell's children move into
the document body and the wrapper is removed, keeping the caption and its bookmark.

Optional extras, off unless the document asks for them:

- restore body-anchored cover artwork from the reference template, which Pandoc drops;
- promote an inline logo to an anchored one with explicit positioning;
- insert a landscape section for a wide table;
- synthesise a `w:tblGrid` for tables that lack one, and mirror the widths into `w:tcW` with a
  fixed layout;
- unwrap `w:hyperlink` elements, which LibreOffice renders with a trailing character;
- set `numId=0` on headings that must escape the template's automatic numbering.

Always validate after editing: re-read the zipped XML and assert that what you expected to
survive is still there. A `.docx` that fails to open gives no useful error.

## PDF

`xelatex` is the engine, because the templates use system fonts. A PDF build needs a working
TeX installation — TinyTeX is enough:

```r
quarto::quarto_install_tinytex()
```

or `quarto install tinytex` at the shell. Where a template supplies
`include-in-header:` and `include-after-body:` partials, keep them in `docs/assets/`.

## Long renders

An analysis document can take minutes to hours. For those:

- Run the render detached — a `screen` or `tmux` session, or a background job — with the log
  in `logs/`, and tell the user the session name.
- **Review the code before starting**, not after. Invoke
  [`../../scientific-quarto-review/SKILL.md`](../../scientific-quarto-review/SKILL.md) or run
  a code review on the changed chunks; a typo found after a two-hour render costs two hours.
- Cache expensive steps behind a flag (`update_data <- FALSE`) that loads a saved object
  instead, and flip it back once the object exists.
- Do not add `freeze:` or `cache:` to work around a slow chunk without telling the user — a
  stale cache produces a document that disagrees with its own data.

## When a render fails

1. Read the actual error, which is usually the last R message before the Pandoc noise.
2. Check that the working directory is what the document assumes. A missing file is far more
   often a root-directory problem than a missing file.
3. Check for `@key` citations with no bibliography entry — they render literally rather than
   erroring.
4. Check that every `#| label:` is unique. Duplicates break cross-references silently.
5. Render one format at a time to find which one fails.
6. Treat every warning as unresolved until you have classified it.

## Silent rendering traps

These render without an error and leave a wrong document:

- **One labelled output per chunk.** A chunk that emits both a figure and a table gets no
  `fig-` identifier, so `@fig-...` stays unresolved. Split it into a data chunk, a figure chunk
  and a table chunk.
- **`<U+2014>`-style escapes** in captions, `cat()` output or table headers mean the R session
  ran without a UTF-8 locale, typical of a detached or server render. Set `LANG` and `LC_ALL` to
  a UTF-8 locale in the render wrapper; until then keep em dashes and non-ASCII letters out of
  `#| fig-cap:`, `#| tbl-cap:` and `cat()` strings (body prose is unaffected).
- **Quote a `!expr` caption that contains a colon**, or YAML parses the chunk option wrongly.
- **Tables describing a fitted model read from the fitted object**, not from the config or the
  formula variable, so a render that loads a cached fit still reports the model it shows.
- **A successful render says nothing about legibility.** Look at the figures: extract the
  embedded base64 images from a self-contained HTML (or open the PNGs) and check that maps,
  legends and small multiples are readable at the rendered size.

## Long renders and cache provenance

Review changed analysis code before an expensive render using available review tools or
a careful independent pass. A named agent command is optional. Launch the render in a
background process that survives the agent call, from the project root, with a unique log
and an exit-status record. Use the host's background-job facility, or screen/tmux on Unix,
or PowerShell Start-Process on Windows. Create the logs directory first; report the job
identifier, log and output path. Confirm process completion and inspect the output rather
than inferring success from the presence of an old file.

Keep model-specific flags in the method pack. Cache reuse needs matching data, relevant
configuration, model code and package versions. Record their hashes/versions beside cached
results; if no record exists, treat validity as unknown and rebuild the affected stage.
Invalidate dependent diagnostics when their fit changes. Preserve unrelated outputs and
prior results rather than deleting an entire output directory. Respect project renv locks;
an ecosystem update does not authorize changing a reproducible project's environment.
