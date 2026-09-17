# Collaboration by Time of Day

This standard RMarkdown report describes when collaboration occurs over the
day using Viva Insights person-query data. It renders
[collaboration-by-time-of-day.html](collaboration-by-time-of-day.html).

## Inputs and prerequisites

The example uses package-provided data. For a real adaptation, use a
person-level daily collaboration extract with date/time and collaboration
measures required by the source chunks. Install `tidyverse`, `vivainsights`
and `lubridate`, as well as `rmarkdown`.

## Safe scope and privacy

This is descriptive analysis, not an employee-performance assessment. Review
schema, population eligibility, coverage, aggregation and disclosure controls
before adapting it to real data.

## Render

From this directory:

```r
rmarkdown::render("collaboration-by-time-of-day.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. Local packaging and
documentation changes are not upstream content.
