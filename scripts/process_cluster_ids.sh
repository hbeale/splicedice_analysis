#!/bin/bash

# Process LUAD cluster IDs and convert to intropolis format
# Script based on original R markdown workflow

# Set base directory
base_dir="/mnt/data/"
# Uncomment one of these if needed:
# base_dir="/mnt/data/intropolis_chr1/"
# base_dir="/mnt/tiny_data/"

send_alerts=true

# Define file paths
original_intropolis_PS_file="${base_dir}2020.11.16.intropolis_PS.tsv.gz"
luad_PS_file="${base_dir}dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz"

original_intropolis_cluster_ids_file="${base_dir}2020.11.16.intropolis_PS.cluster_id_only.awk.tsv.gz"
luad_and_corresponding_intropolis_cluster_ids_file="${base_dir}luad_and_corresponding_intropolis_cluster_ids.tsv.gz"
luad_cluster_ids_in_intropolis_format_file="${base_dir}luad_cluster_ids_in_intropolis_format.tsv.gz"

intropolis_PS_present_in_luad_file="${base_dir}2020.11.16.intropolis_PS.in_luad.tsv.gz"

intropolis_cluster_ids_present_in_luad_file="${base_dir}intropolis_cluster_ids_present_in_luad.gz"
new_intropolis_cluster_ids_in_order_file="${base_dir}new_intropolis_cluster_ids_in_order.tsv.gz"

intropolis_no_cluster_id_file="${base_dir}2020.11.16.intropolis_PS.in_luad.no_cluster_id.tsv.gz"
intropolis_PS_updated_cluster_ids_file="${base_dir}2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz"

# Print current date and time
echo "Starting process at $(date)"

# Describe input files
echo "Characterizing input files:"
echo "Original intropolis PS file: $original_intropolis_PS_file"
ls -lh $original_intropolis_PS_file
zcat $original_intropolis_PS_file | head | cut -f1-6 
INTROPOLIS_LINES=$(zcat $original_intropolis_PS_file | wc -l)
echo "Line count: $INTROPOLIS_LINES"

echo
echo "LUAD PS file: $luad_PS_file"
ls -lh $luad_PS_file
zcat $luad_PS_file | head | cut -f1-6
LUAD_LINES=$(zcat $luad_PS_file | wc -l)
echo "Line count: $LUAD_LINES"

# Step 1: Convert LUAD cluster IDs to intropolis format using convert_luad_clusters.R
echo
echo "Step 1: Converting LUAD cluster IDs to intropolis format"
echo "Running convert_luad_clusters.R script"
Rscript convert_luad_clusters.R "$luad_PS_file" "$luad_and_corresponding_intropolis_cluster_ids_file" "$luad_cluster_ids_in_intropolis_format_file" "$base_dir"

# Check output from Step 1
echo "Checking output from Step 1:"
ls -lh $luad_and_corresponding_intropolis_cluster_ids_file
zcat $luad_and_corresponding_intropolis_cluster_ids_file | head 
LUAD_CONVERTED_LINES=$(zcat $luad_and_corresponding_intropolis_cluster_ids_file | wc -l)
echo "Line count: $LUAD_CONVERTED_LINES"

# Step 2: Make subset intropolis data
echo
echo "Step 2: Making subset of intropolis data"
rm -f ${luad_cluster_ids_in_intropolis_format_file/.gz}
gzip -d --keep $luad_cluster_ids_in_intropolis_format_file
zcat $original_intropolis_PS_file | grep -f ${luad_cluster_ids_in_intropolis_format_file/.gz} | pigz > $intropolis_PS_present_in_luad_file

# Send alert if requested
if $send_alerts; then
  ~/alert_msg.sh 'limited intropolis data to luad'
fi

# Check output from subset
echo "Checking subset intropolis output:"
ls -lh $intropolis_PS_present_in_luad_file
zcat $intropolis_PS_present_in_luad_file | head | cut -f1-6
SUBSET_LINES=$(zcat $intropolis_PS_present_in_luad_file | wc -l)
echo "Line count: $SUBSET_LINES"

# Step 3: Get list of IDs in reduced intropolis data
echo
echo "Step 3: Getting list of IDs in reduced intropolis data"
zcat $intropolis_PS_present_in_luad_file | awk '{print $1}' | grep -v cluster | pigz > $intropolis_cluster_ids_present_in_luad_file

# Send alert if requested
if $send_alerts; then
  ~/alert_msg.sh 'got list of IDs in reduced intropolis data'
fi

# Step 4: Reorder the LUAD cluster IDs using reorder_luad_clusters.R
echo
echo "Step 4: Reordering LUAD cluster IDs"
echo "Running reorder_luad_clusters.R script"
Rscript reorder_luad_clusters.R "$luad_and_corresponding_intropolis_cluster_ids_file" "$intropolis_cluster_ids_present_in_luad_file" "$new_intropolis_cluster_ids_in_order_file"

# Check output from reordering
echo "Checking reordered cluster IDs output:"
ls -lh $new_intropolis_cluster_ids_in_order_file
zcat $new_intropolis_cluster_ids_in_order_file | head | cut -f1-6
REORDERED_LINES=$(zcat $new_intropolis_cluster_ids_in_order_file | wc -l)
echo "Line count: $REORDERED_LINES"

# Step 5: Replace cluster ID in intropolis PS file
echo
echo "Step 5: Replacing cluster ID in intropolis PS file"
# Remove cluster IDs from column 1
zcat $intropolis_PS_present_in_luad_file | cut -f2- | pigz > $intropolis_no_cluster_id_file 

# Add new cluster IDs in column 1
paste <(zcat $new_intropolis_cluster_ids_in_order_file) <(zcat $intropolis_no_cluster_id_file) | pigz > $intropolis_PS_updated_cluster_ids_file

# Send alert if requested
if $send_alerts; then
  ~/alert_msg.sh 'replaced cluster ID in intropolis PS file'
fi

# Check final output
echo
echo "Checking final output file:"
ls -lh $intropolis_PS_updated_cluster_ids_file
zcat $intropolis_PS_updated_cluster_ids_file | head | cut -f1-6
FINAL_LINES=$(zcat $intropolis_PS_updated_cluster_ids_file | wc -l)
echo "Line count: $FINAL_LINES"

echo
echo "Process completed at $(date)"