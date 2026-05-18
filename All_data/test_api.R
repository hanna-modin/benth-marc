library(httr)
library(jsonlite)

url <- "https://www.marinespecies.org/rest/AphiaRecordByAphiaID/2"
cat("Testing URL:", url, "\n")

response <- tryCatch(
  httr::GET(url, httr::timeout(10)),
  error = function(e) { 
    cat("ERROR:", e$message, "\n")
    NULL
  }
)

if (!is.null(response)) {
  cat("Status:", httr::status_code(response), "\n")
  content <- httr::content(response, as="text", encoding="UTF-8")
  cat("Content length:", nchar(content), "\n")
  cat("First 500 chars:\n")
  cat(substr(content, 1, 500), "\n")
  
  if (nchar(content) > 0) {
    record <- tryCatch(
      jsonlite::fromJSON(content, simplifyVector = FALSE),
      error = function(e) {
        cat("JSON parse error:", e$message, "\n")
        NULL
      }
    )
    if (!is.null(record)) {
      cat("JSON parsed successfully. Keys:", paste(names(record), collapse = ", "), "\n")
      cat("Valid name:", record$valid_name, "\n")
    }
  }
} else {
  cat("No response\n")
}
