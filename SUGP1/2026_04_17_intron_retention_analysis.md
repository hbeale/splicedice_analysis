

# Goals

* generate a stable example of  running the intron retention portion of the splicedice code with IP



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
/dev/vdb1       2.0T  1.4T  631G  70% /mnt
```



## Check reference files

```
ls /mnt/ref/GRCh38.primary_assembly.genome.fa
ls /mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```

if they are not present, obtain them as described in https://github.com/hbeale/splicedice_analysis/blob/main/misc/reference_file_sources.md



# Reset from any previous runs

Confirm example directory space is empty

```
ls -alth /mnt/splicedice_example/ /mnt/splicedice_ir_example
```

delete if it's not

```
rm -r /mnt/splicedice_example/
sudo rm -r /mnt/splicedice_ir_example/
```

Exit python environments if one is active

```
deactivate
```

# 



## Download repo

### splicedice_analysis

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/hbeale/splicedice_analysis.git


```



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -t splicedice_analysis:latest .
```

completed without error



# Run intron prospector

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-04-21_19-37-42/
```

## launch docker

```
sudo docker run -it --rm \
-v /mnt:/mnt \
splicedice_analysis:latest /bin/bash
```

```
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=/mnt/data/intron_prospector_runs/2026-04-21_19-37-42/
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
201886 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801019.bed
219896 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801020.bed
204840 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801023.bed
219369 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801024.bed
212111 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801027.bed
222909 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801028.bed

```



expected lines: 

we saw around 150,000 in the TCGA data

with problematic data, there were around 1500 junctions detected



# splicedice quant

## make bed manifest

```
bed_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bed_manifest.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
out_base=/mnt/data/intron_prospector_runs/2026-04-21_19-37-42/

cat $phenotypes | while read id pheno ; do
# echo id is $id pheno is $pheno
echo -e "$id\t${out_base}${id}.bed\t$pheno"
done > $bed_manifest
```


## Quantify splice junction usage - attempt 1

```
ls -alth /mnt/splicedice_ir_example/analysis/
```



```
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
```

### something went wrong - no output

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/intron_prospector_runs$ sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 6 files...
        Done [0:00:2.30]
Finding clusters from 0 junctions...
        Done [0:00:0.00]
Writing cluster file...
        Done [0:00:0.00]
Writing junction bed file...
        Done [0:00:0.00]
Gathering junction counts...
        Done [0:00:2.65]
Writing inclusion counts...
        Done [0:00:0.00]
Calculating PS values...
        Done [0:00:0.00]
Writing PS values...
        Done [0:00:0.00]
All done [0:00:4.95]
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/intron_prospector_runs$ ls -alth /mnt/splicedice_ir_example/analysis/
total 8.0K
drwxrwxr-x 2 ubuntu ubuntu 98 Apr 21 19:59 .
-rw-r--r-- 1 root   root   68 Apr 21 19:59 _allPS.tsv
-rw-r--r-- 1 root   root   68 Apr 21 19:59 _inclusionCounts.tsv
-rw-r--r-- 1 root   root    0 Apr 21 19:59 _junctions.bed
-rw-r--r-- 1 root   root    0 Apr 21 19:59 _allClusters.tsv
drwxrwxr-x 4 ubuntu ubuntu 38 Apr 21 19:34 ..
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/intron_prospector_runs$ head /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801019.bed
chr1    14829   14969   sj1     97      .
chr1    15038   15795   sj2     64      .
chr1    15947   16606   sj6     4       .
chr1    16765   16857   sj8     64      .
chr1    17055   17232   sj10    125     .
chr1    17055   17605   sj11    15      .
chr1    17368   17525   sj13    2       .
chr1    17368   17605   sj12    109     .
chr1    17525   188049  sj14    22      .
chr1    17742   17914   sj16    159     .
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/intron_prospector_runs$ 
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ cat $bed_manifest 
SRR12801019     /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801019.bed    control
SRR12801020     /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801020.bed    SUGP1_kd
SRR12801023     /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801023.bed    control
SRR12801024     /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801024.bed    SUGP1_kd
SRR12801027     /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801027.bed    control
SRR12801028     /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801028.bed    SUGP1_kd
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ 

```



## try with different sequence data  - attempt 2 - succeeds



### Run splicedice quant

```

bed_manifest=/mnt/splicedice_example_archives/2026.04.02_16.27.36/analysis/bed_manifest.tsv
quant_out=/mnt/scratch/splicedice_example/analysis/2026.04.21_13.20.15/

sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o $quant_out
```

std out

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o $quant_out
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 46 files...
        Done [0:00:21.69]
Finding clusters from 396672 junctions...
        Done [0:00:5.49]
Writing cluster file...
        Done [0:00:8.44]
Writing junction bed file...
        Done [0:00:2.53]
Gathering junction counts...
        Done [0:00:30.61]
Writing inclusion counts...
        Done [0:00:21.14]
Calculating PS values...
        Done [0:00:23.64]
Writing PS values...
        Done [0:00:22.47]
All done [0:02:16.01]
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ head $quant_out/_allPS.tsv | cut -f1-5
cluster TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16    TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981    TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2    TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b
chr1:14696-185174:-     0.000   0.000   0.000   0.000
chr1:14830-14969:-      nan     nan     nan     nan
chr1:14830-15020:-      nan     nan     nan     nan
chr1:14830-15795:-      0.000   0.000   0.000   0.000
chr1:14844-14969:-      nan     nan     nan     nan
chr1:15013-25232:+      nan     nan     nan     1.000
chr1:15039-15795:-      1.000   1.000   1.000   1.000
chr1:15948-16606:-      1.000   1.000   1.000   1.000
chr1:16311-16606:-      0.000   0.000   0.000   0.000


```

contains data, and looks right 



### compare bed files

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ head /mnt/data/intron_prospector_runs/2026-04-01_21-53-28/TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981.bed 
chr1    15038   15795   sj1     26      -
chr1    15947   16606   sj2     6       -
chr1    16765   16857   sj3     23      -
chr1    17055   17232   sj4     60      -
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ head /mnt/data/intron_prospector_runs/2026-04-21_19-37-42/SRR12801020.bed
chr1    14829   14969   sj2     176     .
chr1    14829   15020   sj3     3       .
chr1    15038   15795   sj4     93      .
chr1    15038   16606   sj5     2       .
chr1    15246   185761  sj7     2       .

```



is the difference the dots? 



see if it works with `splicedice-dev`

## try IP with old splicedice  - attempt 3 - fails



```
mkdir -p /mnt/splicedice_example/git_code /mnt/splicedice_example/analysis
cd /mnt/scratch
git clone https://github.com/pRottinghuis/splicedice-dev.git
cd splicedice-dev
sudo docker build -t splicedice-dev_with_ip_branch_v1.4.0:latest .

```



###  Run intron prospector

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-04-21_21-31-31/
```

###  launch docker

```
sudo docker run -it --rm \
-v /mnt:/mnt \
splicedice-dev_with_ip_branch_v1.4.0:latest /bin/bash
```

version

```
root@0e0af24082f3:/opt# intronProspector --version
intronProspector 1.4.0 https://github.com/diekhans/intronProspector
```

```
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=/mnt/data/intron_prospector_runs/2026-04-21_21-31-31/
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
201886 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801019.bed
219896 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801020.bed
204840 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801023.bed
219369 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801024.bed
212111 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801027.bed
222909 /mnt/data/intron_prospector_runs/2026-04-21_19-37-42//SRR12801028.bed

```

### run quant

#### make bed manifest

```
bed_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bed_manifest_2026-04-21_21-31-31.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
out_base=/mnt/data/intron_prospector_runs/2026-04-21_21-31-31/

cat $phenotypes | while read id pheno ; do
# echo id is $id pheno is $pheno
echo -e "$id\t${out_base}${id}.bed\t$pheno"
done > $bed_manifest
```


#### Quantify splice junction usage

```
ls -alth /mnt/splicedice_ir_example/analysis/
```



```
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice-dev_with_ip_branch_v1.4.0:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
```

### 



still didn't generate meaningful output

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch/splicedice-dev$ sudo docker run --rm \
-v /mnt/:/mnt \
splicedice-dev_with_ip_branch_v1.4.0:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 6 files...
        Done [0:00:2.44]
Finding clusters from 0 junctions...
        Done [0:00:0.00]
Writing cluster file...
        Done [0:00:0.00]
Writing junction bed file...
        Done [0:00:0.00]
Gathering junction counts...
        Done [0:00:2.68]
Writing inclusion counts...
        Done [0:00:0.00]
Calculating PS values...
        Done [0:00:0.00]
Writing PS values...
        Done [0:00:0.00]
