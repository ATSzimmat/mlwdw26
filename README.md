
<img src="images/clipboard-520238277.png" width="175" />

# mlwdw26 (MLW Data Wrangling 2026)

Welcome to the R package mlwdw26 – a new tool for organizing the data
generated in the creation of the Medieval Latin Dictionary (MLW), which
is being developed at the Bavarian Academy of Sciences (BAdW) since
1939!

The primary goal of the package is to organize the articles of the MLW
into a structured tabular format and to supplement and extend the often
rather short quotations provided as evidence in the articles using the
source texts from which these quotations were taken. This was intended,
above all, to provide users of this data with greater transparency and
to enable the application of machine learning methods to the data in
various research contexts.

# Installation

You can install the current version of mlwdw26 by executing this in R:

    install.packages("remotes")
    install.packages("readr")
    remotes::install_github("ATSzimmat/mlwdw26")
    library(mlwdw26)

# Functions

## *convert_doc*

### Description

- This function converts all .doc-files in the specified folder to
  .txt-files using the LibreOffice program and gives back a folder with
  the converted files.

- The folder used in the example below is available on the GitHub
  repository in a folder named “toy”.

- The folder containing the .doc-files you want to convert should be
  located in your project folder before using this function.

- This function takes into account the outdated line-break logic of the
  .doc-files.

- Note: This function requires LibreOffice to be located in a folder
  named “Applications” and that you are currently using a Mac.

### Output

- A new folder was created containing the converted files. The name of
  this folder is the same as the folder containing the .doc-files, with
  “\_txt” appended to the end.

### Assumptions

- The folder with the files you want to convert is located in your
  project folder.

- The folder containing the .doc-files contains only .doc-files (so no
  other documents or even folders containing .doc-files).

- The user’s computer is a Mac and has the same LibreOffice program
  installed as the creator’s computer that it is located in the
  “Applications” folder.

### Usage

    convert_doc(doc_folder)

with doc_folder being a path to a certain folder containing .doc-files.

### Example

    # Convert the .doc-files from an example folder 
    convert_doc(doc_folder = "toy/toy_doc")

## *create_df_2*

### Decription

- This function creates an Evidence-dataset containing the columns
  “langer_beleg”, “pruef_beleg” and “pruef_stelle” from all .txt-files
  located in the specified folder.

  - The column “langer_beleg” contains the source texts whereby each
    line of the dataset only includes one sentence of the respective
    texts.

  - The column “pruef_beleg” includes a simplified version of the
    sentences. (only words longer than 3 letters and spaces, and all
    uppercase letters converted to lowercase.)

  - The column “pruef_stelle” contains the text file names of the texts
    of the source material

- The folder used in the example below is available on the GitHub
  repository in a folder named “toy”. You have to use convert_doc on the
  folder before executing the example code.

- The folder containing the .txt-files you want to use should be located
  in your project folder before using this function.

- You should load that folder in your project folder and you should
  execute convert_doc on the respective files before using this
  function.

- To ensure that each line of the dataset contains only one sentence,
  the lines of the .txt-files are split according to sentences (ending
  with . ! or ?), lines split in other ways are merged and words split
  by hyphenation are rejoined.

- Beforehand, some cleanup operations are performed that could interfere
  with the line splitting process.

  - Entries in () and sentences consisting of only one word are excluded
    from this process - the latter is intended, among other things, to
    handle abbreviations.

  - If a sentence includes an abbreviation, part of the sentence would
    be cut off as a result of the splitting. To handle this, sentences
    with a maximum of five words will be extended by the next sentence.

  - Edition references in () are removed from the text file names (e.g.,
    (ed. N. Bubnov, Gerberti opera math. 1899. p. 203,7)).

  - Consecutive word strings in all caps are given their own line.

  - Since there is between the evidence-sentences and quotations an
    irregular use of the letters u and v, all v’s are replaced by u’s.

- All non-letters are removed from the text file names, and only the
  first 3 words of the text file names are retained.

### Output

- An Evidence-dataset containing the columns “langer_beleg”,
  “pruef_beleg” and “pruef_stelle” and that is ready for use with
  merge_df.

### Assumptions

- The folder you want to use is located in your project folder and you
  have executed convert_doc on the folder containing the .doc-files.

- The folder containing the .txt-files contains only .txt-files (and no
  other documents or folders).

- The editorial notes in () in the text file names have no special
  meaning and can be deleted without further ado.

- Sentences ending with an abbreviation are no more than 5 words long.

- The following expressions in the source material have no special
  meaning and can be deleted without further ado:

  - Arabic numerals (with a p.:\* or l.:) before them or in () or \<\>
    or \[\] or with \[a-z\] after them or a period

  - Roman or Arabic numerals at the beginning of a line (with a period
    after them)\*

  - The expression “\t”

  - The characters …/\|\*«»„“+¯\_\<\>”’\[\]

  - Any expressions in ()

- Lines of the following type in the source material have no special
  meaning and can be deleted without further ado:

  - Roman or Arabic numerals (with or without a point after them), which
    occupy an entire line

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

### Usage

    create_df_2(txt_folder)

with txt_folder being a path to a certain folder containing the
.txt-files.

### Example

    # Create an Evidence-dataset
    toy_belege <- create_df_2(txt_folder = "toy/toy_doc_txt")
    # View the result
    View(toy_belege)

## *create_df*

### Description

