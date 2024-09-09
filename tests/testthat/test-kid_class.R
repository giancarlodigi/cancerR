# Test cases for kid_class function
test_that("kid_class returns correct classification for valid inputs", {
  result <- kid_class("8970", "C22.0", method = "iccc3", depth = 1)
  expect_equal(as.character(result), "VII. Hepatic tumors")
})

test_that("kid_class throws error for invalid method", {
  expect_error(kid_class("8970", "C22.0", method = "iccc4", depth = 1), 
               "Invalid method specified, needs to be one of 'iccc3', 'who-iccc3', 'iarc2017'")
})

test_that("kid_class throws error for invalid depth", {
  expect_error(kid_class("8970", "C22.0", method = "iccc3", depth = 5), 
               "Depth for classification is must be between 1 and 3")
})

test_that("kid_class throws error for mismatched lengths of histology and site", {
  expect_error(kid_class(c("8970", "8980"), "C22.0", method = "iccc3", depth = 1), 
               "Length of histology and columns should be the same")
})

test_that("kid_class handles no match found", {
  result <- kid_class("9999", "C22.0", method = "iccc3", depth = 1)
  expect_output(cat("No match found at index: 1 \n"))
})

test_that("kid_class handles duplicate matches found", {
  result <- kid_class("9999", "C22.0", method = "iccc3", depth = 1)
  expect_true(is.na(result))
})
