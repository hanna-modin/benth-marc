# Install packages if not already installed
if (!require("worrms", quietly = TRUE)) {
  install.packages("worrms")
}
if (!require("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}
if (!require("writexl", quietly = TRUE)) {
  install.packages("writexl")
}

library(worrms)
library(tidyverse)
library(writexl)

setwd("C:\\Users\\hamod4691\\Code\\arctic-benthic-biodiversity\\GBIF")

# Read the CSV file with cleaned names
cleaned_names_df <- read.csv("unique_names_cleaned.csv", stringsAsFactors = FALSE)
cleaned_names_df$cleaned_name <- stringr::str_squish(cleaned_names_df$cleaned_name)
species <- cleaned_names_df$cleaned_name
species <- unique(species[!is.na(species) & species != ""])

get_wm_records <- function(species_names, batch_size = 100) {
  # Split the species names into smaller batches
  batches <- split(species_names, ceiling(seq_along(species_names) / batch_size))
  
  # Initialize an empty list to store the results
  all_records <- list()
  
  # Loop through each batch and fetch records
  for (batch in batches) {
    records <- tryCatch({
      worrms::wm_records_names(batch)
    }, error = function(e) {
      message("Error fetching records: ", e)
      setNames(vector("list", length(batch)), batch)
    })

    all_records <- c(all_records, records)
    
    # Pause between requests to avoid overwhelming the server
    Sys.sleep(1)  # Adjust the sleep time as needed
  }
  
  return(all_records)
}

a <- get_wm_records(species)
names(a) <- species

# Extract AphiaID for each species (taking the first match)
get_first_aphiaid <- function(x) {
  if (is.null(x) || nrow(x) == 0 || is.null(x$AphiaID)) {
    return(NA_integer_)
  }
  suppressWarnings(as.integer(x$AphiaID[1]))
}

aphia_ids <- vapply(a, get_first_aphiaid, integer(1))
aphia_map <- tibble::tibble(
  cleaned_name = names(aphia_ids),
  AphiaID = aphia_ids
)

# Add AphiaID column to the original data frame
cleaned_names_df <- cleaned_names_df %>%
  left_join(aphia_map, by = "cleaned_name")

# Save the updated data frame back to the CSV file
write_xlsx(cleaned_names_df, "unique_names_aphia.xlsx")
message("Updated excel file saved with AphiaID column")