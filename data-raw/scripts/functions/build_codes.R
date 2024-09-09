#' Build Site Codes from Character Codes and Ranges
#'
#' @description 
#' This function takes an input data frame and splits the 'site', 'hist', and 'behav' 
#' columns into multiple values based on commas or spaces. 
#' It then applies the 'convert_numeric' function to each element in the list and removes 
#' the original 'site', 'hist', and 'behav' columns.
#'
#' @param x A data frame with 'site', 'hist', and 'behav' columns.
#' @return A modified data frame with 'site', 'hist', and 'behav' columns split 
#'    into multiple values and converted to numeric values.
#' @examples
#' data <- data.frame(site = "C50.1, C50.2", hist = "8000, 8010", behav = "3, 2")
#' build_codes(data)
#' @noRd
build_codes <- function(x) {

  # Define the split pattern for splitting the string into multiple values
  split_pattern <- ",\\s*" # comma followed by zero or more spaces

  # Check if 'site' column is present in the input data
  if ("site" %in% colnames(x)) {
    
    # Split the 'site' column values into multiple values
    x$site1 <- strsplit(x$site, split_pattern)

    # Convert the multiple values in each row to numeric values
    x$site2 <- lapply(x$site1,
      function(y) {
        unlist(lapply(y, convert_numeric))
      }
    )

    # Assign the newly created values to 'site' column
    x$site <- x$site2

    # Remove intermediate columns
    x$site1 <- x$site2 <- NULL
  }

  # Check if 'hist' column is present in the input data
  if ("hist" %in% colnames(x)) {

    # Split the 'hist' column values into multiple values
    x$hist1 <- strsplit(x$hist, split_pattern)

    # Convert the multiple values in each row to numeric values
    x$hist2 <- lapply(x$hist1, 
      function(y) {
        unlist(lapply(y, convert_numeric))
      }
    )

    # Assign the newly created values to 'hist' column
    x$hist <- x$hist2

    # Remove intermediate columns
    x$hist1 <- x$hist2 <- NULL
  }

  # Check if 'behav' column is present in the input data
  if ("behav" %in% colnames(x)) {

    # Split the 'behav' column values into multiple values
    x$behav1 <- strsplit(x$behav, split_pattern)

    # Convert the multiple values in each row to numeric values
    x$behav2 <- lapply(x$behav1,
      function(y) {
        unlist(lapply(y, convert_numeric))
      }
    )

    # Assign the newly created values to 'behav' column
    x$behav <- x$behav2

    # Remove intermediate columns
    x$behav1 <- x$behav2 <- NULL
  }

  # Return the modified data frame
  return(x)
}