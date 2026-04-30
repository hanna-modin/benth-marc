#https://github.com/tomjwebb/WoRMS-functional-groups

setwd("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/Worms traits")

library(worrms)
library(readr)
library(tidyverse)

get_worms_fgrp <- function(AphiaID) {
	attr_dat <- try(
		worrms::wm_attr_data_(id = AphiaID, include_inherited = TRUE),
		silent = TRUE
	)

	if (inherits(attr_dat, "try-error") || nrow(attr_dat) == 0) {
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
		select(AphiaID, AphiaID_Inherited, stage, functional_group_raw, functional_group_normalized)

	out %>%
		group_by(AphiaID, stage) %>%
		summarise(
			functional_group_raw = paste(sort(unique(functional_group_raw)), collapse = "; "),
			functional_group_normalized = paste(sort(unique(functional_group_normalized)), collapse = "; "),
			inherited = any(AphiaID_Inherited != AphiaID, na.rm = TRUE),
			inherited_from_AphiaID = paste(sort(unique(AphiaID_Inherited[!is.na(AphiaID_Inherited)])), collapse = "; "),
			note = case_when(
				inherited ~ "At least one functional group for this life stage is inherited from a higher taxon",
				TRUE ~ "Functional group for this life stage is directly associated with the queried AphiaID"
			),
			.groups = "drop"
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

read_aphia_ids_csv <- function(path, id_col = "AphiaID") {
	in_dat <- readr::read_csv(path, show_col_types = FALSE)
	if (!id_col %in% names(in_dat)) {
		stop("Column '", id_col, "' not found in ", path)
	}
	in_dat[[id_col]]
}

species <- c(124321)

traits_data <- wm_attr_data_(id = species)
write_csv(traits_data, "traits_data.csv")

traits_definitions <- wm_attr_def_(id = species)
write_csv(traits_definitions, "traits_definitions.csv")

get_worms_fgrp(AphiaID = 124321)
get_worms_fgrp(AphiaID = 100803)

default_ids <- c(124321, 100803)
input_ids_csv <- "aphia_ids_input.csv"

aphia_ids <- if (file.exists(input_ids_csv)) {
	read_aphia_ids_csv(input_ids_csv, id_col = "AphiaID")
} else {
	default_ids
}

all_stage_fg_results <- run_worms_fgrp_ids(
	aphia_ids = aphia_ids,
	chunk_size = 250,
	pause_sec = 0.02,
	checkpoint_path = "functional_groups_checkpoint.csv",
	reset_checkpoint = TRUE,
	resume_from_checkpoint = TRUE
)

write_csv(all_stage_fg_results, "functional_groups.csv")


#CHANGE RESET CHECKPOINT TO FALSE
