#!/usr/bin/env Rscript

# Load required libraries
library(tidyverse)

# Define arguments - you'll need to set these when running the script
args <- commandArgs(trailingOnly = TRUE)

# If arguments are provided, use them; otherwise use placeholder values
if (length(args) >= 1) {
  luad_PS_file <- args[1]
} else {
  stop("Input file path must be provided as first argument")
}

if (length(args) >= 2) {
  luad_and_corresponding_intropolis_cluster_ids_file <- args[2]
} else {
  luad_and_corresponding_intropolis_cluster_ids_file <- "luad_and_corresponding_intropolis_cluster_ids.tsv"
}

if (length(args) >= 3) {
  luad_cluster_ids_in_intropolis_format_file <- args[3]
} else {
  luad_cluster_ids_in_intropolis_format_file <- "luad_cluster_ids_in_intropolis_format.tsv"
}

if (length(args) >= 4) {
  base_dir <- args[4]
} else {
  base_dir <- getwd()
}

# Load data
luad_PS <- read_tsv(luad_PS_file)

# Make cluster IDs like the ones in intropolis
# Break cluster IDs into parts
# Warning message "Expected 4 pieces." is acceptable
luad_PS_cluster_ids <- luad_PS %>%
  select(cluster) %>%
  separate(cluster, 
           into = c("chr", "start", "stop", "strand"),
           convert = TRUE,
           remove = FALSE) %>%
  mutate(strand = str_sub(cluster, -1))

# Exclude chromosomes with "random" and "chrUn" in the name
luad_PS_cluster_ids_in_main_chr <- luad_PS_cluster_ids %>%
  filter(! stop == "random",
         ! chr == "chrUn") %>%
  mutate(stop_num = as.numeric(stop),
         start_num = as.numeric(start))

# Add 1 in the start pos
luad_cluster_ids_with_intropolis_format <- luad_PS_cluster_ids_in_main_chr %>%
  rename(luad_cluster_id = cluster) %>%
  mutate(intropolis_start = start_num + 1,
        intropolis_cluster_id = paste0(chr, ":", intropolis_start, "-", stop_num)) 

head(luad_cluster_ids_with_intropolis_format)

luad_cluster_ids_with_intropolis_format_min <- luad_cluster_ids_with_intropolis_format %>%
  select(luad_cluster_id, intropolis_cluster_id)

# De-duplicate
# In tiny data with 1000 samples, 276 entries had cluster ids that differ only depending on whether the positive or negative strand
# In all these cases, we exclude one; usually the negative strand cluster id

dupes_just_1 <- luad_cluster_ids_with_intropolis_format_min %>%
    filter(duplicated(intropolis_cluster_id))

if (base_dir == "/mnt/tiny_data/") { # Show what the data looks like 
  dupes_both <- luad_cluster_ids_with_intropolis_format_min %>%
    filter(intropolis_cluster_id %in% dupes_just_1$intropolis_cluster_id)
  
  luad_PS %>%
    filter(str_detect(cluster, "chr1:16027-16606")) %>%
    mutate(mean_PS = rowSums(pick(where(is.numeric)), na.rm = TRUE)/(ncol(luad_PS)-1)) %>%
    select(cluster, mean_PS)
  
  luad_PS %>%
    filter(cluster %in% dupes_both$luad_cluster_id) %>%
    arrange(cluster) %>%
    mutate(mean_PS = rowSums(pick(where(is.numeric)), na.rm = TRUE)/(ncol(luad_PS)-1)) %>%
    select(cluster, mean_PS) %>%
    head()
}

luad_cluster_ids_with_intropolis_format_min_no_dupes <- luad_cluster_ids_with_intropolis_format_min %>%
  filter(!intropolis_cluster_id %in% dupes_just_1$intropolis_cluster_id)

# Write output
write_tsv(luad_cluster_ids_with_intropolis_format_min_no_dupes, 
          luad_and_corresponding_intropolis_cluster_ids_file)

luad_cluster_ids_with_intropolis_format_min_no_dupes %>% 
  select(cluster = intropolis_cluster_id) %>%
  write_tsv(luad_cluster_ids_in_intropolis_format_file)

cat("Processing complete. Output files written:\n")
cat(paste("1.", luad_and_corresponding_intropolis_cluster_ids_file, "\n"))
cat(paste("2.", luad_cluster_ids_in_intropolis_format_file, "\n"))