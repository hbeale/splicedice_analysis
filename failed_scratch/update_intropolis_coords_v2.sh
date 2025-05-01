#!/bin/bash

# Converted from the R Markdown file by Holly Beale
# Date: April 24, 2025

# Define base directory
base_dir="/mnt/data/"
# Uncomment the line below for test run with tiny data
# base_dir="/mnt/tiny_data/"

# Set whether to send alerts
send_alerts=false

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
zcat $luad_PS_file | awk '
BEGIN {OFS="\t"; print "luad_cluster_id\tintropolis_cluster_id"}
NR > 1 {
    cluster = $1;
    if (cluster ~ /random/ || cluster ~ /chrUn/) next;
    
    # Split cluster ID to get chr, start, stop, strand
    split(cluster, parts, ":");
    chr = parts[1];
    
    # Extract positions and strand
    pos_strand = parts[2];
    strand = substr(pos_strand, length(pos_strand));
    
    # Remove the strand character to get positions
    gsub(/[+-]$/, "", pos_strand);
    
    # Split into start-stop
    split(pos_strand, pos, "-");
    start = pos[1];
    stop = pos[2];
    
    # Add 1 to start position for intropolis format
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

# Extract just the intropolis format cluster IDs for grep
zcat $luad_and_corresponding_intropolis_cluster_ids_file | awk 'NR > 1 {print $2}' > luad_cluster_ids_for_grep.txt

# Also create a proper TSV file with header
echo -e "cluster" > luad_cluster_ids_with_header.txt
cat luad_cluster_ids_for_grep.txt >> luad_cluster_ids_with_header.txt
gzip -c luad_cluster_ids_with_header.txt > $luad_cluster_ids_in_intropolis_format_file

# Check output
echo "Checking output of LUAD cluster ID conversion..."
ls -lh $luad_and_corresponding_intropolis_cluster_ids_file
zcat $luad_and_corresponding_intropolis_cluster_ids_file | head 
zcat $luad_and_corresponding_intropolis_cluster_ids_file | wc -l
echo

# Make subset of intropolis data
echo "Creating subset of intropolis data based on LUAD cluster IDs..."
date
# Create subset by filtering for the cluster IDs
zcat $original_intropolis_PS_file | head -1 > intropolis_header.txt
zcat $original_intropolis_PS_file | grep -F -f luad_cluster_ids_for_grep.txt >> intropolis_subset.txt
gzip -c intropolis_subset.txt > $intropolis_PS_present_in_luad_file
rm luad_cluster_ids_for_grep.txt intropolis_header.txt intropolis_subset.txt luad_cluster_ids_with_header.txt
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
zcat $intropolis_PS_present_in_luad_file | awk 'NR > 1 {print $1}' | gzip > $intropolis_cluster_ids_present_in_luad_file
date
echo

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'got list of IDs in reduced intropolis data'
fi

# Reorder the LUAD cluster IDs
echo "Reordering LUAD cluster IDs to match intropolis order..."
date

# Create a file with the mapping between intropolis IDs and LUAD IDs
zcat $intropolis_cluster_ids_present_in_luad_file > intropolis_ids.txt
zcat $luad_and_corresponding_intropolis_cluster_ids_file | awk 'NR > 1 {print $2 "\t" $1}' > id_mapping.txt

# Create a new file with LUAD cluster IDs in the same order as intropolis
echo "cluster" > new_cluster_ids.txt
while read -r intropolis_id; do
    grep -F "$intropolis_id" id_mapping.txt | cut -f2 >> new_cluster_ids.txt
done < intropolis_ids.txt

gzip -c new_cluster_ids.txt > $new_intropolis_cluster_ids_in_order_file
rm intropolis_ids.txt id_mapping.txt new_cluster_ids.txt

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
echo "Merging new cluster IDs with intropolis data..."
# First decompress both files
zcat $new_intropolis_cluster_ids_in_order_file > temp_cluster_ids.txt
zcat $intropolis_no_cluster_id_file > temp_intropolis_data.txt

# Check if the files match in line count (excluding header)
cluster_lines=$(wc -l < temp_cluster_ids.txt)
intropolis_lines=$(wc -l < temp_intropolis_data.txt)

echo "Cluster ID lines: $cluster_lines, Intropolis data lines: $intropolis_lines"

if [ "$cluster_lines" -eq "$intropolis_lines" ]; then
    # Simple paste if line counts match
    paste temp_cluster_ids.txt temp_intropolis_data.txt | gzip > $intropolis_PS_updated_cluster_ids_file
elif [ "$((cluster_lines-1))" -eq "$((intropolis_lines-1))" ]; then
    # If only header line exists, handle separately
    head -1 temp_cluster_ids.txt > header.txt
    tail -n +2 temp_cluster_ids.txt > data_cluster_ids.txt
    tail -n +2 temp_intropolis_data.txt > data_intropolis.txt
    
    paste header.txt <(head -1 temp_intropolis_data.txt) > merged_header.txt
    paste data_cluster_ids.txt data_intropolis.txt > merged_data.txt
    
    cat merged_header.txt merged_data.txt | gzip > $intropolis_PS_updated_cluster_ids_file
    rm header.txt data_cluster_ids.txt data_intropolis.txt merged_header.txt merged_data.txt
else
    echo "ERROR: Line count mismatch between cluster IDs and intropolis data"
    exit 1
fi

rm temp_cluster_ids.txt temp_intropolis_data.txt
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