- This function creates an Article-dataset from all .mlw-files located
  in the specified folder, containing the columns “lemma”,
  “u\*\_bedeutung”, “zitat” and “stelle”.

  - The column “lemma” contains the specification of the observed lemma

  - The columns “u\*\_bedeutung” contain the meanings of the lemma in
    the respective “u\*\_bedeutung” layer

  - The column “zitat” contains the quotations whereby each line of the
    dataset only oncludes one quotation

  - The column “stelle” contains a reference which corresonds to name of
    the source text the quotation was taken from

- The folder used in the example below is available on the GitHub
  repository in a folder named “toy”.

- You should load the folder with the .mlw-files you want to use in your
  project folder before using this function.

- The function leans up the lemma information, adds the field name
  ZITAT, renames the field name UNTER_BEDEUTUNG to U_BEDEUTUNG

- Lines of the .mlw-files that do not have a field name such as
  BEDEUTUNG or LEMMA are recursively appended to the last entry with a
  field name

- The function replaces the field name ANHÄNGER with the field name of
  the last member of the U\*\_BEDEUTUNG-layers

- The function is not limited to a specific number of U\*BEDEUTUNG
  layers but dynamically adds as many U\*BEDEUTUNG layers as necessary.

- The function educes the lemma entry to its first word.

- The function removes all \\#/\\^\*:‘; and all entries in (((()))),
  (()), (), {{}}, {}, \<\<\>\>, \<\>,’’ in the quotation column.

- All non-letters are removed from the reference, leaving only the first
  3 words.

- The quotation column is reduced to words longer than 3 letters and
  spaces, and all capital letters are converted to lowercase.

- Because there is an irregular use of the letters u and v between the
  source texts and the quotations, all v’s are replaced with u.

- The functions splits lines containing multiple quotations into
  individual quotations.

### Output

- An Article-dataset containing the columns “lemma”, “u\*\_bedeutung”,
  “zitat” and “stelle” and that is ready for use with merge_df

### Assumptions

- The folder you want to use is located in your project folder.

- The folder containing the .mlw-files contains only .mlw-files (and no
  other documents or folders).

- Any Arabic numerals, annotations in () or {} in the lemma entry have
  no special meaning and can be deleted without further ado.

- All citations in the .mlw-files begin with a star \*.

- Paragraphs in the -mlw-files with the following field names can be
  removed without further ado:

  - AUTOR(IN)

  - STRUKTUR

  - ETYMOLOGIE

  - GRAMMATIK

  - VEL

  - METRIK

  - SCHREIBWEISE

  - UNTERDRÜCKE

  - GEBRAUCH

  - Absatz

<!-- -->

- The first word of the lemma entry is sufficient, and the rest can be
  deleted without further ado.

- All entries in (((()))), (()), (), {{}}, {}, \<\<\>\>, \<\>, ’’ in the
  quote column have no special meaning and can be deleted without
  further ado.

- All \\#/.^\*:’; in the quote column have no special meaning and can be
  deleted without further ado.

- All quotations are enclosed in quotation marks.

- Everything quotation-column, between the quotation marks, belongs to
  the source reference.

### Usage

    create_df(mlw_folder)

with a path to a certain folder containing the .mlw-files.

### Example

    # Create an Article-dataset
    toy_artikel <- create_df(mlw_folder = "toy/toy_mlw")
    # View the result
    View(toy_artikel)

## *merge_df*

### Description

- This function takes an Article-dataset created by create_df and an
  Evidence-dataset created by create_df_2 and gives back an
  Article-dataset with extended quotes.

- The function compares the entries of the “pruef_beleg” column of the
  Evidence-dataset with the entries of the “zitat” column of the
  Article-dataset and adds the entries of the “langer_beleg” column to
  the Article-dataset in the line of the respective quotation if the
  comparision indicates a match

- The conditions for a match are stated below

- All quotes from the Article-dataset for which no suitable partner
  could be found are stored separately in a CSV-file, always named
  “fehler.csv”, including metadata, and the conditions that were met or
  not met are explicitly stated.

- All quotes for which the function found multiple possible partners are
  saved in a CSV file, always named “nicht_eindeutig.csv”.

- The data used in the example below is available on the GitHub
  repository in a folder named “toy”. Before executing the example code
  you should apply convert_doc, create_df and create_df_2 on the
  repective files.

- The Article-dataset generated by create_df and the Evidence-dataset
  you want to use, generated by convert_doc and create_df_2 should be
  loaded in your Global Environment before you use the function.

### Conditions for a match

- A = Does the candidate sentence from the Evidence-dataset contain all
  the words of the quote?

- B = Do the first 3 or 1 word(s) of the quote’s reference match those
  of the respective text file name from the Evidence-dataset?

- C = Is the quote at least five words long?

- D = Does the candidate sentence contain the lemma for which the quote
  was created?

### Output

- An Article-dataset with extended citations

### Assumptions

- The data you want to use is loaded in your global Environment.
- The conditions under which the function assumes a match correspond at
  least approximately to those that require an actual match.

### Usage

    merge_df(lem_dat, bel_dat)

with lem_dat being an Article-dataset created by create_df and bel_dat
being an Evidence-dataset created by create_df_2

### Example

    # Extend the Citations of the Article-dataset
    final_df <- merge_df(lem_dat = toy_artikel , bel_dat = toy_belege)
    # View the new Article-dataset
    View(final_df)
    # View the quotes with no suitable partner
    errors <- readr::read_csv("fehler.csv")
    View(errors)
    # View the quotes with several possible partners
    ambiguous <- readr::read_csv("nicht_eindeutig.csv")
    View(ambiguous)