All done [0:00:5.12]
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch/splicedice-dev$ head /mnt/data/intron_prospector_runs/2026-04-21_21-31-31/SRR12801019.bed
chr1    14829   14969   sj1     97      .
chr1    15038   15795   sj2     64      .
chr1    15947   16606   sj6     4       .
chr1    16765   16857   sj8     64      .
chr1    17055   17232   sj10    125     .
chr1    17055   17605   sj11    15      .
chr1    17368   17525   sj13    2       .
chr1    17368   17605   sj12    109     .
chr1    17525   188049  sj14    22      .
chr1    17742   17914   sj16    159     .
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch/splicedice-dev$ 
```

## attempt 4: use old seq data and change "-" and "+" in working data to "."

hypothesis: it's the strand at issue. if that's the case, i expect this to fail

result = yes, it's the strand at issue



### change bed files 

make sure TCGA ids are unique

```
cat $bed_manifest | cut -f2 | sed 's/^.*TCGA/TCGA/' | cut -c1-12 | wc -l
cat $bed_manifest | cut -f2 | sed 's/^.*TCGA/TCGA/' | cut -c1-12 | sort | uniq | wc -l
```



```

new_out_dir=/mnt/scratch/2026.04.22_09.32.16/; mkdir -p $new_out_dir
bed_manifest=/mnt/splicedice_example_archives/2026.04.02_16.27.36/analysis/bed_manifest.tsv
rm -fr $new_out_dir/bed_manifest.tsv
cat $bed_manifest | cut -f2,3 | while read bed_file pheno; 
do 
TCGA_id=`echo $bed_file | sed 's/^.*TCGA/TCGA/' | cut -c1-12`
echo $TCGA_id
sed 's/\t[+-]$/\t./' $bed_file > $new_out_dir/${TCGA_id}.bed
# head $new_out_dir/${TCGA_id}.bed
# head $bed_file
echo -e "$TCGA_id\t$new_out_dir/${TCGA_id}.bed\t$pheno" >> $new_out_dir/bed_manifest.tsv
done

```

check output

```
head $new_out_dir/bed_manifest.tsv
head /mnt/scratch/2026.04.22_09.32.16//TCGA-67-6215.bed 
```



### Run splicedice quant

```
bed_manifest=$new_out_dir/bed_manifest.tsv
quant_out=/mnt/scratch/2026.04.22_09.32.16/

sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o $quant_out
```

std out

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch/splicedice-dev$ bed_manifest=$new_out_dir/bed_manifest.tsv
quant_out=/mnt/scratch/2026.04.22_09.32.16/

sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o $quant_out
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 46 files...
        Done [0:00:13.01]
Finding clusters from 0 junctions...
        Done [0:00:0.00]
Writing cluster file...
        Done [0:00:0.00]
Writing junction bed file...
        Done [0:00:0.00]
Gathering junction counts...
        Done [0:00:15.45]
Writing inclusion counts...
        Done [0:00:0.00]
Calculating PS values...
        Done [0:00:0.00]
Writing PS values...
        Done [0:00:0.00]
All done [0:00:28.46]


```

contains data, and looks right 

# RESUME TROUBLESHOOTING HERE

### 

# RESUME HERE

## 

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/intron_prospector_runs$ ls -alth /mnt/splicedice_ir_example/analysis/
total 0
drwxrwxr-x 2 ubuntu ubuntu  6 Apr 21 19:34 .
drwxrwxr-x 4 ubuntu ubuntu 38 Apr 21 19:34 ..
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/intron_prospector_runs$ sudo docker run --rm \

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





# Calculate intron_coverage

## make bam manifest

```
bam_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bam_manifest.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
alignment_version=star_2.7.11b_2026.04.16

cat $phenotypes | while read id pheno ; do
# echo id is $id pheno is $pheno
bam_file=/mnt/output/${alignment_version}/$id/${id}_Aligned.sortedByCoord.out.bam
echo -e "$id\t$bam_file\t$pheno\t$pheno"
done > $bam_manifest
```

## 

## intron_coverage

```
base_dir=/mnt/splicedice_ir_example/analysis
bam_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bam_manifest.tsv

sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice intron_coverage \
-b $bam_manifest \
-m ${base_dir}/_allPS.tsv \
-j ${base_dir}/_junctions.bed \
-n 6 \
-o ${base_dir}/coverage_output

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

# Generate inclusion count table

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





# Cleanup and archive



```
deactivate 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```



/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/

