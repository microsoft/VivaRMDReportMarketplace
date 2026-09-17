# Meeting Engagement Drivers

This standard RMarkdown example explores simulated meeting engagement drivers.
It renders [meeting-engagement-drivers.html](meeting-engagement-drivers.html).

## Inputs and prerequisites

The report creates its demonstration data in the document. Install
`tidyverse`, `vivainsights`, `randomForest` and `rmarkdown`.

## Safe scope and privacy

The model and its data are illustrative. They are not a basis for individual
assessment or a validated explanation of engagement. Real use requires
appropriate outcome definition, data-quality, aggregation, disclosure and
privacy review.

## Render

From this directory:

```r
rmarkdown::render("meeting-engagement-drivers.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`.
