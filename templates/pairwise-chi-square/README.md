# Pairwise Chi-Square

This standard RMarkdown example runs pairwise association tests for
categorical person attributes. It renders
[pairwise_chisq.html](pairwise_chisq.html).

## Inputs and prerequisites

The example uses package-provided data. A real adaptation needs one
appropriately eligible and de-duplicated row per person plus categorical
attributes. Install `vivainsights`, `dplyr`, `purrr` and `rmarkdown`.

## Safe scope and privacy

Tests describe associations in the supplied sample; they do not establish
causation. Validate population coverage, cell sizes, multiple-testing
decisions and disclosure protections before adapting to real data.

## Render

From this directory:

```r
rmarkdown::render("pairwise_chisq.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`.
