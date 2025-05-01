#!/bin/bash

# Converted from the R Markdown file by Holly Beale
# Date: April 24, 2025

# Define base directory
# base_dir="/mnt/data/"
# Uncomment the line below for test run with tiny data
base_dir="/mnt/tiny_data/"

# Set whether to send alerts
send_alerts=true

# Define input files
original_intropolis_PS_file="${base_dir}2020.11.16.intropolis_PS.tsv.gz"
luad_PS_file="${base_dir}dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz"

# Define output files
original_intropolis_cluster_ids_file="${base_dir}2020.11.16.intropolis_PS.cluster_id_only.awk.tsv.gz"
luad_and_corresponding_intropolis_cluster_ids_file="${base_dir}luad_and_corresponding_intropolis_cluster_ids.tsv.gz"
luad_cluster_ids_in_intropolis_format_file="${base_dir}luad_cluster_ids_in_intropolis_format.tsv.gz"
intropolis_PS_present_in_luad_file="${base_dir}2020.11.16.intropolis_PS.in_luad.tsv.gz"
intropolis_cluster_ids_present_in_luad_file="${base_dir}intropolis_cluster_ids_present_in_luad.gz"
new_intropolis_cluster_ids_in_order_file="${base_dir}new_intropolis_cluster_ids_in_order.tsv.gz"
intropolis_no_cluster_id_file="${base_dir}2020.11.16.intropolis_PS.in_luad.no_cluster_id.tsv.gz"
intropolis_PS_updated_cluster_ids_file="${base_dir}2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz"

# Display file paths
echo "Input file paths:"
echo "Original intropolis PS file: $original_intropolis_PS_file"
echo "LUAD PS file: $luad_PS_file"
echo

# Characterize input files
echo "Characterizing input files..."
date
ls -lh $original_intropolis_PS_file
zcat $original_intropolis_PS_file | head | cut -f1-6 
zcat $original_intropolis_PS_file | wc -l
date

echo
ls -lh $luad_PS_file
zcat $luad_PS_file | head | cut -f1-6
zcat $luad_PS_file | wc -l
date
echo

# Process LUAD data to match intropolis format
echo "Processing LUAD data to match intropolis format..."

# Extract cluster IDs and convert to intropolis format
# This script uses awk to:
# 1. Parse cluster IDs
# 2. Filter out chromosomes with "random" and "chrUn"
# 3. Add 1 to start position for intropolis format
# 4. Create new cluster IDs in intropolis format
# 5. Remove duplicates (keeping only one entry per intropolis_cluster_id)

zcat $luad_PS_file | awk '
BEGIN {OFS="\t"; print "luad_cluster_id", "intropolis_cluster_id"}
NR > 1 {
    cluster = $1;
    if (cluster ~ /random/ || cluster ~ /chrUn/) next;
    
    # Split cluster ID into components
    split(cluster, parts, ":");
    chr = parts[1];
    split(parts[2], pos_strand, "[\\-\\+]");
    split(pos_strand[1], pos, "-");
    start = pos[1];
    stop = pos[2];
    strand = substr(cluster, length(cluster));
    
    # Add 1 to start position
    intropolis_start = start + 1;
    
    # Create intropolis format cluster ID
    intropolis_id = chr ":" intropolis_start "-" stop;
    
    # Store in array to handle duplicates later
    if (!(intropolis_id in seen)) {
        ids[++count] = intropolis_id;
        orig[intropolis_id] = cluster;
        seen[intropolis_id] = 1;
    }
}
END {
    for (i = 1; i <= count; i++) {
        print orig[ids[i]], ids[i];
    }
}' | gzip > $luad_and_corresponding_intropolis_cluster_ids_file

# Extract just the intropolis format cluster IDs
zcat $luad_and_corresponding_intropolis_cluster_ids_file | awk 'NR > 1 {print $2}' | awk '{print "cluster\n" $0}' | gzip > $luad_cluster_ids_in_intropolis_format_file

# Check output
echo "Checking output of LUAD cluster ID conversion..."
ls -lh $luad_and_corresponding_intropolis_cluster_ids_file
zcat $luad_and_corresponding_intropolis_cluster_ids_file | head 
zcat $luad_and_corresponding_intropolis_cluster_ids_file | wc -l
echo

# Make subset of intropolis data
echo "Creating subset of intropolis data based on LUAD cluster IDs..."
date
gunzip -c $luad_cluster_ids_in_intropolis_format_file > ${luad_cluster_ids_in_intropolis_format_file/.gz}
zcat $original_intropolis_PS_file | grep -f ${luad_cluster_ids_in_intropolis_format_file/.gz} | gzip > $intropolis_PS_present_in_luad_file
rm ${luad_cluster_ids_in_intropolis_format_file/.gz}
date
echo

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'limited intropolis data to luad'
fi

# Check output
echo "Checking subset of intropolis data..."
ls -lh $intropolis_PS_present_in_luad_file
zcat $intropolis_PS_present_in_luad_file | head | cut -f1-6
zcat $intropolis_PS_present_in_luad_file | wc -l
echo

# Get list of cluster IDs in reduced intropolis data
echo "Extracting cluster IDs from reduced intropolis data..."
date
zcat $intropolis_PS_present_in_luad_file | awk '{print $1}' | grep -v cluster | gzip > $intropolis_cluster_ids_present_in_luad_file
date
echo

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'got list of IDs in reduced intropolis data'
fi

# Reorder the LUAD cluster IDs
echo "Reordering LUAD cluster IDs to match intropolis order..."
date

# Join the intropolis cluster IDs with their corresponding LUAD IDs
# Output a file with LUAD cluster IDs in the same order as intropolis
zcat $intropolis_cluster_ids_present_in_luad_file | awk '
BEGIN {OFS="\t"; print "cluster"}
NR > 1 {print $1}' > temp_intropolis_ids.txt

join -t $'\t' -1 1 -2 2 \
    <(zcat $intropolis_cluster_ids_present_in_luad_file | sort) \
    <(zcat $luad_and_corresponding_intropolis_cluster_ids_file | sort -k2,2) \
    | awk '{print $2}' | awk 'BEGIN {OFS="\t"; print "cluster"} {print $1}' \
    | gzip > $new_intropolis_cluster_ids_in_order_file

rm temp_intropolis_ids.txt

# Check output
echo "Checking reordered LUAD cluster IDs..."
ls -lh $new_intropolis_cluster_ids_in_order_file
zcat $new_intropolis_cluster_ids_in_order_file | head
zcat $new_intropolis_cluster_ids_in_order_file | wc -l
echo

# Replace cluster ID in intropolis PS file
echo "Replacing cluster IDs in intropolis PS file..."
date
# Remove cluster IDs from column 1
zcat $intropolis_PS_present_in_luad_file | cut -f2- | gzip > $intropolis_no_cluster_id_file 
date

# Add new cluster IDs in column 1
paste <(zcat $new_intropolis_cluster_ids_in_order_file) <(zcat $intropolis_no_cluster_id_file) | gzip > $intropolis_PS_updated_cluster_ids_file
date
echo

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'replaced cluster ID in intropolis PS file'
fi

# Check final output
echo "Checking final output..."
ls -lh $intropolis_PS_updated_cluster_ids_file
zcat $intropolis_PS_updated_cluster_ids_file | head | cut -f1-6
zcat $intropolis_PS_updated_cluster_ids_file | wc -l
date

echo "Processing complete!"