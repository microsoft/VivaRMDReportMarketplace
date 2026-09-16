# Utility RMarkdown examples

These examples are portable RMarkdown starting points for common Viva
Insights analyses. They are separate from the Marketplace's parameterized
`wpa::generate_report2()` templates: most are intended to be opened and
knit directly. Any real-query adaptation needs schema, coverage and privacy
review. `evaluate-intervention.Rmd`, `did-metric-scan.Rmd` and
`event-study-did.Rmd` are educational simulations, **not supported real-data
causal recipes**; they cannot be made causal by swapping the data-loading chunk.

The examples include standard HTML reports and two `flexdashboard` examples.
The source files are self-contained where possible and clearly mark simulated
data or illustrative effects.

The data-dependent examples include synthetic inputs in `_data`. In
particular, the Copilot consumption and top-performers examples read files from
that directory; keep the RMarkdown file's working directory at `utility-r`
when rendering them. The GitHub developer-productivity example generates its
`_data/github` CSV outputs from `github-developer-experience-helpers.R` during
rendering.

`generate-demo-data.R` deterministically regenerates the synthetic top-performer
fixture and task allocation; see [`_data/README.md`](_data/README.md).
The RF example averages within person, selects on a person-disjoint validation
population, and evaluates a frozen model once on held-out people.
The consumption report sources `consumption-contracts.R`; keep it alongside the
Rmd. Input task totals must reconcile by person and window before any chart runs.

The usage-segment trend example requires all six named Copilot action metrics
and rejects missing, non-numeric, non-finite or negative counts before
classifying use. Observed zeros remain valid; missing evidence is not zero
activity. Real exports also need eligibility and person-week coverage checks:
the notebook cannot identify unobserved rows or source-provided placeholder
zeros. See its input-contract and real-data guidance before adapting it.

## Regression checks

From the repository root, with the example packages installed:

```text
Rscript templates\sample-code\utility-r\tests\regression.R
```

For only the usage-segment input contract (F-13), append `--usage-only`.
It checks each/all missing metrics, unknown and invalid counts, unchanged
sample totals and legitimate all-zero activity.

The base-assertion checks execute source chunks and numerical counterexamples.
They do not install packages or configure library paths; normal R library
configuration (including `R_LIBS_USER`) is respected. Render the examples
separately with `rmarkdown::render()` to validate their complete outputs.

See the collection-level
[README](../README.md) for the source repository, attribution, and rendering
guidance.
