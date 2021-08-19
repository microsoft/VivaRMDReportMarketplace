# Minimal RMarkdown Report Template

## Parameters
The following parameters describe the arguments that will be passed to within the report function. 

- `data`: the input must be a data frame with the columns as a Standard Person Query, which is built using the `sq_data` inbuilt into the 'wpa' package.  
- `report_title`: string containing the title of the report, which will be passed to `set_title` within the RMarkdown template.
- `hrvar`: string specifying the HR attribute that will be passed into the single plot. 
- `mingroup`: numeric value specifying the minimum group size to filter the data by.

## Report Type
This is a standard RMarkdown report.

## Report output
This report contains one single plot and a print out of the data diagnostics. 

## Data preparation
No data preparation is required as long as it is a Standard Person Query. 