# Custom Networks

These two standard RMarkdown examples are one network-visualisation use case:
person-to-person and group-to-group collaboration networks. They render
[custom-network-p2p.html](custom-network-p2p.html) and
[custom-network-g2g.html](custom-network-g2g.html).

## Inputs and prerequisites

Both examples use package-provided data and require the packages declared in
their setup chunks, including `vivainsights`, `dplyr`, `igraph`, `ggraph`,
`ggplot2`, `RColorBrewer`, `viridis` and `rmarkdown`. A real adaptation needs
appropriately aggregated collaboration edges and group attributes.

## Safe scope and privacy

Network edges can expose sensitive relationships. Apply eligibility, minimum
group, aggregation and disclosure review before using real organizational
data; do not use these visualisations to assess individuals.

## Render

From this directory:

```r
rmarkdown::render("custom-network-p2p.Rmd")
rmarkdown::render("custom-network-g2g.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. Local packaging and
documentation are adaptations.
