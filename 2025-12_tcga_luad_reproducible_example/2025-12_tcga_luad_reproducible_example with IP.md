[TOC]

# Summary
This code and output shows that using the intron prospector implementation generates the same results as what we previously saw with bam_to_junc_bed.py in splicedice. 

Specifically, building a signature based on the u2af1 genotype (35 wt, 11 s34f) creates a signature that then correctly re-identifies each of the samples used to generate it. 

# Server

hbeale_mesa

10.50.100.135



# Reset from any previous runs

Confirm example directory space is empty

```
ls -alth /mnt/splicedice_example/
```

delete if it's not

```
rm -r /mnt/splicedice_example/
```

Exit python environments if one is active

```
deactivate
```

# Setup

## Check reference files

```
ls /mnt/ref/GRCh38.primary_assembly.genome.fa
ls /mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```

if they are not present, obtain them as described in https://github.com/hbeale/splicedice_analysis/blob/main/misc/reference_file_sources.md



## Download repos

### splicedice

```
cd /mnt/splicedice_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 
```

### splicedice-dev

```
mkdir -p /mnt/splicedice_example/git_code /mnt/splicedice_example/analysis
cd /mnt/splicedice_example/git_code
git clone https://github.com/pRottinghuis/splicedice-dev.git

```



Proceed based on

https://github.com/pRottinghuis/splicedice-dev/blob/5082d2dbccdd885b78b91c4a3b352eaa0fff80f5/notebooks/2026-02_tcga_luad_reproducible_example/2026-02-01_tcga_luad_intronProspector_1fex.md



## Build docker

```
cd /mnt/splicedice_example/git_code/splicedice-dev
docker build -t splicedice-dev:latest .
```

## Get manifest

```
wget https://raw.githubusercontent.com/hbeale/splicedice_analysis/refs/heads/main/2025-12_tcga_luad_reproducible_example/bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv -P  /mnt/splicedice_example/analysis/
```



# Run intron prospector

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

## launch docker

```
sudo docker run -it --rm \
-v /mnt:/mnt \
splicedice-dev:latest /bin/bash
```

```
bam_manifest=/mnt/splicedice_example/analysis/bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=/mnt/data/intron_prospector_runs/2026-04-01_21-53-28/

cat $bam_manifest | cut -f1-2 | while read id bam_file; do
echo echo id is $id
echo bam file is $bam_file
intronProspector -S --genome-fasta=$genome \
--intron-bed6=$out_base/${id}.bed \
$bam_file

done

```

# Run splicedice



## Format intronProspector output for SpliceDICE

Create _manifest.tsv

```
bam_manifest=/mnt/splicedice_example/analysis/bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=/mnt/data/intron_prospector_runs/2026-04-01_21-53-28/

bed_manifest=/mnt/splicedice_example/analysis/bed_manifest.tsv

cat $bam_manifest | cut -f1,3 | while read id genotype ; do
echo -e "$id\t${out_base}${id}.bed\t$genotype"
done > $bed_manifest
```



## Run splicedice quant

```
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice-dev:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_example/analysis/
```

output files

```
ubuntu@hbeale-mesa:/mnt/splicedice_example/git_code/splicedice-dev$ ls -alth ../../analysis/
-rw-r--r-- 1 root   root   105M Apr  1 23:38 _allPS.tsv
drwxrwxr-x 2 ubuntu ubuntu  181 Apr  1 23:38 .
-rw-r--r-- 1 root   root    51M Apr  1 23:37 _inclusionCounts.tsv
-rw-r--r-- 1 root   root    21M Apr  1 23:36 _junctions.bed
-rw-r--r-- 1 root   root   133M Apr  1 23:36 _allClusters.tsv
-rw-rw-r-- 1 ubuntu ubuntu 7.8K Apr  1 23:13 bed_manifest.tsv
-rw-rw-r-- 1 ubuntu ubuntu 8.6K Apr  1 21:23 bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv

```



## Signature analysis


### Prepare signature manifest

```
cd /mnt/splicedice_example/analysis/
cat $bed_manifest | cut -f1,3 > /mnt/splicedice_example/analysis/sig_manifest.txt
```



### Compare two conditions

```
here=/mnt/splicedice_example/analysis/
python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py compare \
  -p _allPS.tsv \
  -m sig_manifest.txt \
  -o $here
  
```

output

```
.sig.tsv
```

std out

