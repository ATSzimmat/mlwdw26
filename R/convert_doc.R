#' Convert .doc-files containing evidence material to .txt-format
#'
#' This function converts .doc-files to .txt files using the LibreOffice program.The folder used in the example below is available on the GitHub repository in a folder named "toy". The folder containing the .doc-files you want to convert should be located in your project folder before using this function. Note: This function requires LibreOffice to be located in a folder named "Applications" and that you are currently using a Mac. This is also the reason why the examples contain the comment "## Not run" - do not be confused by this - it merely serves to prevent R from causing errors. Unfortunately, this also means the "Run examples" button won't work - please run the example manually instead. For further informations see https://github.com/ATSzimmat/mlwdw26.
#'
#' @param doc_folder Path to a certain folder containing .doc-files.
#' @returns A new folder was created containing the converted files. The name of this folder is the same as the folder containing the .doc-files, with "_txt" appended to the end.
#' @export
#' @examples
 #' \dontrun{# Convert the .doc-files from a example folder with .doc-files from the toy folder
#' convert_doc(doc_folder = "toy/toy_doc")
#' }
convert_doc <- function(doc_folder) {
  soffice <- "/Applications/LibreOffice.app/Contents/MacOS/soffice"
  output_dir <- paste0(stringr::str_remove(doc_folder, "/$"), "_txt")
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  doc_files <- list.files(doc_folder, pattern = "\\.doc$", full.names = TRUE, ignore.case = TRUE)
  for (doc_path in doc_files) {
    system2(soffice, args = c("--headless", "--convert-to", "txt:Text", "--outdir", output_dir, shQuote(doc_path)))
    generated_txt <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(doc_path)), ".txt"))
    if (!file.exists(generated_txt)) next
    zeilen <- readLines(generated_txt, warn = FALSE, encoding = "UTF-8")
    clean_zeilen <- stringr::str_trim(zeilen)
    final_text <- ifelse(nchar(clean_zeilen) > 0, paste0(" ", clean_zeilen, " "), "")
    writeLines(final_text, generated_txt, useBytes = TRUE)
    cat("Erfolgreich verarbeitet:", basename(generated_txt), "\n")
  }
}
