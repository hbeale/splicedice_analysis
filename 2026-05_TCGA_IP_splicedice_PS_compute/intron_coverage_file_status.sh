#!/usr/bin/env bash
set -euo pipefail

repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
analysis_base=/mnt/splicedice_ir_example/analysis/

bam_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bam_manifest_2026.06.03_15.06.58.tsv

output=/mnt/data/intron_coverage_file_status_$(date +%Y%m%d_%H%M%S).tsv
echo $output

echo -e "id\tintron_coverage_exists\tbam_exists" > "$output"

cat $bam_manifest | grep -v ^id | while read id bam_file genotype; do

intron_coverage_file=${analysis_base}/coverage_output/${id}_intron_coverage.txt

[[ -f "$intron_coverage_file" ]] && ic=yes || ic=no
[[ -f "$bam_file" ]] && bam=yes || bam=no

echo -e "${id}\t${ic}\t${bam}"

done >> "$output"

echo "Written to $output"

awk -F'\t' 'NR>1 {
if ($2=="yes" && $3=="yes") both++
if ($2=="yes" && $3=="no")  intron_coverage_only++
if ($2=="no"  && $3=="yes") bam_only++
if ($2=="no"  && $3=="no")  neither++
} END {
    print "both:     " both+0
    print "intron_coverage only: " intron_coverage_only+0
    print "bam only: " bam_only+0
    print "neither:  " neither+0
}' $output
df -h | grep mnt
