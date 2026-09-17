# Information Value

This standard RMarkdown example illustrates information-value calculations for
predictor variables. It renders
[information-value.html](information-value.html).

## Inputs and prerequisites

The document uses `vivainsights` package data. Install `vivainsights`,
`dplyr` and `rmarkdown`.

## Safe scope and limitations

The values and resulting rankings are illustrative only. Before applying the
method to real data, define the outcome and population, validate data quality,
guard against leakage and review privacy and appropriate use.

## Render

From this directory:

```r
rmarkdown::render("information-value.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`.
