

# 2026-05-14_intron_retention_strand_fix.md



# Goals

* only introns on the positive strand appear in _intron_retention.tsv, but introns on both strands appear in the sample-specific _intron_coverage.txt files. Try to fix this, and see how the results change.



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
/dev/vdb1       2.0T  1.6T  505G  76% /mnt
```

## Check reference files

```
ls /mnt/ref/GRCh38.primary_assembly.genome.fa
ls /mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```

if they are not present, obtain them as described in https://github.com/hbeale/splicedice_analysis/blob/main/misc/reference_file_sources.md



# Make a copy of existing data

(I'm working from the output of 2026-05-05_intron_retention_walkthrough.md, so I'm going to stash a copy)

```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

cp -R /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.05.14_21.01.48/



## Download repo

### splicedice_analysis

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis
cd /mnt/splicedice_ir_example/git_code
# git clone https://github.com/hbeale/splicedice_analysis.git
git pull


```



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
# docker build -t splicedice_analysis:latest .
docker build -f Dockerfile_include_negative_strand_introns -t splicedice_analysis:latest  .
```

completed without error





# Calculate intron_coverage

## intron_coverage

```
base_dir=/mnt/splicedice_ir_example/analysis
bam_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bam_manifest.tsv

docker run --rm \
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





# 

```
getting paths for bam files
creating junction percentiles
SRR12801019 starting 5.030228137969971
SRR12801019 collected 669.7956454753876
SRR12801019 counted 1324.6302309036255
SRR12801019 done 1338.96710729599
SRR12801023 starting 6.502277851104736
SRR12801023 collected 695.1016933917999
SRR12801023 counted 1358.8561520576477
SRR12801023 done 1372.7720515727997
SRR12801024 starting 7.2598254680633545
SRR12801024 collected 808.1289699077606
SRR12801024 counted 1522.3234629631042
SRR12801024 done 1536.3319182395935
SRR12801028 starting 8.646437644958496
SRR12801028 collected 866.7798347473145
SRR12801028 counted 1633.6519515514374
SRR12801028 done 1647.4408512115479
SRR12801027 starting 7.962236642837524
SRR12801027 collected 830.3708031177521
SRR12801027 counted 1640.1329731941223
SRR12801027 done 1654.2178111076355
Your runtime was 1671.900325536728 seconds.
{"status":"OK","nsent":2,"apilimit":"0\/1000"}


```



```
ls -alth /mnt/splicedice_ir_example/analysis/coverage_output
```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ ls -alth /mnt/splicedice_ir_example/analysis/coverage_output
total 169M
-rw-r--r-- 1 root   root   29M May 14 21:45 SRR12801020_intron_coverage.txt
-rw-r--r-- 1 root   root   29M May 14 21:44 SRR12801027_intron_coverage.txt
-rw-r--r-- 1 root   root   29M May 14 21:44 SRR12801028_intron_coverage.txt
-rw-r--r-- 1 root   root   29M May 14 21:43 SRR12801024_intron_coverage.txt
-rw-r--r-- 1 root   root   29M May 14 21:40 SRR12801023_intron_coverage.txt
-rw-r--r-- 1 root   root   29M May 14 21:39 SRR12801019_intron_coverage.txt
drwxrwxr-x 3 ubuntu ubuntu 259 May  6 00:08 ..
drwxr-xr-x 2 root   root   240 May  5 21:41 .
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 


```



### Generate inclusion count table

```
this_docker=splicedice_analysis:latest
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
docker run --rm \
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
/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:121: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Gathering inclusion counts and clusters...
Calculating IR values...
Done 204.63945484161377
Writing output...
{"status":"OK","nsent":2,"apilimit":"1\/1000"}

```

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ ls -alth /mnt/splicedice_ir_example/analysis/
total 101M
-rw-r--r-- 1 root   root   5.7M May 14 22:27 _intron_retention_RSD.tsv
-rw-r--r-- 1 root   root   5.7M May 14 22:27 _intron_retention.tsv
...

```

## Assess results

```
old=/mnt/splicedice_ir_example_archives/2026.05.14_21.01.48/analysis/_intron_retention.tsv
new=/mnt/splicedice_ir_example/analysis/_intron_retention.tsv

```



### are there + and - strand results?

```

echo old
cat $old | cut -f1 | grep -v Junction |  sed 's/.*\(.\)$/\1/'  | sort | uniq -c
echo new
cat $new | cut -f1 | grep -v Junction |  sed 's/.*\(.\)$/\1/'  | sort | uniq -c

```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ 
echo old
cat $old | cut -f1 | grep -v Junction |  sed 's/.*\(.\)$/\1/'  | sort | uniq -c
echo new
cat $new | cut -f1 | grep -v Junction |  sed 's/.*\(.\)$/\1/'  | sort | uniq -c
old
  48488 +
new
  48488 +
  47911 -
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ 

```





## compare intron_retention results to previous version

```

cat $new | grep ":+" | head 
head $old

```



from a spot-check, these look identical



# sort intron_retention results

```

cd /mnt/splicedice_ir_example/analysis/
cat _intron_retention.tsv  | head -1 > _intron_retention.sorted.tsv
cat _intron_retention.tsv | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n |  cut -f1 -d":" | uniq
cat _intron_retention.tsv | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n >> _intron_retention.sorted.tsv

f_old=_intron_retention_RSD.tsv
f_sorted=_intron_retention_RSD.sorted.tsv
cat $f_old  | head -1 > $f_sorted
cat _intron_retention.tsv | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n |  cut -f1 -d":" | uniq
cat $f_old | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n >> $f_sorted

```

 # Find a few interesting examples on the minus strand

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
ir_jxn_neg <- ir_jxn %>%
filter(str_detect(Junction, ":-$"))
ir_jxn_neg %>% arrange(desc(abs_increase_in_ir)) %>% head

# does ir table include junctions with no IR?
ir %>% mutate(total = rowSums(pick(where(is.numeric), -Junction))) %>% head
> ir %>% mutate(total = rowSums(pick(where(is.numeric), -Junction)))  %>% filter(total == 0) %>% nrow
[1] 17


```





# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

cp -R /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.05.05_20.12.55/



