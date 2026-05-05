# Debug script to diagnose empty datasets_OBIS.xlsx

setwd("C:\\Users\\hamod4691\\Code\\arctic-benthic-biodiversity\\OBIS")

library(jsonlite)
library(dplyr)
library(arrow)

# Load the data
dataset_east_json <- jsonlite::fromJSON("dataset_east.json")
dataset_west_json <- jsonlite::fromJSON("dataset_west.json")

cat("=== Dataset East Structure ===\n")
str(dataset_east_json, max.level = 1)
cat("\nNumber of records:", length(dataset_east_json), "\n")
cat("Column names:", names(dataset_east_json), "\n\n")

cat("=== Dataset West Structure ===\n")
str(dataset_west_json, max.level = 1)
cat("\nNumber of records:", length(dataset_west_json), "\n")
cat("Column names:", names(dataset_west_json), "\n\n")

# Extract selected fields
selected_fields <- c("id", "url", "published", "title", "abstract", "intellectualrights")

dataset_east_selected <- dplyr::select(dataset_east_json, dplyr::any_of(selected_fields))
dataset_west_selected <- dplyr::select(dataset_west_json, dplyr::any_of(selected_fields))

cat("=== After Selection ===\n")
cat("East selected rows:", nrow(dataset_east_selected), "\n")
cat("West selected rows:", nrow(dataset_west_selected), "\n")
cat("East ID values sample:", head(dataset_east_selected$id, 5), "\n")
cat("West ID values sample:", head(dataset_west_selected$id, 5), "\n\n")

# Merge
datasets_merged <- dplyr::bind_rows(dataset_east_selected, dataset_west_selected) %>%
  dplyr::distinct(id, .keep_all = TRUE)

cat("=== After Merge & Dedup ===\n")
cat("Merged rows:", nrow(datasets_merged), "\n")
cat("ID class:", class(datasets_merged$id), "\n")
cat("ID values sample:", head(datasets_merged$id, 5), "\n\n")

# Load the parquet file
merged_obis_ids <- read_parquet("merged_OBIS.parquet") %>%
  dplyr::select(id) %>%
  dplyr::distinct() %>%
  dplyr::mutate(id = as.character(id))

cat("=== Parquet IDs ===\n")
cat("Unique IDs in parquet:", nrow(merged_obis_ids), "\n")
cat("ID class:", class(merged_obis_ids$id), "\n")
cat("ID values sample:", head(merged_obis_ids$id, 5), "\n\n")

# Check for matches
datasets_merged_char <- datasets_merged %>%
  dplyr::mutate(id = as.character(id))

cat("=== Checking Matches ===\n")
matched <- dplyr::semi_join(datasets_merged_char, merged_obis_ids, by = "id")
cat("Rows after semi_join:", nrow(matched), "\n")

# Check if any IDs match at all
common_ids <- intersect(datasets_merged_char$id, merged_obis_ids$id)
cat("Common IDs found:", length(common_ids), "\n")
if (length(common_ids) > 0) {
  cat("Sample common IDs:", head(common_ids, 5), "\n")
}
