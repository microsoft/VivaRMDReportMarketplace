# Top Performers Random Forest

This standard RMarkdown document demonstrates a person-disjoint train,
validation and held-out-test workflow for a random forest. It renders
[top-performers-rf.html](top-performers-rf.html).

## Inputs, data and prerequisites

The document reads `_data/Top_Performers_Dataset_v2.csv`. It is entirely
synthetic: `generate-demo-data.R` deterministically produces 200 invented
people, eight observations per person, simulated numeric features and an
invented five-level label using seed `20260916`. Run
`Rscript generate-demo-data.R` from any directory to regenerate it. Install
the packages declared in the report, including `dplyr`, `tidyr`,
`tidyverse`, `vivainsights`, `randomForest`, `caret`, `pROC`, `knitr` and
`rmarkdown`. `tidyverse` supplies the document's `dplyr`, `tidyr`, `ggplot2`,
`scales` and `purrr` functions.

## Safe scope and privacy

The labels, identifiers and model results have no business validity. This is
training-only and must not rank employees or be adapted into an employee
ranking workflow. Real-data use requires appropriate-use, privacy and model
governance review.

## Render

From this directory:

```r
rmarkdown::render("top-performers-rf.Rmd")
```

## Source and attribution

The RMarkdown was imported and locally adapted from `examples/utility-r` in
[microsoft/viva-insights-sample-code](https://github.com/microsoft/viva-insights-sample-code),
snapshot `6beb236f59ea0ca17e2ac419bc92b3f905490db7`. The synthetic fixture and
its generator are local components, not upstream content.
