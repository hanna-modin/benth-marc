#!/usr/bin/env Rscript

required_packages <- c("httr", "jsonlite", "writexl")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
	stop("Missing required packages: ", paste(missing_packages, collapse = ", "))
}

`%||%` <- function(x, y) {
	if (is.null(x) || length(x) == 0 || all(is.na(x))) y else x
}

clean_aphia_ids <- function(x) {
	x <- as.character(x)
	x <- gsub("[^0-9]", "", x)
	x[x == ""] <- NA_character_
	x <- unique(x)
	suppressWarnings(as.integer(x[!is.na(x)]))
}

first_non_empty <- function(values) {
	values <- as.character(values)
	values <- values[!is.na(values) & nzchar(values)]
	if (length(values)) values[1] else NA_character_
}

extract_text_field <- function(record, fields) {
	if (is.null(record)) return(NA_character_)
	for (field in fields) {
		if (!is.null(record[[field]]) && length(record[[field]]) > 0) {
			value <- first_non_empty(record[[field]])
			if (!is.na(value)) return(value)
		}
	}
	NA_character_
}

extract_integer_field <- function(record, fields) {
	value <- extract_text_field(record, fields)
	if (is.na(value)) return(NA_integer_)
	value <- gsub("[^0-9]", "", value)
	if (!nzchar(value)) return(NA_integer_)
	suppressWarnings(as.integer(value))
}

extract_species_epithet <- function(scientific_name) {
	if (is.na(scientific_name) || !nzchar(scientific_name)) return(NA_character_)
	tokens <- strsplit(trimws(scientific_name), "\\s+")[[1]]
	if (length(tokens) < 2) return(NA_character_)
	tokens[2]
}

fetch_worms_record <- function(aphia_id, cache_env, cache_file, debug = FALSE) {
	key <- as.character(aphia_id)
	if (exists(key, envir = cache_env, inherits = FALSE)) {
		if (debug) message("  [CACHE HIT] ", key)
		return(get(key, envir = cache_env, inherits = FALSE))
	}

	url <- sprintf("https://www.marinespecies.org/rest/AphiaRecordByAphiaID/%s", key)
	if (debug) message("  [REQUEST] ", url)
	
	response <- tryCatch(
		httr::GET(url, httr::timeout(10)),
		error = function(e) {
			if (debug) message("  [ERROR] Request failed: ", e$message)
			NULL
		}
	)
	
	if (is.null(response)) {
		if (debug) message("  [NULL RESPONSE]")
		return(NULL)
	}
	
	status <- httr::status_code(response)
	if (debug) message("  [STATUS] ", status)
	
	if (status != 200) {
		if (debug) message("  [FAILED] Status code: ", status)
		return(NULL)
	}

	content <- httr::content(response, as = "text", encoding = "UTF-8")
	if (debug) message("  [CONTENT LENGTH] ", nchar(content))
	
	if (!nzchar(content)) {
		if (debug) message("  [EMPTY CONTENT]")
		return(NULL)
	}

	record <- tryCatch(
		jsonlite::fromJSON(content, simplifyVector = FALSE),
		error = function(e) {
			if (debug) message("  [JSON PARSE ERROR] ", e$message)
			NULL
		}
	)
	
	if (is.null(record)) {
		if (debug) message("  [JSON PARSE FAILED]")
		return(NULL)
	}

	if (debug) message("  [SUCCESS] Keys: ", paste(names(record), collapse = ", "))
	
	assign(key, record, envir = cache_env)
	saveRDS(as.list(cache_env), cache_file)
	record
}

