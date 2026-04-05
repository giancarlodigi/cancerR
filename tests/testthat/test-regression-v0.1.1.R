# Regression tests for version 0.1.1 fixes

test_that("aya_class handles numeric site input with decimals (Fixed in v0.1.1)", {
  # This previously failed because site_convert was only called for characters
  # and 50.1 was not converted to 501, missing the lookup table match.
  result_char <- aya_class(9020, "C50.1", "3", method = "Barr 2020", depth = 1)
  result_num  <- aya_class(9020, 50.1, "3", method = "Barr 2020", depth = 1)
  
  expect_equal(result_num, result_char)
  expect_equal(as.character(result_num), "9. Carcinomas")
})

test_that("kid_class handles numeric site input with decimals (Fixed in v0.1.1)", {
  # Similar fix for kid_class
  result_char <- kid_class("8970", "C22.0", method = "iccc3", depth = 1)
  result_num  <- kid_class("8970", 22.0, method = "iccc3", depth = 1)
  
  expect_equal(result_num, result_char)
  expect_equal(as.character(result_num), "VII. Hepatic tumors")
})

test_that("site_convert handles decimal codes correctly (Fixed in v0.1.1)", {
  # Fixed regex \\d{1-2} to \\d{1,2}
  expect_equal(site_convert("C34.1"), 341)
  expect_equal(site_convert("8.1"), 81)
  expect_equal(site_convert(8.1), 81)
})

test_that("site_convert preserves invalid numeric strings to avoid accidental wildcard matches (Fixed in v0.1.1)", {
  # "8000" should stay 8000 (not NA) so it doesn't match NA rows in lookup tables
  expect_equal(site_convert("8000", validate = FALSE), 8000)
})

test_that("error message typo is fixed (Fixed in v0.1.1)", {
  # "columns" -> "site columns"
  expect_error(kid_class(c("8970", "8980"), "C22.0"), 
               "Length of histology and site columns should be the same")
})
