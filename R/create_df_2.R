#' Create an Evidence-dataset from the .txt-files that is ready for use with merge_df
#'
#' This function creates a dataset from all .txt-files located in the specified folder, containing the columns "langer_beleg", "pruef_beleg" and "pruef_stelle". The folder used in the example below is available on the GitHub repository in a folder named "toy". You have to use convert_doc on the folder before executing the example code. The folder containing the .txt-files you want to use should be located in your project folder before using this function. Please execute the example code manually and don't use the run_examples button.For further informations see https://github.com/ATSzimmat/mlwdw26.
#'
#' @param txt_folder Path to a certain folder containing .txt-files.
#' @returns An evidence dataset containing the columns "langer_beleg", "pruef_beleg" and "pruef_stelle" and that is ready for use with merge_df
#' @export
#' @examples
#' # Create the Evidence-dataset
#' toy_belege <- create_df_2(txt_folder = "toy/toy_doc_txt")
#' # View the result
#' View(toy_belege)
create_df_2 <- function(txt_folder) {

  # Hilfsfunktion zum Vektorisieren der txt Dateien
  II_vectorize_txt <- function(pfad) {
    # txt-Dateien einlesen
    belegtext <- readr::read_lines(pfad)
    text_neu <- belegtext
    # Erste Anpassungen
    # Zahlen
    text_neu <- gsub("p\\.:*\\d+\\s*:*,*", "", text_neu)
    text_neu <- gsub("l\\.:*\\d+\\s*:*,*", "", text_neu)
    # Nummerierungen entfernen
    text_neu <- gsub("(^|[—-])\\s*(\\d+[a-z]?|[IVXLCDM]+)\\.\\s*", "", text_neu)
    # Sämtliche arabischen Zahlen entfernen
    text_neu <- gsub("\\d+", "", text_neu)
    # Jegliche leere Klammern (diese wurden als Hüllen zurückgelassen) entfernen
    text_neu <- gsub("\\(+-*—*\\s*\\)+","", text_neu)
    text_neu <- gsub("\\[+\\]+","", text_neu)
    text_neu <- gsub("<+>+","", text_neu)
    # Römische Zahlen (Nur diejenigen, wo eine ganze Zeile nur aus ihnen, Leerzeichen oder PUnkten besteht)
    text_neu <- text_neu[!grepl("^\\s*[IVXLCDM]+\\.?\\s*(\\t[IVXLCDM]+\\.?)*\\s*$", text_neu)]
    # Römische Zahlen am Zeilenanfang löschen
    text_neu <- gsub("^\\s*[IVXLCDM]+\\.+\\s*", "", text_neu)
    # \t statt Leerzeichen verhindern
    text_neu <- gsub("\\t", " ", text_neu)
    # Leere Zeilen oder Zeilen, die nur aus Punkten bestehen raus
    text_neu <- text_neu[!grepl("^\\s*\\.*\\s*$", text_neu)]
    # … und ... duch . ersetzen
    text_neu <- gsub("…", ". ", text_neu)
    text_neu <- gsub("\\.\\.\\.", ". ", text_neu)
    # " ." verhindern
    text_neu <- gsub("\\s+\\.\\s*$", ". ", text_neu)
    # ". —" verhindern
    text_neu <- gsub("\\s*\\.\\s*—", ". ", text_neu)
    # Unerwünschte Ausdrücke
    text_neu <- text_neu[!grepl("^\\s*!*(Achtung\\s*Sonderzeichen|Sonderzeichen|Sonderzeichen\\s*unterstrichen)!*\\s*$",text_neu)]
    # "Korrektur"
    text_neu <- text_neu[!grepl("^\\s*Korrektur\\s*$", text_neu)]
    # "Rasur"
    text_neu <- text_neu[!grepl("^\\s*Rasur von \\d+ Zeile(n)?\\.\\s*$", text_neu)]
    # "Druckfehler verbessert"
    text_neu <- text_neu[!grepl("^\\s*Druckfehler verbessert.*", text_neu)]
    # "Latitudo" und "Longitudo"
    text_neu <- text_neu[!grepl("^\\s*Latitudo(\\s+[IVXLCDM]+|\\s+\\d+)*\\s*$", text_neu)]
    text_neu <- text_neu[!grepl("^\\s*Longitudo(\\s+[IVXLCDM]+|\\s+\\d+)*\\s*$", text_neu)]
    # Klammer-Einträge, die ganze Zeile einnehmen
    text_neu <- text_neu[!grepl("^\\s*\\(.*\\)\\s*$", text_neu)]
    text_neu <- gsub("^\\s*\\(.*\\)\\.\\s*$", ".", text_neu)
    # Überstreichungen Korrekturen
    text_neu <- text_neu[!grepl("^\\s*Überstreichungen Korrekturen\\s*$", text_neu)]
    # ACHTUNG: GRIECHISCH
    text_neu <- text_neu[!grepl("^\\s*ACHTUNG: GRIECHISCH\\s*$", text_neu)]
    # Jede Zeile, die mit "Achtung: Sonderzeichen" beginnt
    text_neu <- text_neu[!grepl("^\\s*Achtung:", text_neu)]
    # Jede Zeile, die mit "Druckfehler verbessert:" beginnt
    text_neu <- text_neu[!grepl("^\\s*Druckfehler verbessert:", text_neu)]
    # Punkte hinter Folgen von Wörtern in Großbuchstaben hinzufügen
    # Hilfsfunktion
    add_dot_after_uppercase_headings <- function(text) {
      for (i in seq_len(length(text) - 1)) {
        current <- trimws(text[i])
        nextline <- trimws(text[i + 1])
        is_uppercase_words <- !grepl("[a-z]", current)
        no_dot_at_end <- !grepl("[.!?]$", current)
        next_is_sentence_start <-
          grepl("^[A-Z][a-z]{2,}", nextline)
        if (is_uppercase_words && no_dot_at_end && next_is_sentence_start) {
          text[i] <- paste0(text[i], ".")}}
      text}
    # Hilfsfunktion anwenden
    text_neu <- add_dot_after_uppercase_headings(text_neu)
    # Zeilen nach Sätzen auftrennen
    # Hilfsfunktion
    merge_lines <- function(text) {
      result <- c()
      buffer <- ""
      for (line in text) {
        if (nchar(buffer) == 0) {
          buffer <- line
        } else {
          if (grepl("-$", buffer)) {
            buffer <- paste0(substr(buffer, 1, nchar(buffer)-1), " ", line)
          } else {
            buffer <- paste(buffer, line)}}
        if (grepl("[.!?]$", buffer)) {
          result <- c(result, buffer)
          buffer <- ""}}
      if (nchar(buffer) > 0) {
        result <- c(result, buffer)}
      return(result)}
    # Hilfsfunktion Anwenden
    text_neu <- merge_lines(text_neu)
    # Zeilen in Sätze splitten
    # Hilfsfunktion
    split_into_sentences <- function(text) {
      sentences <- c()
      for (line in text) {
        line <- trimws(line)
        brackets <- gregexpr("\\([^\\)]*\\)", line, perl = TRUE)[[1]]
        if (brackets[1] != -1) {
          matches <- regmatches(line, gregexpr("\\([^\\)]*\\)", line, perl = TRUE))[[1]]
          for (i in seq_along(matches)) {
            placeholder <- paste0("__BRACKET", i, "__")
            line <- sub("\\([^\\)]*\\)", placeholder, line, perl = TRUE)}
        } else {
          matches <- c()}
        parts <- unlist(strsplit(
          line,
          "(?<=[.!?])\\s+(?=[A-Z])",
          perl = TRUE))
        i <- 1
        while (i < length(parts)) {
          if (grepl("^[A-Za-z]\\.$", parts[i])) {
            parts[i] <- paste(parts[i], parts[i + 1])
            parts <- parts[-(i + 1)]
            next}
          if (grepl("^\\p{L}+[.!?]$", parts[i], perl = TRUE)) {
            parts[i] <- paste(parts[i], parts[i + 1])
            parts <- parts[-(i + 1)]
            next}
          i <- i + 1}
        if (length(matches) > 0) {
          for (i in seq_along(matches)) {
            parts <- gsub(
              paste0("__BRACKET", i, "__"),
              matches[i],
              parts,
              fixed = TRUE)}}
        sentences <- c(sentences, parts)}
      return(sentences)}
    # Hilfsfunktion anwenden
    text_neu <- split_into_sentences(text_neu)
    # Weitere Textanpassungen
    # Alles in Klammern raus
    text_neu <- gsub("\\(.*\\)", "", text_neu)
    # Mehrere Leerzeichen hintereinander verhindern
    text_neu <- gsub("\\s+", " ", text_neu)
    # Bindestriche innerhalb von Wörtern raus (z. B. "par- vitatis")
    text_neu <- gsub("(?<=\\w)\\s*-\\s*(?=\\w)", "", text_neu, perl = TRUE)
    # " ." und " ," und " ;" und " :" verhindern
    text_neu <- gsub("\\s+\\.", ".", text_neu)
    text_neu <- gsub("\\s+,", ",", text_neu)
    text_neu <- gsub("\\s+;", ";", text_neu)
    text_neu <- gsub("\\s+:", ":", text_neu)
    # Doppelte . verhindern
    text_neu <- gsub("\\s*\\.\\s*\\.\\s*", ".", text_neu)
    # Alle eckigen Klammern raus
    text_neu <- gsub("\\[", "", text_neu)
    text_neu <- gsub("\\]", "", text_neu)
    # Alle / und | entfernen
    text_neu <- gsub("/", "", text_neu)
    text_neu <- gsub("[\\|\\*«»„“\\+¯_\\<\\>”’]", "", text_neu)
    text_neu <- gsub("\\\\+", "", text_neu)
    # Überreste von Nummerierungen raus
    text_neu <- gsub("\\s*\\.\\s*-*—*\\.*\\s*\\s*", ".", text_neu)
    text_neu <- gsub("\\s*\\.\\s*—\\.*\\s*[a-z]?\\.*\\s*", ".", text_neu)
    # Doppelte Punkte raus
    text_neu <- gsub("\\.\\.", ".", text_neu)
    # Römische Zahlen am Zeilenanfang löschen
    text_neu <- gsub("^\\s*[IVXLCDM]+\\.+\\s*", "", text_neu)
    # ".a -> . a"
    text_neu <- gsub("\\.([A-Z])", ". \\1", text_neu)
    # Zeilen die nur aus Punkten bestehen entfernen
    text_neu <- text_neu[!grepl("^\\s*\\.\\s*\\.*\\s*$", text_neu)]
    # Leere Zeilen entfernen
    text_neu <- text_neu[!grepl("^$", text_neu)]
    # Ergebnis ausgeben
    return(text_neu)}
  # Jetzt wird die Hauptfunktion ausgeführt
  # Alle txt-Dateien im Ordner auflisten
  files <- list.files(
    path = txt_folder,
    pattern = "\\.txt$",
    full.names = TRUE)
  # Hilfsfunktion II_vectorize_txt auf alle aufgelisteten txt-Dateien anwenden
  df_list <- lapply(files, function(f) {
    text_vec <- II_vectorize_txt(f)
    # Falls Datei keinen verwertbaren Text enthält, überspringen
    if (length(text_vec) == 0) return(NULL)
    # Dateiennamen identifizieren und bereinigen
    file_name <- tools::file_path_sans_ext(basename(f))
    file_name <- gsub(
      "\\s*\\(\\s*ed\\.[^)]*\\)",
      "",
      file_name,
      ignore.case = TRUE)
    file_name <- trimws(gsub("\\s+", " ", file_name))
    # DataFrame erstellen mit dem nach Sätzen aufgeteilten Text in der einen Spalte und den Dateinamen der txt-Dateien in der anderen
    data.frame(
      text   = text_vec,
      source = rep(file_name, length(text_vec)),
      stringsAsFactors = FALSE)})
  df_list <- df_list[!sapply(df_list, is.null)]
  if (length(df_list) == 0) {
    return(data.frame(
      langer_beleg = character(),
      pruef_beleg = character(),
      pruef_stelle = character(),
      stringsAsFactors = FALSE
    ))
  }
  df <- do.call(rbind, df_list)
  rownames(df) <- NULL
  # Nun wird das Dataset zur weiteren Verwendung überarbeitet
  # Erste kleinere Anpassungen
  toy_belege <- df
  toy_belege$text <- gsub("\\.", ". ", toy_belege$text)
  toy_belege$text <- trimws(toy_belege$text)
  # An Sätze, die höchstens 5 Wörter lang sind wir der nächste Satz engehangen
  toy_belege <- toy_belege %>%
    dplyr::mutate(.row_id = dplyr::row_number()) %>%
    dplyr::group_by(source) %>%
    dplyr::group_modify(~{
      tmp <- .x
      wc <- stringr::str_count(tmp$text, "\\S+")
      for (i in seq_len(nrow(tmp) - 1)) {
        if (!is.na(wc[i]) && wc[i] <= 5) {
          tmp$text[i] <- paste(tmp$text[i], tmp$text[i + 1])
          tmp$text[i + 1] <- NA}}
      tmp
    }) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!is.na(text)) %>%
    dplyr::arrange(.row_id) %>%
    dplyr::select(-.row_id)
  # Text vereinfachen (hierfür wird eine weitere Version des Belege-Datasets erstellt)
  # Nur Buchstaben behalten
  toy_belege_2 <- toy_belege %>% dplyr::mutate(text = stringr::str_replace_all(text, "[^A-Za-z ]", ""))
  # Zu kurze Wörter entfernen
  toy_belege_2 <- toy_belege_2 %>%dplyr::mutate(text = stringr::str_replace_all(text, "\\b\\w{1,3}\\b", ""),text = stringr::str_squish(text))
  #  Nur noch Kleinbuchstaben
  toy_belege_2 <- toy_belege_2 %>% dplyr::mutate(text = tolower(text))
  # NA und überflüssige Leerzeichen entfernen
  toy_belege_2 <- toy_belege_2 %>%
    dplyr::mutate(
      text = stringr::str_replace_all(text, "NA", ""),
      text = stringr::str_squish(text)
    )
  # Belegmaterial aus dem die Belege extrahiert werden
  orig_beleg <- toy_belege %>% dplyr::select(text, source)
  # Belegmaterial mit dem auf passende Zitate geprüft wird
  pruefmaterial <- toy_belege_2 %>% dplyr::select(text, source)
  orig_beleg <- toy_belege %>% dplyr::rename(langer_beleg=text, stelle=source) %>% dplyr::select(langer_beleg)
  pruefmaterial <- toy_belege_2 %>% dplyr::rename(pruef_beleg=text, stelle=source)
  # Beide Datasets zusammenfügen
  toy_belege <- cbind(orig_beleg, pruefmaterial)
  # Alle us durch vs ersetzen (im Prüfbeleg)
  toy_belege <- toy_belege %>% dplyr::mutate(pruef_beleg = stringr::str_replace_all(pruef_beleg, "v", "u"))
  # Stellenangabe anpassen (alle Nicht-Buchstaben entfernen und nur die ersten 3 Wörter der Stellenangabe behalten
  toy_belege <- toy_belege %>% dplyr::mutate(pruef_stelle = stelle %>%
                                               stringr::str_replace_all("[^A-Za-z ]", "") %>%
                                               stringr::str_squish() %>%
                                               stringr::str_extract("^\\S+(?:\\s+\\S+){0,2}"))
  toy_belege <- toy_belege %>% dplyr::select(-stelle)

  df <- toy_belege

  return(df)}
