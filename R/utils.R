#' Unnest lookup table
#'
#' @description
#' This function unnests a lookup table by repeating rows based on the
#' length of the list-columns and replacing them with vectors.
#'
#' @param data A data frame representing the lookup table.
#'
#' @return A data frame with the list-columns unnested.
#' @noRd
unnest_lookup_table <- function(data) {
  # Check if the input is a data frame
  if (!is.data.frame(data)) {
    stop("Input must be a data frame")
  }

  # Check if the specified columns exist in the data frame
  columns <- c("hist", "site", "behav")
  missing_columns <- setdiff(columns, colnames(data))
  if (length(missing_columns) > 0) {
    stop(paste("Missing columns:", paste(missing_columns, collapse = ", ")))
  }

  # Unnest the columns one by one
  for (column in columns) {
    # Check if the column is a list-column
    if (!is.list(data[[column]])) {
      stop(paste("Column", column, "is not a list-column"))
    }

    # Repeat rows by the length of the list in the column
    repeat_rows <- sapply(data[[column]], length)
    repeated_data <- data[rep(1:nrow(data), repeat_rows), , drop = FALSE]

    # Replace the list-column with a vector
    repeated_data[[column]] <- unlist(data[[column]], use.names = FALSE)

    data <- repeated_data
  }

  # Return the unnested data
  return(data)
}

#' Lookup search function
#'
#' @description
#' This function performs a search lookup operation on two vectors.
#'
#' @param look_vect The vector containing the lookup values.
#' @param x_vect The vector to be searched.
#'
#' @return A logical matrix indicating whether each element in \code{x_vect} is found in \code{look_vect}.
#'
#' @examples
#' look_vect <- c("apple", "banana", "orange")
#' x_vect <- c("apple", "grape", "banana", "kiwi")
#' search_lookup(look_vect, x_vect)
#'
#' @noRd
search_lookup <- function(look_vect, x_vect) {
  sapply(look_vect, function(y) x_vect %in% y)
}

#' Find Match Index
#'
#' @description
#' This function finds the indices of matches in a lookup table and handles
#' cases where there are no matches or multiple matches.
#'
#' @param results A matrix of results where each element is 1 if there is a match and 0 otherwise.
#' @param expected_length An integer representing the expected length of the result vector.
#'
#' @return An integer vector of indices. The vector will contain:
#' \itemize{
#'   \item The row index of the lookup table corresponding to the row number in the input data.
#'   \item \code{1234567890} for no match.
#'   \item \code{0987654321} for multiple matches.
#' }
#' @noRd
find_match_index <- function(results, expected_length) {
  # Empty vector to store the indices to use for the diagnostic levels
  idx <- vector("integer", expected_length)

  # Empty vectors to store the positions of the duplicate rows or no match found
  idx_none <- NULL
  idx_mult <- NULL

  # Transpose the results if the vector length is 1
  if (expected_length == 1) {
    results <- t(results)
  }

  # Check for no match or duplicate matches
  if ( !sum(colSums(results)) == expected_length ) {
    # Check for no match
    if ( (sum(colSums(results)) - expected_length ) < 0) {
      # Get the positions of the duplicate rows
      idx_none <- which(colSums(results) == 0)

      # Print each of the indices of the duplicate rows
      #warning("No match found at index: ", paste(idx_none, collapse = ", "))
    }

    # Check for duplicate matches
    if ( (sum(colSums(results)) - expected_length ) > 0 ) {
      # Get the positions of the duplicate rows
      idx_mult <- which(colSums(results) > 1)

      # Print each of the indices of the duplicate rows
      #warning("Duplicate matches found at index: ", paste(idx_mult, collapse = ", "))
    }
  }

  # Find where it found a match in lookup table
  pos_df <- as.data.frame(which(results == 1, arr.ind = TRUE))

  # Insert the row index of the lookup table which corresponds to the row num
  # in the input data
  idx[pos_df$col] <- pos_df$row

  # Add identifiers to the index vector where there was
  # - 1234567890 = no match
  # - 0987654321 = multiple matches
  if (!is.null(idx_none)) {
    idx[idx_none] <- 1234567890
  }

  if (!is.null(idx_mult)) {
    idx[idx_mult] <- 0987654321
  }

  return(idx)
}

