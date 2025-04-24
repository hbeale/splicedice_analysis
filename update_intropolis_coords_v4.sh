#!/bin/bash

# Converted from the R Markdown file by Holly Beale
# Using only clusters that exist in BOTH intropolis and LUAD datasets

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

# Step 1: Extract and convert LUAD cluster IDs to intropolis format
echo "[Step 1] Converting LUAD cluster IDs to intropolis format..."

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
zcat "$luad_and_corresponding_intropolis_cluster_ids_file" | awk 'NR > 1 {print $2}' > "$TMPDIR/luad_intropolis_format_ids.txt"

# Also create a file with header for later use
echo "cluster" > "$TMPDIR/luad_clusters_header.txt"
cat "$TMPDIR/luad_intropolis_format_ids.txt" >> "$TMPDIR/luad_clusters_header.txt"
gzip -c "$TMPDIR/luad_clusters_header.txt" > "$luad_cluster_ids_in_intropolis_format_file"

# Step 2: Extract all cluster IDs from original intropolis file
echo "[Step 2] Extracting original intropolis cluster IDs..."

# Extract all cluster IDs from intropolis (skip header)
zcat "$original_intropolis_PS_file" | awk 'NR > 1 {print $1}' | sort | uniq > "$TMPDIR/all_intropolis_ids.txt"

# Step 3: Find intersection (clusters that exist in BOTH datasets)
echo "[Step 3] Finding intersection of cluster IDs..."

# Sort the LUAD intropolis format IDs
sort "$TMPDIR/luad_intropolis_format_ids.txt" > "$TMPDIR/luad_intropolis_format_ids_sorted.txt"

# Find intersection (only IDs that exist in both files)
comm -12 "$TMPDIR/all_intropolis_ids.txt" "$TMPDIR/luad_intropolis_format_ids_sorted.txt" > "$TMPDIR/intersection_ids.txt"

echo "Total LUAD clusters converted to intropolis format: $(wc -l < "$TMPDIR/luad_intropolis_format_ids.txt")"
echo "Total unique intropolis clusters: $(wc -l < "$TMPDIR/all_intropolis_ids.txt")"
echo "Intersection (clusters in both datasets): $(wc -l < "$TMPDIR/intersection_ids.txt")"

# Step 4: Extract intropolis data for the intersection clusters
echo "[Step 4] Extracting intropolis data for intersection clusters..."

# Get header from original intropolis file
zcat "$original_intropolis_PS_file" | head -1 > "$TMPDIR/intropolis_header.tsv"

# Use grep to extract matching lines from intropolis file
zcat "$original_intropolis_PS_file" | grep -F -f "$TMPDIR/intersection_ids.txt" > "$TMPDIR/intropolis_matches.tsv"

# Combine header and matches
cat "$TMPDIR/intropolis_header.tsv" "$TMPDIR/intropolis_matches.tsv" > "$TMPDIR/intropolis_subset.tsv"
gzip -c "$TMPDIR/intropolis_subset.tsv" > "$intropolis_PS_present_in_luad_file"

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'limited intropolis data to luad'
fi

# Step 5: Get list of cluster IDs from the subset
echo "[Step 5] Extracting cluster IDs from subset..."

zcat "$intropolis_PS_present_in_luad_file" | awk 'NR > 1 {print $1}' | gzip > "$intropolis_cluster_ids_present_in_luad_file"

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'got list of IDs in reduced intropolis data'
fi

# Step 6: Map the intropolis IDs to LUAD cluster IDs
echo "[Step 6] Mapping intropolis IDs to LUAD cluster IDs..."

# Extract cluster IDs from the subset
zcat "$intropolis_cluster_ids_present_in_luad_file" > "$TMPDIR/subset_intropolis_ids.txt"

# Create mapping from intropolis format to LUAD format
zcat "$luad_and_corresponding_intropolis_cluster_ids_file" | awk 'NR > 1 {print $2 "\t" $1}' > "$TMPDIR/id_mapping.txt"

# Create new cluster ID file with header
echo "cluster" > "$TMPDIR/new_clusters.txt"

# For each intropolis ID in the subset, find the corresponding LUAD ID
while read -r intropolis_id; do
    luad_id=$(grep -F "$intropolis_id" "$TMPDIR/id_mapping.txt" | cut -f2)
    if [ -n "$luad_id" ]; then
        echo "$luad_id" >> "$TMPDIR/new_clusters.txt"
    else
        echo "WARNING: No LUAD ID found for intropolis ID: $intropolis_id"
        # Use the original intropolis ID as fallback (shouldn't happen with proper intersection)
        echo "$intropolis_id" >> "$TMPDIR/new_clusters.txt"
    fi
done < "$TMPDIR/subset_intropolis_ids.txt"

# Save the ordered LUAD cluster IDs
gzip -c "$TMPDIR/new_clusters.txt" > "$new_intropolis_cluster_ids_in_order_file"

# Step 7: Create the final file with LUAD cluster IDs
echo "[Step 7] Creating final file with LUAD cluster IDs..."

# Remove cluster IDs from the intropolis data
zcat "$intropolis_PS_present_in_luad_file" | cut -f2- > "$TMPDIR/intropolis_no_cluster.tsv"
gzip -c "$TMPDIR/intropolis_no_cluster.tsv" > "$intropolis_no_cluster_id_file"

# Combine the new LUAD cluster IDs with the intropolis data
paste "$TMPDIR/new_clusters.txt" "$TMPDIR/intropolis_no_cluster.tsv" > "$TMPDIR/updated_file.tsv"
gzip -c "$TMPDIR/updated_file.tsv" > "$intropolis_PS_updated_cluster_ids_file"

# Send alert if enabled
if [ "$send_alerts" = true ]; then
    ~/alert_msg.sh 'replaced cluster ID in intropolis PS file'
fi

# Step 8: Verify results
echo "[Step 8] Verifying results..."

echo "Final file contents (first 10 lines):"
zcat "$intropolis_PS_updated_cluster_ids_file" | head -10

echo "Line counts:"
echo "Original filtered intropolis: $(zcat "$intropolis_PS_present_in_luad_file" | wc -l)"
echo "New cluster IDs: $(zcat "$new_intropolis_cluster_ids_in_order_file" | wc -l)"
echo "Final output: $(zcat "$intropolis_PS_updated_cluster_ids_file" | wc -l)"

echo "Processing complete!"