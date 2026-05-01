#https://github.com/tomjwebb/WoRMS-functional-groups

setwd("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/Worms traits")

library(worrms)
library(readxl)
library(readr)
library(writexl)
library(tidyverse)

get_worms_fgrp <- function(AphiaID, max_retries = 3, base_wait = 0.5) {
	for (attempt in 1:max_retries) {
		tryCatch(
			{
				attr_dat <- worrms::wm_attr_data_(id = AphiaID, include_inherited = TRUE)
				
				if (nrow(attr_dat) == 0) {
					return(tibble(
						AphiaID = AphiaID,
						stage = NA_character_,
						functional_group_raw = NA_character_,
						functional_group_normalized = NA_character_,
						inherited = NA,
						inherited_from_AphiaID = NA_character_,
						note = "No attribute data found"
					))
				}

				fg_dat <- attr_dat %>%
					filter(measurementType == "Functional group")

				if (nrow(fg_dat) == 0) {
					return(tibble(
						AphiaID = AphiaID,
						stage = NA_character_,
						functional_group_raw = NA_character_,
						functional_group_normalized = NA_character_,
						inherited = NA,
						inherited_from_AphiaID = NA_character_,
						note = "No functional group found"
					))
				}

				stage_vals <- purrr::map_chr(fg_dat$children, function(ch) {
					if (is.null(ch) || nrow(ch) == 0 || !"measurementType" %in% names(ch)) {
						return("adult")
					}

					life_stage <- ch %>%
						filter(measurementType == "Life stage") %>%
						pull(measurementValue)

					if (length(life_stage) == 0 || is.na(life_stage[[1]])) "adult" else life_stage[[1]]
				})

				out <- tibble(
					AphiaID = as.numeric(fg_dat$AphiaID),
					AphiaID_Inherited = as.numeric(fg_dat$AphiaID_Inherited),
					stage = stage_vals,
					fun_grp = fg_dat$measurementValue
				) %>%
					distinct()

				out <- out %>%
					mutate(
						functional_group_raw = fun_grp,
						functional_group_normalized = case_when(
						str_detect(fun_grp, ">") ~ tolower(word(fun_grp, -1)),
						fun_grp == "Pisces" ~ "fish",
						fun_grp == "Algae > Macroalgae" ~ "macroalgae",
						TRUE ~ tolower(fun_grp)
					)
					) %>%
					select(AphiaID, stage, functional_group_raw, functional_group_normalized)

				return(out %>%
					group_by(AphiaID, stage) %>%
					summarise(
						functional_group_raw = paste(sort(unique(functional_group_raw)), collapse = "; "),
						functional_group_normalized = paste(sort(unique(functional_group_normalized)), collapse = "; "),
						inherited = NA,
						inherited_from_AphiaID = NA_character_,
						note = case_when(
							TRUE ~ "Functional group for this life stage is directly associated with the queried AphiaID"
						),
						.groups = "drop"
					))
			},
			error = function(e) {
				err_msg <- as.character(e)
				if (grepl("429|Too Many Requests", err_msg)) {
					wait_time <- base_wait * (2 ^ (attempt - 1))
					message("Rate limited (429) on AphiaID ", AphiaID, ". Retry ", attempt, " after ", round(wait_time, 1), "s")
					Sys.sleep(wait_time)
					if (attempt < max_retries) {
						return(get_worms_fgrp(AphiaID = AphiaID, max_retries = 1, base_wait = wait_time * 2))
					}
				}
				# Return empty result on error
				return(tibble(
					AphiaID = AphiaID,
					stage = NA_character_,
					functional_group_raw = NA_character_,
					functional_group_normalized = NA_character_,
					inherited = NA,
					inherited_from_AphiaID = NA_character_,
					note = paste("Error:", err_msg)
				))
			}
		)
	}
	# Fallback if all retries exhausted
	tibble(
		AphiaID = AphiaID,
		stage = NA_character_,
		functional_group_raw = NA_character_,
		functional_group_normalized = NA_character_,
		inherited = NA,
		inherited_from_AphiaID = NA_character_,
		note = "Query failed after max retries"
	)
}

worms_fgrp_col_types <- readr::cols(
	AphiaID = readr::col_double(),
	stage = readr::col_character(),
	functional_group_raw = readr::col_character(),
	functional_group_normalized = readr::col_character(),
	inherited = readr::col_logical(),
	inherited_from_AphiaID = readr::col_character(),
	note = readr::col_character()
)

coerce_worms_fgrp_schema <- function(df) {
	df %>%
		mutate(
			AphiaID = as.numeric(AphiaID),
			stage = as.character(stage),
			functional_group_raw = as.character(functional_group_raw),
			functional_group_normalized = as.character(functional_group_normalized),
			inherited = as.logical(inherited),
			inherited_from_AphiaID = as.character(inherited_from_AphiaID),
			note = as.character(note)
		) %>%
		select(
			AphiaID,
			stage,
			functional_group_raw,
			functional_group_normalized,
			inherited,
			inherited_from_AphiaID,
			note
		)
}

