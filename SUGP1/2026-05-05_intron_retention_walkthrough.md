

# 2026-05-05_intron_retention_walkthrough



# Goals

* demonstrate a stable example of  running the intron retention portion of the splicedice code with IP



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
/dev/vdb1       2.0T  1.5T  607G  71% /mnt
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

differs from previous attempts because the command omits "-S" per https://brooks-lab.slack.com/archives/C5XLQGPHV/p1776902373087839?thread_ts=1776878443.042789&cid=C5XLQGPHV



create directories

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
ip_run_dir=/mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-05-05_20-28-22
```

document IP version

```
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

```

std out

```
intron-prospector 1.5.1 https://github.com/diekhans/intron-prospector
```



run ip

```
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=${ip_run_dir}
alignment_version=star_2.7.11b_2026.04.16

```



```
for id in $ids; do

bam_file=/mnt/output/${alignment_version}/$id/${id}.bam

echo echo id is $id
echo bam file is $bam_file
echo output will be $out_base/${id}.bed

sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$out_base/${id}.bed \
$bam_file

done
bash /mnt/scratch/alert_msg.sh intron_prospector_complete 

```



```
wc -l $out_base/${id}.bed
head $out_base/${id}.bed
```

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ wc -l $out_base/${id}.bed
219717 /mnt/data/intron_prospector_runs/2026-05-05_20-28-22//SRR12801028.bed
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ head $out_base/${id}.bed
chr1    14829   14969   sj0_GT/AG       201     -
chr1    15038   15795   sj3_GT/AG       127     -
chr1    15059   15795   sj5_GT/AG       3       -
chr1    15947   16606   sj8_GT/AG       8       -
chr1    16310   16606   sj9_GT/AG       13      -
chr1    16765   16857   sj10_GT/AG      28      -
chr1    17055   17232   sj11_GT/AG      261     -
chr1    17055   17605   sj12_GT/AG      11      -
chr1    17368   17525   sj16_GT/AG      16      -
chr1    17368   17605   sj15_GT/AG      213     -

```



# splicedice quant

## make bed manifest

```
bed_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bed_manifest_${TS}.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
out_base=/mnt/data/intron_prospector_runs/${TS}/

cat $phenotypes | while read id pheno ; do
echo -e "$id\t${out_base}${id}.bed\t$pheno"
done > $bed_manifest

cat $bed_manifest

```

std out

```
SRR12801019     /mnt/data/intron_prospector_runs/2026-05-05_20-28-22/SRR12801019.bed    control
SRR12801020     /mnt/data/intron_prospector_runs/2026-05-05_20-28-22/SRR12801020.bed    SUGP1_kd
SRR12801023     /mnt/data/intron_prospector_runs/2026-05-05_20-28-22/SRR12801023.bed    control
SRR12801024     /mnt/data/intron_prospector_runs/2026-05-05_20-28-22/SRR12801024.bed    SUGP1_kd
SRR12801027     /mnt/data/intron_prospector_runs/2026-05-05_20-28-22/SRR12801027.bed    control
SRR12801028     /mnt/data/intron_prospector_runs/2026-05-05_20-28-22/SRR12801028.bed    SUGP1_kd
```





## Quantify splice junction usage

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
drwxrwxr-x 2 ubuntu ubuntu  6 May  5 20:21 .
drwxrwxr-x 4 ubuntu ubuntu 38 May  5 20:21 ..

```



```
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 6 files...
        Done [0:00:4.24]
Finding clusters from 333069 junctions...
        Done [0:00:3.73]
Writing cluster file...
        Done [0:00:3.71]
Writing junction bed file...
        Done [0:00:2.36]
Gathering junction counts...
        Done [0:00:6.08]
Writing inclusion counts...
        Done [0:00:5.12]
Calculating PS values...
        Done [0:00:8.71]
Writing PS values...
        Done [0:00:5.30]
All done [0:00:39.25]
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 
```







```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ ls -alth /mnt/splicedice_ir_example/analysis/
total 87M
-rw-r--r-- 1 root   root   20M May  5 21:07 _allPS.tsv
drwxrwxr-x 2 ubuntu ubuntu  98 May  5 21:07 .
-rw-r--r-- 1 root   root   14M May  5 21:07 _inclusionCounts.tsv
-rw-r--r-- 1 root   root   18M May  5 21:07 _junctions.bed
-rw-r--r-- 1 root   root   37M May  5 21:07 _allClusters.tsv
drwxrwxr-x 4 ubuntu ubuntu  38 May  5 20:21 ..
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```



# Calculate intron_coverage

## make bam manifest

```
bam_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bam_manifest.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
alignment_version=star_2.7.11b_2026.04.16

cat $phenotypes | while read id pheno ; do
# echo id is $id pheno is $pheno
bam_file=/mnt/output/${alignment_version}/$id/${id}.bam
echo -e "$id\t$bam_file\t$pheno\t$pheno"
done > $bam_manifest

