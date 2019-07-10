
# PRArulebook

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN
status](https://www.r-pkg.org/badges/version/PRArulebook)](https://cran.r-project.org/package=PRArulebook)
[![Travis build
status](https://travis-ci.org/erzk/PRArulebook.svg?branch=master)](https://travis-ci.org/erzk/PRArulebook)
<!-- badges: end -->

The goal of `PRArulebook` is to scrape the Prudential Regulation
Authority [Rulebook](http://www.prarulebook.co.uk/) to obtain its text
and structure.

This package was developed while preparing the following Staff Working
Paper:

Amadxarif, Z., Brookes, J., Garbarino, N., Patel, R., Walczak, E. (2019)
*Textual Complexity in Prudential Regulation*. Bank of England Staff
Working Paper No. xxx.

## Installation

You can install the development version of `PRArulebook` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("erzk/PRArulebook")
```

## Examples

Load the package

``` r
library(PRArulebook)
```

### Structure

The simplest way to extract a rulebook structure is to use
`get_structure` function

``` r
# get the structure of the rulebook down to the part-level
parts <-
  get_structure("16-11-2007",
                layer = "part")
# or rule-level (without rule-level URLs)
rules <-
  get_structure("18-06-2019",
                layer = "rule")
```

This will start scraping the PRA rulebook. Pulling data will take longer
if you decide to pull more granular data. The rulebook has several
layers and each of them can be passed to the `layer` argument of
`get_structure` (in descending order):

  - `sector`
  - `part`
  - `chapter`
  - `rule`

![](get_structure_demo.gif)

### Content

#### Text

To get content of the rulebook (text or links) use `get_content`
function a URL of a given chapter/part/sector. This function can be
applied on the entire rulebook in the following way

``` r
# scrape text
parts_text <-
  purrr::map_df(parts$part_url,
                get_content)
```

#### Network

``` r
# scrape links
parts_links <-
  purrr::map_df(parts$part_url,
                get_content,
                "links")
```

Which will return a data frame with *from/to url*, *text* used in a
link, and a *type* of a link.

This
[page](http://www.prarulebook.co.uk/rulebook/Content/Part/216145/16-11-2007)
with extracted links (edges) will return the following

![](parts_links.png)

Scraped data containing information about the links can be used for
network analysis (warning: further cleaning is required).

### Rule-level data

Things get a bit more complicated when you need **rules and their
corresponding URLs**. This requires digging through the code on the
chapter-level and then visiting each rule separately so it is **much
slower** than the previous method.

The first command extracts the structure on the chapter-level. The
second command extracts rule-IDs.

``` r
chapters_df <-
  get_structure("16-11-2007",
                layer = "chapter")
rules_df <-
  scrape_rule_structure(chapters_df,
                        date = "16-11-2007")
```

This will generate a data frame with rule-level structure. The next step
is obtaining the rule IDs and text.

``` r
rules_df_id <- list()

for (i in 1:nrow(rules_df)) {
  print(i)
  rules_df_id[[i]] <-
    scrape_rule_id(rules_df$rule_url[i],
                   rules_df$rule_number_sel[i],
                   rules_df$rule_text_sel[i])
}

rules_df_id_df <- dplyr::bind_rows(rules_df_id)
```

### Disclaimer

This is an outcome of a research project and is not an official Bank of
England software. All errors are mine. The software and code samples are
provided “as is” without warranty of any kind, either express or
implied. Use at your own risk.
