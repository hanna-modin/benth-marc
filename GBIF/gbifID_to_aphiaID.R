library(rgbif)
library(worrms)
library(arrow)
library(stats)

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

resolve_aphiaid_parquet <- function(parquet_path = "GBIF/gbif_final.parquet",
																		taxon_key_col = "sourceID",
																		aphia_col = "aphiaID",
																		output_path = NULL) {
	if (!file.exists(parquet_path)) {
		stop(paste0("Parquet file not found: ", parquet_path))
	}

	df <- arrow::read_parquet(parquet_path)
	if (!taxon_key_col %in% names(df)) {
		stop(paste0("Column not found: ", taxon_key_col))
	}

	unique_keys <- unique(df[[taxon_key_col]])
	unique_keys <- unique_keys[!is.na(unique_keys)]
	if (length(unique_keys) == 0) {
		message("No non-missing taxon keys found in column: ", taxon_key_col)
		if (is.null(output_path)) output_path <- parquet_path
		arrow::write_parquet(df, output_path)
		return(list(df = df, empty_count = sum(is.na(df[[aphia_col]]))))
	}

	# Resolve AphiaIDs for unique taxon keys
	results_list <- lapply(unique_keys, function(k) {
		res <- resolve_aphiaid_from_taxonkey(k)
		data.frame(taxonKey = k, AphiaID = res$AphiaID, stringsAsFactors = FALSE)
	})
	mapping <- do.call(rbind, results_list)
	# Ensure unique mapping
	mapping <- mapping[!duplicated(mapping$taxonKey), , drop = FALSE]

	# Create a named vector for fast lookup
	map_vec <- setNames(mapping$AphiaID, as.character(mapping$taxonKey))

	# Assign aphia column (preserve existing columns and order)
	df[[aphia_col]] <- as.integer(map_vec[as.character(df[[taxon_key_col]])])

	if (is.null(output_path)) output_path <- parquet_path
	arrow::write_parquet(df, output_path)

	empty_count <- sum(is.na(df[[aphia_col]]))
	message("Wrote: ", output_path)
	message("Empty/NA rows in ", aphia_col, ": ", empty_count)

	invisible(list(df = df, empty_count = empty_count))
}