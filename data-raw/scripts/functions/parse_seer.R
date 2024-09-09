#' Extracts the SEER level from a string.
#'
#' This function takes a string and splits it into two parts based on the first occurrence
#' of a space character. It then returns the first part of the split string, representing
#' the first level.
#'
#' @param x Input string to be split.
#' @return The first level of the input string.
extract_lvl <- function(x) {
  stringr::str_split(x, "\\s", n = 2) |>
    purrr::pluck(1, 1)
}

#' Manipulates the SEER data to create lookup tables.
#'
#' This function takes a data frame and manipulates it to create lookup tables for the
#' SEER data.
#'
#' Output is saved to the data-raw/processed/ dir
#' 
#' @param x Input data frame to be manipulated.
#' @param save_name Name of the file to save the output to.
#' @return NULL
parse_seer <- function(x, save_name) {
  df <- x |>
    tidyr::fill(label)

  # Find where the Unclassified row is located
  IDX_STOP <- min(which(df$label == "Unclassified")) - 1

  # Subset the data
  df <- df[1:IDX_STOP, ]

  # Determine level
  df <- df |>
    dplyr::rowwise() |>
    dplyr::mutate(
      # Use the number of periods to determine the level
      lvl = stringr::str_split(label, "\\s", n = 2) |>
        purrr::map(purrr::pluck, 1) |>
        purrr::map_dbl(stringr::str_count, "\\."),
      lvl = lvl + 1
    ) |>
    dplyr::ungroup()

  # Create a column for each level
  for (i in seq_len(max(df$lvl))) {
    df <- df |>
      dplyr::mutate(
        !!dplyr::sym(paste0("pos_", i)) := ifelse(
          lvl == i,
          stringr::str_squish(label),
          NA_character_
        )
      )
  }

  # Filter to the valid rows
  df_valid <- df |>
    tidyr::fill(dplyr::starts_with("pos"))

  # Validate the position columns since fill was used
  for (i in 2:max(df_valid$lvl)) {
    df_valid <- df_valid |>
      dplyr::rowwise() |>
      dplyr::mutate(
        !!dplyr::sym(paste0("pos_", i)) := ifelse(
          stringr::str_starts(
            string = !!dplyr::sym(paste0("pos_", i)),
            pattern = extract_lvl(!!dplyr::sym(paste0("pos_", i - 1)))
          ),
          !!dplyr::sym(paste0("pos_", i)),
          NA_character_
        )
      ) |>
      dplyr::ungroup()
  }

  # Reorder the columns
  df_valid <- df_valid |>
    dplyr::select(dplyr::starts_with("pos"), hist, site, behav, seer_grp) |>
    dplyr::mutate(
      dplyr::across(
        .cols = c(hist, site, behav, seer_grp),
        .fns = ~ dplyr::na_if(stringr::str_trim(.), "")
      ),
      # Strip any special characters from the end of the string
      dplyr::across(
        dplyr::starts_with("pos_"),
        ~ stringr::str_replace_all(.x, "[^a-zA-Z0-9\\)]+$", "")
      ),

      # Remove unnecessary text from the end of the string
      dplyr::across(
        dplyr::starts_with("pos_"),
        ~ stringr::str_replace_all(
          .x, 
          "\\(if collected\\)|\\(not collected by some registries\\)|\\(all behaviors\\)", 
          ""
        )
      ),

      # Remove any leading or trailing whitespace
      dplyr::across(
        .cols = dplyr::where(is.character),
        .fns = stringr::str_squish # ~ str_replace_all(., "[\r\n]+", " ")
      ),

      # Remove "C" from the site column
      site = stringr::str_remove_all(site, "C")
    ) |>
    dplyr::filter(
      !(is.na(hist) & is.na(site) & is.na(behav))
    )

  # Save the output
  write.csv(
    df_valid,
    file = paste0("data-raw/processed/", save_name, ".csv"),
    row.names = F,
    na = ""
  )
}
