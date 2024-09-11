#' Adolescent and young adult cancer classification
#'
#' @description
#' This function classifies the type of adolescent and young adult cancer cases
#' based on the histology, site, and behaviour codes of the cancer. It uses the
#' International Classification of Diseases for Oncology (ICD-O), 3rd edition
#' codes to determine the classification. The function returns a value is based
#' on the method specified and the depth level of the classification hierarchy
#' to be determined.
#'
#' @param histology Histology code of the cancer.
#' @param site Site (aka topography) code of the cancer.
#' @param behaviour Behaviour code of the cancer.
#' @param method Method used for the diagnosis classification of the cancer.
#'    Default is \code{"Barr 2020"}. 
#'    Can be one of \code{"Barr 2020"}, \code{"SEER v2006"},
#'    \code{"SEER v2020"}, \code{"SEER-WHO v2008"}.
#' @param depth Depth level of the classification hierarchy to be determined.
#'    If set to \code{99}, will return the SEER grouping.
#' @param verbose Logical value to print messages to the console if unable to 
#'    classify or duplicates found. Default is \code{FALSE}.
#'
#' @return
#' Returns the diagnostic classification of the cancer based on the specified
#' method and depth level.
#'
#'
#' @export
#'
#' @examples
#' # First position in the classification hierarchy
#' aya_class("9020", "C50.1", "3", method = "Barr 2020", depth = 1)
#'
#' # Second position in the classification hierarchy
#' aya_class("9020", "C50.1", "3", method = "Barr 2020", depth = 2)
#'
#' # Third position in the classification hierarchy
#' aya_class(9020, "C50.1", "3", method = "Barr 2020", depth = 3)
aya_class <- function(histology, site, behaviour, method = "Barr 2020", depth = 1, verbose = FALSE) {
  # Assuming 'method' variable holds the method type
  if (!method %in% c("Barr 2020", "SEER v2006", "SEER v2020", "SEER-WHO v2008")) {
    stop("Invalid method specified, needs to be one of 'Barr 2020', 'SEER v2006', 'SEER v2020', 'SEER-WHO v2008'")
  }

  # Get the lookup table based on the method specified
  lookup_table <- get_lookup_table(method)

  # Check max depth
  validate_depth(lookup_table, depth)

  # Length of histology, site, and behaviour columns should be the same
  if (length(histology) != length(site) | length(histology) != length(behaviour)) {
    stop("Length of histology, site, and behaviour columns should be the same")
  }

  # Check if the SEER grouping is available for the specified method
  if (depth == 99 && method == "Barr 2020") {
    stop("SEER grouping is not available for Barr 2020 method")
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
      search_lookup(lookup_table[["site"]], site) *
      search_lookup(lookup_table[["behav"]], behaviour)
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
