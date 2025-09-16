# NOT COMPLETED; CONTAINS ERRORS; IGNORE

# Steps

1. Download repositories

2. Create envelope

3. Run analysis

   

## overview

1) Run bam_to_junc_bed
2) Quantify splice junction usage
3) Generate a signature 
4) Fit beta
5) Query signature against original files



# Run steps



## Assumptions

You have bam files from the datasets you want to analyze. You have created a manifest listing the IDs, paths, and phenotypes of each file. 

Set up example directory

```
mkdir -p /mnt/splicedice_example/git_code /mnt/splicedice_example/bam_files /mnt/splicedice_example/analysis

```

Set up data

```
ln -s /mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv /mnt/splicedice_example/analysis/bam_manifest.txt
```



## Download repos

```
cd /mnt/splicedice_example/git_code
mkdir -p dr; cd dr
git clone https://github.com/dennisrm/splicedice.git

cd /mnt/splicedice_example/git_code
mkdir -p bl; cd bl
git clone https://github.com/BrooksLabUCSC/splicedice.git

```



## Create environment

```
cd /mnt/splicedice_example/git_code/bl/splicedice/
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

splicedice bam_to_junc_bed \
-m bam_manifest.txt \
-o . \
--genome $genome \
--annotation $genes \
--number_threads 4
```



outputs

```
_manifest.txt
_junction_beds
```





### Quantify splice junction usage

```
splicedice quant -m _manifest.txt -o .
```

output

```

_allPS.tsv
_inclusionCounts.tsv
```



### Prepare signature manifest

```
cat _manifest.txt | cut -f1,3 > sig_manifest.txt
```



### Compare two conditions

```
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py

python3 /mnt/splicedice_example/git_code/dr/splicedice/code/signature.py \
  -p _allPS.tsv \
  -m sig_manifest.txt \
  -o .
```



## Generate signature

```
python3 /mnt/splicedice_example/git_code/dr/splicedice/code/signature.py fit_beta.py \
-p _allPS.tsv \
-s .sig.tsv \
-m sig_manifest.txt \
-o .
```



## Query to find other matching samples

```
python3 /mnt/splicedice_example/git_code/dr/splicedice/code/signature.py query \
-p _allPS.tsv  \
-b .beta \
-o .
```



output

```
.pvals.tsv
```



Cleanup:

```
this_archive_folder=/mnt/splicedice_example_`date "+%Y.%m.%d_%H.%M.%S"`
echo $this_archive_folder
mv /mnt/splicedice_example $this_archive_folder
```



mv /mnt/splicedice_example
