

[TOC]

# Starting point

/mnt/splicedice_ir_example_archives/2025.10.08_21.47.01/ from "2025_10_08_intron_retention_walkthrough_v2.md"



# Behind-the-scenes setup for the demo

Confirm example directory space is empty

```
ls -alth /mnt/splicedice_ir_example/
```



Set up example directory

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis

```

Set up data

```
ln -s /mnt/data/bams/javier_erj_jurica_ssa/javier_erj_jurica_ssa_bam_manifest.txt /mnt/splicedice_ir_example/analysis/bam_manifest.txt
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
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 

```

# Switch to branch to test

```
git checkout remove-makeRSDtable-option,-make-default 
```



## Create environment

```
cd /mnt/splicedice_ir_example/git_code/splicedice/
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/activate
pip install pysam
splicedice

```





# Copy data from previous run

```
genes=/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf
here=/mnt/splicedice_ir_example/analysis/
prev_output_dir=/mnt/splicedice_ir_example_archives/2025.10.08_21.47.01/analysis/
cd $here
cp ${prev_output_dir}/_inclusionCounts.tsv ${prev_output_dir}/_allClusters.tsv .
cp -r ${prev_output_dir}/coverage_output .
```



## Generate inclusion count table

I should be able to run it without including the makeRSDtable arg

```

splicedice ir_table \
--annotation $genes \
-i _inclusionCounts.tsv \
-c _allClusters.tsv \
-d coverage_output \
-o ${here}
```

std out

```
```



## Compare output to previous output

```
old=${prev_output_dir}/_intron_retention_RSD.tsv
new=${here}/_intron_retention_RSD.tsv
diff --report-identical-files $old $new
```



```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ diff --report-identical-files $old $new
Files /mnt/splicedice_ir_example_archives/2025.10.08_21.47.01/analysis//_intron_retention_RSD.tsv and /mnt/splicedice_ir_example/analysis//_intron_retention_RSD.tsv are identical
(splicedice_env) ubuntu@hbeale-mesa:/
```



