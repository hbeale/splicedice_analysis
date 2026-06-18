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
mkdir -p ${this_base_dir}/git_code/ ${this_base_dir}/analysis/ ${this_base_dir}/intron_beds ${this_base_dir}/bams
```

## get code

```bash
cd ${this_base_dir}/git_code/
git clone https://github.com/hbeale/splicedice_analysis.git
```

## build docker

a few minutes

```bash
this_dockerfile=${working_files}/Dockerfile_$this_commit
cat $code_base/Dockerfile_splicedice_by_hash | sed "s/replace_with_hash/${this_full_SHA_hash}/" > $this_dockerfile
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f $this_dockerfile .
bash ~/alert_msg.sh "docker build complete"
```



## make manifests

```bash
this_manifest=${working_files}/manifests/primary_manifest.txt
mkdir -p `dirname $this_manifest`
cat ${code_base}/manifests/primary_manifest.txt | sed "s|/mnt/data/tcga|${this_base_dir}/bams|" | \
sed "s|/mnt/data/intron_prospector_runs/common|${this_base_dir}/intron_beds|" > $this_manifest

cat $this_manifest | grep -v dataset_id | cut -f1,3,4 > ${this_base_dir}/analysis/quant_manifest.txt

```



# Run pipeline

## run intron-prospector

```bash
date
time bash ${code_base}/scripts/run_intron-prospector.sh \
    --manifest $this_manifest \
    --genome /mnt/ref/GRCh38.primary_assembly.genome.fa \
    --disk-constraint yes
date
~/alert_msg.sh "ip_done"

```

std out

```bash
Thu Jun 18 17:48:58 UTC 2026

processing TCGA-86-8074-01A
neither bed or bam file exists
downloading bam file...
using token: /home/ubuntu/gdc-user-token.2026-05-28T20_33_35.481Z.txt
...
processing TCGA-78-8660-01A
neither bed or bam file exists
downloading bam file...
using token: /home/ubuntu/gdc-user-token.2026-05-28T20_33_35.481Z.txt
100% [#######################################################################################################################] Time:  0:01:38  53.7 MiB/s
100% [#######################################################################################################################] Time:  0:00:04   1.0 MiB/s 
ERROR: ('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))
WARNING: Unable to download annotations for 4ee7ff21-a0ae-4885-92d2-a088d6f87cf0: 'NoneType' object has no attribute 'raise_for_status'
Successfully downloaded: 1
bam file exists but bed file does not
running intron-prospector...


```

i don't know if the error was temporary or not. probably a good reason to check that all the bed files exist and have the expected chromosomes present. 

## run quant

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

