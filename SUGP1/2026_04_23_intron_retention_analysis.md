

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

differs from previous attempts because the command omits "-S" per https://brooks-lab.slack.com/archives/C5XLQGPHV/p1776902373087839?thread_ts=1776878443.042789&cid=C5XLQGPHV

```
TS=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p /mnt/data/intron_prospector_runs/"$TS"/
echo /mnt/data/intron_prospector_runs/"$TS"/
```

```
/mnt/data/intron_prospector_runs/2026-04-23_17-01-15/
```

## launch docker

```
sudo docker run -it --rm \
-v /mnt:/mnt \
splicedice_analysis:latest /bin/bash
```

```
intronProspector -v
```

```
root@b5daef20ab80:/opt# intronProspector -v
=====
===== Notice: intronProspector has been renamed to intron-prospector
===== support for the old name will be removed in a future release 
=====
intron-prospector 1.5.0 https://github.com/diekhans/intronProspector
root@b5daef20ab80:/opt# 
```



```
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa
out_base=/mnt/data/intron_prospector_runs/2026-04-23_17-01-15/
alignment_version=star_2.7.11b_2026.04.16

for id in $ids; do
bam_file=/mnt/output/${alignment_version}/$id/${id}_Aligned.sortedByCoord.out.bam
echo echo id is $id
echo bam file is $bam_file
echo output will be $out_base/${id}.bed
intronProspector --genome-fasta=$genome \
--intron-bed6=$out_base/${id}.bed \
$bam_file

done
bash /mnt/scratch/alert_msg.sh intron_prospector_complete # doesn't work in this docker

```



### sanity check

```
for id in $ids; do
wc -l $out_base/${id}.bed
done
```

std out

```
199521 /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801019.bed
216428 /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801020.bed
202382 /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801023.bed
216536 /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801024.bed
209183 /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801027.bed
219717 /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801028.bed

```



expected lines: 

we saw around 150,000 in the TCGA data

with problematic data, there were around 1500 junctions detected



confirm that junctions are stranded

```
root@b5daef20ab80:/opt# head  /mnt/data/intron_prospector_runs/2026-04-23_17-01-15//SRR12801019.bed
chr1    14829   14969   sj0_GT/AG       97      -
chr1    15038   15795   sj1_GT/AG       64      -
chr1    15947   16606   sj4_GT/AG       4       -
chr1    16765   16857   sj6_GT/AG       64      -
chr1    17055   17232   sj7_GT/AG       125     -
chr1    17055   17605   sj8_GT/AG       15      -
chr1    17368   17525   sj10_GT/AG      2       -
chr1    17368   17605   sj9_GT/AG       109     -
chr1    17525   188049  sj11_GT/AG      22      -
chr1    17742   17914   sj13_GT/AG      159     -
root@b5daef20ab80:/opt# 
```





# splicedice quant

## make bed manifest

```
bed_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bed_manifest_2026-04-23_17-01-15.tsv
phenotypes=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/id_phenotype.txt
out_base=/mnt/data/intron_prospector_runs/2026-04-23_17-01-15/

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
ubuntu@hbeale-mesa:~$ sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 6 files...
        Done [0:00:3.57]
Finding clusters from 333069 junctions...
        Done [0:00:3.35]
Writing cluster file...
        Done [0:00:3.17]
Writing junction bed file...
        Done [0:00:2.07]
Gathering junction counts...
        Done [0:00:5.28]
Writing inclusion counts...
        Done [0:00:4.34]
Calculating PS values...
        Done [0:00:7.22]
Writing PS values...
        Done [0:00:4.49]
All done [0:00:33.49]
ubuntu@hbeale-mesa:~$ 
[ hbeale-mesa ][help: <ESC> to copy/scroll][         


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

expected duration: 1 hour with 4 cores, 40 min with 6

std out

```
ubuntu@hbeale-mesa:~$ sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice intron_coverage \
-b $bam_manifest \
-m ${base_dir}/_allPS.tsv \
-j ${base_dir}/_junctions.bed \
-n 6 \
-o ${base_dir}/coverage_output