build_worms_row <- function(aphia_id, cache_env, cache_file, debug = FALSE) {
	source_record <- fetch_worms_record(aphia_id, cache_env, cache_file, debug = debug)
	if (is.null(source_record)) {
		return(data.frame(
			AphiaID = as.integer(aphia_id),
			accepted_scientific_name = NA_character_,
			phylum = NA_character_,
			class = NA_character_,
			order = NA_character_,
			family = NA_character_,
			genus = NA_character_,
			species_epithet = NA_character_,
			taxon_rank = NA_character_,
			taxonomic_issue = NA_character_,
			taxonomic_status = NA_character_,
			valid_authority = NA_character_,
			stringsAsFactors = FALSE,
			check.names = FALSE
		))
	}

	accepted_id <- extract_integer_field(source_record, c("valid_AphiaID", "validAphiaID", "accepted_AphiaID", "acceptedAphiaID", "AphiaID"))
	accepted_record <- source_record
	if (!is.na(accepted_id) && !identical(accepted_id, as.integer(aphia_id))) {
		alt_record <- fetch_worms_record(accepted_id, cache_env, cache_file, debug = debug)
		if (!is.null(alt_record)) {
			accepted_record <- alt_record
		}
	}

	accepted_scientific_name <- extract_text_field(accepted_record, c("valid_name", "scientificname", "scientificName"))
	phylum <- extract_text_field(accepted_record, c("phylum"))
	class_name <- extract_text_field(accepted_record, c("class"))
	order_name <- extract_text_field(accepted_record, c("order"))
	family <- extract_text_field(accepted_record, c("family"))
	genus <- extract_text_field(accepted_record, c("genus"))
	taxon_rank <- extract_text_field(accepted_record, c("rank", "taxonRank", "taxon_rank"))
	taxonomic_issue <- extract_text_field(source_record, c("taxonomicStatus", "taxonomicstatus", "taxonomicIssue", "taxonomic_issue"))
	if (is.na(taxonomic_issue)) {
		taxonomic_issue <- extract_text_field(accepted_record, c("taxonomicStatus", "taxonomicstatus", "taxonomicIssue", "taxonomic_issue"))
	}
	taxonomic_status <- extract_text_field(source_record, c("status", "taxonomic_status", "taxonomicStatus", "taxonomicstatus"))
	if (is.na(taxonomic_status)) {
		taxonomic_status <- extract_text_field(accepted_record, c("status", "taxonomic_status", "taxonomicStatus", "taxonomicstatus"))
	}
	valid_authority <- extract_text_field(accepted_record, c("valid_authority", "validAuthority", "authority"))

	if (is.na(accepted_scientific_name)) {
		accepted_scientific_name <- extract_text_field(source_record, c("scientificname", "scientificName", "valid_name"))
	}
	if (is.na(phylum)) phylum <- extract_text_field(source_record, c("phylum"))
	if (is.na(class_name)) class_name <- extract_text_field(source_record, c("class"))
	if (is.na(order_name)) order_name <- extract_text_field(source_record, c("order"))
	if (is.na(family)) family <- extract_text_field(source_record, c("family"))
	if (is.na(genus)) genus <- extract_text_field(source_record, c("genus"))
	if (is.na(taxon_rank)) taxon_rank <- extract_text_field(source_record, c("rank", "taxonRank", "taxon_rank"))
	if (is.na(valid_authority)) valid_authority <- extract_text_field(source_record, c("valid_authority", "validAuthority", "authority"))

	species_epithet <- extract_species_epithet(accepted_scientific_name)

	data.frame(
		AphiaID = as.integer(aphia_id),
		accepted_scientific_name = accepted_scientific_name,
		phylum = phylum,
		class = class_name,
		order = order_name,
		family = family,
		genus = genus,
		species_epithet = species_epithet,
		taxon_rank = taxon_rank,
		taxonomic_issue = taxonomic_issue,
		taxonomic_status = taxonomic_status,
		valid_authority = valid_authority,
		stringsAsFactors = FALSE,
		check.names = FALSE
	)
}

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
	stop("Usage: Rscript validate_nomenclature_from_csv.R <input_csv_file> [--debug]")
}

input_csv <- args[1]
debug_mode <- "--debug" %in% args

if (!file.exists(input_csv)) {
	stop("Input file not found: ", input_csv)
}

message("Reading input CSV: ", input_csv)
source_df <- read.csv(input_csv, stringsAsFactors = FALSE)

# Find AphiaID column
aphia_col_candidates <- grep("aphia.*id|^aphiaid$|^aphia_id$", names(source_df), ignore.case = TRUE, value = TRUE)
if (!length(aphia_col_candidates)) {
	stop("Could not find an AphiaID column in the CSV. Available columns: ", paste(names(source_df), collapse = ", "))
}
aphia_col <- aphia_col_candidates[1]

unique_aphia_ids <- clean_aphia_ids(source_df[[aphia_col]])
if (!length(unique_aphia_ids)) {
	stop("No valid AphiaIDs were found in column: ", aphia_col)
}

message("Found ", length(unique_aphia_ids), " unique AphiaIDs in column: ", aphia_col)

# Setup output paths
output_dir <- dirname(normalizePath(input_csv, winslash = "/", mustWork = FALSE))
base_name <- tools::file_path_sans_ext(basename(input_csv))
output_xlsx <- file.path(output_dir, paste0(base_name, "_worms_taxonomy.xlsx"))
cache_file <- file.path(output_dir, paste0(base_name, "_worms_cache.rds"))

# Load cache if it exists
cache_env <- list2env(if (file.exists(cache_file)) readRDS(cache_file) else list(), parent = emptyenv())

unique_aphia_df <- data.frame(AphiaID = unique_aphia_ids, stringsAsFactors = FALSE)

message("Querying WoRMS for ", length(unique_aphia_ids), " unique AphiaIDs.")
if (debug_mode) message("[DEBUG MODE ENABLED]")

taxonomy_rows <- vector("list", length(unique_aphia_ids))
for (i in seq_along(unique_aphia_ids)) {
	aphia_id <- unique_aphia_ids[[i]]
	if (i == 1 || i %% 50 == 0 || i == length(unique_aphia_ids)) {
		message(sprintf("Resolving %d/%d (AphiaID=%s)", i, length(unique_aphia_ids), aphia_id))
	}
	taxonomy_rows[[i]] <- build_worms_row(aphia_id, cache_env, cache_file, debug = debug_mode && i <= 3)
	Sys.sleep(0.05)
}

worms_taxonomy <- do.call(rbind, taxonomy_rows)
if (nrow(worms_taxonomy) > 1) {
	worms_taxonomy <- worms_taxonomy[!duplicated(worms_taxonomy$AphiaID), , drop = FALSE]
}

workbook <- list(
	unique_aphia_ids = unique_aphia_df,
	worms_taxonomy = worms_taxonomy
)

writexl::write_xlsx(workbook, output_xlsx)
message("Wrote Excel workbook: ", output_xlsx)

invisible(list(
	input_csv = input_csv,
	output_xlsx = output_xlsx,
	unique_aphia_ids = unique_aphia_df,
	worms_taxonomy = worms_taxonomy
))
