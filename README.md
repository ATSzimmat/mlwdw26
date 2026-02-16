
<img src="images/clipboard-520238277.png" width="175" />

# mlwdw26 (MLW Data Wrangling 2026)

Welcome to the R package mlwdw26 – a new tool for organizing the data
generated in the creation of the Medieval Latin Dictionary (MLW), which
is being developed at the Bavarian Academy of Sciences (BAdW) since
1939!

## Motivation

## Functions

### convert_doc

#### Description

This function converts .doc-files to .txt files using the LibreOffice
program. The files used in the example are automatically loaded with the
package and should be located in your project folder as a folder named
“toy”, after you installed the package. This function takes into account
the outdated line-break logic of doc-files. Note: This function requires
LibreOffice to be located in a folder named “Applications” and that you
are currently using a Mac.

#### Output

A new folder was created containing the converted files. The name of
this folder is the same as the folder containing the .doc-files, with
“\_txt” appended to the end.

#### Assumptions

- The folder containing the .doc files contains only .doc files (and no
  other documents or folders).

- The user’s computer (importantly a Mac) has the same LibreOffice
  program installed as the creator’s computer, and it is located in the
  “Applications” folder.

#### Usage

    convert_doc(doc_folder)

with doc_folder being a path to a certain folder containing .doc-files.

#### Example

    # Convert the .doc-files from a example folder with .doc-files from the toy folder
    convert_doc(doc_folder = "toy/toy_doc")

### create_df_2

#### Decription

This function creates a DataFrame from all .txt-files located in the
specified folder, containing the columns “langer_beleg”, “pruef_beleg”
and “pruef_stelle”. The files used in the example were automatically
loaded with the package and should be located in your project folder as
a folder named “toy”, after you installed the package and executed
convert_doc on the doc_folder.

#### Output

An evidence dataset containing the columns “langer_beleg”, “pruef_beleg”
and “pruef_stelle” and that is ready for use with merge_df

#### Usage

    create_df_2(txt_folder)

#### Example

    # Create the evidence dataFrame
    toy_belege <- create_df_2("toy/toy_doc_txt")
    # View the result
    View(toy_belege)

## Installation

You can install and use the current version of mlwdw26 after you
executed this in R:

    install.packages("remotes")
    remotes::install_github("ATSzimmat/mlwdw26")
    library(mlwdw26)
