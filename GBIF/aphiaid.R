install.packages("worrms")
library(worrms)


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
      return(NULL)
    })
    
    all_records <- c(all_records, records)
    
    # Pause between requests to avoid overwhelming the server
    Sys.sleep(1)  # Adjust the sleep time as needed
  }
  
  return(all_records)
}

a<- get_wm_records(species)
names(a)=species
# check scientific names
worms_id_species <- tibble::enframe(a) %>%
   unnest(value) 
worms_id_species