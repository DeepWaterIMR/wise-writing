# Formal Word and PDF reports

Use this mode for fixed-layout reports intended for submission, circulation, printing, or
an organisation's document system. Word and PDF are separate render targets; validate each
one rather than assuming that a correct source produces identical layouts.

## Word template selection

When Word output is requested:

1. If the user supplied a `.docx` or `.dotx` reference document, inspect it and use it as
   the design authority through Quarto's `reference-doc` option.
2. If the user explicitly requests an IMR web report, `nettrapport`, or the bundled IMR
   design, follow [`imr-nettrapport.md`](imr-nettrapport.md). Do not apply that design to
   unrelated reports merely because BAIT is being used.
3. Otherwise, if no template was supplied, ask once whether the user wants to provide an
   MS Word template. Continue without delay if they decline or do not have one.
4. With no user template, use Microsoft Word's generic **Manuscript** design when it is
   installed. Locate `Manuscript.dotx` within the local Microsoft Word or Office
   installation. On macOS its usual path is
   `/Applications/Microsoft Word.app/Contents/Resources/QuickStyles/Manuscript.dotx`.
   Search rather than assuming a path on other platforms.
5. Build a complete local reference document with:

   ```sh
   python scripts/build_manuscript_reference.py \
     --manuscript path/to/Manuscript.dotx \
     --out path/to/manuscript-reference.docx
   ```

   Use the generated `.docx` as `reference-doc`. Do not pass the style-set `.dotx`
   directly: it lacks some Pandoc-specific styles used for tables, captions, and code.
   Treat the generated reference document as local unless its licence permits
   redistribution.
6. If neither a user template nor the installed Manuscript design is available, build a
   plain A4 reference document from Pandoc's default with
   `Rscript scripts/make_word_reference.R path/to/word-reference.docx [margin_cm]`. It adds a
   booktabs-like `Table` style (rules above and below the table and below the header row,
   9 pt text, no paragraph spacing) and an A4 page size, which Pandoc's default lacks, so
   Word would otherwise fall back to US Letter. Tell the user that the Manuscript design
   could not be applied. Do not claim template fidelity that was not verified. `*.docx` is
   often gitignored: commit the reference document with `git add -f`.

Do not copy proprietary or organisation-specific templates into a skill or repository
unless the owner explicitly authorises inclusion. A reference document controls
styles, theme, page properties, and some document parts; its body is not a reusable report
body. Exact covers, closing pages, headers, automatic numbering, or other organisation
features may require a small project-specific postprocessor after Quarto renders. Keep such
logic outside this generic skill and verify it against the supplied template.

## Quarto configuration

Specify only the formats requested. A typical multi-format declaration is:

```yaml
format:
  docx:
    reference-doc: path/to/reference.docx
    columns: 10000 # see "Word layout fixes"
    fig-dpi: 300
  pdf:
    pdf-engine: xelatex
    documentclass: article
    papersize: a4
    number-sections: true
```

Keep bibliography, CSL, PDF header/footer files, images, and reference documents in
documented project locations. Use Pandoc markup rather than fragile Unicode typography
when the same text must render in both Word and PDF.

Keep slow or network-dependent data refreshes in a separate script with an explicit
toggle. The normal compiler should render from validated local snapshots, allow the user
to select formats, and fail clearly rather than silently producing a partly refreshed
report.

## Word layout fixes

Quarto's Word output has layout defects that the reference document cannot fix:

- **Squashed table columns.** Pandoc gives a pipe table fixed relative column widths whenever
  a row is longer than `--columns` (72 characters by default), so a table with long cells gets
  one-character label columns. Set `columns: 10000` in the `docx` format.
- **Dashed frames around figures and tables.** Quarto's Word writer puts every
  cross-referenced figure and table, with its caption, inside a borderless one-cell layout
  table, and Word draws its gridlines dashed. A Lua filter cannot remove it, even at
  `post-quarto`, because the writer creates it after the filters run. Post-process
  `word/document.xml` instead: [`scripts/docx_tidy.R`](../scripts/docx_tidy.R) moves the
  content out of each outermost one-cell table that holds an image or a table and deletes
  the layout table. Captions, bookmarks and cross-references are kept.
- **Column widths.** The same script sets `gridCol` and `tcW` widths from the cell text: the
  longest cell (capped at 30 characters) and never narrower than the longest word. A table
  wider than the text width of its section, read from the following `w:sectPr` so portrait
  and landscape sections both work, shrinks only the width above the longest word, down to
  about 12 characters so long code strings can break.
- **Landscape sections.** `::: landscape` writes an empty `sectPr` for the portrait section
  before it, so that section falls back to US Letter. Write explicit section breaks instead,
  next to any `{=latex}` landscape blocks; HTML and PDF ignore them. Before the landscape
  content, end the portrait section:

  ````markdown
  ```{=openxml}
  <w:p><w:pPr><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1247" w:right="1247" w:bottom="1247" w:left="1247" w:header="708" w:footer="708" w:gutter="0"/></w:sectPr></w:pPr></w:p>
  ```
  ````

  After it, end the landscape section with the same paragraph using
  `<w:pgSz w:w="16838" w:h="11906" w:orient="landscape"/>`. Match `pgMar` to the reference
  document (1247 twips = 2.2 cm).
- **Render wrapper.** Render Word through
  `Rscript scripts/render_word.R <document.qmd> <output.docx> [quarto args]`, which runs
  `quarto render --to docx` and then `docx_tidy()`, and refuses an output file older than the
  render. Copy the scripts into the project (for example `R/`) and tell users not to run
  plain `quarto render --to docx`.
- **QA caveat.** LibreOffice's docx-to-PDF conversion can show PNG figures as blank even in
  unprocessed Quarto output while the images are intact. Check figures in Word before treating
  them as broken.

## Validation

For every requested format:

1. Confirm that the output exists, is non-empty, and is newer than the render start time.
2. Inspect all pages, not only the first page. Check typography, headings and numbering,
   cross-references, citations, figures, table widths, page breaks, margins, headers,
   footers, and missing glyphs.
3. Render Word output to page images or PDF for visual QA. If a supplied template controls
   the design, compare the output with it and check any expected cover or closing pages.
4. Inspect the PDF independently, including the table of contents, links, fonts, equations,
   and final page.
5. Re-render after any template or OOXML post-processing. Treat visual inspection as the
   final shipping gate.

Network filesystems can report a cleanup error after writing a valid output. Classify the
error by checking the expected output's existence, size, and modification time; do not
ignore a failed render merely because an older output file exists.
