# usageKeysStep2.R
# Retrieve GBIF usage keys for taxa at specified ranks.
#install.packages("rgbif")
#install.packages("writexl")
#install.packages("readxl")


`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}

input_path <- file.path(getwd(), "taxa_need_filtering_step_2.xlsx")
output_path <- file.path(getwd(), "taxa_need_filtering_step_2_gbifid.xlsx")

if (!file.exists(input_path)) {
  stop(paste0("Input file not found: ", input_path))
}

raw <- readxl::read_excel(input_path)

required_cols <- c("Taxa", "Rank")
missing_cols <- setdiff(required_cols, names(raw))
if (length(missing_cols) > 0) {
  stop(paste0("Missing required columns: ", paste(missing_cols, collapse = ", ")))
}

# Normalize rank labels to GBIF-expected values where possible.
normalize_rank <- function(rank_value) {
  if (is.na(rank_value)) return(NA_character_)
  r <- tolower(trimws(as.character(rank_value)))
  # Common typos and aliases.
  if (r == "faily") r <- "family"
  if (r %in% c("genus", "family", "order", "class", "phylum", "species", "subspecies")) return(r)
  if (r == "variety") return("variety")
  if (r == "forma") return("form")
  # Pass through if already in GBIF rank vocabulary.
  return(r)
}

rank_norm <- vapply(raw$Rank, normalize_rank, character(1))

df <- raw

df$Rank_normalized <- rank_norm

df$gbifID <- NA_integer_
df$matchType <- NA_character_
df$matched_name <- NA_character_
df$status <- NA_character_
df$note <- NA_character_

# Query GBIF backbone for each taxon/rank.
for (i in seq_len(nrow(df))) {
  taxon <- df$Taxa[i]
  rank <- df$Rank_normalized[i]

  if (is.na(taxon) || trimws(as.character(taxon)) == "") {
    df$status[i] <- "missing_taxon"
    df$note[i] <- "Taxa value is empty"
    next
  }

  if (is.na(rank) || trimws(as.character(rank)) == "") {
    df$status[i] <- "missing_rank"
    df$note[i] <- "Rank value is empty"
    next
  }

  # rgbif::name_backbone supports a rank parameter for correct taxonomic level.
  res <- try(rgbif::name_backbone(name = as.character(taxon), rank = as.character(rank)), silent = TRUE)
  if (inherits(res, "try-error")) {
    df$status[i] <- "error"
    df$note[i] <- as.character(res)
    next
  }

  if (!is.null(res$usageKey) && !is.na(res$usageKey)) {
    df$gbifID[i] <- as.integer(res$usageKey)
    df$matchType[i] <- res$matchType %||% NA_character_
    df$matched_name[i] <- res$scientificName %||% NA_character_
    df$status[i] <- "matched"
    df$note[i] <- NA_character_
  } else {
    df$status[i] <- "unmatched"
    df$note[i] <- "No usageKey returned"
  }

  # Be gentle with the GBIF API.
  Sys.sleep(0.2)
}

writexl::write_xlsx(df, path = output_path)
message("Done. Output written to: ", output_path)
