[TOC]



# Server

hbeale_mesa

10.50.100.135



# Steps

1. Download repository

2. Create envelope

3. Run analysis

   - bam_to_junc_bed
   - Quantify splice junction usage
   - Generate a signature 
   - Fit beta
   - Query signature against original files
   - Confirm results





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
python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py compare \
  -p _allPS.tsv \
  -m sig_manifest.txt \
  -o .
  
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
-s ..sig.tsv \
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
paste /mnt/tmp/mut_match.txt /mnt/tmp/expected_mut.txt
diff /mnt/tmp/mut_match.txt /mnt/tmp/expected_mut.txt


```







# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

# mv /mnt/splicedice_example $this_archive_folder
```

/mnt/splicedice_example_archives/2025.10.01_23.41.25/



# Scratch from previous

## Create environment

```
cd /mnt/splicedice_example/git_code/splicedice/
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source /mnt/splicedice_example/git_code/splicedice/splicedice_env/bin/activate
pip install pysam
splicedice
```



## bam_to_junc_bed

(alert_msg.sh is a notification script that sends me a message via telegram)

```

cd /mnt/splicedice_example/analysis

genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
here=/mnt/splicedice_example/analysis/
bam_manifest=bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv


splicedice bam_to_junc_bed \
-m $bam_manifest \
-o $here \
--genome $genome \
--annotation $genes \
--number_threads 4
~/alert_msg.sh "bam_to_junc_bed complete"


```

outputs

```
_manifest.txt
_junction_beds/
```


### Quantify splice junction usage

```
splicedice quant -m _manifest.txt -o $here
```

output

```
_allPS.tsv
_inclusionCounts.tsv
_junctions.bed
_allClusters.tsv
```

std out

```
Parsing manifest...
        Done [0:00:0.33]
Getting all junctions from 46 files...
        Done [0:01:16.58]
Finding clusters from 524247 junctions...
        Done [0:00:15.36]
Writing cluster file...
        Done [0:00:26.60]
Writing junction bed file...
        Done [0:00:2.73]
Gathering junction counts...
        Done [0:00:51.29]
Writing inclusion counts...
        Done [0:00:25.87]
Calculating PS values...
/mnt/splicedice_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:02:6.04]
Writing PS values...
        Done [0:00:27.83]
All done [0:05:52.63]

```



## Signature analysis


### Prepare signature manifest

```
cat _manifest.txt | cut -f1,3 > sig_manifest.txt
```



### Compare two conditions

```

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
significant intervals: 2693
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



# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_example $this_archive_folder
```

/mnt/splicedice_example_archives/2025.10.01_23.41.25/
