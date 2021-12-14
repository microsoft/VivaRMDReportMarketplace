# Employee Experience RMarkdown Report Template

## Parameters
The following parameters describe the arguments that will be passed to within the report function. 

- `data`: the input must be a data frame with the columns as a Standard Person Query, which is built using the `sq_data` inbuilt into the 'wpa' package.  
- `report_title`: string containing the title of the report, which will be passed to `set_title` within the RMarkdown template.
- `hrvar`: string specifying the HR attribute that will be passed into the single plot. 
- `mingroup`: numeric value specifying the minimum group size to filter the data by.

## Report Type
This is a **flexdashboard** RMarkdown report.

The standard YAML header would be as follows:
```
output:
  flexdashboard::flex_dashboard:
    orientation: rows
    vertical_layout: fill
```    

## Query Spec

### Specifications

Run a single daily person query: 

- Group by `Day`
- At least 3 months
- Ensure that `IsActive` flag is not applied


### All metrics

**Note**: _Custom metrics shown in **bolded italics**_

1. **_Meeting hours 1 on 1_** [SEE SPEC BELOW]
1. **_Meeting hours 1 on 1 with same level_** [SEE SPEC BELOW]
1. Time in self organized meetings
1. Open 2 hour blocks
1. Collaboration hours external
1. Meetings with skip level
1. Meeting hours with skip level
1. ***Meeting hours 3 to 8*** [SEE SPEC BELOW]
1. Internal network size
1. Meeting hours with manager
1. Meeting hours
1. Meetings
1. Meetings with manager
1. Meeting hours with manager 1 on 1
1. Instant messages sent
1. Emails sent
1. Workweek span
1. Collaboration hours
1. ***Meeting hours with skip level max 8*** [SEE SPEC BELOW]
1. ***Meeting hours with manager with 3 to 8*** [SEE SPEC BELOW]


### Custom metrics

1. Meeting Hours 1 on 1: where `Total attendees == 2`
1. Meeting Hours 1 on 1 with same level: `All attendee's and/or recipient's` where `LevelDesignation == @RelativeToPerson` AND `Total attendees == 2`
1. Meeting hours 3 to 8: `Total attendees >= 3` AND `Total attendees <= 8`
1. Meeting hours with skip level max 8:  `Total attendees <= 8`, using `Meeting hours with skip level`. 
1. Meeting hours with manager 3 to 8:  `Total attendees >= 3` AND `Total attendees <= 8`, using `Meeting hours with manager`. This is used to calculate **small group meetings without manager** by deducting this from `Meeting hours for 3 to 8 attendees`.


## Report output
This report contains one single plot and a print out of the data diagnostics. 

## Data preparation
No data preparation is required as long as it is a Standard Person Query. 

## Examples
For an example of the report output, see `minimal report.html`.

To run this report, you may run: 
```R
generate_report2(
  output_format = rmarkdown::html_document(toc = TRUE, toc_depth = 6, theme = "cosmo"),
  output_file = "minimal report.html",
  output_dir = here("minimal-example"), # path for output
  report_title = "Minimal Report",
  rmd_dir = here("minimal-example", "minimal.Rmd"), # path to RMarkdown file,

  # Custom arguments to pass to `minimal-example/minimal.Rmd`
  data = sq_data,
  hrvar = "Organization",
  mingroup = 5
)
```
