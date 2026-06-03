#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
bed_base=/mnt/data/intron_prospector_runs/common/
bam_base=/mnt/data/tcga

output=/mnt/data/file_status_$(date +%Y%m%d_%H%M%S).tsv
echo $output

echo -e "nice_id\tugly_id\tbed_exists\tbam_exists" > "$output"

grep -v ^id "$ip_manifest" | while read ugly_id bam_file nice_id; do
    bed_file=${bed_base}/${nice_id}.bed
    bam_file=${bam_base}/$ugly_id/$bam_file

    [[ -f "$bed_file" ]] && bed=yes || bed=no
    [[ -f "$bam_file" ]] && bam=yes || bam=no

    echo -e "${nice_id}\t${ugly_id}\t${bed}\t${bam}"
done >> "$output"

echo "Written to $output"

awk -F'\t' 'NR>1 {
    if ($3=="yes" && $4=="yes") both++
    if ($3=="yes" && $4=="no")  bed_only++
    if ($3=="no"  && $4=="yes") bam_only++
    if ($3=="no"  && $4=="no")  neither++
} END {
    print "both:     " both+0
    print "bed only: " bed_only+0
    print "bam only: " bam_only+0
    print "neither:  " neither+0
}' $output
df -h | grep mnt