bash /mnt/scratch/alert_msg.sh intron_coverage_complete 
getting paths for bam files
creating junction percentiles
SRR12801019 starting 5.168574571609497
SRR12801019 collected 646.5082108974457
SRR12801019 counted 1292.172986984253
SRR12801019 done 1306.819598197937
SRR12801023 starting 6.569854497909546
SRR12801023 collected 676.583010673523
SRR12801023 counted 1342.231572151184
SRR12801023 done 1355.8899276256561
SRR12801024 starting 7.41332483291626
SRR12801024 collected 802.7375438213348
SRR12801024 counted 1478.8702547550201
SRR12801024 done 1492.9618923664093
SRR12801028 starting 8.798830270767212
SRR12801028 collected 803.678507566452
SRR12801028 counted 1548.7694425582886
SRR12801028 done 1562.9376533031464
SRR12801027 starting 8.152801036834717
SRR12801027 collected 783.6430282592773
SRR12801027 counted 1566.6011719703674
SRR12801027 done 1580.7536129951477
Your runtime was 1593.8625552654266 seconds.
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
ubuntu@hbeale-mesa:~$ 

```

# Generate inclusion count table

```
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/

```





expected duration, 5 min

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
sudo docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/
/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Gathering inclusion counts and clusters...
Calculating IR values...
cluster SRR12801019 GL000009.2:43357-48751:+
cluster SRR12801023 GL000009.2:43357-48751:+
cluster SRR12801024 GL000009.2:43357-48751:+
cluster SRR12801028 GL000009.2:43357-48751:+
cluster SRR12801027 GL000009.2:43357-48751:+
cluster SRR12801020 GL000009.2:43357-48751:+
Done 57.80865454673767
Writing output...
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ ls -alth


```



view files

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ ls -alth
total 87M
drwxr-xr-x 3 root   root   183 Apr 23 18:50 .
-rw-r--r-- 1 root   root    81 Apr 23 18:50 _intron_retention.tsv
-rw-r--r-- 1 root   root   105 Apr 23 18:50 _intron_retention_RSD.tsv
drwxrwxr-x 4 ubuntu ubuntu 116 Apr 23 18:34 ..
drwxr-xr-x 2 root   root   240 Apr 23 17:53 coverage_output
-rw-r--r-- 1 root   root   20M Apr 23 17:18 _allPS.tsv
-rw-r--r-- 1 root   root   14M Apr 23 17:18 _inclusionCounts.tsv
-rw-r--r-- 1 root   root   18M Apr 23 17:18 _junctions.bed
-rw-r--r-- 1 root   root   37M Apr 23 17:18 _allClusters.tsv
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ 

```



output

```
_intron_retention_RSD.tsv
_intron_retention.tsv
```





# Cleanup and archive



```
 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
sudo cp -r /mnt/splicedice_ir_example $this_archive_folder
```



/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/



# Troubleshooting no intron retention values

## review _intron_coverage.txt values



the "coverage_output/S68_SSA_intron_coverage.txt" values look similar; 



some coordinates are identical in the two files, so i think there are no off-by-one errors here

```
14829   14969
15038   15795
```



comparing analysis pre-intron prospector on javier's data



first values in chr1

```


ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/coverage_output$ cat SRR12801020_intron_coverage.txt | grep ^chr1 | head
chr1    12697   13220   .       0.0     +       12698,12827,12958,13089,13214   1,0,0,0,0
chr1    14737   15020   .       180.0   -       14738,14807,14878,14949,15017   180,319,24,20,230
chr1    14787   14977   .       34.0    -       14788,14834,14882,14929,14975   289,34,23,14,284
chr1    14829   14929   .       24.0    -       14830,14854,14879,14904,14928   42,30,24,16,14
chr1    14829   14969   .       23.0    -       14830,14864,14899,14934,14967   42,29,21,18,23
chr1    14829   15020   .       42.0    -       14830,14876,14924,14972,15018   42,24,13,281,230
chr1    15038   15795   .       38.0    -       15039,15227,15416,15605,15787   68,14,38,46,12
chr1    15038   16606   .       56.0    -       15039,15430,15822,16214,16590   68,37,68,56,42
chr1    15059   15795   .       37.0    -       15060,15243,15427,15611,15787   53,16,37,42,12
chr1    15225   185746  .       2.0     -       15226,57855,100485,143115,184040        14,0,0,2,2
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/coverage_output$ cat /mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/coverage_output/S68_SSA_intron_coverage.txt | grep ^chr1 | head
chr1    14829   14969   .       0.0     -       14830,14864,14899,14934,14967   3,2,0,0,0
chr1    15038   15795   .       1.0     -       15039,15227,15416,15605,15787   1,0,1,3,8
chr1    15947   16606   .       4.0     -       15948,16111,16276,16441,16599   0,0,4,6,11
chr1    16765   16853   .       0.0     +       16766,16787,16809,16831,16852   0,0,0,0,0
chr1    16765   16857   .       0.0     +       16766,16788,16811,16834,16856   0,0,0,0,0
chr1    17055   17232   .       0.0     -       17056,17099,17143,17187,17230   0,0,0,1,1
chr1    17055   17605   .       1.0     +       17056,17192,17330,17467,17599   0,1,12,3,1
chr1    17055   17605   .       1.0     -       17056,17192,17330,17467,17599   0,1,16,6,0
chr1    17055   17914   .       4.0     -       17056,17269,17484,17699,17905   0,16,4,12,0
chr1    17368   17605   .       3.0     -       17369,17427,17486,17545,17602   3,3,4,3,0

