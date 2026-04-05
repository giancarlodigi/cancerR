# cancerR 0.1.1

## Bug fixes

* Fixed a critical regex bug in `site_convert()` that prevented correct conversion of ICD-O-3 topography codes with decimals.
* Improved robustness of `aya_class()` and `kid_class()` by ensuring `site_convert()` is always applied to the `site` input, allowing both numeric and character formats to work reliably.
* Fixed a typo in the error message for input length validation in `kid_class()`.

## Architectural changes

* Refactored shared classification logic between `aya_class()` and `kid_class()` into an internal helper function `classify_internal()` to improve maintainability and reduce code duplication.
* Replaced brittle magic numbers in matching logic with internal constants `ERR_NONE` and `ERR_MULT`.

# cancerR 0.1.0

## Initial package release

* Released the development version of cancerR on GitHub.