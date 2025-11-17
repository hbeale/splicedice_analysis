[TOC]

# Versions

uses commit "[Update ir_table.py](https://github.com/BrooksLabUCSC/splicedice/commit/f833a585a789dcde96ec14f3d732befc14fc118f)": f833a58

SHA1=f833a585a789dcde96ec14f3d732befc14fc118f

"Updated simliarity score to not include nan values in denominator", by dennisrm 9/22/2022



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
# /dev/vdb1       2.0T  1.2T  852G  59% /mnt
```



# Copy Javier's data from mustard

Previously completed

Do i have lots of space on hbeale-mesa

```
df -h | grep mnt
# /dev/vdb1       2.0T  1.2T  916G  56% /mnt
```

mkdir on hbeale-mesa

```
mkdir /mnt/mustard_scratch/erj_public/
```

copy from mustard

```
scp -r /scratch/erj_public/Jurica_SSA ubuntu@10.50.100.135:/mnt/mustard_scratch/erj_public/
```



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





# Code setup

Confirm example directory space is empty

```
ls -alth /mnt/splicedice_ir_example/
```

if it's not

```
rm -fr /mnt/splicedice_ir_example/
```



Set up example directory

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis /mnt/splicedice_ir_example/analysis/scripts/ /mnt/splicedice_ir_example/analysis/output/

```

Exit python environments if you're in one

```
deactivate
```



## Download repo

```
SHA1=f833a585a789dcde96ec14f3d732befc14fc118f
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 
cd splicedice
ls
git reset --hard $SHA1
ls

```

std out

```
Cloning into 'splicedice'...
remote: Enumerating objects: 661, done.
remote: Counting objects: 100% (91/91), done.
remote: Compressing objects: 100% (71/71), done.
remote: Total 661 (delta 43), reused 57 (delta 17), pack-reused 570 (from 1)
Receiving objects: 100% (661/661), 793.00 KiB | 3.60 MiB/s, done.
Resolving deltas: 100% (348/348), done.
LICENSE  MANIFEST.in  Pipfile  README.md  data  docs  requirements.txt  scripts  setup.py  splicedice
HEAD is now at f833a58 Update ir_table.py
LICENSE  MANIFEST.in  Pipfile  README.md  data  docs  requirements.txt  scripts  setup.py  splicedice
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ 

```



## Create environment

```
cd /mnt/splicedice_ir_example/git_code/splicedice/
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/activate
pip install pysam
~/alertme.sh 
splicedice
```



std out

```
...
Successfully built splicedice
Installing collected packages: pytz, tzdata, tqdm, threadpoolctl, six, packaging, numpy, llvmlite, joblib, scipy, python-dateutil, patsy, numba, scikit-learn, pandas, statsmodels, pynndescent, umap-learn, splicedice
Successfully installed joblib-1.5.2 llvmlite-0.45.1 numba-0.62.1 numpy-2.3.4 packaging-25.0 pandas-2.3.3 patsy-1.0.2 pynndescent-0.5.13 python-dateutil-2.9.0.post0 pytz-2025.2 scikit-learn-1.7.2 scipy-1.16.3 six-1.17.0 splicedice-0.0.1 statsmodels-0.14.5 threadpoolctl-3.6.0 tqdm-4.67.1 tzdata-2025.2 umap-learn-0.5.9.post2
Collecting pysam
  Using cached pysam-0.23.3-cp312-cp312-manylinux_2_28_x86_64.whl.metadata (1.7 kB)
Using cached pysam-0.23.3-cp312-cp312-manylinux_2_28_x86_64.whl (24.0 MB)
Installing collected packages: pysam
Successfully installed pysam-0.23.3
...
usage: splicedice [-h]
                  {bam_to_junc_bed,quant,intron_coverage,ir_table,compare_sample_sets,pairwise,findOutliers,subset,similarity,select,counts_to_ps}
            ...

```

# bam to bed

copy previous manifest

```
prev_commit_dir=/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/analysis/
prev_script_dir=${prev_commit_dir}/scripts/
new_script_base=/mnt/splicedice_ir_example/analysis/scripts/

cp  ${prev_script_dir}/Manifest_file.txt $new_script_base

```



copy previous script

```
this_script=SSA100_splicedice.sh
cp ${prev_script_dir}/${this_script/splicedice/mesa} $new_script_base/${this_script}

nano ${new_script_base}/$this_script

```



```
output="/mnt/splicedice_ir_example/analysis/output/splicedice/bamtobed/SSA"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
genome="/mnt/ref/GRCh38.primary_assembly.genome.fa"
mkdir -p `dirname $output`
splicedice bam_to_junc_bed \
-m /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt \
--output_prefix ${output} \
--annotation ${gtf} \
--genome ${genome}
~/alert_msg.sh "bam_to_junc_bed complete"

```

```
bash  ${new_script_base}/$this_script
```

std out

```
...
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB10003_S83.filteredAligned.sortedByCoord.out.bam
number of junctions found: 439690
saved to bed: /mnt/splicedice_ir_example/analysis/output/splicedice/bamtobed/SSA_junction_beds/HB10003_S83.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB10004_S84.filteredAligned.sortedByCoord.out.bam
...
```



### compare outputs 

updated; run these next when bam_to_bed is done

```
old_base=/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/analysis/output/mesa/
new_base=/mnt/splicedice_ir_example/analysis/output/splicedice/
```