```



first high values in chr1

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/coverage_output$ cat /mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/coverage_output/S68_SSA_intron_coverage.txt | grep ^chr1 | awk '$5 > 200'  | head
chr1    629525  629870  .       5805.0  +       629526,629611,629697,629783,629866      0,7,17210,21077,5805
chr1    629851  629959  .       12421.0 -       629852,629878,629905,629932,629957      12421,14819,7539,12562,12225
chr1    629860  630379  .       362.0   -       629861,629989,630119,630249,630373      13863,10936,1,34,362
chr1    630044  631287  .       561.0   -       630045,630354,630665,630976,631274      6241,342,0,561,5332
chr1    630882  631309  .       1859.0  +       630883,630988,631095,631202,631304      912,12,1859,3891,2376
chr1    630882  631309  .       263.0   -       630883,630988,631095,631202,631304      784,263,118,148,5415
chr1    631181  631258  .       3576.0  +       631182,631200,631219,631238,631257      3544,3748,4369,3576,2695
chr1    631400  631505  .       362.0   -       631401,631426,631452,631478,631503      2188,446,362,257,253
chr1    633989  634049  .       15104.0 +       633990,634004,634019,634034,634048      19619,16656,15104,13097,8191
chr1    633989  634049  .       17672.0 -       633990,634004,634019,634034,634048      12583,15735,17672,18462,18846
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/coverage_output$ cat SRR12801020_intron_coverage.txt | grep ^chr1 | awk '$5 > 200' | head
chr1    999432  999691  .       331.0   -       999433,999496,999561,999626,999688      16,2,443,331,492
chr1    999613  999691  .       388.0   -       999614,999632,999652,999671,999690      321,363,388,482,536
chr1    999613  999865  .       444.0   -       999614,999676,999739,999802,999862      321,444,1496,637,29
chr1    999727  999865  .       793.0   -       999728,999761,999796,999830,999863      1531,1397,793,48,29
chr1    1338299 1338521 .       218.0   -       1338300,1338354,1338410,1338465,1338518 274,261,218,4,5
chr1    1374240 1374361 .       259.0   -       1374241,1374270,1374300,1374330,1374359 267,271,228,229,259
chr1    1390865 1391160 .       384.0   -       1390866,1390938,1391012,1391086,1391157 384,315,298,386,430
chr1    1390865 1391296 .       384.0   -       1390866,1390972,1391080,1391188,1391291 384,355,371,409,473
chr1    1390865 1391306 .       384.0   -       1390866,1390975,1391085,1391195,1391301 384,347,380,446,478
chr1    1390865 1391317 .       384.0   -       1390866,1390978,1391091,1391204,1391312 384,352,381,442,425
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/coverage_output$ 

```



## review _inclusion_counts.tsv

the coordinates are differnt

where there is chr1:14829-14969:- in the old file, now it is chr1:14830-14969:-



```
f=/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/_inclusionCounts.tsv
cat $f | grep ^chr1 | cut -f1-7 | head
f=/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/_inclusionCounts.tsv
cat $f | grep ^chr1 | cut -f1-7 | head

```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ f=/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/_inclusionCounts.tsv
cat $f | grep ^chr1 | cut -f1-7 | head
chr1:14829-14969:-      23      87      59      61      5       15
chr1:15038-15795:-      9       55      33      16      3       6
chr1:15947-16606:-      0       6       3       2       0       0
chr1:16765-16853:+      0       0       0       0       0       0
chr1:16765-16857:+      3       1       0       6       0       4
chr1:17055-17232:-      151     27      30      33      0       16
chr1:17055-17605:+      0       0       0       0       0       0
chr1:17055-17605:-      9       12      7       4       0       0
chr1:17055-17914:-      0       0       0       0       4       3
chr1:17368-17605:-      48      38      14      30      8       5
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ 
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ 
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ f=/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/_inclusionCounts.tsv
cat $f | grep ^chr1 | cut -f1-7 | head
chr1:12698-13220:+      0       0       2       0       0       0
chr1:14738-15020:-      0       0       0       0       6       0
chr1:14788-14977:-      0       0       0       2       0       0
chr1:14830-14929:-      0       0       2       4       0       0
chr1:14830-14969:-      97      176     115     169     157     201
chr1:14830-15020:-      0       3       0       0       0       0
chr1:15039-15795:-      64      93      63      92      85      127
chr1:15039-16606:-      0       2       0       0       0       0
chr1:15060-15795:-      0       0       0       0       0       3
chr1:15226-185746:-     0       0       30      19      0       0
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ 

