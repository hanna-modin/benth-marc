library(worrms)
library(readr)
library(writexl)

setwd("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/All_data")

# Read the CSV and extract the numeric AphiaID vector
df <- read_csv("update_aphiaID.csv", show_col_types = FALSE)

ids <- unique(df$aphiaID)
ids <- as.integer(ids)
ids <- ids[!is.na(ids)]

# batching + caching parameters
chunk_size <- 50L
cache_file <- "validated_nomenclature_cache2.rds"
output_csv <- "validated_nomenclature2.csv"

# load existing cache (a named list saved as RDS) into an environment
cache_env <- list2env(if (file.exists(cache_file)) readRDS(cache_file) else list(), parent = emptyenv())

ids_to_process <- ids[!vapply(as.character(ids), exists, logical(1), envir = cache_env)]
if (length(ids_to_process) == 0) {
	message("All IDs already cached; writing output from cache")
} else {
	chunks <- split(ids_to_process, ceiling(seq_along(ids_to_process) / chunk_size))
	for (ch in chunks) {
		# call the batch endpoint (max 50 IDs)
		res <- tryCatch(wm_record(id = as.integer(ch)), error = function(e) { message("Batch request failed: ", e$message); NULL })
		if (!is.null(res) && nrow(res) > 0) {
			# wm_record returns a data.frame-like object; assign each row into cache
			for (i in seq_len(nrow(res))) {
				row <- res[i, , drop = FALSE]
				key <- as.character(row$AphiaID)
				# convert row to a list for storage
				assign(key, as.list(row), envir = cache_env)
			}
			# persist cache after each successful chunk
			tryCatch(saveRDS(as.list(cache_env), cache_file), error = function(e) message("Failed saving cache: ", e$message))
		} else {
			# fallback: try per-id to maximize chance of partial success
			for (id in ch) {
				if (!exists(as.character(id), envir = cache_env, inherits = FALSE)) {
					rec <- tryCatch(wm_record(id = as.integer(id)), error = function(e) NULL)
					if (!is.null(rec) && nrow(rec) > 0) {
						assign(as.character(id), as.list(rec[1, , drop = FALSE]), envir = cache_env)
						tryCatch(saveRDS(as.list(cache_env), cache_file), error = function(e) message("Failed saving cache: ", e$message))
					} else {
						assign(as.character(id), NULL, envir = cache_env)
					}
				}
			}
		}
		Sys.sleep(0.1)
	}
}

## build output data.frame from cache in the original ID order
# determine union of all fields returned by cached records
all_keys <- ls(envir = cache_env)
field_names <- unique(unlist(lapply(all_keys, function(k) {
	rec <- get(k, envir = cache_env)
	if (is.null(rec)) return(NULL)
	names(rec)
})))
field_names <- unique(c("AphiaID", field_names))

out_rows <- vector("list", length(ids))
for (i in seq_along(ids)) {
	key <- as.character(ids[[i]])
	# prepare NA-filled named vector
	row_vals <- setNames(rep(NA_character_, length(field_names)), field_names)
	row_vals["AphiaID"] <- key
	if (exists(key, envir = cache_env, inherits = FALSE)) {
		rec <- get(key, envir = cache_env, inherits = FALSE)
		if (!is.null(rec)) {
			for (fn in names(rec)) {
				val <- rec[[fn]]
				if (is.atomic(val) && length(val) > 0) {
					row_vals[fn] <- as.character(val[1])
				} else {
					row_vals[fn] <- NA_character_
				}
			}
		}
	}
	out_rows[[i]] <- as.data.frame(as.list(row_vals), stringsAsFactors = FALSE, check.names = FALSE)
}

results <- do.call(rbind, out_rows)
results$AphiaID <- suppressWarnings(as.integer(as.character(results$AphiaID)))
write.csv(results, output_csv, row.names = FALSE)
message("Wrote ", nrow(results), " rows to ", output_csv)
write_xlsx(results, "validated_nomenclature4.xlsx")

# Extract the vali