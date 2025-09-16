[TOC]

# Steps

1. Download repositories

2. Create envelope

3. Run analysis

   - bam_to_junc_bed
   - Quantify splice junction usage
   - Generate a signature 
   - Fit beta
   - Query signature against original files
   - Confirm results





# Behind-the-scenes setup for the demo

Confirm example directory space is empty

```
ls -alth /mnt/splicedice_example/
```



Set up example directory

```
mkdir -p /mnt/splicedice_example/git_code /mnt/splicedice_example/bam_files /mnt/splicedice_example/analysis

```

Set up data

```
ln -s /mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv /mnt/splicedice_example/analysis/bam_manifest.txt
```



Exit python environments if you're in one

```
deactivate
```

# Demo steps

## Assumptions

You have bam files from the datasets you want to analyze. You have created a manifest listing the IDs, paths, and phenotypes of each file. 

## Download repo

```
cd /mnt/splicedice_example/git_code
git clone -b add_query_scripts_from_dennis https://github.com/BrooksLabUCSC/splicedice.git 


```



## Create environment

```
cd /mnt/splicedice_example/git_code/splicedice/
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source splicedice_env/bin/activate
pip install pysam
splicedice
```



## bam_to_junc_bed

```
cd /mnt/splicedice_example/analysis

genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
here=/mnt/splicedice_example/analysis/

splicedice bam_to_junc_bed \
-m bam_manifest.txt \
-o $here \
--genome $genome \
--annotation $genes \
--number_threads 4

```



outputs

```
_manifest.txt
_junction_beds/
```

## Signature analysis

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



## Confirm expected results

```
cat .pvals.tsv  | rowsToCols stdin stdout -tab -varCol | grep -v query | awk '{printf "%s %.2f %.2f\n",$1,$2,$3}' | cut -f2,3 -d" " | sort | uniq -c
```



expected: 

11 have one phenotype and 35 have another

observed:

```
     35 0.00 1.00
     11 1.00 0.00
```



# Cleanup and archive

(failed; human error)

```
cd /mnt
this_archive_folder=/mnt/splicedice_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`
echo $this_archive_folder
mv /mnt/splicedice_example $this_archive_folder
```

