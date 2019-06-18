
# PRArulebook

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/PRArulebook)](https://cran.r-project.org/package=PRArulebook)
<!-- badges: end -->

The goal of PRArulebook is to scrape the Prudential Regulation Authority
[rulebook](http://www.prarulebook.co.uk/).

This package was developed while preparing a Staff Working Paper.

**Citation**: Amadxarif, Z., Brookes, J., Garbarino, N., Patel, R.,
Walczak, E. (2019) Textual Complexity in Prudential Regulation. Bank of
England Staff Working Paper No. xxx.

## Installation

You can install the released version of PRArulebook from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("PRArulebook")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("erzk/PRArulebook")
```

## Example

This package allows obtaining text and structure of the PRA rulebook

``` r
library(PRArulebook)
```

### Disclaimer

This is an outcome of a research project and this is not an official BoE
software. All errors are mine. The software and code samples are
provided “as is” without warranty of any kind, either express or
implied. Use at your own risk.
