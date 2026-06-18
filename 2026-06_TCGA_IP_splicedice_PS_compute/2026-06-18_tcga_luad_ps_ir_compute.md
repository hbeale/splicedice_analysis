# 2026-06-18_tcga_luad_ps_ir_compute

using method from "2026-06-17 Simplified splicedice pipeline"



This approach is optimized for limited disk space. Bams are downloaded one at a time (for identifying introns with intron-prospector) or in small batches (for calculating intron coverage with splicedice intron_coverage). There are only a few samples in this example. The approach is useful when there are many terabytes of sequencing data. 



# Setup per server

## copy gdc file

```bash
ls ~/gdc-user-token.2026-05-28T20_33_35.481Z.txt
cp /mnt/git_code/gdc-user-token.2026-05-28T20_33_35.481Z.txt ~
```

make sure gdc-client is in the path

```bash
gdc-client
```





# Setup per run

## define location

```bash
this_commit=970d652
this_full_SHA_hash=970d6525e50f01bfd06d695ffd5ad6c41fffaabf
this_description=tcga_luad
timestamp=2026.06.18_10.26.39
this_base_dir=/mnt/sd/${this_description}_${this_commit}_${timestamp}/
code_base=${this_base_dir}/git_code/splicedice_analysis/2026_06_ps_ir_pipeline
working_files=${this_base_dir}/git_code/splicedice_analysis/2026-06_TCGA_IP_splicedice_PS_compute
mkdir -p ${this_base_dir}/git_code/ ${this_base_dir}/analysis/
```



## get code

```bash
cd ${this_base_dir}/git_code/
git clone https://github.com/hbeale/splicedice_analysis.git
```

## build docker

```bash
this_dockerfile=${working_files}/Dockerfile_$this_commit
cat $code_base/Dockerfile_splicedice_by_hash | sed "s/replace_with_hash/${this_full_SHA_hash}/" > $this_dockerfile
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f $this_dockerfile .
bash ~/alert_msg.sh "docker build complete"
```



## make manifests

```bash
n_samples_to_keep=2
cat ${code_base}/manifests/primary_manifest.txt | sed "s|/mnt/data/tcga|${this_base_dir}/bams|" | \
sed "s|/mnt/data/intron_prospector_runs/common|${this_base_dir}/intron_beds|" | \
head -$(( n_samples_to_keep + 1 )) > ${this_base_dir}/analysis/primary_manifest.txt

cat ${this_base_dir}/analysis/primary_manifest.txt | grep -v dataset_id | cut -f1,3,4 > ${this_base_dir}/analysis/quant_manifest.txt

```



# Run pipeline

## run intron-prospector

see below for next time

```bash
disk_constraint="yes"

bash ${code_base}/scripts/run_intron-prospector.sh \
${this_base_dir}/analysis/primary_manifest.txt \
/mnt/ref/GRCh38.primary_assembly.genome.fa \
$disk_constraint
~/alert_msg.sh "ip_done"

```



in future run it like this:

```bash
bash ${code_base}/scripts/run_intron-prospector.sh \
    --manifest ${this_base_dir}/analysis/primary_manifest.txt \
    --genome /mnt/ref/GRCh38.primary_assembly.genome.fa \
    --disk-constraint yes
~/alert_msg.sh "ip_done"

```



## run quant

for two samples, less than 1 minute

```bash
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m ${this_base_dir}/analysis/quant_manifest.txt \
-o ${this_base_dir}/analysis/
date
 ~/alert_msg.sh "quant run complete"

```

## run intron_coverage

```bash
batch_size=2

bash ${code_base}/scripts/run_intron_coverage_pipeline.sh \
    --manifest ${this_base_dir}/analysis/primary_manifest.txt \
    --analysis-base ${this_base_dir}/analysis/ \
    --disk-constraint yes \
    --batch-size $batch_size
 ~/alert_msg.sh "intron_coverage run complete"
 
 
```

## Create intron table

takes about an hour

```bash
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice ir_table \
--annotation $genes \
-i ${this_base_dir}/analysis/_inclusionCounts.tsv \
-c ${this_base_dir}/analysis/_allClusters.tsv \
-d ${this_base_dir}/analysis/coverage_output \
-n 8 \
-o ${this_base_dir}/analysis/
date
~/alert_msg.sh intron_table_creation_complete 

```

## RESUME HERE

