# Viva RMarkdown Report Marketplace

## About

The **Viva RMarkdown Report Marketplace** allows you to download and contribute community RMarkdown Report templates for the Viva R eco-system. You can use this repository in conjunction with the [**wpa**](https://microsoft.github.io/wpa/) R library to design and generate your own static HTML reports. 

## RMarkdown

RMarkdown templates are versatile and powerful documents that can be used to generate static HTML reports and dashboards. An RMarkdown file is a plain-text file with a document header and code-narrative structure (similar to a Jupyter Notebook), which R then uses to generate the report. 

## Vision

The goal of this project is two-fold: 

- Provide a greater choice of reports through the Report marketplace
- Enable users to easily customize an existing report and contribute this back to the community

## Instructions

Each report template subdirectory should have the following elements:
- At least 1 RMarkdown (`.Rmd`) containing the report content
- `README.md` - describes the report and provides documentation on:
    - parameters
    - whether the report is a standard RMarkdown report or something else, e.g. a `flexdashboard`
    - description of the report output
    - details around data preparation
    - an example of the output report
    - example snippet for running the report

Note that your pull request may be rejected if you do not include all of the above information. 

See `minimal-example` in this repository for an example.

### How to use a report template 

1. Clone this repository to your local machine. You can either clone the repository using **GitHub Desktop**, or you can download the repository as a zipped folder. 
2. Select the RMarkdown report template that you would like to use, and copy this to your working analysis directory. For more information about how to set up your working analysis directory, please read this article on [setting up R analysis directories](https://martinctc.github.io/blog/rstudio-projects-and-working-directories-a-beginner's-guide/). 
3. Assuming you have already installed the **wpa** package, load it with the following code: 
```R
library(wpa)
```
4. When you run the report with `wpa::generate_report2()`, provide the path to the template in the argument and all the necessary parameters. An example code would be as follows:

```R
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
```
The arguments that you should pass to each report will differ depending on the report template. Please read the corresponding `README` file in each report template subdirectory for the appropriate example. 

For a full example on how to run the `minimal.Rmd` example in this directory, see `example-usage.R` located at the root of this repository.

### Report Templates

The current report templates are available:
- [Minimal report](https://github.com/microsoft/VivaRMDReportMarketplace/tree/main/templates/minimal-example) - as a minimal example of the report that can be produced with the above workflow. 
- [Employee Experience Report](https://github.com/microsoft/VivaRMDReportMarketplace/tree/main/templates/exp-report) - a report on the Employee Experience Index. 
- [Right to Disconnect Report](https://github.com/microsoft/VivaRMDReportMarketplace/tree/main/templates/rtd-report) - a report on collaboration metrics related to the Right to Disconnect, including an analysis on weekends. 


## References
- https://rstudio.github.io/rstudio-extensions/rmarkdown_templates.html

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.
