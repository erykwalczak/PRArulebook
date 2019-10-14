
# PRArulebook

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/PRArulebook)](https://cran.r-project.org/package=PRArulebook)
<!-- badges: end -->

`PRArulebook` is a package to scrape the PRA (Prudential Regulation
Authority) [Rulebook](http://www.prarulebook.co.uk/) (the website
containing the rules made and enforced by the PRA under powers conferred
by the Financial Services and Markets Act 2000 (FSMA)).

The input to this package is the PRA Rulebook website. Outputs from this
package are the rules published on the PRA Rulebook website in a format
more amenable to text and network analysis.

`PRArulebook` was developed while preparing:

Amadxarif, Z., Brookes, J., Garbarino, N., Patel, R., Walczak, E. (2019)
*The Language of Rules: Textual Complexity in Banking Reforms*. Bank of
England Staff Working Paper.

Any use of this package with the PRA Rulebook must comply with the PRA
Rulebook’s [Terms of Use](http://www.prarulebook.co.uk/terms-of-use).
These include restrictions on using content from the PRA Rulebook for
commercial purposes without obtaining a licence from the PRA.

## Installation

You can install the development version of `PRArulebook` from GitHub
with:

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

This will produce a data frame with information about the structure
(i.e. URLs and names).

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

There is another, even faster way, to acquire this data by scraping the
website in parallel using
[furrr](https://cran.r-project.org/web/packages/furrr/). In this example
it took 153 sec to run the scraper in parallel vs. 249 sec using
`purrr`.

``` r
library(furrr)
library(future)

plan(multiprocess)

parts_text <-
  furrr::future_map_dfr(parts$part_url,
                        get_content,
                        .progress = TRUE)
```

#### Network

To scrape the links and create data set for network analysis
`get_content` function can be used but with a `type` argument set to
`"link"`. Like in the previous example, this call can also be
parallelised.

``` r
# sequential
parts_links <-
  purrr::map_df(parts$part_url,
                get_content,
                "links")

# parallel (faster)
future::plan(multiprocess)

parts_links <-
  furrr::future_map_dfr(parts$part_url,
                        get_content,
                        "links",
                        .progress = TRUE)
```

The code above will return a data frame with *from/to url*, *text* used
in a link, and a *type* of a link.

Scraped data containing information about the links can be used for
network analysis (warning: further cleaning might be required).

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

This will generate a data frame with rule-level structure.

### Disclaimer

This package is an outcome of a research project. All errors are mine.
All views expressed are personal views, not those of any employer.
