#' @export
convert_doc <- function(doc_folder) {
  # Pfad zum LibreOffice-Program definieren
  soffice <- "/Applications/LibreOffice.app/Contents/MacOS/soffice"
  # Output-Ordner erstellen, falls noch nicht existent
  output_dir <- paste0(str_remove(doc_folder, "/$"), "_txt")
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  # Liste aller doc-Dateien erstellen
  doc_files <- list.files(doc_folder, pattern = "\\.doc$", full.names = TRUE, ignore.case = TRUE)
  # For-Schleife für jede gefundene doc-Datei im Input-Ordner
  for (doc_path in doc_files) {
    # doc-Datei in txt-Datei umwandeln und im Outputordner speichern
    system2(soffice, args = c(
      "--headless",
      "--convert-to", "txt:Text",
      "--outdir", output_dir,
      shQuote(doc_path)
    ))
    # Name der Output-Dateien automatisch generieren
    generated_txt <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(doc_path)), ".txt"))
    # Bei Fehlschlag zur nächsten Datei springen
    if (!file.exists(generated_txt)) next
    # Text der neuen txt-Dateien vektorisieren
    zeilen <- readLines(generated_txt, warn = FALSE, encoding = "UTF-8")
    # Zu viele führende und abschließende Leerzeichen verhindern
    clean_zeilen <- str_trim(zeilen)
    # Ein einzelnes führendes und abschließendes Leerzeichen hinzufügen
    final_text <- ifelse(nchar(clean_zeilen) > 0,
                         paste0(" ", clean_zeilen, " "),
                         "")
    # Bereinigten Text zurück in die Datei speichern
    writeLines(final_text, generated_txt, useBytes = TRUE)
    cat("Erfolgreich verarbeitet:", basename(generated_txt), "\n")
  }
}
