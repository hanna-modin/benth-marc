setwd("C:\\Users\\Admin\\Documents\\Hanna")
# Install and load required packages

install.packages("readxl")

install.packages("readr")

install.packages("worrms")

library(readxl)

library(readr)

library(worrms)

# Define the get_aphia_info function

get_aphia_info <- function(taxa_list) {
  
  results <- data.frame(Input_Name = character(),
                        
                        Accepted_Name = character(),
                        
                        AphiaID = numeric(),
                        
                        stringsAsFactors = FALSE)
  
  
  
  for (taxon in taxa_list) {
    
    tryCatch({
      
      record <- wm_records_name(taxon, marine_only = FALSE)
      
      if (length(record) > 0) {
        
        record <- record[[1]]
        
        results <- rbind(results, data.frame(
          
          Input_Name = taxon,
          
          Accepted_Name = ifelse(is.null(record$valid_name), record$scientificname, record$valid_name),
          
          AphiaID = ifelse(is.null(record$valid_AphiaID), record$AphiaID, record$valid_AphiaID)
          
        ))
        
      } else {
        
        results <- rbind(results, data.frame(Input_Name = taxon, Accepted_Name = NA, AphiaID = NA))
        
      }
      
    }, error = function(e) {
      
      results <- rbind(results, data.frame(Input_Name = taxon, Accepted_Name = NA, AphiaID = NA))
      
    })
    
  }
  
  
  
  return(results)
  
}

# Load taxa list from an Excel file

taxa_file <- "missing_aphiaid.xlsx"  # Replace with the correct file path

taxa_data <- read_xlsx(taxa_file, col_types = "text")

# Check column names and extract the taxa list

print(colnames(taxa_data))  # Inspect column names

taxa_list <- taxa_data$ScientificName  # Replace with the correct column name

# Query WoRMS for each taxon

results <- get_aphia_info(taxa_list)

# Save the results to a new CSV file

write_csv(results, "taxa_results.csv")

# Print the results

print(results)