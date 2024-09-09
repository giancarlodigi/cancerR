
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cancerR <!-- <img src="man/figures/package-sticker.png" align="right" style="float:right; height:120px;"/> -->

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/cancerR)](https://CRAN.R-project.org/package=cancerR)
[![R CMD
Check](https://github.com/giancarlodigi/cancerR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/giancarlodigi/cancerR/actions/workflows/R-CMD-check.yaml)
[![Website](https://github.com/giancarlodigi/cancerR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/giancarlodigi/cancerR/actions/workflows/pkgdown.yaml)
[![Test
coverage](https://github.com/giancarlodigi/cancerR/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/giancarlodigi/cancerR/actions/workflows/test-coverage.yaml)
[![License: GPL (\>=
2)](https://img.shields.io/badge/License-GPL%20%28%3E%3D%202%29-blue.svg)](https://choosealicense.com/licenses/gpl-2.0/)
[![LifeCycle](https://img.shields.io/badge/lifecycle-experimental-orange)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Dependencies](https://img.shields.io/badge/dependencies-0/0-brightgreen?style=flat)](#)
<!-- badges: end -->

<p align="left">
• <a href="#overview">Overview</a><br> •
<a href="#features">Features</a><br> •
<a href="#installation">Installation</a><br> •
<a href="#get-started">Get started</a><br> •
<a href="#vignettes">Vignettes</a><br> •
<a href="#upcoming-features">Upcoming features</a><br> •
<a href="#citation">Citation</a><br> •
<a href="#contributing">Contributing</a><br> •
<a href="#references">References</a>
</p>

## Overview

`cancerR` is designed to use administrative data to classify different
cancer subtypes using data commonly collected by cancer registries. This
package is meant for researchers and data scientists who work with
cancer data and need to classify the type of cancer using the
information available in pathology reports which have been coded using
the [International Classification of Diseases for Oncology
(ICD-O)](https://www.who.int/standards/classifications/other-classifications/international-classification-of-diseases-for-oncology).

## Features

The main purpose of `cancerR` is to use information gathered using the
standardized collection system of the
[ICD-O](https://www.who.int/standards/classifications/other-classifications/international-classification-of-diseases-for-oncology)
classification system of tumors to classify the type of cancer.
Depending on the age of the patient, users of the package can classify
the type of cancer according to

The package provides functionality to:

- convert and validate tumor site (a.k.a. topography) codes
- classify childhood cancer according to the [International
  Classification of Childhood
  Cancer](https://doi.org/10.1002/cncr.20910)
- assign adolescent and young adult cancers using the [AYA
  Site](https://seer.cancer.gov/ayarecode/) from the Social,
  Epidemiology, and End Results (SEER) program or the published [AYA
  classification by Barr et al](https://doi.org/10.1002/cncr.33041)

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
## Install < remotes > package (if not already installed) ----
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

## Install < cancerR > from GitHub ----
remotes::install_github("giancarlodigi/cancerR")
```

Then you can attach the package `cancerR`:

``` r
library("cancerR")
```

## Get started

For an overview of the main features of `cancerR`, please read the [Get
started](https://giancarlodigi.github.io/cancerR/articles/cancerR.html)
vignette.

## Vignettes

`cancerR` provides vignettes to learn more about the package:

- the [Get
  started](https://giancarlodigi.github.io/cancerR/articles/cancerR.html)
  vignette describes the basic functionality of the package

## Upcoming features

The package is under active development and planning to add the
following features:

- adult cancer classification according to the
  [ICD-O](https://www.who.int/standards/classifications/other-classifications/international-classification-of-diseases-for-oncology)
- implementing conversion and classification of cancers using ICD-O-2
  codes

## Citation

Please cite `cancerR` as:

> Di Giuseppe Giancarlo (2024) cancerR: An R package to classify cancer
> using administrative data. R package version 0.0.0.9000.
> <https://github.com/giancarlodigi/cancerR/>

## Contributing

All types of contributions are encouraged and valued. For more
information, please reach out to the maintainer of the package.

Please note that the `cancerR` project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## References

Barr RD, Ries LAG, Trama A, et al. A system for classifying cancers
diagnosed in adolescents and young adults. Cancer.
2020;126(21):4634-4659. doi:
[10.1002/cncr.33041](https://doi.org/10.1002/cncr.33041).

Steliarova-Foucher E, Stiller C, Lacour B, Kaatsch P. International
Classification of Childhood Cancer, third edition. Cancer.
2005;103(7):1457-1467. doi:
[10.1002/cncr.20910](https://doi.org/10.1002/cncr.20910).

National Cancer Institute. Surveillance, Epidemiology, and End Results
Program. Adolescent and Young Adult Site Recode ICD-O-3/WHO 2008. 2021.
Available [here](https://seer.cancer.gov/ayarecode/).

World Health Organization. International Classification of Diseases for
Oncology (ICD-O) - 3rd Edition, 1st Revision; 2013. Document manual
found
[here](https://apps.who.int/iris/bitstream/handle/10665/96612/9789241548496_eng.pdf)
