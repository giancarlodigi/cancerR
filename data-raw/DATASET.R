
# Source the functions needed to process the data
list.files("data-raw/scripts/functions/", full.names = T) |> 
  purrr::walk(source)

# Set the python environment
reticulate::use_condaenv("/opt/homebrew/Caskroom/miniforge/base/envs/package-dev")

# Source the scripts to download and process the data
source("data-raw/scripts/1_seer-aya.R")
reticulate::source_python("data-raw/scripts/2_seer-kids.py")
reticulate::source_python("data-raw/scripts/3_aya-Barr.py")

# Create a list of files in the path
file_list <- list.files("data-raw/processed", full.names = TRUE, pattern = ".csv$")

# Removes the file path from the file names and strips the .csv extension
file_names <- gsub(".csv", "", basename(file_list))

# Read each CSV file into a list of data frames
lookup_tables <- lapply(file_list, read.csv)

# Set names of data frames in the list to the corresponding file names
names(lookup_tables) <- file_names

# Apply the build_codes() function to each data frame in the list
lookup_tables <- lapply(lookup_tables, build_codes)

# Factorize the position columns and preserve their ordering
lookup_tables <-
  purrr::map(
    lookup_tables,
    ~ dplyr::mutate(
      .x,
      dplyr::across(
        .cols = tidyselect::starts_with("pos_"),
        .fns = ~ factor(.x, levels = unique(.x[nzchar(.x)]), labels = unique(.x[nzchar(.x)]))
      )
    )
  )

# Save the lookup tables for internal use
usethis::use_data(lookup_tables, overwrite = TRUE, internal = TRUE)
