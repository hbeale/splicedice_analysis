

# Goals

* generate a stable example of  running the intron retention portion of the splicedice code with IP

# Code version

uses commit  da045c4; the latest version

url: https://github.com/BrooksLabUCSC/splicedice/commit/da045c486e314e6f7db253998d886a163172295b

name: Merge pull request [#14](https://github.com/BrooksLabUCSC/splicedice/pull/14) from BrooksLabUCSC/add_query_scripts_from_dennis

SHA1=da045c486e314e6f7db253998d886a163172295b



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
/dev/vdb1       2.0T  1.2T  847G  59% /mnt
```



## Check reference files

```
ls /mnt/ref/GRCh38.primary_assembly.genome.fa
ls /mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```

if they are not present, obtain them as described in https://github.com/hbeale/splicedice_analysis/blob/main/misc/reference_file_sources.md



## Download repos

### splicedice

```
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 
```

### splicedice-dev

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/pRottinghuis/splicedice-dev.git
git clone https://github.com/hbeale/splicedice_analysis.git


```

## Revise docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
cp /mnt/splicedice_ir_example/git_code/splicedice-dev/Dockerfile .
sudo docker build -t splicedice-dev:latest .
```



```
SHA1=da045c486e314e6f7db253998d886a163172295b
28875c0
cd /mnt/splicedice_ir_example/git_code/splicedice
git reset --hard $SHA1
```



```
cd /mnt/splicedice_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 

SHA1=da045c486e314e6f7db253998d886a163172295b
cd /mnt/splicedice_ir_example/git_code/splicedice
git reset --hard $SHA1
```



## testing cloning with docker

--branch can also take tags and detaches the HEAD at that commit in the resulting repository.

clone to a specific branch

failure 1

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch$ BRANCH="28875c0"
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch$ git clone --branch $BRANCH --depth 1 https://github.com/BrooksLabUCSC/splicedice.git splicedice
Cloning into 'splicedice'...
warning: Could not find remote branch 28875c0 to clone.
fatal: Remote branch 28875c0 not found in upstream origin
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch$ 

```

failure 2

```
BRANCH="28875c0e1914b1544780497bf67cff93af69d89c"
git clone --branch $BRANCH --depth 1 https://github.com/BrooksLabUCSC/splicedice.git splicedice
```

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch$ BRANCH="28875c0e1914b1544780497bf67cff93af69d89c"
git clone --branch $BRANCH --depth 1 https://github.com/BrooksLabUCSC/splicedice.git splicedice
Cloning into 'splicedice'...
warning: Could not find remote branch 28875c0e1914b1544780497bf67cff93af69d89c to clone.
fatal: Remote branch 28875c0e1914b1544780497bf67cff93af69d89c not found in upstream origin

```





failure 3

```
SHA1=28875c0e1914b1544780497bf67cff93af69d89c

git clone --depth 1 https://github.com/BrooksLabUCSC/splicedice.git splicedice \
 && cd splicedice \
 && git reset --hard $SHA1 \
 && pip install --no-cache-dir . \
 && cd /opt \
```

```
Collecting numpy==1.24.4 (from splicedice==1.1.0)
  Downloading numpy-1.24.4.tar.gz (10.9 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 10.9/10.9 MB 44.8 MB/s eta 0:00:00
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
ERROR: Exception:
Traceback (most recent call last):
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/pip/_internal/cli/base_command.py", line 180, in exc_logging_wrapper
    status = run_func(*args)
             ^^^^^^^^^^^^^^^
...
ModuleNotFoundError: No module named 'distutils'

```

I'm not so worreid about that; I don't think that error happens in the docker 



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/
sudo docker build -t splicedice_analysis:latest .
```

copmleted without error



# Run intron prospector

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-04-21_19-12-20/
```





## launch docker

```
sudo docker run -it --rm \
-v /mnt:/mnt \
splicedice-dev:latest /bin/bash
```

```
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=/mnt/data/intron_prospector_runs/2026-04-21_19-12-20/
alignment_version=star_2.7.11b_2026.04.16

for id in $ids; do
bam_file=/mnt/output/${alignment_version}/$id/${id}_Aligned.sortedByCoord.out.bam
echo echo id is $id
echo bam file is $bam_file
echo output will be $out_base/${id}.bed
intronProspector -S --genome-fasta=$genome \
--intron-bed6=$out_base/${id}.bed \
$bam_file

done
bash /mnt/scratch/alert_msg.sh intron_prospector_complete

```

### sanity check

```
for id in $ids; do
wc -l $out_base/${id}.bed
done
```

std out

```


```



expected lines: 

we saw around 150,000 in the TCGA data

with problematic data, there were around 1500 junctions detected



# splicedice quant

```
bed_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bed_manifest.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
out_base=/mnt/data/intron_prospector_runs/2026-04-21_19-12-20/

cat $phenotypes | while read id pheno ; do
# echo id is $id pheno is $pheno
echo -e "$id\t${out_base}${id}.bed\t$pheno"
done > $bed_manifest
```



### Quantify splice junction usage

```
ls -alth /mnt/splicedice_ir_example/analysis/
```



```
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice-dev:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
```



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
        Done [0:00:0.00]
Getting all junctions from 20 files...
        Done [0:00:32.48]
Finding clusters from 189859 junctions...
        Done [0:00:1.61]
Writing cluster file...
        Done [0:00:1.07]
Writing junction bed file...
        Done [0:00:0.85]
Gathering junction counts...
        Done [0:00:18.89]
Writing inclusion counts...
        Done [0:00:4.79]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:4.66]
Writing PS values...
        Done [0:00:4.93]
All done [0:01:9.29]


```





### compare outputs 

updated; run these next when bam_to_bed is done

```
old=/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/quant/SSA_Jurica_allPS.tsv
new=/mnt/splicedice_ir_example/analysis/_allPS.tsv
diff --report-identical-files $old $new 

```

identical





## Calculate intron_coverage

```
splicedice intron_coverage \
-b bam_manifest.txt \
-m _allPS.tsv \
-j _junctions.bed \
-n 6 \
-o coverage_output

```

expected duration: 1 hour with 4 cores, 40 min with 6

std out

```
...
S77_SSA done 2225.3187968730927
S78_SSA counted 2238.0456433296204
S78_SSA done 2243.950135231018
Your runtime was 2245.1341302394867 seconds.


```

### compare outputs



```
old_base=/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa//IR_coverage/SSA_Jurica/
new_base=/mnt/splicedice_ir_example/analysis/coverage_output/


cat /mnt/splicedice_ir_example/analysis/_manifest.txt | cut -f1 | while read id; do
echo 
echo $id
new=${new_base}/${id}_intron_coverage.txt
old=${old_base}/${id}_intron_coverage.txt

diff --report-identical-files $old $new | sed 's/^.*identical/identical/'
done

```

all identical

## Generate inclusion count table

```
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i _inclusionCounts.tsv \
-c _allClusters.tsv \
-d coverage_output \
-o ${here}
```

expected duration, 5 min

```
Gathering inclusion counts and clusters...
Calculating IR values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Done 174.06683897972107
Writing output...
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ 


```



output

```
_intron_retention_RSD.tsv
_intron_retention.tsv
```



### compare outputs



```
old="/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/IR_table/SSA_Jurica_intron_retention.tsv"
new="/mnt/splicedice_ir_example/analysis/_intron_retention.tsv"
diff --report-identical-files $old $new

diff --report-identical-files <(cut $old -f1-5 | head) <( cut $new -f1-5 | head)

```

```
not identical; column names are in different order
```

# 

```
R 
library(tidyverse)
old_ir_table <- read_tsv("/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/IR_table/SSA_Jurica_intron_retention.tsv")
new_ir_table <- read_tsv("/mnt/splicedice_ir_example/analysis/_intron_retention.tsv")

old_ir_table_long <- pivot_longer(old_ir_table, -Junction) %>% mutate(old = TRUE)
new_ir_table_long <- pivot_longer(new_ir_table, -Junction) %>% mutate(new = TRUE)

combined_tables <- full_join(old_ir_table_long, new_ir_table_long)
table(combined_tables$new, useNA = "always")
table(combined_tables$old, useNA = "always")
head (combined_tables)
```



```
> table(combined_tables$new, useNA = "always")
table(combined_tables$old, useNA = "always")

  TRUE   <NA> 
713880      0 

  TRUE   <NA> 
713880      0 
> head (combined_tables)
# A tibble: 6 × 5
  Junction               name        value old   new  
  <chr>                  <chr>       <dbl> <lgl> <lgl>
1 KI270721.1:7404-7976:+ S65_DMSO        0 TRUE  TRUE 
2 KI270721.1:7404-7976:+ S66_DMSO        0 TRUE  TRUE 
3 KI270721.1:7404-7976:+ S75_DMSO        0 TRUE  TRUE 
4 KI270721.1:7404-7976:+ S76_DMSO        0 TRUE  TRUE 
5 KI270721.1:7404-7976:+ S73_HB10001     0 TRUE  TRUE 
6 KI270721.1:7404-7976:+ S74_HB10002     0 TRUE  TRUE 
```

identical



# Cleanup and archive



```
deactivate 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```



/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/

# Record as canonical output

## on hbeale-mesa open stack

```
ref_output_dir=/mnt/splicedice_ir_reference_output/ir/2025.12.04_17.56.06
mkdir -p $ref_output_dir
cp -R $this_archive_folder/* $ref_output_dir/

```

```
cd $ref_output_dir/holly_analysis_repo
git clone https://github.com/hbeale/splicedice_analysis.git
# git pull https://github.com/hbeale/splicedice_analysis.git # (if there are updates)
cp $ref_output_dir/holly_analysis_repo/splicedice_analysis/2025-10_intron_retention_example/2025_12_03_intron_retention_validation_data.md $ref_output_dir/README.md

```

## copy to brooks lab file location on mustard

(run command from mustard)

note; I chose not to include bed and coverage files; may revise on angela's feedback

```
mustard_dest=/private/groups/brookslab/hbeale/splicedice_ir_reference_output/2025.12.04_17.56.06
mkdir $mustard_dest
scp ubuntu@10.50.100.135:/mnt/splicedice_ir_reference_output/ir/2025.12.04_17.56.06/analysis/* $mustard_dest
```



```
hcbeale@mustard:/private/groups/brookslab/hbeale$ scp ubuntu@10.50.100.135:/mnt/splicedice_ir_reference_output/ir/2025.12.04_17.56.06/analysis/* $mustard_dest/
_allClusters.tsv                                                                                                100%   23MB  17.1MB/s   00:01    
_allPS.tsv                                                                                                      100%   25MB  17.1MB/s   00:01    
_inclusionCounts.tsv                                                                                            100%   14MB  31.9MB/s   00:00    
_intron_retention.tsv                                                                                           100% 4959KB  12.7MB/s   00:00    
_intron_retention_RSD.tsv                                                                                       100% 4693KB  15.6MB/s   00:00    
scp: /mnt/splicedice_ir_reference_output/ir/2025.12.04_17.56.06/analysis/_junction_beds: not a regular file
_junctions.bed                                                                                                  100% 9948KB  36.9MB/s   00:00    
_manifest.txt                                                                                                   100% 2508     1.1MB/s   00:00    
bam_manifest.txt                                                                                                100% 2372     1.1MB/s   00:00    
scp: /mnt/splicedice_ir_reference_output/ir/2025.12.04_17.56.06/analysis/coverage_output: not a regular file

```

