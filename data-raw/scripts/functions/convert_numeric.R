#' Convert Character to Numeric or Integer Sequence
#'
#' This function converts a character string representing a single numeric value or 
#' a range of numeric values into an integer or a sequence of integers. 
#' It handles missing values and specific ranges.
#'
#' @param x A character string representing a single numeric value or a range 
#'    of numeric values separated by a hyphen.
#'
#' @return An integer or a sequence of integers. If the input is a single numeric value, 
#'    it returns an integer. If the input is a range, it returns a sequence of integers. 
#'    If the input is missing, it returns \code{NA_integer_}.
#'
#' @examples
#' convert_numeric("123")
#' convert_numeric("100-105")
#' convert_numeric(NA)
#' @noRd
convert_numeric <- function(x) {

  # if no site code, preserve missing integer
  if (is.na(x)) {
    NA_integer_
  }

  # check if hyphen exists in character element which denotes a range of site codes
  else if (grepl("[-–]", x)) {

    # if hyphen exists, convert to sequence of numeric values
    if (x == '000-809') {
      range <- as.integer(strsplit(x, "[-–]")[[1]])

      # add NA to the beginning of the sequence to include possibility if site code is missing
      c(NA_integer_, seq(range[1], range[2]))
    } else {
      range <- as.integer(strsplit(x, "[-–]")[[1]])

      # sequence of integers from the first to the second element of the range
      seq(range[1], range[2])
    }

  } else {

    # if hyphen does not exist and is just a single site, convert to integer value
    as.integer(x)
  }
}
