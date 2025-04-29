#!/usr/bin/env Rscript

# Load required libraries
library(tidyverse)

# Define arguments - you'll need to set these when running the script
args <- commandArgs(trailingOnly = TRUE)

# If arguments are provided, use them; otherwise use placeholder values
if (length(args) >= 1) {
  luad_and_corresponding_intropolis_cluster_ids_file <- args[1]
} else {
  stop("Path to luad_and_corresponding_intropolis_cluster_ids file must be provided as first argument")
}

if (length(args) >= 2) {
  intropolis_cluster_ids_present_in_luad_file <- args[2]
} else {
  stop("Path to intropolis_cluster_ids_present_in_luad file must be provided as second argument")
}

if (length(args) >= 3) {
  new_intropolis_cluster_ids_in_order_file <- args[3]
} else {
  new_intropolis_cluster_ids_in_order_file <- "new_intropolis_cluster_ids_in_order.tsv"
}

# Read the input files
luad_and_corresponding_intropolis_cluster_ids <- read_tsv(luad_and_corresponding_intropolis_cluster_ids_file)
intropolis_cluster_ids <- read_tsv(intropolis_cluster_ids_present_in_luad_file,
                                  col_names = "original_intropolis_cluster_id")

# Reorder the LUAD cluster IDs to match the order of intropolis cluster IDs
# Exclude any LUAD cluster IDs not in intropolis
intropolis_cluster_ids_two_formats_raw <- left_join(intropolis_cluster_ids,
                                                   luad_and_corresponding_intropolis_cluster_ids,
                                                   by=c("original_intropolis_cluster_id"="intropolis_cluster_id"))

intropolis_cluster_ids_two_formats <- intropolis_cluster_ids_two_formats_raw %>%
  rename(updated_intropolis_cluster_id = luad_cluster_id)

# Write the output file
intropolis_cluster_ids_two_formats %>% 
  select(cluster = updated_intropolis_cluster_id) %>%
  write_tsv(new_intropolis_cluster_ids_in_order_file)

cat("Processing complete. Output file written:\n")
cat(paste(new_intropolis_cluster_ids_in_order_file, "\n"))