```



## review _allClusters.tsv

coordinates in both columns are shifted (the first is increased by one; the second is unchanged)

```
f=/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/_allClusters.tsv 
cat $f | grep ^chr1 | cut -f1-7 | head
echo
f=/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/_allClusters.tsv 
cat $f | grep ^chr1 | cut -f1-7 | head

```



```
chr1:14829-14969:-
chr1:15038-15795:-
chr1:15947-16606:-
chr1:16765-16853:+      chr1:16765-16857:+
chr1:16765-16857:+      chr1:16765-16853:+
chr1:17055-17232:-      chr1:17055-17605:-,chr1:17055-17914:-
chr1:17055-17605:+
chr1:17055-17605:-      chr1:17055-17232:-,chr1:17055-17914:-,chr1:17368-17605:-
chr1:17055-17914:-      chr1:17055-17605:-,chr1:17055-17232:-,chr1:17368-17605:-,chr1:17742-17914:-
chr1:17368-17605:-      chr1:17055-17914:-,chr1:17055-17605:-

chr1:12698-13220:+
chr1:14738-15020:-      chr1:14788-14977:-,chr1:14830-14929:-,chr1:14830-14969:-,chr1:14830-15020:-
chr1:14788-14977:-      chr1:14738-15020:-,chr1:14830-14929:-,chr1:14830-14969:-,chr1:14830-15020:-
chr1:14830-14929:-      chr1:14788-14977:-,chr1:14738-15020:-,chr1:14830-14969:-,chr1:14830-15020:-
chr1:14830-14969:-      chr1:14830-14929:-,chr1:14788-14977:-,chr1:14738-15020:-,chr1:14830-15020:-
chr1:14830-15020:-      chr1:14830-14969:-,chr1:14830-14929:-,chr1:14788-14977:-,chr1:14738-15020:-
chr1:15039-15795:-      chr1:15039-16606:-,chr1:15060-15795:-,chr1:15226-185746:-
chr1:15039-16606:-      chr1:15039-15795:-,chr1:15060-15795:-,chr1:15226-185746:-,chr1:15948-16606:-,chr1:16028-16606:-,chr1:16311-16606:-
chr1:15060-15795:-      chr1:15039-16606:-,chr1:15039-15795:-,chr1:15226-185746:-

```



look at equivalent clusters that have "subclusters"

```

this_cluster_start_old_coords="chr1:17055"
this_cluster_start_new_coords="chr1:17056"
f=/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/_allClusters.tsv 
cat $f | grep ^${this_cluster_start_old_coords} | cut -f1-7 | head
echo
f=/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/_allClusters.tsv 
cat $f | grep ^${this_cluster_start_new_coords} | cut -f1-7 | head

```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ this_cluster_start_old_coords="chr1:17055"
this_cluster_start_new_coords="chr1:17056"
f=/mnt/splicedice_ir_example_archives/2025.12.04_17.56.06/analysis/_allClusters.tsv 
cat $f | grep ^${this_cluster_start_old_coords} | cut -f1-7 | head
echo
f=/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis/_allClusters.tsv 
cat $f | grep ^${this_cluster_start_new_coords} | cut -f1-7 | head
chr1:17055-17232:-      chr1:17055-17605:-,chr1:17055-17914:-
chr1:17055-17605:+
chr1:17055-17605:-      chr1:17055-17232:-,chr1:17055-17914:-,chr1:17368-17605:-
chr1:17055-17914:-      chr1:17055-17605:-,chr1:17055-17232:-,chr1:17368-17605:-,chr1:17742-17914:-

chr1:17056-17232:-      chr1:15226-185746:-,chr1:17056-17605:-
chr1:17056-17605:-      chr1:17056-17232:-,chr1:15226-185746:-,chr1:17369-17525:-,chr1:17369-17605:-,chr1:17526-188049:-
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2026.04.23_18.52.23/analysis$ 

```



