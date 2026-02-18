#' Create an Article-dataset from the .mlw-files that is ready for use with merge_df
#'
#' This function creates a dataset from all .mlw-files located in the specified folder, containing the columns "lemma", "u*_bedeutung", "zitat" and "stelle".The folder used in the example below is available on the GitHub repository in a folder named "toy". You should load the folder with the .mlw-files you want to use in your project folder before using this function. Please execute the example code manually and don't use the run_examples button. For further informations see https://github.com/ATSzimmat/mlwdw26.
#'
#' @param mlw_folder Path to a certain folder containing .mlw-files.
#' @returns An article dataset containing the columns "lemma", "u*_bedeutung", "zitat" and "stelle" and that is ready for use with merge_df
#' @export
#' @examples
#' # Create the Article-dataset
#' toy_artikel <- create_df(mlw_folder = "toy/toy_mlw")
#' # View the result
#' View(toy_artikel)
create_df <- function(mlw_folder) {
  # Alle mlw-Datei im Ordner auflisten
  mlw_files <- list.files(
    path = mlw_folder,
    pattern = "\\.mlw$",
    full.names = TRUE)
  # In lapply integierte Hilfsfunktion, die mlw-Artikel vektorisiert
  lemmata_vecs <- lapply(mlw_files, function(mlw_dat_name) {
    # Datei ins Vektorformat bringen
    mlw <- readLines(mlw_dat_name, encoding = "UTF-8", warn = FALSE)
    # Lemmazeile bereinigen
    mlw <- mlw[mlw != ""]
    mlw <- sapply(mlw, function(line) {
      if (stringr::str_detect(line, "^LEMMA")) {
        line <- gsub("[\\*0-9\\.]", "", line)
        line <- gsub("\\([^\\)]*\\)", "", line)
        line <- gsub("\\{[^\\}]*\\}", "", line)
        line <- stringr::str_trim(line)
      }
      return(line)
    }, USE.NAMES = FALSE)
    # ZITAT-Feldnamen hinzufügen und Zeilen ohne Feldnamen an die obere Zeile mit Feldnamen anhängen
    mlw <- gsub("\\s+", " ", mlw)
    mlw <- stringr::str_trim(mlw, side = "left")
    result <- c()
    buffer <- NULL
    for (line in mlw) {
      # ZITAT erkennen
      if (stringr::str_detect(line, "^\\* [A-Z]+")) {
        line <- sub("^\\* ", "ZITAT ", line)
        if (!is.null(buffer)) result <- c(result, buffer)
        buffer <- line
        next
      }
      if (stringr::str_detect(line, "^[A-Z]+")) {
        if (!is.null(buffer)) result <- c(result, buffer)
        buffer <- line
        next
      }
      buffer <- paste(buffer, line)
    }
    # Letzte Zeile gesondert zum Ergebnis hinzufügen
    if (!is.null(buffer)) result <- c(result, buffer)
    # Zeilen mit unerwünschte Feldenamen löschen
    vec_ber <- result[
      !grepl("^AUTOR(IN)?\\b", result) &
        !grepl("^STRUKTUR\\b", result) &
        !grepl("^ETYMOLOGIE\\b", result) &
        !grepl("^GRAMMATIK\\b", result) &
        !grepl("^VEL\\b", result) &
        !grepl("^METRIK\\b", result) &
        !grepl("^SCHREIBWEISE\\b", result) &
        !grepl("^UNTERDRÜCKE\\b", result) &
        !grepl("^GEBRAUCH\\b", result) &
        !grepl("^Absatz\\b", result)
    ]
    # Feldname UNTER_BEDEUTUNG durch U_BEDEUTUNG ersetzen
    vec_ber <- gsub("UNTER_BEDEUTUNG", "U_BEDEUTUNG", vec_ber, fixed = TRUE)
    # Feldname ANHÄNGER durch das letzte Mitglied der U_Bedeutungsschicht ersetzen
    pattern <- "^(U+_)?BEDEUTUNG"
    last_bedeutung <- NA
    for (i in seq_along(vec_ber)) {
      # Feldname einer U_Bedeutungsschicht als last_bedeutung definieren
      if (grepl(pattern, vec_ber[i])) {
        last_bedeutung <- sub("^([A-Z_]+).*", "\\1", vec_ber[i])
      }
      # Falls ANHÄNGER auftaucht, diesen durch last_bedeutung ersetzen
      if (grepl("^ANHÄNGER\\b", vec_ber[i])) {
        if (!is.na(last_bedeutung)) {
          vec_ber[i] <- sub("^ANHÄNGER", last_bedeutung, vec_ber[i])
        }
      }
    }
    # Ergebnis ausgeben
    return(vec_ber)
  })
  # Fehlermeldung definieren
  NO_U_LEVEL <- "!_!_Keine weitere Unterbedeutungsebene gefunden_!_!"
  # Dataframe-Liste erstellen
  df_list <- lapply(lemmata_vecs, function(vec) {
    # Spalten des Dataframes definieren
    df <- data.frame(
      lemma = character(0),
      bedeutung = character(0),
      zitat = character(0),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    u_cols <- character(0)
    current_lemma <- NA_character_
    current_bedeutung <- NA_character_
    u_stack <- list()
    # Hilfsfunktion, die sicherstellt, dass eine bestimmte Spalte des Datasets existiert und dass diese entweder mit Inhalt oder mit der oben definierten Fehlermeldung gefüllt wird
    ensure_cols <- function(df, cols) {
      for (col in cols) {
        if (!col %in% names(df)) {
          if (nrow(df) == 0) {
            df[[col]] <- character(0)
          } else {
            df[[col]] <- rep(NO_U_LEVEL, nrow(df))
          }
        }
      }
      df
    }
    # Eine Zeile eines Datasets zusammenbauen, wobei die Feldnamen die neuen Spaltennamen werden
    for (line in vec) {
      line <- trimws(line)
      if (line == "") next
      if (grepl("^LEMMA\\b", line)) {
        current_lemma <- sub("^LEMMA\\s*", "", line)
        u_stack <- list()
        next
      }
      if (grepl("^BEDEUTUNG\\b", line)) {
        current_bedeutung <- sub("^BEDEUTUNG\\s*", "", line)
        u_stack <- list()
        next
      }
      if (grepl("^(U+)_BEDEUTUNG\\b", line)) {
        u_match <- regmatches(line, regexec("^(U+)_BEDEUTUNG\\b", line))[[1]][2]
        u_text <- sub("^(U+)_BEDEUTUNG\\s*", "", line)
        col_name <- paste0(tolower(u_match), "_bedeutung")
        u_stack[[col_name]] <- u_text
        if (!col_name %in% u_cols) {
          u_cols <- c(u_cols, col_name)
          df <- ensure_cols(df, col_name)
        }
        next
      }
      if (grepl("^ZITAT\\b", line) || grepl("^\\*\\s", line)) {
        row <- list(
          lemma = ifelse(is.na(current_lemma), NA_character_, current_lemma),
          bedeutung = ifelse(is.na(current_bedeutung), NA_character_, current_bedeutung)
        )
        for (col in u_cols) {
          row[[col]] <- if (!is.null(u_stack[[col]])) u_stack[[col]] else NO_U_LEVEL
        }
        ztext <- if (grepl("^ZITAT\\b", line)) sub("^ZITAT\\s*", "", line) else sub("^\\*\\s*", "", line)
        row$zitat <- ztext
        # Als Dataframe definieren
        df_row <- as.data.frame(row, stringsAsFactors = FALSE, check.names = FALSE)
        # Eben definierte Hilfsfunktion anwenden
        df <- ensure_cols(df, names(df_row))
        # Wenn eine Unterbedeutungsschicht fehlt, werden dort die Einträge mit Fehlermeldung gefüllt
        missing_in_row <- setdiff(names(df), names(df_row))
        if (length(missing_in_row) > 0) {
          for (col in missing_in_row) df_row[[col]] <- NO_U_LEVEL
        }
        df_row <- df_row[names(df)]
        df <- rbind(df, df_row)
      }
    }
    # Richtige Sortierung der Unterbedeutungsschichten sicherstellen
    if (length(u_cols) > 0) {
      u_cols_sorted <- u_cols[order(nchar(gsub("[^u]", "", u_cols)), u_cols)]
      final_cols <- c("lemma", "bedeutung", u_cols_sorted, "zitat")
      df <- ensure_cols(df, final_cols)
      df <- df[, intersect(final_cols, names(df)), drop = FALSE]
    } else {
      df <- df[, c("lemma", "bedeutung", "zitat"), drop = FALSE]
    }
    # Sicherstellen, dass alle entstandenen Dataframes diegleichen Spalten haben
    df[] <- lapply(df, function(x) if (is.factor(x)) as.character(x) else x)
    df
  })
  all_cols <- unique(unlist(lapply(df_list, names)))
  df_list <- lapply(df_list, function(df) {
    missing <- setdiff(all_cols, names(df))
    if (length(missing) > 0) {
      for (m in missing) {
        df[[m]] <- if (nrow(df) == 0) character(0) else rep(NO_U_LEVEL, nrow(df))
      }
    }
    df[, all_cols, drop = FALSE]
  })
  # Fertige Dataframes zusammenfügen
  final_df <- do.call(rbind, df_list)

  # Zitate bereinigen
  # Unerwünschte Ausdrücke entfernen
  final_df$zitat <- final_df$zitat %>%
    gsub("\\(\\([^()]*\\)\\)", "", .) %>%
    gsub("\\{[^{}]*\\}", "", .) %>%
    gsub("\\{[^}]*\\}", "", .) %>%
    gsub("\\([^)]*\\([^)]*\\)[^)]*\\)", "", .) %>%
    gsub("\\([^)]*\\)", "", .) %>%
    gsub("<[^>]*<[^>]*>[^>]*>", "", .) %>%
    gsub("<[^>]*>", "", .) %>%
    gsub("[\\|#/\\.^*:]", "", .) %>%
    gsub("\\s+", " ", .) %>%
    gsub("'[^']*'", "", .) %>%
    gsub("'","",.) %>%
    gsub("\\(\\(","",.) %>%
    gsub("\\)\\)","",.) %>%
    gsub("\\s*\\s"," ",.) %>%
    gsub('\\s+"', '"', .) %>%
    gsub('"\\s+', '"', .) %>%
    gsub("\\s+,", ",", .) %>%
    gsub("‘", "", .) %>%
    gsub(";", "", .) %>%
    trimws()
  toy_lemmata <- final_df
  # Sicherstellen, dass jedes Zitat in einem eigenen Eintrag steht
  toy_lemmata <- toy_lemmata %>%
    dplyr::rowwise() %>%
    dplyr::mutate(zitat_split = list(stringr::str_extract_all(zitat, '[^"]*"[^"]*"')[[1]])) %>%
    dplyr::ungroup() %>%
    tidyr::unnest(zitat_split) %>%
    dplyr::mutate(zitat = zitat_split) %>%
    dplyr::select(-zitat_split)
  # Überflüssige Leerzeichen entfernen
  toy_lemmata$zitat <- trimws(toy_lemmata$zitat)
  # Hilfsfunktion - Stellenangabe als Autor, Werk, Stelle aufteilen
  split_zitat_final4 <- function(df, zitat_col = "zitat") {
    df <- df %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        zitat_text = stringr::str_extract(get(zitat_col), '"(.*)"') %>% stringr::str_remove_all('"'),
        metadaten = stringr::str_remove(get(zitat_col), '"(.*)"') %>% stringr::str_trim(),
        autor = {
          words <- stringr::str_split(metadaten, "\\s+")[[1]]
          autor_words <- c()
          for(w in words) {
            if(stringr::str_detect(w, "^[A-Z]+$")) {
              autor_words <- c(autor_words, w)
            } else break
          }
          paste(autor_words, collapse = " ")
        },
        rest_nach_autor = if(autor == "") metadaten else stringr::str_replace(metadaten, paste0("^", fixed(autor)), "") %>% stringr::str_trim(),
        werk = { w_match <- stringr::str_extract(rest_nach_autor, "^[^0-9]+"); if(!is.na(w_match)) stringr::str_trim(w_match) else "" },
        zahlen = { z_match <- stringr::str_extract(rest_nach_autor, "\\d.*$"); if(!is.na(z_match)) stringr::str_trim(z_match) else "" }
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(zitat = zitat_text) %>%
      dplyr::select(-zitat_text, -metadaten, -rest_nach_autor)
    return(df)
  }
  # Hilfsfunktion anwenden
  toy_lemmata <- split_zitat_final4(toy_lemmata)
  # Stellenangaben bereinigen
  toy_lemmata <- toy_lemmata %>%
    dplyr::mutate(dplyr::across(c(werk, zahlen), ~ stringr::str_replace_all(., "\\bp\\b", ""))) %>%
    dplyr::mutate(dplyr::across(c(autor, werk, zahlen), ~ stringr::str_squish(.))) %>%
    dplyr::mutate(dplyr::across(c(autor, werk, zahlen), ~ ifelse(. == "", NA, .))) %>%
    # Fehlende Autornamen, die durch das Aufteilen der Zitate entstanden sind, mit dem darüberliegenden Namen auffüllen
    tidyr::fill(autor, .direction = "down") %>%
    tidyr::fill(werk, .direction = "down") %>%
    dplyr::select(-zahlen) %>%
    tidyr::unite("autor_werk", autor, werk, sep = " ", remove = TRUE, na.rm = TRUE) %>%
    dplyr::relocate(zitat, .after = dplyr::last_col()) %>%
    dplyr::rename(stelle = autor_werk)
  # Stellenangabe kuerzen
  toy_lemmata <- toy_lemmata %>%
    dplyr::mutate(pruef_stelle_zitat = stelle %>% stringr::str_replace_all("[^A-Za-z ]", "") %>% stringr::str_squish() %>% stringr::str_extract("^\\S+(?:\\s+\\S+){0,2}")) %>%
    dplyr::select(-stelle) %>%
    dplyr::rename(stelle = pruef_stelle_zitat)
  # Lemma-Angabe-Bereinigung
  toy_lemmata$lemma <- trimws(toy_lemmata$lemma)
  toy_lemmata$lemma <- sub("\\s.*", "", toy_lemmata$lemma)
  toy_lemmata$lemma <- sub("\\s", "", toy_lemmata$lemma)
  # Textbereinigung der Zitate
  toy_lemmata <- toy_lemmata %>% dplyr::rename(text = zitat)
  toy_lemmata <- toy_lemmata %>% dplyr::mutate(
    text = stringr::str_replace_all(text, "[^A-Za-z ]", ""),
    text = stringr::str_replace_all(text, "\\b\\w{1,3}\\b", ""),
    text = stringr::str_squish(text),
    text = tolower(text),
    text = stringr::str_replace_all(text, "NA", ""),
    text = stringr::str_replace_all(text, "v", "u")
  ) %>%
    dplyr::rename(zitat = text)
  # Ergebnis ausgeben
  return(toy_lemmata)
}
