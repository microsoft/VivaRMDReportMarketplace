# Copilot Consumption

This standard RMarkdown report is a synthetic simulation of Copilot credit
consumption and ways of working. It renders
[copilot-consumption-ways-of-working-simulation.html](copilot-consumption-ways-of-working-simulation.html).

## Inputs, data and prerequisites

The report reads only the synthetic CSV fixtures under `_data/consumption` and
sources `consumption-contracts.R` from this directory. The five source
fixtures were imported from the upstream snapshot; the task-type allocation
was locally regenerated from synthetic weekly credits with seed `20260917`.
It reconciles integer-tenth credits exactly by person and complete observation
window. Run `Rscript generate-demo-data.R` from any directory to reproduce the
local task-type allocation. Do not use the generator or reconciliation rule to
repair real feeds.

Install `dplyr`, `tidyr`, `ggplot2`, `scales`, `knitr`, `vivainsights`,
`ggrepel`, `flexdashboard` and `rmarkdown`.

## Safe scope and privacy

All checked-in inputs are demonstrations and contain no customer data or real
identifiers. The simulated task mix and profiles are not evidence about real
people, task mix or behaviour. Real adaptation needs independent schema,
coverage, eligibility, aggregation and privacy review.

## Render

From this directory:

```r
rmarkdown::render("copilot-consumption-ways-of-working-simulation.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. The local allocation,
contracts and fixtures are not attributed to upstream.
