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

  # Use the internal classification function
  return(classify_internal(histology, site, NULL, lookup_table, depth, verbose))
}
