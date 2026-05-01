## Query WoRMS for environment (marine/fresh/terrestrial) for taxa
## Usage: run this script from the `Environment` folder; it reads ../taxonomic_filter.xlsx

pkgs <- c("readxl", "dplyr", "purrr", "worrms", "readr", "writexl")
missing_pkgs <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if(length(missing_pkgs)) stop("Missing required packages: ", paste(missing_pkgs, collapse = ", "))

library(readxl)
library(dplyr)
library(purrr)
library(worrms)
library(readr)

infile <- file.path("..", "taxonomic_filter.xlsx")
if(!file.exists(infile)) stop("Input file not found: ", infile)

df <- read_excel(infile)

# Try to locate an AphiaID column or a scientific name column
aphia_col <- grep("aphia.*id|aphiaid", names(df), ignore.case = TRUE, value = TRUE)
name_col <- grep("scientific.*name|name", names(df), ignore.case = TRUE, value = TRUE)

aphia_col <- if(length(aphia_col)) aphia_col[1] else NA_character_
name_col <- if(length(name_col)) name_col[1] else NA_character_

# Normalize AphiaIDs if present
if(!is.na(aphia_col)){
	df[[aphia_col]] <- as.integer(gsub("[^0-9]", "", as.character(df[[aphia_col]])))
}

# Caching of queries to avoid repeated requests
cache_file <- "worms_env_cache.rds"
cache <- if(file.exists(cache_file)) readRDS(cache_file) else list()

get_env_for <- function(id = NA_integer_, name = NA_character_){
	key <- if(!is.na(id)) as.character(id) else tolower(trimws(as.character(name)))
	if(key %in% names(cache)) return(cache[[key]])

	# Resolve AphiaID if needed
	aphia <- NA_integer_
	if(!is.na(id)) aphia <- as.integer(id)
	if(is.na(aphia) && !is.na(name) && nzchar(name)){
		aphia <- tryCatch(wm_name2id(as.character(name)), error = function(e) NA_integer_)
	}

	env <- NA_character_
	if(!is.na(aphia)){
		rec <- tryCatch(wm_record(aphia), error = function(e) NULL)
		if(!is.null(rec)){
			if(!is.null(rec$environment) && length(rec$environment)){
				env <- paste(unique(rec$environment), collapse = ";")
			} else if(!is.null(rec$isMarine)){
				env <- ifelse(rec$isMarine, "marine", "non-marine")
			}
		}
	}

	# store in cache
	cache[[key]] <<- ifelse(is.na(env), NA_character_, env)
	saveRDS(cache, cache_file)
	return(cache[[key]])
}

# Build input vector to query (prefer AphiaID, fall back to name)
query_keys <- pmap_chr(list(id = if(!is.na(aphia_col)) df[[aphia_col]] else rep(NA_integer_, nrow(df)),
														name = if(!is.na(name_col)) df[[name_col]] else rep(NA_character_, nrow(df))),
											 ~ if(!is.na(..1)) as.character(..1) else as.character(..2))

message("Querying WoRMS for ", length(unique(query_keys)), " unique keys (cached results reused).")

envs <- map_chr(unique(query_keys), function(k){
	# k may be an AphiaID string or name
	if(grepl("^[0-9]+$", k)) return(get_env_for(as.integer(k), NA_character_))
	return(get_env_for(NA_integer_, k))
})
names(envs) <- unique(query_keys)

# Map back to rows
df$worms_environment <- envs[query_keys]

out_xlsx <- file.path("..", "taxonomic_filter.xlsx")
sheet_name <- if (file.exists(out_xlsx)) readxl::excel_sheets(out_xlsx)[1] else "Sheet1"

# Handle multi-row data (e.g., multiple stages per AphiaID) by re-joining environment by AphiaID
if(!is.na(aphia_col) && "AphiaID" %in% names(df)){
	environment_map <- df %>%
		select(AphiaID, worms_environment) %>%
		filter(!is.na(AphiaID)) %>%
		group_by(AphiaID) %>%
		summarise(
			worms_environment = paste(sort(unique(na.omit(worms_environment))), collapse = ";"),
			.groups = "drop"
		)
	df <- df %>%
		select(-worms_environment) %>%
		left_join(environment_map, by = "AphiaID")
}

taxonomic_filter_workbook <- list()
taxonomic_filter_workbook[[sheet_name]] <- df

out_xlsx <- file.path("..", "taxonomic_filter_with_environment.xlsx")
writexl::write_xlsx(taxonomic_filter_workbook, out_xlsx)
message("Wrote results to: ", out_xlsx)

## End

