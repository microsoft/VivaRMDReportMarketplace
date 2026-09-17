# Educational Causal Analysis Simulations

These standard RMarkdown documents demonstrate an intervention evaluation, a
difference-in-differences metric scan and an event-study difference-in-
differences model. They render
[evaluate-intervention.html](evaluate-intervention.html),
[did-metric-scan.html](did-metric-scan.html) and
[event-study-did.html](event-study-did.html).

## Inputs and prerequisites

Each document creates its own simulated panel; it does not consume a customer
export. `evaluate-intervention.Rmd` uses `tidyverse` and `vivainsights`;
the two DiD documents use `dplyr`, `tidyr`, `ggplot2`, `scales` and `fixest`
(`did-metric-scan.Rmd` also uses `purrr`). Install `rmarkdown` to render.

## Safe scope and limitations

These are **educational simulations, not supported real-data causal recipes**.
Replacing a data-loading chunk does not establish identification, and
homogeneous simulation results do not validate heterogeneous staggered
adoption. A real study requires an independently reviewed estimand, treatment
assignment, comparison group, timing, identifying assumptions and privacy
controls.

## Render

From this directory:

```r
rmarkdown::render("evaluate-intervention.Rmd")
rmarkdown::render("did-metric-scan.Rmd")
rmarkdown::render("event-study-did.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. The explicit educational
limitations and local packaging are adaptations.
