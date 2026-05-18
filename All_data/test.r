library(worrms)
setwd("C:\\Users\\hamod4691\\Code\\arctic-benthic-biodiversity\\All_data")

unique_aphia_ids <- read_csv("unique_aphiaIDs.csv")
wm_record_(id = unique_aphia_ids)
