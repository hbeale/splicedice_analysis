# Simplest version of TCGA mesa analysis

# abandoned due to non-updated manifest

RNA-Seq data in TCGA-LUAD dataset including U2AF1 WT and s34f mutant



## versions:

2025_09_05 <- abandoned because I didn't have the relevant genotypes in the columns, and wanted to start from the most correct data to start with 

2025_09_08 <- replaces bam manifest "tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt" with "batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28.tsv"



## 

## experimental design



## server

hbeale-mesa

## overview

1) Download bam files including U2AF1 WT and s34f mutant 
2) Run bam_to_junc_bed
3) Quantify splice junction usage
4) Generate a signature 
5) Fit beta
6) Query signature against original files

## commands

For download and manifest generation, see https://github.com/hbeale/splicedice_analysis/blob/acef02f4523318ea7e8ecac78c851959a4f0c9a8/2025-05_tcga_luad_sig_from_bam/2025-05-22_lab_notebook_tcga_luad_splicedice.md and 2025.09.08_08.54.46_update_batch2_manifest_with_genotype.md

```
/mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28.tsv
```





### run bam_to_junc_bed

```
source /mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/bin/activate

this_bam_manifest=/mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28.tsv
genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

new_timestamp=`~/d`
echo $new_timestamp
splicedice_out=/mnt/output/splicedice_${new_timestamp}/ 
mkdir -p $splicedice_out
echo $splicedice_out
cd $splicedice_out

time splicedice bam_to_junc_bed -m $this_bam_manifest -o $splicedice_out --genome $genome --annotation $genes --number_threads 4
ls -alth $splicedice_out
bash ~/alert_msg.sh "MESA DONE `date '+%Y.%m.%d_%H.%M.%S'`"


```

started 9/8 9:20 

ETA 12:00pm

out dir is 

```
/mnt/output/splicedice_2025.09.08_16.19.28/
```



std out

```
Finding junctions from 46 BAM files...

```



```
...
bam: /mnt/data/tcga/eae099b8-7486-42dc-9565-c875662eb729/db3c11b8-53c7-48f8-a16c-b86c1c7534b0.rna_seq.genomic.gdc_realn.bam
number of junctions found: 308150
saved to bed: /mnt/output/splicedice_2025.09.08_16.19.28/_junction_beds/db3c11b8-53c7-48f8-a16c-b86c1c7534b0.rna_seq.genomic.gdc_realn.junc.bed
new manifest written to: /mnt/output/splicedice_2025.09.08_16.19.28/_manifest.txt

real    159m3.447s
user    566m58.251s
sys     6m44.413s
total 28K
-rw-rw-r--  1 ubuntu ubuntu 9.2K Sep  8 18:59 _manifest.txt
drwxrwxr-x  3 ubuntu ubuntu   49 Sep  8 18:59 .
drwxrwxr-x  2 ubuntu ubuntu 8.0K Sep  8 18:59 _junction_beds
drwxrwxrwx 20 ubuntu ubuntu 4.0K Sep  8 16:19 ..
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/output/splicedice_2025.09.08_16.19.28$ 


```

resume at "Quantify splice junction usage" here:

https://github.com/hbeale/splicedice_analysis/blob/acef02f4523318ea7e8ecac78c851959a4f0c9a8/2025-05_tcga_luad_sig_from_bam/2025-05-22_lab_notebook_tcga_luad_splicedice.md



### Quantify splice junction usage



the splicedice code called in these commands comes from https://github.com/BrooksLabUCSC/splicedice/releases/tag/v1.0.0

```
bed_manifest=/mnt/output/splicedice_2025.09.08_16.19.28/_manifest.txt
out_prefix=/mnt/output/splicedice/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28
time splicedice quant -m ${bed_manifest} -o ${out_prefix}
ls -alth ${out_prefix}*
bash ~/alert_msg.sh "splicedice quant DONE `date '+%Y.%m.%d_%H.%M.%S'`"


```



```
Parsing manifest...
        Done [0:00:0.27]
Getting all junctions from 46 files...
        Done [0:01:12.50]
Finding clusters from 524247 junctions...
        Done [0:00:14.37]
Writing cluster file...
        Done [0:00:26.83]
Writing junction bed file...
        Done [0:00:2.54]
Gathering junction counts...
        Done [0:00:48.83]
Writing inclusion counts...
        Done [0:00:26.68]
Calculating PS values...
/mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:02:11.40]
Writing PS values...
        Done [0:00:27.78]
All done [0:05:51.20]

real    5m53.346s
user    5m51.414s
sys     0m3.738s
-rw-rw-r-- 1 ubuntu ubuntu 142M Sep  8 21:03 /mnt/output/splicedice/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28_allPS.tsv
-rw-rw-r-- 1 ubuntu ubuntu  68M Sep  8 21:01 /mnt/output/splicedice/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28_inclusionCounts.tsv
-rw-rw-r-- 1 ubuntu ubuntu  27M Sep  8 20:59 /mnt/output/splicedice/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28_junctions.bed
-rw-rw-r-- 1 ubuntu ubuntu 964M Sep  8 20:59 /mnt/output/splicedice/batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28_allClusters.tsv

```

# Compare u2af1 wt to s34f

### make signature manifest



```{bash}
bed_manifest=/mnt/output/splicedice_2025.09.08_16.19.28/_manifest.txt
#input_manifest=/mnt/data/manifests/batches_1_and_2_bed_manifest.with_genotypes.2025.05.29_22.26.44.tsv
sig_manifest=${bed_manifest/_manifest/signature_manifest}
echo $sig_manifest
cat $bed_manifest | cut -f1,3 > $sig_manifest
head -2 $sig_manifest
```



output

```
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$ head -2 $sig_manifest
TCGA-55-A4DF-01A_4a5e9e8a-8c48-48cf-8bf0-eb564611d382   u2af1-wt
TCGA-78-7633-01A_c916f887-6e77-4fc6-a692-30375d28650f   u2af1-wt
```

### remake input files without underscores (all dashes)

```
sig_manifest=/mnt/data/manifests/batches_1_and_2_sig_manifest.with_genotypes.2025.05.29_22.26.44.tsv
sig_manifest_all_dashes=${sig_manifest/sig_manifest/sig_manifest.all_dashes}
echo $sig_manifest_all_dashes

```



### Signature

The splicedice code called in these commands comes from Dennis's splicedice repo: https://github.com/dennisrm/splicedice/tree/6708e183a248809a3d28730bc466d7c1c78f3aa4

```
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py

base_dir=/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/
out_dir=${base_dir}

python3 $sig_script compare \
-p $allPS_file_all_dashes \
-m $sig_manifest_all_dashes \
-o $out_dir

```



