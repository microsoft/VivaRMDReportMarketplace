# Viva Insights sample-code templates

This collection brings selected RMarkdown examples from the
[viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code)
repository into the Report Marketplace so the most useful Viva Insights R
examples are available alongside the report templates.

## Contents

The `utility-r` directory contains RMarkdown examples covering:

- collaboration by time of day
- Copilot usage segments and consumption
- custom person-to-person and group-to-group network visuals
- workplace interventions, difference-in-differences, and event studies
- meeting engagement drivers and top-performer modelling
- information value and pairwise chi-square analysis

Most examples use synthetic or package-provided data and are intended as
starting points. For real analyses, replace the example data-loading code with
an exported Viva Insights query and review the assumptions documented in each
RMarkdown file.

The data-dependent examples include their required synthetic inputs under
`utility-r/_data`. The files are for demonstration only and contain no
customer data or real identifiers. The GitHub developer-productivity example
generates its CSV outputs from the checked-in helper script instead of relying
on committed generated data.

The GitHub Copilot developer-productivity example also includes its helper and
render scripts because the RMarkdown file sources them.

## Running an example

Open an `.Rmd` file in RStudio and knit it, or render it with:

```r
rmarkdown::render(
  "templates/sample-code/utility-r/copilot-usage-segments-trend.Rmd"
)
```

Install the packages listed in the setup chunk before rendering. Examples
using `flexdashboard` require that package in addition to `rmarkdown`.

For a rendered preview, see
[`copilot-usage-segments-trend.html`](utility-r/copilot-usage-segments-trend.html).

## Source and attribution

These files are copied from the `examples/utility-r` directory of
`microsoft/viva-insights-sample-code`. They remain under the terms of that
repository's license. The copied snapshot was taken from commit
`6beb236f59ea0ca17e2ac419bc92b3f905490db7`.

Please check the upstream repository for newer versions and original
documentation before making substantial changes.
