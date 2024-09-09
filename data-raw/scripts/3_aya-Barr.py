#
# Purpose:  Create the lookup tables Barr et al's cancer classification system.
#           https://doi.org/10.1002/cncr.33041 
#
# Save path : data-raw/processed/
#
#
# Functionality: 
#   Parse html files and extract the classification system for adolescents and young adults (AYA).
#   Incorporate the erratum updates to the original classification tables.
#
#
# Reference: 
#   Barr RD, Ries LAG, Trama A, Gatta G, Steliarova-Foucher E, Stiller CA, Bleyer WA. 
#   A system for classifying cancers diagnosed in adolescents and young adults. 
#   Cancer. 2020 Nov 1;126(21):4634-4659. doi: 10.1002/cncr.33041. Epub 2020 Sep 9. 
#   Erratum in: Cancer. 2021 Aug 15;127(16):3035-3040. doi: 10.1002/cncr.33481. PMID: 32901932.
#   
#
import pandas as pd
from bs4 import BeautifulSoup

# Criteria to filter out the datasets later on
filter_hist = "hist != ''"

# Location of the raw data
raw_file_loc = "data-raw/raw/html/"

# Make the empty dataframe
cols = [
    "pos_1",
    "pos_2",
    "pos_3",
    "pos_4",
    "pos_5",
    "pos_6",
    "hist",
    "site",
    "behav",
    "seer_grp",
    "seer_grp_ext",
]

# Empty variables to store the data
pos_1 = (
    pos_2
) = pos_3 = pos_4 = pos_5 = pos_6 = hist = site = behav = seer_grp = seer_grp_ext = ""

# set the output dataframe
output_data = pd.DataFrame(columns=cols)

# Original paper tables
file = "AYA_Barr_2020.html"
file_name = raw_file_loc + file

# Read the HTML file
with open(file_name, "r") as f:
    html = f.read()

# Parse the HTML
soup = BeautifulSoup(html, "html.parser")
tables = soup.find_all("tbody")

#################################

# Erratum updates
file = "AYA_Barr_2020_erratum.html"
file_name = raw_file_loc + file

# Read the HTML file
with open(file_name, "r") as f:
    html = f.read()

# Parse the HTML
soup = BeautifulSoup(html, "html.parser")
tables_e = soup.find_all("tbody")

# Subset to only the classification tables
tables_final = tables[1:8]

# Overwrite the original tables using the erratum tables
tables_final[0] = tables_e[0]
tables_final[1] = tables_e[1]
tables_final[5] = tables_e[2]
tables_final[6] = tables_e[3]

# for each table in the table
for i, tbl in enumerate(tables_final):

    # for each row in that table
    for row in tbl.find_all("tr"):

        # Reset the histology and site codes for each table row
        hist = site = ""

        # for each data cell in that row
        for data in row.find_all("td"):

            # Get the class and style attributes
            data_class = data.get("class")
            data_style = data.get("style")

            # This denotes the group headings
            if "right-bordered-cell" in data_class:

                if i != 5:
                    if data_style is None and data.text != "":
                        pos_1 = data.contents[0].strip()
                        pos_2 = pos_3 = pos_4 = pos_5 = pos_6 = ""
                    if data_style == "padding-left:2em;":
                        pos_2 = data.contents[0].strip()
                        pos_3 = pos_4 = pos_5 = pos_6 = ""
                    if data_style == "padding-left:4em;":
                        pos_3 = data.contents[0].strip()
                        pos_4 = pos_5 = pos_6 = ""
                    if data_style == "padding-left:6em;":
                        pos_4 = data.contents[0].strip()
                        pos_5 = pos_6 = ""
                    if data_style == "padding-left:8em;":
                        pos_5 = data.contents[0].strip()
                        pos_6 = ""
                    if data_style == "padding-left:10em;":
                        pos_6 = data.contents[0].strip()

                else:
                    if data_style is None and data.text != "":
                        pos_2 = data.contents[0].strip()
                        pos_3 = pos_4 = pos_5 = pos_6 = ""
                    if data_style == "padding-left:2em;":
                        pos_3 = data.contents[0].strip()
                        pos_4 = pos_5 = pos_6 = ""
                    if data_style == "padding-left:4em;":
                        pos_4 = data.contents[0].strip()
                        pos_5 = pos_6 = ""
                    if data_style == "padding-left:6em;":
                        pos_5 = data.contents[0].strip()
                        pos_6 = ""
                    if data_style == "padding-left:8em;":
                        pos_6 = data.contents[0].strip()

            # Get the behaviour code from the cells with 'center-aligned' class
            if "center-aligned" == data_class[0]:
                behav = data.text.strip()

            # Histology and site codes are in the cells with 'left-aligned' class
            if "left-aligned" == data_class[0]:

                # If the text starts with C, denoting the site, then put it into site, otherwise it's a histology code
                if not (
                    not data.text.strip().startswith("C")
                    and not (data.text.strip() == "")
                ):
                    site = data.text.strip()
                else:
                    hist = data.text.strip()

        # Append the results to the dataset
        output_data = pd.concat(
            [
                output_data,
                pd.DataFrame(
                    [
                        {
                            "pos_1": pos_1,
                            "pos_2": pos_2,
                            "pos_3": pos_3,
                            "pos_4": pos_4,
                            "pos_5": pos_5,
                            "pos_6": pos_6,
                            "hist": hist,
                            "site": site,
                            "behav": behav,
                            "seer_grp": seer_grp,
                            "seer_grp_ext": seer_grp_ext,
                        }
                    ]
                ),
            ],
            ignore_index=True,
        )

# loop through all string columns and replace any occurrence of two consecutive spaces with only one
for col in output_data.select_dtypes(include=["object"]):

    # Remove two or more consecutive spaces
    output_data.loc[:, col] = output_data[col].str.replace(r"\s{2,}", " ", regex=True)

    # Remove the special characters from the end of the string
    output_data.loc[:, col] = output_data[col].str.replace(r"[@*#]$", "", regex=True)
    output_data.loc[:, col] = output_data[col].str.replace(
        r"\(if collected\)", "", regex=True
    )
    output_data.loc[:, col] = output_data[col].str.replace(
        r"\(not collected by some registries\)", "", regex=True
    )
    output_data.loc[:, col] = output_data[col].str.replace(
        r"\(all behaviors\)", "", regex=True
    )

# Add all possible histology codes to the histology column when it is empty
output_data.loc[output_data["site"] == "", "site"] = "C00.0-C80.9"

# Remove the C and . from the site codes
output_data["site"] = output_data["site"].str.replace("[C\\.]", "", regex=True)

# Filter the dataset to remove rows without a histology code and also remove unneeded columns
output_data = output_data.query(filter_hist)

# Remove any columns that are empty
for col in output_data.columns:
    # check if all rows in the column are empty
    if (
        output_data[col].isnull().all()
        or output_data[col].isna().all()
        or (output_data[col] == "").all()
    ):
        # remove the column from the dataframe
        output_data = output_data.drop(col, axis=1)

# Save the file to the extra_data folder
save_path = "data-raw/processed/"
output_data.to_csv(save_path + "AYA_Barr_2020" + ".csv", index=False)