```
Testing for differential splicing...
Groups: u2af1-wt (35), u2af1-s34f (11)
Writing...

```



## Generate beta fit of signature

```
python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py fit_beta \
-p _allPS.tsv \
-s .sig.tsv \
-m sig_manifest.txt \
-o $here

  
```

output

```
.beta.tsv
```

std out

```

Reading...
Fitting beta distributions...
significant intervals: 1601
Writing files...


```



## Query to find other matching samples

```
python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py query \
-p _allPS.tsv  \
-b .beta.tsv \
-o $here
  
```



output

```
.pvals.tsv
```



std out

```

Reading...
Querying...
Writing...
```



## Confirm expected results

```
cat .pvals.tsv  | rowsToCols stdin stdout -tab -varCol | grep -v query | awk '{printf "%s %.2f %.2f\n",$1,$2,$3}' | cut -f2,3 -d" " | sort | uniq -c
```



expected: 

11 datasets have one phenotype and 35 have another

observation confirms it:

```
     35 0.00 1.00
     11 1.00 0.00

```

confirm that it's the exact same samples

```
cat .pvals.tsv  | rowsToCols stdin stdout -tab -varCol | awk '{printf "%s %.2f %.2f\n",$1,$2,$3}' | awk '$2 == "1.00"' | cut -f1 -d " " | sort > /mnt/tmp/mut_match.txt
cat sig_manifest.txt | grep u2af1-s34f | cut -f1 | sort > /mnt/tmp/expected_mut.txt
diff /mnt/tmp/mut_match.txt /mnt/tmp/expected_mut.txt
echo if there is no output from diff the files are the same
echo
paste /mnt/tmp/mut_match.txt /mnt/tmp/expected_mut.txt


```



std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_example/analysis$ cat .pvals.tsv  | rowsToCols stdin stdout -tab -varCol | awk '{printf "%s %.2f %.2f\n",$1,$2,$3}' | awk '$2 == "1.00"' | cut -f1 -d " " | sort > /mnt/tmp/mut_match.txt
cat sig_manifest.txt | grep u2af1-s34f | cut -f1 | sort > /mnt/tmp/expected_mut.txt
diff /mnt/tmp/mut_match.txt /mnt/tmp/expected_mut.txt
echo if there is no output from diff the files are the same
echo
paste /mnt/tmp/mut_match.txt /mnt/tmp/expected_mut.txt
if there is no output from diff the files are the same

TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2    TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2
TCGA-49-6744-01A33c16d35-96da-4400-9f48-1fc7567e30a4    TCGA-49-6744-01A33c16d35-96da-4400-9f48-1fc7567e30a4
TCGA-50-5941-01Aaa7245fd-7073-4ff9-88cc-648a2c9f1f60    TCGA-50-5941-01Aaa7245fd-7073-4ff9-88cc-648a2c9f1f60
TCGA-50-8460-01A3dbc67a1-c49d-407c-867b-dc453f3aebc0    TCGA-50-8460-01A3dbc67a1-c49d-407c-867b-dc453f3aebc0
TCGA-55-1595-01A63da5a36-0ec0-4d89-be9d-7319f0eae8ed    TCGA-55-1595-01A63da5a36-0ec0-4d89-be9d-7319f0eae8ed
TCGA-55-7727-01A86c05b02-68d0-473d-8aea-ab501cb40d29    TCGA-55-7727-01A86c05b02-68d0-473d-8aea-ab501cb40d29
TCGA-55-7903-01A99c213ba-55b9-42b6-9546-62b8d3f6c284    TCGA-55-7903-01A99c213ba-55b9-42b6-9546-62b8d3f6c284
TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b    TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b
TCGA-78-7145-01Aeae099b8-7486-42dc-9565-c875662eb729    TCGA-78-7145-01Aeae099b8-7486-42dc-9565-c875662eb729
TCGA-78-8655-01A6f343aec-65e1-44ad-b4db-339d4ed62373    TCGA-78-8655-01A6f343aec-65e1-44ad-b4db-339d4ed62373
TCGA-MP-A4T4-01A9eeae6b9-2031-47fa-80db-e04d53f0bfbd    TCGA-MP-A4T4-01A9eeae6b9-2031-47fa-80db-e04d53f0bfbd
ubuntu@hbeale-mesa:/mnt/splicedice_example/analysis$ 

```







# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

mv /mnt/splicedice_example $this_archive_folder
```

/mnt/splicedice_example_archives/2026.04.02_16.27.36/



