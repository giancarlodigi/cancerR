#
# Purpose:  Create the lookup tables for the ICCC-3 classification system using the HTML files from the public SEER website.
#           https://seer.cancer.gov/iccc/
#
# Save path : data-raw/processed/
#
#
# References:
#   Steliarova-Foucher E, Stiller C, Lacour B, Kaatsch P. International Classification of Childhood Cancer, Third Edition.
#   Cancer 2005;103:1457-67.
#
#   Steliarova-Foucher E, Colombet M, Ries LAG, Rous B, Stiller CA. Classification of tumours. In: Steliarova-Foucher E,
#   Colombet M, Ries LAG, Moreno F, Dolya A, Shin HY, Hesseling P, Stiller CA. International Incidence of Childhood Cancer
#   Volume III. Lyon: International Agency for Research on Cancer, In press.
#
from bs4 import BeautifulSoup
import pandas as pd
import re


# Function to create the lookup table
def create_lookup(file, hist_id, site_id, behav_id, seer_id, seer_grp_id):

    # Specify where to find the files
    input_file = "data-raw/raw/html/" + file + ".html"
    save_path = "data-raw/processed/"

    # Criteria to filter out the datasets later on
    filter_hist = "hist != ''"

    # Read in the file
    with open(input_file, "r") as f:
        html = f.read()

    # Create the empty dataset
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
    pos_1 = pos_2 = pos_3 = pos_4 = pos_5 = pos_6 = hist = site = behav = seer_grp = (
        seer_grp_ext
    ) = ""

    # Create the empty dataset
    output_data = pd.DataFrame(columns=cols)

    # Read the html file and find the tables contained within
    soup = BeautifulSoup(html, "html.parser")
    table = soup.find("table")

    # Find the table body
    table_body = table.find("tbody")

    # Loop each row of the table
    for row in table_body.find_all("tr"):

        # Reset the histology and site codes for each table row
        hist = site = ""

        # Find if it is a header, which denotes the major table positions
        header = row.find("th")

        # If it is a header, then get the position
        if header:
            # Check the 11. category and puts in 'secthead' since it is missing
            th_class = header.get("class") if header.get("class") else ["secthead"]

            # Get the position 1
            if (
                "secthead" in th_class
                and "left_indent_l2" not in th_class
                and "left_indent_l3" not in th_class
            ):
                pos_1 = header.text
                pos_2 = pos_3 = pos_4 = pos_5 = pos_6 = site = hist = behav = (
                    seer_grp
                ) = seer_grp_ext = ""

            # Get the position 2
            if "secthead" in th_class and "left_indent_l2" in th_class:
                pos_2 = header.text
                pos_3 = pos_4 = pos_5 = pos_6 = site = hist = behav = seer_grp = (
                    seer_grp_ext
                ) = ""

            # Get the position 3
            if "secthead" in th_class and "left_indent_l3" in th_class:
                pos_3 = header.text
                pos_4 = pos_5 = pos_6 = site = hist = behav = seer_grp = (
                    seer_grp_ext
                ) = ""

        # In each row, look through the data elements
        table_data = row.find_all("td")
        for data in table_data:

            # Retinoblastoma has weird HTML tree notation for the ICCC, so this is to grab that
            # this is bc the data is contained within the header line
            if data.find_all("strong") and data.text.startswith("V."):
                pos_1 = data.text
                pos_2 = pos_3 = pos_4 = pos_5 = pos_6 = site = hist = behav = (
                    seer_grp
                ) = seer_grp_ext = ""

            # Get the pos_ statements from the class elements in each table data line
            td_class = data.get("class")
            if td_class:

                # Position 2
                if td_class[0] == "left_indent_l2":
                    pos_2 = data.text.strip()
                    pos_3 = pos_4 = pos_5 = pos_6 = ""
                else:
                    pos_2 = pos_2

                # Position 3
                if td_class[0] == "left_indent_l3":
                    pos_3 = data.text.strip()
                    pos_4 = pos_5 = pos_6 = ""
                else:
                    pos_3 = pos_3

                # Position 4
                if td_class[0] == "left_indent_l4":
                    pos_4 = data.text.strip()
                    pos_5 = pos_6 = ""
                else:
                    pos_4 = pos_4
                    # pos_4 = pos_5 = pos_6 = ''

                # Position 5
                if td_class[0] == "left_indent_l5":
                    pos_5 = data.text.strip()
                    pos_6 = ""
                else:
                    pos_5 = pos_5

                # Position 5
                if td_class[0] == "left_indent_l6":
                    pos_6 = data.text.strip()
                else:
                    pos_6 = pos_6

            # Get the histology, site, behavior, and SEER group codes
            hist = (
                data.text.strip()
                if data.get("headers")[0].startswith(hist_id)
                else hist
            )
            site = (
                data.text.strip()
                if data.get("headers")[0].startswith(site_id)
                else site
            )
            behav = (
                data.text.strip()
                if data.get("headers")[0].startswith(behav_id)
                else behav
            )
            seer_grp_ext = (
                data.text.strip()
                if data.get("headers")[0].startswith(seer_grp_id)
                else seer_grp_ext
            )
            seer_grp = (
                data.text.strip()
                if data.get("headers")[0].startswith(seer_id)
                else seer_grp
            )

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
        output_data.loc[:, col] = output_data[col].str.replace(
            r"\s{2,}", " ", regex=True
        )

        # Remove the special characters from the end of the string
        output_data.loc[:, col] = output_data[col].str.replace(
            r"[@*#]$", "", regex=True
        )
        output_data.loc[:, col] = output_data[col].str.replace(
            r"\(if collected\)", "", regex=True
        )
        output_data.loc[:, col] = output_data[col].str.replace(
            r"\(not collected by some registries\)", "", regex=True
        )
        output_data.loc[:, col] = output_data[col].str.replace(
            r"\(all behaviors\)", "", regex=True
        )

    # Remove the C and . from the site codes
    output_data["site"] = output_data["site"].str.replace("[C\\.]", "", regex=True)

    # Filter the dataset to remove rows without a histology code
    output_data = output_data.query(filter_hist)

    # Check if the entire column is empty, and if it is, remove it
    for col in output_data.columns:
        # check if all rows in the column are empty
        if (
            output_data[col].isnull().all()
            or output_data[col].isna().all()
            or (output_data[col] == "").all()
        ):
            # remove the column from the dataframe
            output_data = output_data.drop(col, axis=1)

    # Write the CSV file
    output_data.to_csv(save_path + file + ".csv", index=False)


