## Load required packages
library(wpa)
library(here) # optional, but makes relative paths more manageable

## Code for calling `generate_report2()`
## For more documentation, run `?generate_report2`

generate_report2(
  output_format = rmarkdown::html_document(toc = TRUE, toc_depth = 6, theme = "cosmo"),
  output_file = "minimal report.html",
  output_dir = here("templates", "minimal-example"), # path for output
  report_title = "Minimal Report",
  rmd_dir = here("templates", "minimal-example", "minimal.Rmd"), # path to RMarkdown file,

  # Custom arguments to pass to `minimal-example/minimal.Rmd`
  data = sq_data,
  hrvar = "Organization",
  mingroup = 5
)
