#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <ip_manifest> <ip_run_dir> <tcga_id>"
    exit 1
fi

ip_manifest=$1
ip_run_dir=$2
tcga_id=$3
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

cat $ip_manifest | grep $tcga_id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

# if [[ -f "$bam_file" && $(find "$bam_file" -mmin +60) ]]; then
if [[ -f "$bam_file" ]]; then
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