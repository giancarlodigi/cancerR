#' Classification of childhood cancer.
#'
#' @description
#' Determines the type of childhood cancer cases based on the histology
#' and site codes of the cancer. It uses the International Classification of Childhood
#' Cancer (ICCC) codes to determine the classification. The function returns a value
#' based on the method specified and the depth level of the classification hierarchy
#' to be determined.
#'
#' @param histology Histology code of the cancer.
#' @param site Site (aka topography) code of the cancer.
#' @param method Method to use for diagnosis classification.
#'    Default is \code{"iccc3"}.
#'    Can be one of \code{"iccc3"}, \code{"who-iccc3"}, \code{"iarc2017"}.
#' @param depth Depth level of the classification hierarchy to be determined.
#'   If set to \code{99}, will return the SEER grouping.
#' @param verbose Logical value to print messages to the console if unable to 
#'    classify or duplicates found. Default is \code{FALSE}.
#'
#' @return
#' Returns the diagnostic classification of the childhood cancer based on the specified
#' method and depth level.
#'
#' @export
#' @examples
#' kid_class("8522", "C50.1", method = "iccc3", depth = 1)
#'
#' kid_class("8970", "C22.0", method = "iccc3", depth = 2)
kid_class <- function(histology, site, method = "iccc3", depth = 1, verbose = FALSE) {

  # Assuming 'method' variable holds the method type
  if (!method %in% c("iccc3", "who-iccc3", "iarc2017")) {
    stop("Invalid method specified, needs to be one of 'iccc3', 'who-iccc3', 'iarc2017'")
  }

  # Get the lookup table based on the method specified
  lookup_table <- get_lookup_table(method)

  # Check max depth
  validate_depth(lookup_table, depth)

  # Length of histology, site, and behaviour columns should be the same
  if (length(histology) != length(site)) {
    stop("Length of histology and columns should be the same")
  }

  # Length of the input data
  LEN <- length(histology)

  # Check formats of the input data
  if (is.character(site)) {
    # Don't force valid ICD-O-3 site codes
    site <- site_convert(site, validate = FALSE)
  }

  # Use matrix multiplication to find the intersection of the search results
  results <- t(
    search_lookup(lookup_table[["hist"]], histology) *
      search_lookup(lookup_table[["site"]], site)
  )

  # Find position in the lookup table index
  positions <- find_match_index(results, LEN)

  # Check for errors and print them to the console
  error_none <- determine_errors(positions, "none")
  error_mult <- determine_errors(positions, "mult")

  # Print messages to the console if verbose is set to TRUE
  if (verbose) {
    if (!is.null(error_none)) {
      message("No match found at index: ", paste(error_none, collapse = ", "), "\n")
    }
    if (!is.null(error_mult)) {
      message(
        "Duplicate matches found at index: ",
        paste(error_mult, collapse = ", "),
        "\n"
      )
    }
  }

  # Get the diagnostic levels from the lookup table based on the depth specified
  if (depth == 99) {
    type <- lookup_table$seer_grp[positions]
  } else {
    type <- lookup_table[[paste0("pos_", depth)]][positions]
  }

  return(type)
}
