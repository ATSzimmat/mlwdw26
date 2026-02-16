
<img src="images/clipboard-520238277.png" width="175" />

# mlwdw26 (MLW Data Wrangling 2026)

Welcome to the R package mlwdw26 – a new tool for organizing the data
generated in the creation of the Medieval Latin Dictionary (MLW), which
is being developed at the Bavarian Academy of Sciences (BAdW) since
1939!

## Motivation

## Functions & Workflow

### convert_doc

#### Description

This function converts .doc-files to .txt files using the LibreOffice
program. The files used in the example are automatically loaded with the
package and should be located in your project folder as a folder named
“toy”, after you installed the package. Note: This function requires
LibreOffice to be located in a folder named “Applications” and that you
are currently using a Mac.

#### Usage

    convert_doc(doc_folder)

with doc_folder being a path to a certain folder containing .doc-files.

#### Value

A new folder was created containing the converted files. The name of
this folder is the same as the folder containing the .doc-files, with
“\_txt” appended to the end.

#### Example

    # Convert the .doc-files from a example folder with .doc-files from the toy folder
    convert_doc(doc_folder = "toy/toy_doc")

## Installation

You can install and use the current version of mlwdw26 after you
executed this in R:

    install.packages("remotes")
    remotes::install_github("ATSzimmat/mlwdw26")
    library(mlwdw26)
