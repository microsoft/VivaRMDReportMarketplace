# Right to Disconnect Report Template

## Parameters

The following parameters describe the arguments that will be passed to within the report function. 

- `data`: the input must be a data frame with the columns as a Standard Person Query, which is built using the `sq_data` inbuilt into the 'wpa' package.  
- `report_title`: string containing the title of the report, which will be passed to `set_title` within the RMarkdown template.
- `hrvar`: string specifying the HR attribute that will be passed into the single plot.
- `mingroup`: numeric value specifying the minimum group size to filter the data by.
- `min_activity`: numeric value specifying the minimum number of emails or instant messages sent for any given day to be included in the data. You may wish to use this argument to exclude low/non-activity days such as annual leave or public holidays.  

## Report Type

This is a **flexdashboard** RMarkdown report.

The standard YAML header would be as follows:
```
output:
  flexdashboard::flex_dashboard:
    orientation: rows
    vertical_layout: fill
```    

## Report output

This report contains the following pages:
- `Overview`
- `Drill-down`
- `Channels`
- `Channels - %`
- `Time Trend`

## Data preparation

No data preparation is required as long as it is a Standard Person Query grouped at the **daily** level. Daily grouping is essential for the report to display day of the week break down properly. 

## Package pre-requisites

To run this report, you will need the following R packages installed:
- `wpa`
- `dplyr`
- `lubridate`
- `flexdashboard`

## Examples

For an example of the report output, see `rtd report.html`.

To run this report, you may run as an example: 
```R
generate_report2(
  output_format = flexdashboard::flex_dashboard(
    orientation = "columns",
    vertical_layout = "fill"
  ),
  output_file = "rtd report.html",
  output_dir = here::here("templates", "rtd-report"), # path for output
  rmd_dir = here::here("templates",
                       "rtd-report",
                       "rtd_report.Rmd"), # path to RMarkdown file,

  # Custom arguments to pass to `minimal-example/minimal.Rmd`
  data = spq_df, # Variable containing daily person query data frame
  hrvar = "Organization",
  mingroup = 5,
  min_activity = 1,
  report_title = "Right to Disconnect Report"
)
```