## prompt to cluade

I'm running splicedice ir_table from https://public.gi.ucsc.edu/~hcbeale/splicedice/ and no inclusion counts are reported. I think it's an off-by-one issue. explain where ir_table gets coordinates to match data from its inputs



## Fix attempt 1

### 

```
The fix
In ir_table.py, change the cluster key construction to match the 1-based start used everywhere else:
python# Before:
cluster = f"{row[0]}:{row[1]}-{row[2]}:{row[5]}"

# After:
cluster = f"{row[0]}:{int(row[1])+1}-{row[2]}:{row[5]}"
```

### update docker to "update_coordinates_in_ir_table" branch

new Dockerfile



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ diff Dockerfile Dockerfile_2026.04.23_13.00.36 
11c11,13
< RUN git clone --depth 2 https://github.com/BrooksLabUCSC/splicedice.git splicedice \
---
> ARG BRANCH="update_coordinates_in_ir_table"
> 
> RUN git clone --branch $BRANCH --depth 2 https://github.com/BrooksLabUCSC/splicedice.git splicedice \
13d14
<  && git reset --hard $SHA1_splicedice \
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```



```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -f Dockerfile_2026.04.23_13.00.36 -t splicedice_analysis:2026.04.23_13.00.36 .
```

error

```
> [5/6] RUN git clone --depth 2       https://github.com/diekhans/intronProspector.git  && cd intronProspector  && git reset --hard ba9a26fe752175136562b75abc1d293cc7384fd6  && ./configure  && make -j$(nproc)  && make install  && cd /opt  && rm -rf intronProspector:                                                     
1.497 Cloning into 'intronProspector'...                                                                                                                        
2.543 fatal: Could not parse object 'ba9a26fe752175136562b75abc1d293cc7384fd6'.                                                                                 
------
Dockerfile_2026.04.23_13.00.36:20
--------------------
  19 |     ARG SHA1_intronProspector="ba9a26fe752175136562b75abc1d293cc7384fd6"
  20 | >>> RUN git clone --depth 2 \
  21 | >>>       https://github.com/diekhans/intronProspector.git \
  22 | >>>  && cd intronProspector \
  23 | >>>  && git reset --hard $SHA1_intronProspector \
  24 | >>>  && ./configure \
  25 | >>>  && make -j$(nproc) \
  26 | >>>  && make install \
  27 | >>>  && cd /opt \
  28 | >>>  && rm -rf intronProspector
  29 |     
--------------------
ERROR: failed to solve: process "/bin/sh -c git clone --depth 2       https://github.com/diekhans/intronProspector.git  && cd intronProspector  && git reset --hard $SHA1_intronProspector  && ./configure  && make -j$(nproc)  && make install  && cd /opt  && rm -rf intronProspector" did not complete successfully: exit code: 128
ubuntu@hbeale-mesa:/mnt/splicedice_ir
```

use a different sha

86940e1e8fefb5cc791f0dc08d7ae5ccdf485548

```
cp Dockerfile_2026.04.23_13.00.36 Dockerfile_2026.04.23_13.11.53
nano !$
```

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ diff Dockerfile_2026.04.23_13.00.36 Dockerfile_2026.04.23_13.11.53 
19c19
< ARG SHA1_intronProspector="ba9a26fe752175136562b75abc1d293cc7384fd6"
---
> ARG SHA1_intronProspector="86940e1e8fefb5cc791f0dc08d7ae5ccdf485548"
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```



try building again



```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -f Dockerfile_2026.04.23_13.11.53  -t splicedice_analysis:2026.04.23_13.11.53 .
```



failed again; try removing sha altogether

```
cp Dockerfile_2026.04.23_13.11.53 Dockerfile_2026.04.23_13.16.18
nano !$
diff Dockerfile_2026.04.23_13.11.53 Dockerfile_2026.04.23_13.16.18
```

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ diff Dockerfile_2026.04.23_13.11.53 Dockerfile_2026.04.23_13.16.18
19c19
< ARG SHA1_intronProspector="86940e1e8fefb5cc791f0dc08d7ae5ccdf485548"
---
> 
23d22
<  && git reset --hard $SHA1_intronProspector \
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```





try building again



```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -f Dockerfile_2026.04.23_13.16.18  -t splicedice_analysis:2026.04.23_13.16.18 .
```



ran without error 



### Generate inclusion count table

```
this_docker=splicedice_analysis:2026.04.23_13.16.18
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