# ICCC-3 Main file:                     https://seer.cancer.gov/iccc/iccc3.html
# ICCC-3 Extended file:                 https://seer.cancer.gov/iccc/iccc3_ext.html
# ICCC recode ICD-O-3/WHO 2008 file:    https://seer.cancer.gov/iccc/iccc-who2008.html
# ICCC-3 / IARC 2017:                   https://seer.cancer.gov/iccc/iccc-iarc-2017.html

# ICCC-3 main table
create_lookup(
    "ICCC_3e_2005",
    hist_id="x2",
    site_id="x3",
    behav_id="N/A",
    seer_id="x4",
    seer_grp_id="N/A",
)

# ICCC-3 extended table
create_lookup(
    "ICCC_3e_2005_ext",
    hist_id="x2",
    site_id="x3",
    behav_id="N/A",
    seer_id="x4",
    seer_grp_id="N/A",
)

# ICCC-3 / WHO2008 classification
create_lookup(
    "ICCC_WHO2008",
    hist_id="x3",
    site_id="x2",
    behav_id="x4",
    seer_id="x5",
    seer_grp_id="x6",
)

# ICCC-3 / IARC2017 classification
create_lookup(
    "ICCC_3e_IARC2017",
    hist_id="x2",
    site_id="x3",
    behav_id="x4",
    seer_id="x6",
    seer_grp_id="x5",
)
