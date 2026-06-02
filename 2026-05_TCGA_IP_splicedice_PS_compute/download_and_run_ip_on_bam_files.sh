#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt

ip_run_dir=/mnt/data/intron_prospector_runs/common/
bam_base=/mnt/data/tcga

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v


cat $ip_manifest | grep -v ^id | while read ugly_id bam_file_basename nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=${bam_base}/$ugly_id/$bam_file_basename

echo
echo checking $nice_id
if [[ ! -f "$bed_file" && ! -f "$bam_file" ]]; then 
echo "neither bed or bam file exists"

# download bam file
echo "downloading bam file..."
mkdir -p ${bam_base}/$ugly_id
/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file $token_file $ugly_id

fi

if [[ ! -f "$bed_file" && -f "$bam_file" ]]; then 
echo "bam file exists but bed file does not"

# run IP
echo "running intron-prospector..."
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file
fi

# delete bam file...
if [[ -f "$bam_file"  && -f "$bed_file" ]]; then 
echo "both bed and bam files now exist"
echo "deleting bam file"
rm $bam_file 
fi

done

