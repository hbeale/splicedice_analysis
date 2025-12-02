





# Versions

after showing that I can get the same results as Javier with the latest code (2025_11_18_intron_retention_replication_retry_with_da045c4.md), i'm going to try to figure out where that differs from mine



changes from 2025_10_08_intron_retention_walkthrough_v2.md

different genome (now /mnt/ref/GRCh38.primary_assembly.genome.fa  like Javier, was Homo_sapiens.GRCh38.dna.primary_assembly.fa)

different bam manifest

## 

# Code version

uses commit  da045c4

url: https://github.com/BrooksLabUCSC/splicedice/commit/da045c486e314e6f7db253998d886a163172295b

name: Merge pull request [#14](https://github.com/BrooksLabUCSC/splicedice/pull/14) from BrooksLabUCSC/add_query_scripts_from_dennis

SHA1=da045c486e314e6f7db253998d886a163172295b

"Updated simliarity score to not include nan values in denominator", by hbeale 9/16/2025



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
/dev/vdb1       2.0T  1.2T  849G  59% /mnt
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
SHA1=da045c486e314e6f7db253998d886a163172295b
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
Receiving objects: 100% (661/661), 793.00 KiB | 4.64 MiB/s, done.
Resolving deltas: 100% (348/348), done.
LICENSE  MANIFEST.in  Pipfile  README.md  data  docs  requirements.txt  scripts  setup.py  splicedice
HEAD is now at da045c4 Merge pull request #14 from BrooksLabUCSC/add_query_scripts_from_dennis
LICENSE  MANIFEST.in  Pipfile  README.md  data  docs  requirements.txt  scripts  setup.py  splicedice


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
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
usage: splicedice [-h]
                  {bam_to_junc_bed,quant,intron_coverage,ir_table,compare_sample_sets,pairwise,findOutliers,subset,similarity,select,counts_to_ps}
                  ...

```



## Make bam manifest

```
cat /mnt/splicedice_ir_example_archives/2025.10.03_22.17.53/analysis/bam_manifest.txt | sed 's/^S65_DMSO_1/S65_DMSO/' | \
sed 's/^S66_DMSO_2/S66_DMSO/' | \
sed 's/^S75_DMSO_3/S75_DMSO/' | \
sed 's/^S76_DMSO_4/S76_DMSO/' | \
sed 's/^S73_HB_10001/S73_HB10001/' | \
sed 's/^S74_HB_10002/S74_HB10002/' | \
sed 's/^S83_HB_10003/S83_HB10003/' | \
sed 's/^S84_HB_10004/S84_HB10004/' | \
sed 's/^S71_HB_1001/S71_HB1001/' | \
sed 's/^S72_HB_1002/S72_HB1002/' | \
sed 's/^S81_HB_1003/S81_HB1003/' | \
sed 's/^S82_HB_1004/S82_HB1004/' | \
sed 's/^S69_SSA_1001/S69_SSA/' | \
sed 's/^S70_SSA_1002/S70_SSA/' | \
sed 's/^S79_SSA_1003/S79_SSA/' | \
sed 's/^S80_SSA_1004/S80_SSA/' | \
sed 's/^S67_SSA_101/S67_SSA/' | \
sed 's/^S68_SSA_102/S68_SSA/' | \
sed 's/^S77_SSA_103/S77_SSA/' | \
sed 's/^S78_SSA_104/S78_SSA/' > /mnt/splicedice_ir_example/analysis/bam_manifest.txt

diff <(cut -f1 /mnt/splicedice_ir_example/analysis/bam_manifest.txt ) <(cut -f1 /mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/scripts/Manifest_file.txt )

```

(note column 4, tx, is still different)



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
saved to bed: /mnt/splicedice_ir_example/analysis/_junction_beds/SSA102_S68.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/data/bams/javier_erj_jurica_ssa/S77_SSA_103/SSA103_S77.filteredAligned.sortedByCoord.out.bam
number of junctions found: 475249
saved to bed: /mnt/splicedice_ir_example/analysis/_junction_beds/SSA103_S77.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/data/bams/javier_erj_jurica_ssa/S78_SSA_104/SSA104_S78.filteredAligned.sortedByCoord.out.bam
number of junctions found: 501288
saved to bed: /mnt/splicedice_ir_example/analysis/_junction_beds/SSA104_S78.filteredAligned.sortedByCoord.out.junc.bed
new manifest written to: /mnt/splicedice_ir_example/analysis/_manifest.txt

real    33m27.913s
user    122m49.919s
sys     2m15.272s
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
```

outputs

```
_manifest.txt
_junction_beds/

```



### compare outputs 

updated; run these next when bam_to_bed is done

```
old_base=/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output/splicedice/
new_base=/mnt/splicedice_ir_example/analysis/
cat /mnt/splicedice_ir_example/analysis/bam_manifest.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/_junction_beds/$bed_file_name
old=${old_base}/bamtobed/SSA_junction_beds/$bed_file_name

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
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ splicedice quant -m _manifest.txt -o $here
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 20 files...
        Done [0:00:32.29]
Finding clusters from 189859 junctions...
        Done [0:00:1.62]
Writing cluster file...
        Done [0:00:1.07]
Writing junction bed file...
        Done [0:00:0.85]
Gathering junction counts...
        Done [0:00:18.80]
Writing inclusion counts...
        Done [0:00:4.81]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:4.83]
Writing PS values...
        Done [0:00:4.93]
All done [0:01:9.19]
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ 

All done [0:01:30.02]

```





### compare outputs 

updated; run these next when bam_to_bed is done

```
old=/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output/splicedice/quant/SSA_Jurica_allPS.tsv
new=/mnt/splicedice_ir_example/analysis/_allPS.tsv
diff --report-identical-files $old $new 

```

identical



## REsUME HERE





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
S77_SSA done 2317.0898628234863
S78_SSA counted 2365.252301931381
S78_SSA done 2371.0287070274353
Your runtime was 2372.32368016243 seconds.

```

### compare outputs



```
old_base=/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output/splicedice//IR_coverage/SSA_Jurica/
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
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis$ splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i _inclusionCounts.tsv \
-c _allClusters.tsv \
-d coverage_output \
-o ${here}
Gathering inclusion counts and clusters...
Calculating IR values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Done 171.4899878501892
Writing output...

```



output

```
_intron_retention_RSD.tsv
```



### compare outputs



compare output from one bam file

```
old="/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output//splicedice/IR_table/SSA_Jurica_intron_retention.tsv"
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
old_ir_table <- read_tsv("/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output//splicedice/IR_table/SSA_Jurica_intron_retention.tsv")
new_ir_table <- read_tsv("/mnt/splicedice_ir_example/analysis/_intron_retention.tsv")

old_ir_table_long <- pivot_longer(old_ir_table, -Junction) %>% mutate(old = TRUE)
new_ir_table_long <- pivot_longer(new_ir_table, -Junction) %>% mutate(new = TRUE)

combined_tables <- full_join(old_ir_table_long, new_ir_table_long)
```



```
> table(combined_tables$new, useNA = "always")

  TRUE   <NA> 
713880      0 
> table(combined_tables$old, useNA = "always")

  TRUE   <NA> 
713880      0 
> 

```



# Cleanup and archive



```
deactivate 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```



/mnt/splicedice_ir_example_archives/2025.12.02_22.32.45/

