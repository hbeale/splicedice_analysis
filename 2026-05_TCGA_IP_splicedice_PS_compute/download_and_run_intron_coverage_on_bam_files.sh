#!/usr/bin/env bash
set -euo pipefail


repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
analysis_base=/mnt/splicedice_ir_example/analysis/

bam_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bam_manifest_2026.06.03_15.06.58.tsv

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt


cat $bam_manifest | grep -v ^id | head -1 | while read id bam_file genotype; do
echo processing $id
echo $bam_file

# id=TCGA-86-8074-01A
#bam_file=/mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam

expected_output=${analysis_base}/coverage_output/${id}_intron_coverage.txt

# make single-sample bam manifest
cat $bam_manifest | grep -w "$id" > /mnt/scratch/tmp/${id}_bam_manifest.tsv


echo
echo checking $id
if [[ ! -f "$bam_file" && ! -f "$expected_output" ]]; then 
echo "neither the bam file or intron coverage output are present"

# get ugly_id
ugly_id=`cat $ip_manifest | grep $id | cut -f1`

# download bam file
echo "downloading bam file..."
mkdir -p `dirname $bam_file`
date
time /mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file $token_file $ugly_id
date
fi

if [[ -f "$bam_file" ]]; then 
echo "bam file exists"

echo "running intron_coverage..."
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice intron_coverage \
-b /mnt/scratch/tmp/${id}_bam_manifest.tsv \
-m ${analysis_base}/_allPS.tsv \
-j ${analysis_base}/_junctions.bed \
-o ${analysis_base}/coverage_output
date
fi

# delete bam file...
if [[ -f "$bam_file"  && -f "$expected_output" ]]; then 
echo "both intron_coverage and bam files now exist"
echo "deleting bam file"
rm $bam_file 
fi

done