#' Determine errors in a vector
#'
#' @description
#' This function determines the positions of errors (no match or duplicates) in a given vector 
#' based on the specified error type. The input `x` is a the numeric vector
#' ouput by the \code{find_match_index()} function.
#'
#' @param x A numeric vector to check for errors.
#' @param type A character string specifying the type of error to check for.
#'  Possible values are "none" and "mult".
#'
#' @return A numeric vector containing the positions of errors, or NULL if no errors are found.
#'
#' @examples
#' x <- c(1, 2, 3, 1234567890, 5)
#' determine_errors(x, "none")
#' # Output: 4
#'
#' x <- c(1, 2, 3, 4, 5)
#' determine_errors(x, "none")
#' # Output: NULL
#'
#' x <- c(1, 2, 3, 0987654321, 5)
#' determine_errors(x, "mult")
#' # Output: 4
#'
#' x <- c(1, 2, 3, 4, 5)
#' determine_errors(x, "mult")
#' # Output: NULL
#' @noRd
determine_errors <- function(x, type) {

  if (type == "none") {
    pos <- which(x == 1234567890)
  } else if (type == "mult") {
    pos <- which(x == 0987654321)
  }

  if (length(pos) > 0) {
    return(pos)
  } else if (length(pos) == 0) {
    return(NULL)
  }
}


#' Validate the depth for the lookup table
#'
#' @description
#' This function validates the depth parameter for classification. The depth parameter
#' specifies the maximum depth of the classification tree. It should be between 1 and
#' the maximum depth of the input data.
#'
#' @param x Lookup table to be checked
#' @param depth Depth parameter specified by the user
#'
#' @return This function does not return anything. It throws an error if the depth
#' parameter is invalid.
#' @noRd
validate_depth <- function(x, depth) {

  dep <- grep("pos_", colnames(x), value = TRUE)
  dep <- max(as.integer(gsub("pos_", "", dep)))

  if ( (depth > dep | depth < 1) && depth != 99) {
    stop("Depth for classification is must be between 1 and ", dep)
  }

}

#' Get the lookup table based on the specified method.
#'
#' @description
#' This function returns the lookup table based on the specified method for
#' cancer classification.
#'
#' @param method The method for cancer classification.
#' @param long Logical indicating whether to return the long format of the lookup table.
#' @return The lookup table based on the specified method.
#' @examples
#' get_lookup_table("Barr 2020")
#' get_lookup_table("iccc3", long = TRUE)
#' @noRd
get_lookup_table <- function(method, long = FALSE){

  # Adolescent and young adult (AYA) cancer classification -------------------
  if (method == "Barr 2020") {
    lookup_table <- lookup_tables$AYA_Barr_2020
  } else if (method == "SEER v2006") {
    lookup_table <- lookup_tables$AYA_seer_2006
  } else if (method == "SEER v2020") {
    lookup_table <- lookup_tables$AYA_seer_2020re
  } else if (method == "SEER-WHO v2008") {
    lookup_table <- lookup_tables$AYA_seer_WHO2008
  } else

  # Pediatric cancer classification -----------------------------------------
  if (method == "iccc3") {
    lookup_table <- lookup_tables$ICCC_3e_2005_ext
  } else if (method == "who-iccc3") {
    lookup_table <- lookup_tables$ICCC_WHO2008
  } else if (method == "iarc2017") {
    lookup_table <- lookup_tables$ICCC_3e_IARC2017
  } else {
    stop("Invalid method specified")
  }

  if (long) {
    lookup_table <- unnest_lookup_table(lookup_table)
  }

  return(lookup_table)
}
