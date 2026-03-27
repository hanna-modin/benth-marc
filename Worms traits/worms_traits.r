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
		return(tibble(AphiaID = AphiaID, adult = NA_character_))
	}

	fg_dat <- attr_dat %>%
		filter(measurementType == "Functional group")

	if (nrow(fg_dat) == 0) {
		return(tibble(AphiaID = AphiaID, adult = NA_character_))
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
		stage = stage_vals,
		fun_grp = fg_dat$measurementValue
	) %>%
		distinct()

	if (nrow(out) > 1) {
		out <- out %>%
			group_by(stage) %>%
			mutate(nth_stage_val = row_number()) %>%
			ungroup() %>%
			mutate(
				stage = case_when(
					nth_stage_val == 1 ~ stage,
					TRUE ~ paste(stage, nth_stage_val, sep = "_")
				)
			) %>%
			select(-nth_stage_val)
	}

	out %>%
		mutate(functional_group = case_when(
			str_detect(fun_grp, ">") ~ tolower(word(fun_grp, -1)),
			fun_grp == "Pisces" ~ "fish",
			fun_grp == "Algae > Macroalgae" ~ "macroalgae",
			TRUE ~ tolower(fun_grp)
		)) %>%
		select(-fun_grp) %>%
		pivot_wider(names_from = stage, values_from = functional_group)
}

species <- c(124321)

traits_data <- wm_attr_data_(id = species)
write_csv(traits_data, "traits_data.csv")

traits_definitions <- wm_attr_def_(id = species)
write_csv(traits_definitions, "traits_definitions.csv")

get_worms_fgrp(AphiaID = 124321)
get_worms_fgrp(AphiaID = 100803)
