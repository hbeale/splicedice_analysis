

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

```





Proceed based on

https://github.com/pRottinghuis/splicedice-dev/blob/5082d2dbccdd885b78b91c4a3b352eaa0fff80f5/notebooks/2026-02_tcga_luad_reproducible_example/2026-02-01_tcga_luad_intronProspector_1fex.md



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice-dev
sudo docker build -t splicedice-dev:latest .
```



# Run intron prospector

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-04-17_23-47-01/
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
out_base=/mnt/data/intron_prospector_runs/2026-04-17_23-47-01/
alignment_version=star_2.7.11b_2026.04.16

for id in $ids; do
bam_file=/mnt/output/${alignment_version}/$id/${id}.bam
echo echo id is $id
echo bam file is $bam_file
intronProspector -S --genome-fasta=$genome \
--intron-bed6=$out_base/${id}.bed \
$bam_file

done
bash /mnt/scratch/alert_msg.sh intron_prospector_complete

```

# 

something is wrong; there are around 1500 junctions detected in the HEK cells, and around 150,000 in the TCGA data







# repeat, modifying docker to use latest code



## edit dockerfile

```
# for installing https://github.com/diekhans/intronProspector.git, 
# changed the preceeding line from
RUN git clone --branch v1.4.0 --depth 1 \
# to 
RUN git clone --depth 1 \

```



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice-dev
sudo docker build -t splicedice-dev:latest .
```



## date stamp

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-04-18_00-03-14/
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
out_base=/mnt/data/intron_prospector_runs/2026-04-18_00-03-14/
alignment_version=star_2.7.11b_2026.04.16

for id in $ids; do
bam_file=/mnt/output/${alignment_version}/$id/${id}.bam
echo echo id is $id
echo bam file is $bam_file
intronProspector -S --genome-fasta=$genome \
--intron-bed6=$out_base/${id}.bed \
$bam_file

done
bash /mnt/scratch/alert_msg.sh intron_prospector_complete

```

```
cd $out_base
```

```
root@445a53be4523:/mnt/data/intron_prospector_runs/2026-04-18_00-03-14# for i in *.bed; do wc -l $i; done
1268 SRR12801019.bed
1503 SRR12801020.bed
1378 SRR12801023.bed
1332 SRR12801024.bed
1507 SRR12801027.bed
1456 SRR12801028.bed
```

how big are the bam files?

```
for id in $ids; do
bam_file=/mnt/output/${alignment_version}/$id/${id}.bam
ls -lh $bam_file
done
```

too small

```
-rw-rw-r-- 1 1000 1000 37M Apr 17 21:19 /mnt/output/star_2.7.11b_2026.04.16/SRR12801019/SRR12801019.bam
-rw-rw-r-- 1 1000 1000 47M Apr 17 21:42 /mnt/output/star_2.7.11b_2026.04.16/SRR12801020/SRR12801020.bam
-rw-rw-r-- 1 1000 1000 40M Apr 17 22:00 /mnt/output/star_2.7.11b_2026.04.16/SRR12801023/SRR12801023.bam
-rw-rw-r-- 1 1000 1000 41M Apr 17 22:22 /mnt/output/star_2.7.11b_2026.04.16/SRR12801024/SRR12801024.bam
-rw-rw-r-- 1 1000 1000 48M Apr 17 22:42 /mnt/output/star_2.7.11b_2026.04.16/SRR12801027/SRR12801027.bam
-rw-rw-r-- 1 1000 1000 44M Apr 17 23:04 /mnt/output/star_2.7.11b_2026.04.16/SRR12801028/SRR12801028.bam

```

cd /mnt/output/${alignment_version}

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
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis /mnt/splicedice_ir_example/analysis/

```

Exit python environments if you're in one

```
deactivate
```

## Download repo

```
SHA1=da045c486e314e6f7db253998d886a163172295b
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 
cd splicedice

```



show current state of repo

```
git rev-parse --short HEAD
```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ git rev-parse --short HEAD
28875c0
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
Successfully built splicedice
Installing collected packages...
Successfully installed ...
Collecting pysam...
Installing collected packages: pysam
Successfully installed pysam-0.23.3
{"status":"OK","nsent":2,"apilimit":"1\/1000"}

usage: splicedice [-h]
                  {bam_to_junc_bed,quant,intron_coverage,ir_table,compare_sample_sets,pairwise,findOutliers,subset,similarity,select,counts_to_ps}
                  ...

```



## Copy and modify bam manifest

modify javier's manifest to use current bam paths

```
a=/mnt/mustard_scratch/erj_public/Jurica_SSA/scripts/Manifest_file.txt
b=/mnt/data/bams/javier_erj_jurica_ssa/javier_erj_jurica_ssa_bam_manifest.txt

paste <( cut -f1 $a) <(cut -f2 $b) <(cut -f3-4 $a) > /mnt/splicedice_ir_example/analysis/bam_manifest.txt


```



## Find junctions in bam files

```
cd /mnt/splicedice_ir_example/analysis

genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
genes=/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf
here=/mnt/splicedice_ir_example/analysis/

time splicedice bam_to_junc_bed \
-m bam_manifest.txt \
-o $here \
--genome $genome \
--annotation $genes \
--number_threads 4
~/alert_msg.sh "bam_to_junc_bed complete"


```



std out

```
...
saved to bed: /mnt/splicedice_ir_example/analysis/_junction_beds/SSA103_S77.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/data/bams/javier_erj_jurica_ssa/S78_SSA_104/SSA104_S78.filteredAligned.sortedByCoord.out.bam
number of junctions found: 581521
saved to bed: /mnt/splicedice_ir_example/analysis/_junction_beds/SSA104_S78.filteredAligned.sortedByCoord.out.junc.bed
new manifest written to: /mnt/splicedice_ir_example/analysis/_manifest.txt

real    33m35.181s
user    125m47.642s
sys     1m46.595s
{"status":"OK","nsent":2,"apilimit":"2\/1000"}
```

outputs

```
_manifest.txt
_junction_beds/

```



### compare outputs 

updated; run these next when bam_to_bed is done

```
old_base=/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/bamtobed/
new_base=/mnt/splicedice_ir_example/analysis/
cat /mnt/splicedice_ir_example/analysis/bam_manifest.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/_junction_beds/$bed_file_name
old=${old_base}/SSA_junction_beds/$bed_file_name

echo $bed_file_name
diff --report-identical-files $old $new | sed 's/^.*identical/identical/'
done
```





finding: results are identical

duration: 34 min

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

