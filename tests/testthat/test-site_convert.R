test_that("site_convert handles character input with 'C'", {
  expect_equal(site_convert("C34.1"), 341)
  expect_equal(site_convert("C341"), 341)
  expect_equal(site_convert("C34"), 340)
})

test_that("site_convert handles numeric input", {
  expect_equal(site_convert(34.1), 341)
  expect_equal(site_convert(341), 341)
  expect_equal(site_convert(34), 340)
})

test_that("site_convert handles invalid ICD-O-3 site codes", {
  expect_warning(result <- site_convert(c("C999", "C34.1")), "invalid ICD-O-3 site codes found and set to NA")
  expect_equal(result, c(NA, 341))
})

test_that("site_convert handles valid ICD-O-3 site codes", {
  expect_equal(site_convert(c("C34.1", "C50.9")), c(341, 509))
})

test_that("site_convert handles mixed valid and invalid codes", {
  expect_warning(result <- site_convert(c("C34.1", "C999", "C50.9")), "invalid ICD-O-3 site codes found and set to NA")
  expect_equal(result, c(341, NA, 509))
})

test_that("site_convert handles invalid codes without warning if validate is FALSE", {
  expect_equal(site_convert(c("C999", "C34.1"), validate = FALSE), c(999, 341))
})

test_that("site_convert stops for codes with two digits after the dot", {
  expect_error(site_convert("C34.12"), "ICD-O-3 site codes should not have two digits after the dot.")
})
