# GitHub Developer Experience

This `flexdashboard` simulates relationships between developer experience,
GitHub activity and Copilot. It renders
[github-copilot-developer-productivity-simulation.html](github-copilot-developer-productivity-simulation.html).

## Inputs, data and prerequisites

The RMarkdown sources `github-developer-experience-helpers.R` in this
directory. That helper deterministically creates its synthetic CSV inputs
under `_data/github` at render time; those generated files are ignored by Git.
`render-github-developer-experience.R` is an optional wrapper that verifies
packages and renders from this folder. Install `rmarkdown`, `flexdashboard`,
`dplyr`, `tidyr`, `ggplot2`, `scales`, `knitr`, `stringr` and `vivainsights`.

## Safe scope and privacy

No live system or input file is read. The simulation, thresholds and
relationships are illustrative and must not be used as evidence about real
developer productivity or people.

## Render

From this directory:

```r
rmarkdown::render("github-copilot-developer-productivity-simulation.Rmd")
# or: Rscript render-github-developer-experience.R
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. The local helper,
generated fixtures and wrapper are locally adapted components.
