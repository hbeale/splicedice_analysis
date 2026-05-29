#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

ip_run_dir=/mnt/data/intron_prospector_runs/common/

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

if [[ -f "$bam_file" && $(find "$bam_file" -mmin +60) ]]; then
echo "$bam_file for $nice_id exists and not modified in the last hour"
if [[ ! -f "$bed_file" ]]; then
echo "bed file $bed_file for $nice_id does not exist"
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file

fi
echo 
fi
done
