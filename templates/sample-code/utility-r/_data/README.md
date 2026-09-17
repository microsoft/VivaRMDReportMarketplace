# Demonstration data provenance

No customer exports belong in this directory.

## Locally generated fixtures

Run from any working directory:

```text
Rscript <path-to-utility-r>\generate-demo-data.R
```

- **Top_Performers_Dataset_v2.csv**: new, entirely synthetic data from
  `generate_top_performers()` (seed `20260916`). 200 invented people, eight
  observations each, four simulated numeric features and an invented, stable
  five-level label. `SYNTH_RF_0001`-style IDs are sequence numbers. Parameters,
  seeds and labels are not derived from the replaced dataset or any employee
  records. The previous fixture's provenance was unverified; this replacement
  makes no claim about its origin. Metrics/labels have no business validity.
- **consumption/consumption-query/consumption-task-types.csv**: locally
  regenerated allocation (seed `20260917`). It uses only the already synthetic
  weekly credit totals in `consumption-weekly.csv`, never the old task file.
  Newly invented random task preferences allocate integer tenths of credits
  exactly within each person and the complete observation window.
  `PeriodStart` is the first week start; `PeriodEnd` is the last week start plus
  six days, inclusive. All people, including zero-credit people, are retained.
  This replaces independently generated task totals that did not reconcile with
  weekly consumption. Token weights, weekly consumption and Ways of Working
  inputs are unchanged. The allocation is not evidence about real task mix.

The generator pins R's RNG algorithms and seeds. Base R writes the files; tests
check repeated generation and exact person/window totals. Floating-point
reconciliation tolerance is `1e-8` credits, not a rescaling allowance.
The report checks input keys, windows and totals and fails on a mismatch.
Never use this generator to "repair" arbitrary real task feeds.

## Upstream synthetic fixtures

The other four consumption CSVs (people snapshot, consumption weekly, person
query weekly, network monthly) are unchanged from
`microsoft/viva-insights-sample-code` commit
`6beb236f59ea0ca17e2ac419bc92b3f905490db7`, where they are supplied as synthetic
demonstration assets. Their generator is not included in this snapshot; the local
generator above does not claim to reproduce them.

`_data/github/` is generated at render time by
`github-developer-experience-helpers.R`, with its own seed and invariant checks,
and is ignored by Git.