run_worms_fgrp_ids <- function(
	aphia_ids,
	chunk_size = 250,
	pause_sec = 0.02,
	checkpoint_path = NULL,
	reset_checkpoint = TRUE,
	resume_from_checkpoint = TRUE
) {
	ids_tbl <- tibble(AphiaID = as.numeric(aphia_ids)) %>%
		filter(!is.na(AphiaID)) %>%
		distinct()

	if (nrow(ids_tbl) == 0) {
		return(tibble(
			AphiaID = numeric(),
			stage = character(),
			functional_group_raw = character(),
			functional_group_normalized = character(),
			inherited = logical(),
			inherited_from_AphiaID = character(),
			note = character()
		))
	}

	idx <- split(seq_len(nrow(ids_tbl)), ceiling(seq_len(nrow(ids_tbl)) / chunk_size))
	out_list <- vector("list", length(idx))
	existing_checkpoint <- NULL

	if (!is.null(checkpoint_path) && isTRUE(reset_checkpoint) && file.exists(checkpoint_path)) {
		file.remove(checkpoint_path)
	}

	if (!is.null(checkpoint_path) && isTRUE(resume_from_checkpoint) && file.exists(checkpoint_path)) {
		existing_checkpoint <- readr::read_csv(
			checkpoint_path,
			col_types = worms_fgrp_col_types,
			show_col_types = FALSE
		) %>%
			coerce_worms_fgrp_schema()
		completed_ids <- existing_checkpoint %>%
		filter(!is.na(AphiaID)) %>%
		distinct(AphiaID)

		ids_tbl <- ids_tbl %>%
		anti_join(completed_ids, by = "AphiaID")

		message("Resume mode: ", nrow(completed_ids), " AphiaID(s) already in checkpoint, ", nrow(ids_tbl), " remaining")
	}

	if (nrow(ids_tbl) == 0) {
		if (!is.null(existing_checkpoint)) {
			return(existing_checkpoint)
		}
		return(tibble(
			AphiaID = numeric(),
			stage = character(),
			functional_group_raw = character(),
			functional_group_normalized = character(),
			inherited = logical(),
			inherited_from_AphiaID = character(),
			note = character()
		))
	}

	idx <- split(seq_len(nrow(ids_tbl)), ceiling(seq_len(nrow(ids_tbl)) / chunk_size))
	out_list <- vector("list", length(idx))

	for (i in seq_along(idx)) {
		chunk_ids <- ids_tbl$AphiaID[idx[[i]]]
		chunk_out <- purrr::map_dfr(chunk_ids, function(x) {
			if (pause_sec > 0) Sys.sleep(pause_sec)
			get_worms_fgrp(AphiaID = x)
		}) %>%
			coerce_worms_fgrp_schema()

		if (!is.null(checkpoint_path)) {
			readr::write_csv(chunk_out, checkpoint_path, append = file.exists(checkpoint_path))
		}

		out_list[[i]] <- chunk_out
		message("Completed chunk ", i, " of ", length(idx), " (", length(chunk_ids), " IDs)")
	}

	new_rows <- bind_rows(out_list) %>%
		coerce_worms_fgrp_schema()

	if (!is.null(existing_checkpoint)) {
		bind_rows(existing_checkpoint, new_rows) %>%
			coerce_worms_fgrp_schema()
	} else {
		new_rows
	}
}

read_aphia_ids_excel <- function(path, id_col = "AphiaID") {
	in_dat <- readxl::read_excel(path)
	if (!id_col %in% names(in_dat)) {
		stop("Column '", id_col, "' not found in ", path)
	}
	parsed <- gsub("[^0-9]", "", as.character(in_dat[[id_col]]))
	parsed[parsed == ""] <- NA_character_
	as.integer(parsed)
}

read_taxonomic_filter_input <- function(path) {
	in_dat <- readxl::read_excel(path)
	if (!"AphiaID" %in% names(in_dat)) {
		stop("Column 'AphiaID' not found in ", path)
	}

	scientific_name_col <- intersect(c("scientificname (WoRMS)", "scientificname", "ScientificName (GBIF)", "ScientificName"), names(in_dat))[1]
	if (is.na(scientific_name_col) || length(scientific_name_col) == 0) {
		in_dat$scientificname <- NA_character_
	} else {
		in_dat$scientificname <- as.character(in_dat[[scientific_name_col]])
	}

	in_dat <- in_dat %>%
		mutate(
			AphiaID = {
				parsed <- gsub("[^0-9]", "", as.character(AphiaID))
				parsed[parsed == ""] <- NA_character_
				as.integer(parsed)
			},
			scientificname = as.character(scientificname)
		) %>%
		select(AphiaID, scientificname, everything())

	in_dat
}

