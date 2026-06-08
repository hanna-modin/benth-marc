library(rgbif)
library(worrms)

`%||%` <- function(x, y) {
	if (is.null(x) || length(x) == 0) y else x
}

resolve_aphiaid_from_taxonkey <- function(taxon_key) {
	if (is.na(taxon_key) || !nzchar(as.character(taxon_key))) {
		return(data.frame(
			taxonKey = taxon_key,
			taxon_name = NA_character_,
			AphiaID = NA_integer_,
			stringsAsFactors = FALSE
		))
	}

	taxon <- try(rgbif::name_usage(key = as.integer(taxon_key)), silent = TRUE)
	if (inherits(taxon, "try-error")) {
		return(data.frame(
			taxonKey = taxon_key,
			taxon_name = NA_character_,
			AphiaID = NA_integer_,
			stringsAsFactors = FALSE
		))
	}

	taxon_name <- taxon$data$canonicalName[1] %||% NA_character_
	if (is.na(taxon_name) || !nzchar(taxon_name)) {
		taxon_name <- taxon$data$scientificName[1] %||% NA_character_
	}

	if (is.na(taxon_name) || !nzchar(taxon_name)) {
		return(data.frame(
			taxonKey = taxon_key,
			taxon_name = NA_character_,
			AphiaID = NA_integer_,
			stringsAsFactors = FALSE
		))
	}

	worms_match <- try(worrms::wm_records_name(taxon_name, marine_only = FALSE), silent = TRUE)
	if (inherits(worms_match, "try-error") || nrow(worms_match) == 0) {
		return(data.frame(
			taxonKey = taxon_key,
			taxon_name = taxon_name,
			AphiaID = NA_integer_,
			stringsAsFactors = FALSE
		))
	}

	aphia_id <- worms_match$valid_AphiaID[1]
	if (is.na(aphia_id) || !nzchar(as.character(aphia_id))) {
		aphia_id <- worms_match$AphiaID[1]
	}

	if (is.na(aphia_id) || !nzchar(as.character(aphia_id))) {
		aphia_id <- NA_integer_
	}

	data.frame(
		taxonKey = taxon_key,
		taxon_name = taxon_name,
		AphiaID = as.integer(aphia_id),
		stringsAsFactors = FALSE
	)
}

resolve_aphiaid_column <- function(input_csv, taxon_key_column = "taxonKey", output_csv = NULL) {
	df <- read.csv(input_csv, stringsAsFactors = FALSE)
	if (!taxon_key_column %in% names(df)) {
		stop(paste0("Column not found: ", taxon_key_column))
	}

	results <- do.call(rbind, lapply(df[[taxon_key_column]], resolve_aphiaid_from_taxonkey))
	df$taxon_name <- results$taxon_name
	df$AphiaID <- results$AphiaID

	if (is.null(output_csv)) {
		output_csv <- sub("\\.csv$", "_aphia.csv", input_csv, ignore.case = TRUE)
	}

	write.csv(df, output_csv, row.names = FALSE)
	message("Wrote: ", output_csv)
	return(df)
}

# Example:
# resolve_aphiaid_column("your_file.csv", taxon_key_column = "taxonKey")