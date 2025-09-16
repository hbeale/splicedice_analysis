# Simplest version of TCGA mesa analysis

RNA-Seq data in TCGA-LUAD dataset including U2AF1 WT and s34f mutant

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

For download and manifest generation, see https://github.com/hbeale/splicedice_analysis/blob/acef02f4523318ea7e8ecac78c851959a4f0c9a8/2025-05_tcga_luad_sig_from_bam/2025-05-22_lab_notebook_tcga_luad_splicedice.md

```
/mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt
```

list:

/mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt



### run bam_to_junc_bed

```
source /mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/bin/activate

this_bam_manifest=/mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt
genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

new_timestamp=`~/d`
echo $new_timestamp
splicedice_out=/mnt/output/splicedice_${new_timestamp}/ 
mkdir -p $splicedice_out
echo $splicedice_out

time splicedice bam_to_junc_bed -m $this_bam_manifest -o $splicedice_out --genome $genome --annotation $genes --number_threads 4
ls -alth $splicedice_out
bash ~/alert_msg.sh "MESA DONE `date '+%Y.%m.%d_%H.%M.%S'`"


```

started 9/5/1:39

ETA 4:40pm

```
/mnt/output/splicedice_2025.09.05_20.38.57/
```



```
new manifest written to: /mnt/output/splicedice_2025.09.05_20.38.57/_manifest.txt

real    157m34.716s
user    559m48.894s
sys     7m8.688s
total 28K
drwxrwxr-x  3 ubuntu ubuntu   49 Sep  5 23:17 .
-rw-rw-r--  1 ubuntu ubuntu 9.2K Sep  5 23:17 _manifest.txt
drwxrwxr-x  2 ubuntu ubuntu 8.0K Sep  5 23:17 _junction_beds
drwxrwxrwx 19 ubuntu ubuntu 4.0K Sep  5 20:38 ..

```

resume at "Quantify splice junction usage" here:

https://github.com/hbeale/splicedice_analysis/blob/acef02f4523318ea7e8ecac78c851959a4f0c9a8/2025-05_tcga_luad_sig_from_bam/2025-05-22_lab_notebook_tcga_luad_splicedice.md



### Quantify splice junction usage



the splicedice code called in these commands comes from https://github.com/BrooksLabUCSC/splicedice/releases/tag/v1.0.0

```
bed_manifest=/mnt/output/splicedice_2025.09.05_20.38.57/_manifest.txt
out_prefix=/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/batches_1_and_2_bed_manifest.with_genotypes.2025.05.29_22.26.44
time splicedice quant -m ${batches_1_and_2_bed_manifest_with_gt} -o ${out_prefix}
ls -alth ${out_prefix}*
bash ~/alertme.sh
```
