#' Convert .doc-files from the evidence material to txt format
#'
#' This function converts .doc files to .txt using LibreOffice.
#'
#' @param doc_folder Path to a folder containing .doc documents.
#' @export
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
