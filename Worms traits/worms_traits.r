setwd("C:/Users/hamod4691/Code/arctic-benthic-biodiversity/Worms traits")

if (!requireNamespace("worrms", quietly = TRUE)) {
	install.packages("worrms", repos = "https://cloud.r-project.org")
}
library(worrms)
library(readr)

species <- c(124321)

traits_data <- wm_attr_data_(id = species)
write_csv(traits_data, "traits_data.csv")

traits_definitions <- wm_attr_def_(id = species)
write_csv(traits_definitions, "traits_definitions.csv")
