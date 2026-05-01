#!/usr/bin/env Rscript
# Determine extinct/extant status for taxa in taxonomic_filter.xlsx using WoRMS REST API

## Helpers: null-coalescing operator
`%||%` <- function(a,b) if(!is.null(a)) a else b

required <- c('readxl','httr','jsonlite','dplyr','stringr')
missing_pkgs <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if(length(missing_pkgs)) stop('Missing required packages: ', paste(missing_pkgs, collapse = ', '))

# locate taxonomic_filter.xlsx in likely locations relative to current working dir
candidate_paths <- c(
	file.path(getwd(), 'taxonomic_filter.xlsx'),
	file.path(getwd(), '..', 'taxonomic_filter.xlsx'),
	file.path(getwd(), '..', '..', 'taxonomic_filter.xlsx'),
	'../taxonomic_filter.xlsx',
	'../../taxonomic_filter.xlsx'
)
input_xlsx <- normalizePath(candidate_paths[file.exists(candidate_paths)][1], winslash='\\', mustWork=FALSE)
if(is.na(input_xlsx) || !file.exists(input_xlsx)) stop('Cannot find taxonomic_filter.xlsx in expected locations. Tried: ', paste(candidate_paths, collapse='; '))

df <- readxl::read_excel(input_xlsx)
df <- as.data.frame(df)

cols_lower <- tolower(names(df))

# helper: find a column by candidates
find_col <- function(cands){
	for(c in cands){
		idx <- which(cols_lower == tolower(c))
		if(length(idx)) return(names(df)[idx[1]])
	}
	return(NA_character_)
}

aphia_col <- find_col(c('AphiaID','aphiaid','aphia'))
name_col  <- find_col(c('scientificName','scientific_name','scientificname','name','taxon','originalName','original_name'))
if(is.na(name_col)) stop('Could not find a taxon name column in taxonomic_filter.xlsx; expected one of scientificName/name/taxon')

clean_aphia <- function(x){
	x <- as.character(x)
	x[is.na(x)] <- ''
	y <- gsub('[^0-9]','', x)
	y[y==''] <- NA
	as.integer(y)
}

base_url <- 'https://www.marinespecies.org/rest'

query_by_aphia <- function(id){
	url <- sprintf('%s/AphiaRecordByAphiaID/%s', base_url, id)
	res <- httr::GET(url)
	if(httr::status_code(res) != 200) return(NULL)
	jsonlite::fromJSON(httr::content(res, 'text', encoding='UTF-8'), simplifyVector = FALSE)
}

query_by_name <- function(name){
	name_enc <- URLencode(name, reserved=TRUE)
	url <- sprintf('%s/AphiaRecordsByName/%s?like=false', base_url, name_enc)
	res <- httr::GET(url)
	if(httr::status_code(res) != 200) return(NULL)
	jsonlite::fromJSON(httr::content(res, 'text', encoding='UTF-8'), simplifyVector = FALSE)
}

# prepare output columns
df$worms_query_source <- NA_character_
df$worms_AphiaID <- NA_integer_
df$worms_matched_name <- NA_character_
df$worms_isExtinct <- NA

aphia_ids <- if(!is.na(aphia_col)) clean_aphia(df[[aphia_col]]) else rep(NA_integer_, nrow(df))

for(i in seq_len(nrow(df))){
	Sys.sleep(0.05) # polite pause between requests
	row_name <- as.character(df[[name_col]][i])
	# try AphiaID first if present
	if(!is.na(aphia_ids[i]) && !is.null(aphia_ids[i])){
		rec <- tryCatch(query_by_aphia(aphia_ids[i]), error=function(e) NULL)
		if(!is.null(rec) && length(rec)>0){
			df$worms_query_source[i] <- 'AphiaID'
			df$worms_AphiaID[i] <- as.integer(rec$AphiaID %||% NA)
			df$worms_matched_name[i] <- rec$scientificname %||% rec$scientificName %||% row_name
			if(!is.null(rec$isExtinct)) df$worms_isExtinct[i] <- as.logical(rec$isExtinct)
			next
		}
	}
	# fallback: query by name
	if(!is.na(row_name) && nzchar(row_name)){
		recs <- tryCatch(query_by_name(row_name), error=function(e) NULL)
		if(!is.null(recs) && length(recs)>0){
			rec <- recs[[1]]
			df$worms_query_source[i] <- 'Name'
			df$worms_AphiaID[i] <- as.integer(rec$AphiaID %||% NA)
			df$worms_matched_name[i] <- rec$scientificname %||% rec$scientificName %||% row_name
			if(!is.null(rec$isExtinct)) df$worms_isExtinct[i] <- as.logical(rec$isExtinct)
			next
		}
	}
	df$worms_query_source[i] <- 'none'
}

sheet_name <- if (file.exists(input_xlsx)) readxl::excel_sheets(input_xlsx)[1] else 'Sheet1'

# Handle multi-row data (e.g., multiple stages per AphiaID) by re-joining extinct info by AphiaID
if(!is.na(aphia_col) && 'AphiaID' %in% names(df)){
	extinct_cols <- c('worms_query_source', 'worms_AphiaID', 'worms_matched_name', 'worms_isExtinct')
	extinct_map <- df %>%
		select(AphiaID, all_of(extinct_cols)) %>%
		distinct() %>%
		filter(!is.na(AphiaID))
	df <- df %>%
		select(-all_of(extinct_cols)) %>%
		left_join(extinct_map, by = 'AphiaID')
}

taxonomic_filter_workbook <- list()
taxonomic_filter_workbook[[sheet_name]] <- df
writexl::write_xlsx(taxonomic_filter_workbook, input_xlsx)
message('Wrote results to: ', input_xlsx)

invisible(df)

