# Examples

## `config.yaml`

A filled-in project configuration. Copy it, edit the identity and author fields, and pass it
to `scaffold_document()`:

```r
source("<wise-writing>/scaffold.R")
scaffold_document("config.yaml", "../my-paper", types = "manuscript")
```

`types` takes any of `manuscript`, `data-report`, `cruise-report`, `assessment-report`,
`advice-sheet`, `benchmark-report`, or several at once:

```r
scaffold_document("config.yaml", "../survey-2027",
                  types = c("cruise-report", "data-report"))
```

The scaffold copies the project skeleton, keeps only the document types you asked for, copies
each type's assets into `docs/assets/`, and stamps the author block and the identity fields
from the config. Everything else — figure widths, the citation style, paths — is read at run
time by `R/0_setup.R`, so it can be changed later by editing `config.yaml` rather than the
documents.

Then, in the new project:

```bash
git init
quarto render docs/manuscript/manuscript.qmd   # or the Preview/Render button
```

Word and PDF go through `Rscript docs/render.R`.
