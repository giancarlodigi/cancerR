#' Convert ICD-O-3 topography codes
#'
#' @description
#' Converts ICD-O-3 topography codes in to a numeric format.
#' It removes the "C" from the beginning of the string if present, and ensures
#' that the codes are valid ICD-O-3 site codes.
#'
#' @param x The ICD-O-3 site codes to be converted.
#' @param validate Logical indicating whether to make the converted values
#' have valid ICD-O-3 sites codes between C00.0 and C97.0, setting any invalid
#' codes to `NA`. Default value is `TRUE`.
#'
#' @return Returns a converted ICD-O-3 topography code in a numeric format.
#'
#' @details
#' Takes in a character or numeric vector of ICD-O-3 site codes and converts
#' them to a standardized numeric format. The function will remove the "C"
#' from the beginning of the string if present. It will also automatically
#' detect if the codes have are in decimal ("C34.1") or integer ("C341") format
#' and convert them.
#'
#' If \code{validate} is set to `TRUE`, the function checks if the topography
#' codes are valid ICD-O-3 site codes for neoplasms which range from
#' C00.0 to C97.0. Any invalid codes will be set to `NA` and a warning will be
#' issued indicating the number of invalid codes found.
#'
#' @examples
#' # Character input with and without "C" at the beginning
#' site_convert(c("C80.1", "C34.1", "C50.3", "C424", "80.9"))
#'
#' # Numeric input
#' site_convert(c(80.1, 8.1, 81, 708)) # Numeric input
#' @export
site_convert <- function(x, validate = TRUE) {
  # Remove the "C" from the beginning of the string
  if (is.character(x)) {
    x <- gsub("^C", "", x)
  }

  if (is.numeric(x)) {
    x <- as.character(x)
  }

  if (any(grepl("\\.\\d{2}$", x))) {
    stop("ICD-O-3 site codes should not have two digits after the dot.")
  }

  x <- ifelse(
    grepl("\\d{1-2}\\.\\d{1}$", x),
    as.numeric(x) * 10,
    ifelse(
      grepl("\\d{3}", x) & !grepl("\\.", x),
      as.numeric(x),
      ifelse(
        grepl("\\d{2}", x) & !grepl("\\.", x),
        as.numeric(x) * 10,
        NA_real_
      )
    )
  )

  # Ensure the values are valid ICD-O-3 site codes
  if (validate) {
    num_pre <- sum(is.na(x))

    invalid_codes <- !(x >= 0 & x <= 970)
    x[invalid_codes] <- NA_real_

    num_invalid <- sum(is.na(x))
    if (num_invalid != num_pre) {
      warning(paste0("There were ", num_invalid - num_pre, " invalid ICD-O-3 site codes found and set to NA."))
    }
  }

  return(as.integer(x))
}
