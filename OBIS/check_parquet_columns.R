# Check what columns exist in merged_OBIS.parquet
setwd("C:\\Users\\hamod4691\\Code\\arctic-benthic-biodiversity\\OBIS")

library(arrow)

# Read just the schema to see column names
parquet_file <- "merged_OBIS.parquet"
schema <- arrow::read_parquet(parquet_file, as_data_frame = FALSE)

cat("Column names in merged_OBIS.parquet:\n")
print(names(schema))

cat("\n\nFirst few rows:\n")
first_rows <- arrow::read_parquet(parquet_file, n_rows = 5)
head(first_rows, 2)
