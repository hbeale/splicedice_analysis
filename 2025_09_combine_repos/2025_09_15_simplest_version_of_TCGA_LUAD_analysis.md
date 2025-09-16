# Simplest version of TCGA mesa analysis

RNA-Seq data in TCGA-LUAD dataset including U2AF1 WT and s34f mutant



## versions:

2025_09_05 <- abandoned because I didn't have the relevant genotypes in the columns, and wanted to start from the most correct data to start with 

2025_09_08 <- replaces bam manifest "tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt" with "batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28.tsv"

2025_09_10 <- replaces bam manifest "batch_2_bam_manifest.with_genotypes.2025.09.08_09.13.28.tsv" with "batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv"

(has dashes as separators instead of underscores, which is required by splicedice)

2025-09-15 <- makes directories and outputs more consistent





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

For download and manifest generation, see https://github.com/hbeale/splicedice_analysis/blob/acef02f4523318ea7e8ecac78c851959a4f0c9a8/2025-05_tcga_luad_sig_from_bam/2025-05-22_lab_notebook_tcga_luad_splicedice.md  and "2025.09.10_10.03.13_update_batch2_manifest_with_genotype.md"



### set up environment

```
source /mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/bin/activate

```



### setup with simple file names

create simple file names

```
new_timestamp=`~/d`
echo $new_timestamp
splicedice_out=/mnt/output/splicedice_${new_timestamp}/ 
mkdir -p $splicedice_out
echo $splicedice_out
cd $splicedice_out
ln -s /mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv ${splicedice_out}/bam_manifest.tsv


```

/mnt/output/splicedice_2025.09.15_19.46.34/



```
this_dir=/mnt/output/splicedice_2025.09.15_19.46.34/
this_bam_manifest=${this_dir}/bam_manifest.tsv
genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```



### bam_to_junc_bed

```
time splicedice bam_to_junc_bed \
-m $this_bam_manifest \
-o $this_dir \
--genome $genome \
--annotation $genes \
--number_threads 4

ls -alth $this_dir
bash ~/alert_msg.sh "MESA DONE `date '+%Y.%m.%d_%H.%M.%S'`"

```



output

```
-rw-rw-r--  1 ubuntu ubuntu 9.1K Sep 15 22:45 _manifest.txt
drwxrwxr-x  2 ubuntu ubuntu 8.0K Sep 15 22:45 _junction_beds

```

```
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/output/splicedice_2025.09.15_19.46.34$ ls _junction_beds/ | wc -l
46
```



### Quantify splice junction usage



the splicedice code called in these commands comes from https://github.com/BrooksLabUCSC/splicedice/releases/tag/v1.0.0

```
this_bed_manifest=${this_dir}/_manifest.txt
time splicedice quant -m ${this_bed_manifest} -o ${this_dir}/
ls -lth ${this_dir}/*
bash ~/alert_msg.sh "splicedice quant DONE `date '+%Y.%m.%d_%H.%M.%S'`"


```



```
Parsing manifest...
        Done [0:00:0.31]
Getting all junctions from 46 files...
        Done [0:01:14.12]
Finding clusters from 524247 junctions...
        Done [0:00:14.80]
Writing cluster file...
        Done [0:00:26.46]
Writing junction bed file...
        Done [0:00:2.58]
Gathering junction counts...
        Done [0:00:51.31]
Writing inclusion counts...
        Done [0:00:26.27]
Calculating PS values...
/mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)   
        Done [0:02:12.70]
Writing PS values...
        Done [0:00:27.05]
All done [0:05:55.60]

real    5m57.966s
user    5m55.363s
sys     0m3.985s



```

```
output: 
_allPS.tsv
_inclusionCounts.tsv
```





# Compare u2af1 wt to s34f

### make signature manifest



```{bash}
sig_manifest=${bed_manifest/_manifest/signature_manifest}
echo $sig_manifest
cat $bed_manifest | cut -f1,3 > $sig_manifest

```



output

```


```



### Signature

The splicedice code called in these commands comes from Dennis's splicedice repo: https://github.com/dennisrm/splicedice/tree/6708e183a248809a3d28730bc466d7c1c78f3aa4

```
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py

time python3 $sig_script compare \
  -p ${this_dir}/_allPS.tsv \
  -m $sig_manifest \
  -o ${this_dir}/
date


```

output

