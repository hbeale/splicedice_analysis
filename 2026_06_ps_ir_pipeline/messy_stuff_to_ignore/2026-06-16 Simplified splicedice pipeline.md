# 2026-06-16 Simplified splicedice pipeline 



This approach is optimized for limited disk space. Bams are downloaded one at a time (for identifying introns with intron-prospector) or in small batches (for calculating intron coverage with splicedice intron_coverage). There are only a few samples in this example. The approach is useful when there are many terabytes of sequencing data. 



command

```bash
this_base_dir=/mnt/sd/ex_streamlined_4dd834b_2026.06.16_21.04.07/
code_base=${this_base_dir}/git_code/splicedice_analysis/2026_06_ps_ir_pipeline

```

## run intron-prospector

```bash
script=${code_base}/scripts/run_intron-prospector.sh
manifest=${code_base}/manifests/primary_manifest.4dd834b_2026.06.16_21.04.07.2_samples.txt 
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
disk_constraint="yes"

bash $script $manifest $genome $disk_constraint
~/alert_msg.sh "ip_done"

```

## run quant

```bash
bed_manifest=${code_base}/manifests/quant_manifest.4dd834b_2026.06.16_21.04.07.2_samples.txt
mkdir ${this_base_dir}/analysis/
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o ${this_base_dir}/analysis/
date
 ~/alert_msg.sh "quant run complete"

```

std out

```bash
Wed Jun 17 22:46:29 UTC 2026
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 2 files...
        Done [0:00:0.99]
Finding clusters from 206575 junctions...
        Done [0:00:1.56]
Writing cluster file...
        Done [0:00:1.33]
Writing junction bed file...
        Done [0:00:1.19]
Gathering junction counts...
        Done [0:00:1.40]
Writing inclusion counts...
        Done [0:00:1.91]
Calculating PS values...
        Done [0:00:2.97]
Writing PS values...
        Done [0:00:1.85]
All done [0:00:13.19]
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)

real    0m18.325s
user    0m0.046s
sys     0m0.063s
Wed Jun 17 22:46:48 UTC 2026
{"status":"OK","nsent":2,"apilimit":"10\/1000"}
```



## run intron_coverage

```bash
this_base_dir=/mnt/sd/ex_streamlined_4dd834b_2026.06.16_21.04.07/
script=git_code/splicedice_analysis/2026_06_ps_ir_pipeline/scripts/run_intron_coverage_pipeline.sh
mini_manifest=${this_manifest/.txt}.2_samples.txt
analysis_base=${this_base_dir}/analysis/
batch_size=2

bash ${this_base_dir}/${script} \
    --manifest $mini_manifest \
    --analysis-base $analysis_base \
    --disk-constraint yes \
    --batch-size $batch_size
 ~/alert_msg.sh "intron_coverage run complete"
 
```

std out

```bash


=== 2 samples still need intron_coverage ===

========================================================   
BATCH 1: 2 samples
========================================================   

--- downloading BAMs for batch 1 ---
using token: /home/ubuntu/gdc-user-token.2026-05-28T20_33_35.481Z.txt
TCGA-86-8074-01A: queuing 567c5d5f-2b27-4070-86c3-3905d06ed02b for download
TCGA-62-8402-01A: queuing cae0680e-f7bf-4742-aeca-8fac6d4f4934 for download
Downloading 2 BAM(s)...
Wed Jun 17 22:47:56 UTC 2026
100% [#######################################################################################################################] Time:  0:03:22  56.4 MiB/s
100% [#######################################################################################################################] Time:  0:01:47  56.0 MiB/s
Successfully downloaded: 2
Downloads complete.
Wed Jun 17 22:54:10 UTC 2026

--- running intron_coverage for batch 1 ---
Running intron_coverage on 2 samples with 2 threads...
Wed Jun 17 22:54:10 UTC 2026
getting paths for bam files
creating junction percentiles
[W::hts_idx_load3] The index file is older than the data file: /mnt/sd/ex_streamlined_4dd834b_2026.06.17_14.51.32//bams/567c5d5f-2b27-4070-86c3-3905d06ed02
b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam.bai
[W::hts_idx_load3] The index file is older than the data file: /mnt/sd/ex_streamlined_4dd834b_2026.06.17_14.51.32//bams/cae0680e-f7bf-4742-aeca-8fac6d4f493
4/2a48ffd2-9212-48f4-a836-7572eb2feffe.rna_seq.genomic.gdc_realn.bam.bai
TCGA-62-8402-01A starting 3.611396312713623
TCGA-62-8402-01A collected 1049.0025448799133
TCGA-62-8402-01A counted 1838.3440732955933
TCGA-62-8402-01A done 1846.9565541744232
Your runtime was 2918.855702638626 seconds.

real    48m44.038s
user    0m0.260s
sys     0m0.065s
Wed Jun 17 23:42:54 UTC 2026
intron_coverage complete.

--- disk_constraint=yes: cleaning up BAMs ---
TCGA-62-8402-01A: output confirmed, deleting BAM

batch 1 complete

========================================================   
All batches complete.
========================================================   
{"status":"OK","nsent":2,"apilimit":"11\/1000"}

```



## Create intron table

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
bash /mnt/scratch/alert_msg.sh intron_table_creation_complete 

```



std out

```bash
Wed Jun 17 16:12:34 UTC 2026
Starting ir_table with 2 samples
Loading annotation...
Annotation loaded: 528735 annotated junctions. 62.1s
Gathering inclusion counts and clusters...
Loaded 2 samples and 206575 clusters. 65.3s
Collecting junctions across all samples...
getJunctions complete: 183464 junctions. 2.7s
RSD filtering complete: 48212 junctions retained. 17.7s
Junction collection and RSD filtering complete: 48212 junctions retained. 83.0s
Writing IR table...
IR calculated for 2/2 samples
IR table written. 93.6s
Done. Total runtime: 93.6s

real    1m39.728s
user    0m0.059s
sys     0m0.068s
Wed Jun 17 16:14:14 UTC 2026

```