compare all

```

cat /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/bamtobed/SSA_junction_beds/$bed_file_name
old=${old_base}/bamtobed/SSA_junction_beds/$bed_file_name

echo $bed_file_name
diff --report-identical-files $old $new | sed 's/^.*identical/identical/'
done

```



results: all bed files are identical 2025.11.13_17.04.55



# QUANT 

copy previous script

```
prev_commit_dir=/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/analysis/
prev_script_dir=${prev_commit_dir}/scripts/
new_script_base=/mnt/splicedice_ir_example/analysis/scripts/
this_script=SSA100_splicedice_quant.sh
cp ${prev_script_dir}/${this_script/splicedice/mesa} $new_script_base/${this_script}

nano ${new_script_base}/$this_script

```



/mnt/splicedice_ir_example/analysis/scripts/SSA100_splicedice_quant.sh

```
#!/bin/bash
set -e

BDMF="/mnt/splicedice_ir_example/analysis/output/splicedice/bamtobed/SSA_manifest.txt"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
genome="/mnt/ref/GRCh38.primary_assembly.genome.fa"
out="/mnt/splicedice_ir_example/analysis/output/splicedice/quant/SSA_Jurica"
mkdir -p `dirname $out`

splicedice quant \ 
-m ${BDMF} \
-o ${out}

~/alert_msg.sh "$0 complete"

```

```
bash /mnt/splicedice_ir_example/analysis/scripts/SSA100_splicedice_quant.sh
```



std out

```
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 20 files...
        Done [0:00:32.83]
Finding clusters from 189859 junctions...
        Done [0:00:1.40]
Writing cluster file...
        Done [0:00:1.05]
Writing junction bed file...
        Done [0:00:0.78]
Gathering junction counts...
        Done [0:00:18.67]
Writing inclusion counts...
        Done [0:00:4.90]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:4.63]
Writing PS values...
        Done [0:00:5.07]
All done [0:01:9.33]
{"status":"OK","nsent":2,"apilimit":"2\/1000"}
```



### compare outputs



compare output from one bam file

```

old="/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/analysis/output/mesa/quant/SSA_Jurica_allPS.tsv"
new="/mnt/splicedice_ir_example/analysis/output/splicedice/quant/SSA_Jurica_allPS.tsv"
diff --report-identical-files $old $new
```

```
identical
```



## Calculate intron_coverage for each sample

nano /mnt/splicedice_ir_example/analysis/scripts/SSA100_splicedice_IRcoverage.sh

```
#!/bin/bash
set -e

project="/mnt/splicedice_ir_example/analysis/output/splicedice/quant/"
output="/mnt/splicedice_ir_example/analysis/output/splicedice/IR_coverage/"
mkdir -p $output
splicedice intron_coverage \
-b /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt \
-m ${project}SSA_Jurica_allPS.tsv \
-j ${project}SSA_Jurica_junctions.bed \
-o ${output}SSA_Jurica 

~/alert_msg.sh "$0 complete"

```



```
bash  /mnt/splicedice_ir_example/analysis/scripts/SSA100_splicedice_IRcoverage.sh
```



```
getting paths for bam files
creating junction percentiles
...
S78_SSA counted 10974.943749666214
S78_SSA done 10980.606030464172
Your runtime was 10981.715834617615 seconds.
Your runtime was 10995.562909603119 seconds.
```

### compare outputs



compare output from one bam file



compare all

```
old_base=/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/analysis/output/mesa//IR_coverage/SSA_Jurica/
new_base=/mnt/splicedice_ir_example/analysis/output/splicedice/IR_coverage/SSA_Jurica/


cat /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt | cut -f1 | while read id; do
echo 
echo $id
new=${new_base}/${id}_intron_coverage.txt
old=${old_base}/${id}_intron_coverage.txt

diff --report-identical-files $old $new #| sed 's/^.*identical/identical/'
done

```

all identical

# Combine IR coverage into table



nano /mnt/splicedice_ir_example/analysis/scripts/SSA100_splicedice_IRtable.sh

```
#!/bin/bash
set -e

output="/mnt/splicedice_ir_example/analysis/output/splicedice/IR_table/"
project="/mnt/splicedice_ir_example/analysis/output/splicedice/quant/"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
mkdir -p $output
splicedice ir_table -i ${project}SSA_Jurica_inclusionCounts.tsv \
-c ${project}SSA_Jurica_allClusters.tsv \
-d /mnt/splicedice_ir_example/analysis/output/splicedice/IR_coverage/SSA_Jurica \
-o ${output}SSA_Jurica \
-a $gtf \
-r

~/alert_msg.sh "$0 complete"

```

run script

```
bash  /mnt/splicedice_ir_example/analysis/scripts/SSA100_splicedice_IRtable.sh
```



started at 2025.11.14_09.26.19



std out

```
Gathering inclusion counts and clusters...
Calculating IR values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
  Done 168.9955370426178
Writing output...
{"status":"OK","nsent":2,"apilimit":"4\/1000"}
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ 


```



### compare outputs



compare output from one bam file

```
old="/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/analysis/output//mesa/IR_table/SSA_Jurica_intron_retention.tsv"
new="/mnt/splicedice_ir_example/analysis/output/splicedice/IR_table/SSA_Jurica_intron_retention.tsv"
diff --report-identical-files $old $new
```

```
identical
```



## 

# Cleanup and archive



```
deactivate 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/
