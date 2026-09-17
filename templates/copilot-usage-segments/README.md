# Copilot Usage Segments

This standard RMarkdown report assigns illustrative Copilot usage segments and
shows their trend. It renders
[copilot-usage-segments-trend.html](copilot-usage-segments-trend.html).

## Inputs and prerequisites

The example uses `vivainsights::pq_data`. Real input needs one covered
person-week for every eligible person and all six named Copilot action metrics:
Teams, Copilot Chat (work), Excel, Outlook, PowerPoint and Word. The input
contract rejects missing, non-numeric, non-finite and negative counts; an
observed zero remains valid and is not missing evidence. Install
`vivainsights`, `dplyr`, `tidyr`, `ggplot2`, `scales` and `rmarkdown`.

## Safe scope and privacy

The notebook cannot establish population eligibility, complete person-week
coverage or distinguish omitted observations from source-provided placeholder
zeros. Confirm those properties and appropriate disclosure controls before
real-data use.

## Render

From this directory:

```r
rmarkdown::render("copilot-usage-segments-trend.Rmd")
```

## Source and attribution

Imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. The input validation and
local packaging are adaptations, not claims about the upstream snapshot.
