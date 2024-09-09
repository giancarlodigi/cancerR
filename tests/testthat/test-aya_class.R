
# Classification system works for both character and numeric input
test_that("classification system works for both character and numeric input", {
  expect_equal(as.character(aya_class(9835, 800, 3, method = "Barr 2020", depth = 1)), "1. Leukemias and related disorders")
  expect_equal(as.character(aya_class("9835", 800, "3", method = "Barr 2020", depth = 2)), "1.1 Acute lymphoblastic leukemia")
  expect_equal(as.character(aya_class(8345, "C73.9", "3", method = "SEER v2020", depth = 3)), "9.1.1 Medullary")
  expect_length(aya_class(9835, 800, 3, method = "Barr 2020", depth = 1), 1)
})

# Invalid method specified
test_that("invalid method throws an error", {
  expect_error(aya_class(9835, 800, 3, method = "Barr 2021", depth = 1), "Invalid method specified, needs to be one of 'Barr 2020', 'SEER v2006', 'SEER v2020', 'SEER-WHO v2008'")
  expect_error(aya_class("9835", "C80.2", 3, method = "SEER", depth = 1), "Invalid method specified, needs to be one of 'Barr 2020', 'SEER v2006', 'SEER v2020', 'SEER-WHO v2008'")
})

# Invalid depth
# - depends on the method used
test_that("invalid depth throws an error", {
  expect_error(aya_class(9835, 800, 3, method = "Barr 2020", depth = 0), "Depth for classification is must be between 1 and 6")
  expect_error(aya_class("9835", "C80.2", 3, method = "SEER-WHO v2008", depth = 5), "Depth for classification is must be between 1 and 4")
})

# Expect a console print that no match was found
test_that("no match found prints message or returns NA", {
  expect_output(aya_class(9383, "8000", "3", method = "Barr 2020", depth = 3), "No match found at index:  1")
  expect_output(aya_class("9999", 800, "3", method = "SEER v2020", depth = 2), "No match found at index:  1")
  expect_true(is.na(aya_class("9999", 800, "3", method = "SEER v2020", depth = 2)))
})
