## Test platforms
* local Arch Linux, R 4.5.3
* macos-latest (on GitHub Actions), R-release
* windows-latest (on GitHub Actions), R-release
* ubuntu-latest (on GitHub Actions), R-devel, R-release, R-oldrel-1

## R CMD check results

0 errors | 0 warnings | 0 notes

## Resubmission
This is a patch release (v0.1.1) that addresses critical bugs and refactors internal logic for better maintainability.

### Changes since v0.1.0:
* Fixed a critical regex bug in `site_convert()` that prevented correct conversion of ICD-O-3 topography codes with decimals.
* Improved robustness of `aya_class()` and `kid_class()` by ensuring `site_convert()` is always applied to the `site` input, supporting both numeric and character formats.
* Refactored shared classification logic into an internal helper function `classify_internal()` to reduce code duplication.
* Replaced internal "magic numbers" with constants for clearer error handling.
* Added a comprehensive regression test suite for version 0.1.1.
