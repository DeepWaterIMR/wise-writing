# Advice-sheet tables

Advice-sheet tables are not ordinary tables. They carry real subscripts, merged group rows, and
footnotes, and Word **clips** a table wider than the text column rather than reflowing it.
Build them with flextable and fit them explicitly.

Set the defaults once, in the setup chunk, and size figures to the column for Word:

```r
flextable::set_flextable_defaults(
  font.family = "Calibri", font.size = 9, table.layout = "fixed",
  border.color = "black", big.mark = " ", decimal.mark = ".", padding = 2
)
if (identical(knitr::opts_knit$get("rmarkdown.pandoc.to"), "docx")) {
  knitr::opts_chunk$set(out.width = "6.3in")
}
```

**The house style**, applied as the last step before any column-specific alignment or width:

```r
ices_ft <- function(ft) {
  ft |>
    flextable::bg(bg = "#E8EAEA", part = "header") |>
    flextable::border_inner(officer::fp_border(color = "black", width = 0.5)) |>
    flextable::border_outer(officer::fp_border(color = "black", width = 0.75)) |>
    flextable::font(fontname = "Calibri", part = "all") |>
    flextable::fontsize(size = 9, part = "all") |>
    flextable::align(align = "center", part = "header") |>
    flextable::padding(padding = 2, part = "all") |>
    flextable::autofit() |>
    fit_ft_page()
}
```

**Fit to the page**, scaling the chosen relative widths so their total is the text column:

```r
fit_ft_page <- function(ft, max_width = 6.7) {
  w <- ft$body$colwidths
  ft <- flextable::width(ft, j = seq_along(w), width = w * max_width / sum(w))
  flextable::set_table_properties(ft, layout = "fixed", width = 1)
}
```

**Reference points need real subscripts.** flextable does not read markdown inside a cell, so
`B~MSY~` has to be composed:

```r
flextable::compose(
  ft, i = 1, j = "Reference point",
  value = flextable::as_paragraph("MSY B", flextable::as_sub("trigger"))
)
```

Doing this by hand for every cell is where advice sheets acquire inconsistencies. Wrap it in a
helper and call the helper.

**The item/description blocks** — *Basis of the advice*, *Basis of the assessment*, the
management-plan block — are all the same shape: no header row, a bold shaded label column, and
a wide description column. `flextable::delete_part(part = "header")` is what removes the header.

**The catch-scenario table is grouped.** An *Advice basis* row, the advice-rule scenario, an
*Other scenarios* row, then the rest. The group rows are merged across the table, bold, and
shaded; the percentage columns are the change in biomass and the change from the previous
advice. When there was no previous advice, that column is a dash with a footnote saying why —
never a zero, which reads as "no change".

## The annual-update trap

The advice-history table carries one row per year with the text of that year's advice. **That
text cannot be derived** — it is a historical record — so it is hard-coded, and when the
assessment year advances past its last entry the column lengths stop matching.

Key it by year rather than holding it in a bare vector:

```r
advice_history <- list(
  "2024" = list(advice = "MSY approach", advised_catch = 4200, tac = 4000),
  "2025" = list(advice = "MSY approach", advised_catch = 3900, tac = 3900)
)
```

A missing year then fails loudly instead of silently shifting every row by one. **Extend the
list. Never pad, recycle, or shorten the year range to make the lengths match.**


[spict-wise](https://github.com/DeepWaterIMR/spict-wise)'s `R/advice_tables.R` is a
worked implementation of everything above.
