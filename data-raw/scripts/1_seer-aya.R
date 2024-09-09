###
###
### This script downloads and processes the SEER Adolescent and Young Adult (AYA)
### Site Recode and ICD-O-3 Histology and Behavior Recode for the following years.
###
###
### Data are publically available from: https://seer.cancer.gov/ayarecode/
###

## Download the data ----------------------------------------------------------

# AYA WHO 2008
download.file(
  "https://seer.cancer.gov/ayarecode/ayarecodewho2008.txt",
  "data-raw/raw/aya-who2008.txt",
  method = "auto"
)

# AYA 2006
download.file(
  "https://seer.cancer.gov/ayarecode/ayarecode.txt",
  "data-raw/raw/aya.txt",
  method = "auto"
)

# AYA 2020 Revision
download.file(
  "https://seer.cancer.gov/ayarecode/ayarecode-2020revision.xlsx",
  "data-raw/raw/aya-2020rev.xlsx",
  method = "auto"
)

## Parse the data ------------------------------------------------------------

# AYA 2020 Revision
"data-raw/raw/aya-2020rev.xlsx" |>
  readxl::read_xlsx() |>
  janitor::clean_names() |>
  dplyr::rename(
    hist = icd_o_3_histology,
    site = icd_o_3_primary_site,
    behav = icd_o_3_behavior,
    seer_grp = recode_value
  ) |>
  dplyr::mutate(
    label = stringr::str_replace(label, "(\\d+|A)\\.\\s", "\\1 "),
    label = ifelse(stringr::str_detect(label, "\\(continued\\)"), NA_character_, label),
    site = stringr::str_replace_all(site, "(\\.|C)", ""),
  ) |>
  parse_seer("AYA_seer_2020rev")

# AYA WHO 2008
"data-raw/raw/aya-who2008.txt" |>
  readr::read_delim(delim = ";", skip = 2, col_names = F) |>
  suppressMessages() |>
  dplyr::rename_with(~ c("label", "behav", "site", "hist", "seer_grp")) |>
  dplyr::mutate(
    label = stringr::str_trim(label),
    label = stringr::str_replace(label, "(\\d+|A)\\.\\s", "\\1 "),
  ) |>
  parse_seer("AYA_seer_WHO2008")

# AYA 2006
"data-raw/raw/aya.txt" |>
  readr::read_delim(delim = ";", skip = 2, col_names = F) |>
  suppressMessages() |>
  dplyr::rename_with(~ c("label", "behav", "site", "hist", "seer_grp")) |>
  dplyr::mutate(
    label = stringr::str_trim(label),
    label = stringr::str_replace(label, "(\\d+|A)\\.\\s", "\\1 "),
  ) |>
  parse_seer("AYA_seer_2006")
