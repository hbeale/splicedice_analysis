#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

bed_base=/mnt/data/intron_prospector_runs/common/


cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$bed_base/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

# ls $bed_file
# ls $bam_file

if [[ -f "$bed_file" && -f "$bam_file" && $(find "$bed_file" -mmin +60) ]]; then
echo "Deleting $bam_file (bed file $bed_file exists)"
echo rm "$bam_file"
echo 

# else
# echo "Skipping: bed=$bed_file exists=$([ -f "$bed_file" ] && echo yes || echo no), bam exists=$([ -f "$bam_file" ] && echo yes || echo no)"
fi

done
