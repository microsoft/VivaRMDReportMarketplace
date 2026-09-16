# Utility RMarkdown examples

These examples are portable RMarkdown starting points for common Viva
Insights analyses. They are separate from the Marketplace's parameterized
`wpa::generate_report2()` templates: most are intended to be opened and
knit directly, with the data-loading section adapted to the analyst's
exported query.

The examples include standard HTML reports and two `flexdashboard` examples.
The source files are self-contained where possible and clearly mark simulated
data or illustrative effects.

The data-dependent examples include synthetic inputs in `_data`. In
particular, the Copilot consumption and top-performers examples read files from
that directory; keep the RMarkdown file's working directory at `utility-r`
when rendering them. The GitHub developer-productivity example generates its
`_data/github` CSV outputs from `github-developer-experience-helpers.R` during
rendering.

See the collection-level
[README](../README.md) for the source repository, attribution, and rendering
guidance.
