
<img src="images/clipboard-520238277.png" width="175" />

# mlwdw26 (MLW Data Wrangling 2026)

Welcome to the R package mlwdw26 – a new tool for organizing the data
generated in the creation of the Medieval Latin Dictionary (MLW), which
is being developed at the Bavarian Academy of Sciences (BAdW) since
1939!

## Motivation

## Functions

### *convert_doc*

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

The folder containing the .doc files contains only .doc files (and no
other documents or folders).

The user’s computer (importantly a Mac) has the same LibreOffice program
installed as the creator’s computer, and it is located in the
“Applications” folder.

#### Usage

    convert_doc(doc_folder)

with doc_folder being a path to a certain folder containing .doc-files.

#### Example

    # Convert the .doc-files from a example folder with .doc-files from the toy folder
    convert_doc(doc_folder = "toy/toy_doc")

### *create_df_2*

#### Decription

This function creates a Dataset from all .txt-files located in the
specified folder, containing the columns “langer_beleg”, “pruef_beleg”
and “pruef_stelle”. The files used in the example were automatically
loaded with the package and should be located in your project folder as
a folder named “toy”, after you installed the package and executed
convert_doc on the doc_folder.

The lines of the .txt files are split according to sentences (ending
with . ! or ?), and lines split by entries are merged (words split by
hyphenation are rejoined).

Entries in () and sentences consisting of only one word (one or more
letters) are excluded from this process - the latter is intended, among
other things, to handle abbreviations.

Consecutive word strings in all caps are given their own line.
Beforehand, some cleanup operations are performed that could interfere
with the line splitting process.

Edition references in () are removed from the text file names (e.g.,
(ed. N. Bubnov, Gerberti opera math. 1899. p. 203,7)).

In the event that a sentence ends with an abbreviation and thus part of
the sentence would be cut off, the next sentence is appended to
sentences that are at most 5 words long.

Since there is between the supporting texts and quotations contain an
irregular use of the letters u and v, all v’s are replaced by u.

All non-letters are removed from the reference, and only the first 3
words of the reference are retained.

Afterwards the function creates two new columns from the text column
(long_document and test_document), where the test_document column
reduces words longer than 3 letters and spaces, and converts all
uppercase letters to lowercase

#### Output

An evidence dataset containing the columns “langer_beleg”, “pruef_beleg”
and “pruef_stelle” and that is ready for use with merge_df

#### Assumptions

The folder containing the .txt-files contains only .txt-files (and no
other documents or folders).

The editorial notes in parentheses in the .txt file names have no
special meaning and can be deleted without further ado.

Sentences ending with an abbreviation are no more than 5 words long.

The following expressions in the source material have no special meaning
and can be deleted without further ado:

- Arabic numerals (with a p.:\* or l.:*)* before them or in parentheses
  () or \<\> or \[\] or with \[a-z\] after them or a period

- Roman or Arabic numerals at the beginning of a line (with a period
  after them)\*

- The expression “\t”

- The characters ……/\|\*«»„“+¯\_\<\>”’\[\]

- Any expressions in parentheses

Lines of the following type in the source material (noted as
pseudo-regular expressions) have no special meaning and can be deleted
without further ado:

- Roman or Arabic numerals (with a period after them)\*, which occupy an
  entire line

- “Achtung Sonderzeichen\|Sonderzeichen\|Sonderzeichen
  unterstrichen!\*”, which occupy an entire line

- “Korrektur” as the beginning of a line

- “Rasur von \[arabische Zahl\] Zeile(n)” that occupy an entire line

- “Druckfehler verbessert” that occupy an entire line

- “Latitudo \[Arabic or Roman numeral\]” that occupy an entire line

- “Longitudo \[Arabic or Roman numeral\]”

- “Überstreichungen Korrekturen” that occupy an entire line

- “ACHTUNG: GRIECHISCH” that occupy an entire line

- “Achtung:” as beginning of line

- “Druckfehler verbessert:” as beginning of line

#### Usage

    create_df_2(txt_folder)

with txt_folder being a path to a certain folder containing the
.txt-files.

#### Example

    # Create the evidence dataFrame
    toy_belege <- create_df_2(txt_folder = "toy/toy_doc_txt")
    # View the result
    View(toy_belege)

### *create_df*

#### Description

This function creates a DataFrame from all .mlw-files located in the
specified folder, containing the columns “lemma”, “u\*\_bedeutung”,
“zitat” and “stelle”. The files used in the example were automatically
loaded with the package and should be located in your project folder as
a folder named “toy”, after you installed the package.

#### Output

An article dataset containing the columns “lemma”, “u\*\_bedeutung”,
“zitat” and “stelle” and that is ready for use with merge_df

#### Usage

    create_df(mlw_folder)

with a path to a certain folder containing the .mlw-files.

#### Example

    toy_artikel <- create_df(mlw_folder = "toy/toy_mlw")
    View(toy_artikel)

## Installation

You can install and use the current version of mlwdw26 after you
executed this in R:

    install.packages("remotes")
    remotes::install_github("ATSzimmat/mlwdw26")
    library(mlwdw26)