cat $bam_manifest
```

std out

```
SRR12801019     /mnt/output/star_2.7.11b_2026.04.16/SRR12801019/SRR12801019.bam control control
SRR12801020     /mnt/output/star_2.7.11b_2026.04.16/SRR12801020/SRR12801020.bam SUGP1_kd        SUGP1_kd
SRR12801023     /mnt/output/star_2.7.11b_2026.04.16/SRR12801023/SRR12801023.bam control control
SRR12801024     /mnt/output/star_2.7.11b_2026.04.16/SRR12801024/SRR12801024.bam SUGP1_kd        SUGP1_kd
SRR12801027     /mnt/output/star_2.7.11b_2026.04.16/SRR12801027/SRR12801027.bam control control
SRR12801028     /mnt/output/star_2.7.11b_2026.04.16/SRR12801028/SRR12801028.bam SUGP1_kd        SUGP1_kd

```



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

bash /mnt/scratch/alert_msg.sh intron_coverage_complete 

```

```
bash /mnt/scratch/alert_msg.sh intron_coverage_complete 
getting paths for bam files
creating junction percentiles
SRR12801019 starting 5.78981614112854
SRR12801019 collected 764.0202257633209
SRR12801019 counted 1499.732224702835
SRR12801019 done 1516.1809346675873
SRR12801023 starting 7.480536460876465
SRR12801023 collected 852.4540610313416
SRR12801023 counted 1615.712028503418
SRR12801023 done 1631.7985084056854
SRR12801024 starting 8.271928310394287
SRR12801024 collected 1014.5133769512177
SRR12801024 counted 1795.4695270061493
SRR12801024 done 1811.6707293987274
SRR12801028 starting 9.826818227767944
SRR12801028 collected 991.7477378845215
SRR12801028 counted 1842.5847833156586
SRR12801028 done 1858.4821002483368
SRR12801027 starting 9.06928825378418
SRR12801027 collected 999.4874250888824
SRR12801027 counted 1890.870949268341
SRR12801027 done 1906.8732109069824
Your runtime was 1917.9056751728058 seconds.

```



```
ls -alth /mnt/splicedice_ir_example/analysis/
```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ ls -alth /mnt/splicedice_ir_example/analysis/
total 87M
drwxr-xr-x 2 root   root   240 May  5 21:41 coverage_output
drwxrwxr-x 3 ubuntu ubuntu 121 May  5 21:09 .
-rw-r--r-- 1 root   root   20M May  5 21:07 _allPS.tsv
-rw-r--r-- 1 root   root   14M May  5 21:07 _inclusionCounts.tsv
-rw-r--r-- 1 root   root   18M May  5 21:07 _junctions.bed
-rw-r--r-- 1 root   root   37M May  5 21:07 _allClusters.tsv
drwxrwxr-x 4 ubuntu ubuntu  38 May  5 20:21 ..
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```



### Generate inclusion count table

```
this_docker=splicedice_analysis:latest
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
sudo docker run --rm \
-v /mnt/:/mnt \
$this_docker \
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/

bash /mnt/scratch/alert_msg.sh intron_table_creation_complete 


```

std out

```
/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Gathering inclusion counts and clusters...
Calculating IR values...
Done 161.63768029212952
Writing output...


```

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ ls -alth /mnt/splicedice_ir_example/analysis/
total 92M
-rw-r--r-- 1 root   root   2.9M May  5 21:47 _intron_retention_RSD.tsv
drwxrwxr-x 3 ubuntu ubuntu  183 May  5 21:47 .
-rw-r--r-- 1 root   root   2.9M May  5 21:47 _intron_retention.tsv
drwxr-xr-x 2 root   root    240 May  5 21:41 coverage_output
-rw-r--r-- 1 root   root    20M May  5 21:07 _allPS.tsv
-rw-r--r-- 1 root   root    14M May  5 21:07 _inclusionCounts.tsv
-rw-r--r-- 1 root   root    18M May  5 21:07 _junctions.bed
-rw-r--r-- 1 root   root    37M May  5 21:07 _allClusters.tsv
drwxrwxr-x 4 ubuntu ubuntu   38 May  5 20:21 ..
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 
```



# sort intron_retention results

```

cd /mnt/splicedice_ir_example/analysis/
cat _intron_retention.tsv  | head -1 > _intron_retention.sorted.tsv
cat _intron_retention.tsv | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n |  cut -f1 -d":" | uniq
cat _intron_retention.tsv | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n >> _intron_retention.sorted.tsv

```

 # Find a few interesting examples

```
R
library(tidyverse)
ir <- read_tsv("/mnt/splicedice_ir_example/analysis/_intron_retention.tsv")
ir_longer <- ir %>% pivot_longer(-Junction) %>% mutate(group = ifelse(name %in% c("SRR12801019", "SRR12801023", "SRR12801027"), "control", "kd"))
ir_jxn_group_sum <- ir_longer %>% group_by(Junction, group) %>% summarize(mean_group_val = mean(value))
ir_jxn <- ir_jxn_group_sum %>% 
group_by(Junction) %>% 
summarize(
abs_increase_in_ir = mean_group_val[group == "kd"] - mean_group_val[group == "control"], 
fold_increase_in_ir = mean_group_val[group == "kd"]/mean_group_val[group == "control"]
)

ir_jxn %>% arrange(desc(abs_increase_in_ir)) %>% head
ir %>% filter(Junction == "chr6:31944854-31944979:+") %>% select(-Junction)
ir %>% filter(Junction == "chr12:94282402-94294485:+") %>% select(-Junction)
```





# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

cp -R /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.05.05_20.12.55/