default_ids <- c(124321, 100803)
input_ids_xlsx <- file.path("..", "taxonomic_filter.xlsx")

input_taxa <- if (file.exists(input_ids_xlsx)) {
	read_taxonomic_filter_input(input_ids_xlsx)
} else {
	tibble(
		AphiaID = default_ids,
		scientificname = NA_character_
	)
}

input_taxa <- input_taxa %>%
	filter(!is.na(AphiaID))

aphia_ids <- input_taxa$AphiaID

## Wrapper with retry logic for rate-limit handling
get_worms_attr_data_safe <- function(id, max_retries = 3, base_wait = 0.5) {
	for (attempt in 1:max_retries) {
		tryCatch(
			{
				Sys.sleep(base_wait)
				return(suppressWarnings(wm_attr_data_(id = id)))
			},
			error = function(e) {
				if (grepl("429|Too Many Requests", as.character(e))) {
					wait_time <- base_wait * (2 ^ (attempt - 1))
					message("Rate limited (429). Retry ", attempt, " after ", round(wait_time, 1), "s wait")
					Sys.sleep(wait_time)
					if (attempt < max_retries) {
						# Recursive retry
						get_worms_attr_data_safe(id = id, max_retries = 1, base_wait = wait_time * 2)
					} else {
						NULL
					}
				} else {
					# Other errors are silently ignored (e.g., 204 No Content)
					NULL
				}
			}
		)
	}
	NULL
}

traits_data <- purrr::map_dfr(aphia_ids, function(id) {
	result <- tryCatch(get_worms_attr_data_safe(id = id, max_retries = 3, base_wait = 0.5),
		error = function(e) NULL)
	if (is.null(result)) tibble() else result
}, .progress = TRUE)
write_csv(traits_data, "taxonomic_filter_traits_data.csv")

## Safe wrapper for attr def queries
get_worms_attr_def_safe <- function(id, max_retries = 3, base_wait = 0.5) {
	for (attempt in 1:max_retries) {
		tryCatch(
			{
				Sys.sleep(base_wait)
				return(suppressWarnings(wm_attr_def_(id = id)))
			},
			error = function(e) {
				if (grepl("429|Too Many Requests", as.character(e))) {
					wait_time <- base_wait * (2 ^ (attempt - 1))
					message("Rate limited (429). Retry ", attempt, " after ", round(wait_time, 1), "s wait")
					Sys.sleep(wait_time)
					if (attempt < max_retries) {
						get_worms_attr_def_safe(id = id, max_retries = 1, base_wait = wait_time * 2)
					} else {
						NULL
					}
				} else {
					NULL
				}
			}
		)
	}
	NULL
}

traits_definitions <- purrr::map_dfr(aphia_ids, function(id) {
	result <- tryCatch(get_worms_attr_def_safe(id = id, max_retries = 3, base_wait = 0.5),
		error = function(e) NULL)
	if (is.null(result)) tibble() else result
}, .progress = TRUE)
write_csv(traits_definitions, "taxonomic_filter_traits_definitions.csv")

all_stage_fg_results <- run_worms_fgrp_ids(
	aphia_ids = aphia_ids,
	chunk_size = 250,
	pause_sec = 0.5,  # Increased from 0.02 to reduce rate-limit hits
	checkpoint_path = "taxonomic_filter_functional_groups_checkpoint.csv",
	reset_checkpoint = TRUE,
	resume_from_checkpoint = TRUE
)

all_stage_fg_results <- all_stage_fg_results %>%
	left_join(
		input_taxa %>%
			distinct(AphiaID, .keep_all = TRUE) %>%
			select(AphiaID, scientificname) %>%
			distinct(),
		by = "AphiaID"
	)

taxonomic_filter_xlsx <- file.path("..", "taxonomic_filter.xlsx")
taxonomic_filter_sheet <- if (file.exists(taxonomic_filter_xlsx)) readxl::excel_sheets(taxonomic_filter_xlsx)[1] else "Sheet1"

stage_cols <- c(
	"AphiaID",
	"stage",
	"functional_group_raw",
	"functional_group_normalized",
	"inherited",
	"inherited_from_AphiaID",
	"note"
)

taxonomic_filter_out <- input_taxa %>%
	left_join(
		all_stage_fg_results %>%
			select(any_of(stage_cols)),
		by = "AphiaID",
		relationship = "many-to-many"
	)

taxonomic_filter_workbook <- list()
taxonomic_filter_workbook[[taxonomic_filter_sheet]] <- taxonomic_filter_out
write_xlsx(taxonomic_filter_workbook, taxonomic_filter_xlsx)
message("Wrote results to: ", taxonomic_filter_xlsx)


# Change reset_checkpoint = TRUE to reset_checkpoint = FALSE to resume from where it stopped if interrupted.