```
-rw-rw-r--  1 ubuntu ubuntu 390K Sep 15 23:34 .sig.tsv

```



## Fit beta

The splicedice code called in these commands comes from Dennis's splicedice repo: https://github.com/dennisrm/splicedice/tree/6708e183a248809a3d28730bc466d7c1c78f3aa4



```shell
time python3 $sig_script fit_beta \
-p ${this_dir}_allPS.tsv \
-s $this_dir/.sig.tsv \
-m $sig_manifest \
-o $this_dir/
~/alertme.sh
```




```
Reading...
Fitting beta distributions...
significant intervals: 2693
Writing files...

real    0m5.037s
user    0m11.623s
sys     0m2.042s
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
```



check out results

```{shell}
head ${out_dir}/.beta.tsv | grep splice_interval
head ${out_dir}/.beta.tsv | grep -v splice_interval | awk '{printf "%s %.2f %.2f %.2f %.2f %.2f %.2f\n",$1,$2,$3,$4,$5,$6,$7}' | head
```

```
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/output/splicedice_2025.09.10_17.13.23$ head ${out_dir}/.beta.tsv | grep splice_interval
head ${out_dir}/.beta.tsv | grep -v splice_interval | awk '{printf "%s %.2f %.2f %.2f %.2f %.2f %.2f\n",$1,$2,$3,$4,$5,$6,$7}' | head
splice_interval median_u2af1-wt alpha_u2af1-wt  beta_u2af1-wt   median_u2af1-s34f       alpha_u2af1-s34f        beta_u2af1-s34f
chr1:17368-17605:- 0.79 6.64 1.87 0.89 7.90 1.04
chr1:17368-17605:+ 0.66 4.42 2.15 0.78 4.58 1.17
chr1:498456-498683:- 0.27 1.72 4.25 0.17 1.28 6.55
chr1:733364-735422:+ 0.64 1.79 0.82 0.86 3.13 0.61
chr1:729955-735422:+ 0.07 0.68 10.29 0.00 0.38 14.57
chr1:939412-941143:+ 0.56 0.56 0.65 1.00 0.00 0.00
chr1:1338653-1339286:+ 0.49 4.93 4.89 0.30 1.80 3.63
chr1:939460-941143:+ 0.37 0.41 0.47 0.00 0.00 0.00
chr1:1338653-1339286:- 0.48 3.36 3.82 0.25 0.97 3.25

```



## Query



### run query

The splicedice code called in these commands comes from Dennis's splicedice repo: https://github.com/dennisrm/splicedice/tree/6708e183a248809a3d28730bc466d7c1c78f3aa4

```shell
beta_file=${this_dir}/.beta.tsv

time python3 $sig_script query \
-p ${this_dir}_allPS.tsv  \
-b $beta_file \
-o $this_dir/

```



output

```
.pvals.tsv
```



### review results

```shell
cat .pvals.tsv  | rowsToCols stdin stdout -tab -varCol | grep -v query | awk '{printf "%s %.2f %.2f\n",$1,$2,$3}' | cut -f2,3 -d" " | sort | uniq -c
```

```
-rw-rw-r--  1 ubuntu ubuntu 3.7K Sep 15 23:44 .pvals.tsv
drwxrwxr-x  3 ubuntu ubuntu  216 Sep 15 23:44 .
-rw-rw-r--  1 ubuntu ubuntu 294K Sep 15 23:41 .beta.tsv
-rw-rw-r--  1 ubuntu ubuntu 390K Sep 15 23:34 .sig.tsv
-rw-rw-r--  1 ubuntu ubuntu 142M Sep 15 23:17 _allPS.tsv
-rw-rw-r--  1 ubuntu ubuntu  68M Sep 15 23:14 _inclusionCounts.tsv
-rw-rw-r--  1 ubuntu ubuntu  27M Sep 15 23:13 _junctions.bed
-rw-rw-r--  1 ubuntu ubuntu 964M Sep 15 23:13 _allClusters.tsv
-rw-rw-r--  1 ubuntu ubuntu 9.1K Sep 15 22:45 _manifest.txt
drwxrwxr-x  2 ubuntu ubuntu 8.0K Sep 15 22:45 _junction_beds
lrwxrwxrwx  1 ubuntu ubuntu   79 Sep 15 19:47 bam_manifest.tsv -> /mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv
drwxrwxrwx 22 ubuntu ubuntu 4.0K Sep 15 19:46 ..

```

