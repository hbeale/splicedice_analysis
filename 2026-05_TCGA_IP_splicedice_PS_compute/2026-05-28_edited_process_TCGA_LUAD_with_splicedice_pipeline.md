# 2026-05-28_edited_process_TCGA_LUAD_with_splicedice_pipeline



# Goal

* generate a TCGA LUAD demo dataset and resource with percent spliced and intron retention results

# Strategies

there isn't enough space on my server to download all the bam files at once. 

we need to 1) find introns for each sample (requires bam file; generates bed file), 2) calculate PS values (requires bed files from all samples if we want PS values for all samples at every clusters found in any sample), and then 3) calculate intron coverage (requires bam files and PS file as input). 

I download each bam file, find introns with intron prospector, and then delete the bam file. 

Then I calculate PS values from the whole cohort at once from the bed files

Then I re-download batches of bam files, calculate intron coverage, and then delete the batch of bam files. 

Then I calculate intron retention values from the whole cohort at once from the intron coverage files

it's imperfect to download the bam files twice, but it's necessary  given my current constraints



# Setup



## Reference files

```
/mnt/ref/GRCh38.primary_assembly.genome.fa
/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```

if they are not present, obtain them from  https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.primary_assembly.genome.fa.gz 

and ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/gencode.v47.primary_assembly.annotation.gtf.gz

and uncompress



## Download repo

### splicedice_analysis

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/hbeale/splicedice_analysis.git


```



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -t splicedice_analysis:latest .
```



# Run intron-prospector



```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}download_and_run_ip_on_bam_files.sh
log_file=${base_note_dir}download_and_run_ip_on_bam_files.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```



```
bash $script | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
```



## qc: see if any bed files are missing major chromosomes 

```
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"

for f in /mnt/data/intron_prospector_runs/common/*.bed; do
    missing=$(comm -23 \
        <(echo "$expected" | tr ' ' '\n' | sort) \
        <(cut -f1 "$f" | sort -u)) 
    [[ -n "$missing" ]] && echo "$(basename $f): MISSING: $missing" || echo "$(basename $f): OK"
done

```



# splicedice quant

## make bed manifest

```
repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
ip_manifest=${repo_base}2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
u2af1_info=${repo_base}/2025-12_tcga_luad_reproducible_example/bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv

bed_base=/mnt/data/intron_prospector_runs/common/

cat $u2af1_info | grep s34f | cut -c1-16 > /mnt/tmp/u2af1_samples.txt


bed_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bed_manifest_2026.06.03_15.06.58.tsv


cat $ip_manifest | grep -v ^id | while read id bam_basename sample_id_key ; do
if grep -qw "$sample_id_key" /mnt/tmp/u2af1_samples.txt; then
pheno=u2af1
else
pheno=other
fi
echo -e "$sample_id_key\t${bed_base}${sample_id_key}.bed\t$pheno"
done > $bed_manifest


```



## run quant

```
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest_10 \
-o /mnt/splicedice_ir_example/analysis/
date
 ~/alert_msg.sh "quant run complete"

```

note warning:

```
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)

```



# Calculate intron coverage

### define script

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=download_and_run_intron_coverage_on_bam_files_v3.sh
script=${base_note_dir}${script_basename}
log_file=${base_note_dir}${script_basename/.sh}.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

# Create intron table

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

### run ir_table in new dir - 

note: next time add -u so it's not buffering

```
new_dir=splicedice_ir_example5
base_dir=/mnt/${new_dir}/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time python -u $(which splicedice) ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"

```