```





expected duration, 5 min

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ sudo docker run --rm \
-v /mnt/:/mnt \
$this_docker \
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/
Gathering inclusion counts and clusters...
Calculating IR values...
Done 63.38924431800842
Writing output...
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 



```



view files

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ ls -alth
total 87M
-rw-r--r-- 1 root   root   105 Apr 23 20:22 _intron_retention_RSD.tsv
-rw-r--r-- 1 root   root    81 Apr 23 20:22 _intron_retention.tsv
drwxr-xr-x 3 root   root   183 Apr 23 18:50 .
drwxrwxr-x 4 ubuntu ubuntu 116 Apr 23 18:34 ..
drwxr-xr-x 2 root   root   240 Apr 23 17:53 coverage_output
-rw-r--r-- 1 root   root   20M Apr 23 17:18 _allPS.tsv
-rw-r--r-- 1 root   root   14M Apr 23 17:18 _inclusionCounts.tsv
-rw-r--r-- 1 root   root   18M Apr 23 17:18 _junctions.bed
-rw-r--r-- 1 root   root   37M Apr 23 17:18 _allClusters.tsv
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ date


```



output

```
_intron_retention_RSD.tsv
_intron_retention.tsv
```



results are too small; no junctions detected



confirm that new code is in the docker

```
sudo docker run --rm -it \
-v /mnt/:/mnt \
$this_docker /bin/bash

```

```
root@fee12ef672b5:/# cat ./usr/local/lib/python3.8/site-packages/splicedice/ir_table.py | grep "cluster ="
                cluster = f"{row[0]}:{int(row[1])+1}-{row[2]}:{row[5]}"

```

## Fix attempt 2



```
# in getAnnotated:
annotated.add(f"{chromosome}:{exons[i][1]+1}-{exons[i+1][0]-1}:{strand}")
#                                          ^^
```

save change to update_coordinates_in_ir_table branch



### update docker



```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -f Dockerfile_2026.04.23_13.16.18  -t splicedice_analysis:2026.04.23_14.06.32 .
```

ran too quickly

confirm that new code is in the docker

```
this_docker=splicedice_analysis:2026.04.23_14.06.32
sudo docker run --rm -it \
-v /mnt/:/mnt \
$this_docker /bin/bash

```

```
cat /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py | grep "annotated.add"
```



expected:

`annotated.add(f"{chromosome}:{exons[i][1]+1}-{exons[i+1][0]-1}:{strand}")`

observed

```
            annotated.add(f"{chromosome}:{exons[i][1]}-{exons[i+1][0]-1}:{strand}")
```



try --no-cache



```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -f Dockerfile_2026.04.23_13.16.18 --no-cache -t splicedice_analysis:2026.04.23_14.06.32 .
```

confirm that new code is in the docker

```
this_docker=splicedice_analysis:2026.04.23_14.06.32
sudo docker run --rm -it \
-v /mnt/:/mnt \
$this_docker /bin/bash

```

```
cat /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py | grep "annotated.add"
```

observed

`      annotated.add(f"{chromosome}:{exons[i][1]+1}-{exons[i+1][0]-1}:{strand}")`

### Generate inclusion count table

```
this_docker=splicedice_analysis:2026.04.23_14.06.32
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

```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ sudo docker run --rm \
-v /mnt/:/mnt \
$this_docker \
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/
Gathering inclusion counts and clusters...
Calculating IR values...
Done 164.40822505950928
Writing output...
/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```

```
ls -alth
```



# sort intron_retention results

```
--field-separator=":"
cat _intron_retention.tsv  | head -1 > _intron_retention.sorted.tsv
cat _intron_retention.tsv | sort --field-separator=":" -k1,1V -k2,2n |  cut -f1 -d":" | uniq
cat _intron_retention.tsv | sort --field-separator=":" -k1,1V -k2,2n >> _intron_retention.sorted.tsv

```



```
_intron_retention_RSD.tsv
cat _intron_retention_RSD.tsv  | head -1 > _intron_retention_RSD.sorted.tsv
cat _intron_retention_RSD.tsv  | sort --field-separator=":" -k1,1V -k2,2n |  cut -f1 -d":" | uniq
cat _intron_retention_RSD.tsv | sort --field-separator=":" -k1,1V -k2,2n >> _intron_retention_RSD.sorted.tsv

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

mv /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.05.05_20.12.55/



