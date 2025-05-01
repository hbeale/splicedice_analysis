#!/bin/bash

# Converted from the R Markdown file by Holly Beale
# Direct approach focusing on preserving cluster IDs

# Define base directory
# base_dir="/mnt/data/"
# Uncomment for test run
base_dir="/mnt/tiny_data/"

# Set whether to send alerts
send_alerts=false

# Define input files
original_intropolis_PS_file="${base_dir}2020.11.16.intropolis_PS.tsv.gz"
luad_PS_file="${base_dir}dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz"

# Define output files
luad_and_corresponding_intropolis_cluster_ids_file="${base_dir}luad_and_corresponding_intropolis_cluster_ids.tsv.gz"
luad_cluster_ids_in_intropolis_format_file="${base_dir}luad_cluster_ids_in_intropolis_format.tsv.gz"
intropolis_PS_present_in_luad_file="${base_dir}2020.11.16.intropolis_PS.in_luad.tsv.gz"
intropolis_cluster_ids_present_in_luad_file="${base_dir}intropolis_cluster_ids_present_in_luad.gz"
new_intropolis_cluster_ids_in_order_file="${base_dir}new_intropolis_cluster_ids_in_order.tsv.gz"
intropolis_no_cluster_id_file="${base_dir}2020.11.16.intropolis_PS.in_luad.no_cluster_id.tsv.gz"
intropolis_PS_updated_cluster_ids_file="${base_dir}2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz"

echo "Starting processing..."
echo "Input files:"
echo "- Original intropolis PS file: $original_intropolis_PS_file"
echo "- LUAD PS file: $luad_PS_file"

# Create temporary directory
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Step 1: Process LUAD data to extract and convert cluster IDs
echo "[Step 1] Processing LUAD data..."

# Extract and convert LUAD cluster IDs to intropolis format
zcat "$luad_PS_file" | awk '
BEGIN {OFS="\t"; print "luad_cluster_id\tintropolis_cluster_id"}
NR > 1 {
    cluster = $1;
    # Skip chromosomes with "random" and "chrUn"
    if (cluster ~ /random/ || cluster ~ /chrUn/) next;
    
    # Parse cluster ID and get components
    split(cluster, parts, ":");
    chr = parts[1];
    
    # Get positions and strand
    pos_strand = parts[2];
    strand = substr(pos_strand, length(pos_strand));
    
    # Remove strand character and split into start-stop
    gsub(/[+-]$/, "", pos_strand);
    split(pos_strand, pos, "-");
    start = pos[1];
    stop = pos[2];
    
    # Add 1 to start position for intropolis format
    intropolis_start = start + 1;
    intropolis_id = chr ":" intropolis_start "-" stop;
    
    # Store only one instance per intropolis ID (de-duplicate)
    if (!(intropolis_id in seen)) {
        print cluster, intropolis_id;
        seen[intropolis_id] = 1;
    }
}' | gzip > "$luad_and_corresponding_intropolis_cluster_ids_file"

# Extract just the intropolis format cluster IDs
zcat "$luad_and_corresponding_intropolis_cluster_ids_file" | awk 'NR > 1 {print $2}' > "$TMPDIR/intropolis_format_ids.txt"

# Create a file with header for grep lookup
echo "cluster" > "$TMPDIR/luad_clusters_header.txt"
cat "$TMPDIR/intropolis_format_ids.txt" >> "$TMPDIR/luad_clusters_header.txt"
gzip -c "$TMPDIR/luad_clusters_header.txt" > "$luad_cluster_ids_in_intropolis_format_file"

# Step 2: Find intropolis PS entries that match LUAD cluster IDs
echo "[Step 2] Finding matching intropolis entries..."

# Extract header from original intropolis file
zcat "$original_intropolis_PS_file" | head -1 > "$TMPDIR/intropolis_header.tsv"

# Find matching lines in intropolis file
zcat "$original_intropolis_PS_file" | grep -F -f "$TMPDIR/intropolis_format_ids.txt" > "$TMPDIR/intropolis_matches.tsv"

# Combine header and matches
cat "$TMPDIR/intropolis_header.tsv" "$TMPDIR/intropolis_matches.tsv" > "$TMPDIR/intropolis_subset.tsv"
gzip -c "$TMPDIR/intropolis_subset.tsv" > "$intropolis_PS_present_in_luad_file"

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'limited intropolis data to luad'
fi

# Step 3: Extract cluster IDs from reduced intropolis data
echo "[Step 3] Extracting cluster IDs from reduced intropolis data..."

zcat "$intropolis_PS_present_in_luad_file" | awk 'NR > 1 {print $1}' | gzip > "$intropolis_cluster_ids_present_in_luad_file"

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'got list of IDs in reduced intropolis data'
fi

# Step 4: Map intropolis IDs to LUAD cluster IDs
echo "[Step 4] Mapping intropolis IDs to LUAD cluster IDs..."

# Extract the intropolis cluster IDs from the filtered data
zcat "$intropolis_cluster_ids_present_in_luad_file" > "$TMPDIR/intropolis_subset_ids.txt"

# Create mapping from intropolis IDs to LUAD IDs
zcat "$luad_and_corresponding_intropolis_cluster_ids_file" | awk 'NR > 1 {print $2 "\t" $1}' > "$TMPDIR/id_mapping.txt"

# Create new cluster ID file with header
echo "cluster" > "$TMPDIR/new_clusters.txt"

# For each intropolis ID, find the corresponding LUAD ID
while read -r intropolis_id; do
    grep -F "$intropolis_id" "$TMPDIR/id_mapping.txt" | cut -f2 >> "$TMPDIR/new_clusters.txt"
    # If no match is found, use the original intropolis ID
    if [ $? -ne 0 ]; then
        echo "$intropolis_id" >> "$TMPDIR/new_clusters.txt"
    fi
done < "$TMPDIR/intropolis_subset_ids.txt"

# Save the ordered LUAD cluster IDs
gzip -c "$TMPDIR/new_clusters.txt" > "$new_intropolis_cluster_ids_in_order_file"

# Step 5: Create the final file with LUAD cluster IDs
echo "[Step 5] Creating final file with LUAD cluster IDs..."

# Extract the original intropolis data without the first column (cluster IDs)
zcat "$intropolis_PS_present_in_luad_file" | cut -f2- > "$TMPDIR/intropolis_no_cluster.tsv"
gzip -c "$TMPDIR/intropolis_no_cluster.tsv" > "$intropolis_no_cluster_id_file"

# Create the final file by combining the new cluster IDs with the data
paste "$TMPDIR/new_clusters.txt" "$TMPDIR/intropolis_no_cluster.tsv" > "$TMPDIR/updated_file.tsv"
gzip -c "$TMPDIR/updated_file.tsv" > "$intropolis_PS_updated_cluster_ids_file"

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'replaced cluster ID in intropolis PS file'
fi

# Step 6: Verify outputs
echo "[Step 6] Verifying outputs..."

# Check the final output
echo "Final file contents (first 10 lines):"
zcat "$intropolis_PS_updated_cluster_ids_file" | head -10

echo "Line counts:"
echo "Original filtered intropolis: $(zcat "$intropolis_PS_present_in_luad_file" | wc -l)"
echo "New cluster IDs: $(zcat "$new_intropolis_cluster_ids_in_order_file" | wc -l)"
echo "Final output: $(zcat "$intropolis_PS_updated_cluster_ids_file" | wc -l)"

echo "Processing complete!"