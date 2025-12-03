

# Versions

AFAICT the only difference between my previous analysis (with results that differed from Javier's) and the ones that generated identical results are the different bam manifest (i renamed samples and used different phenotypes), and a different gene model



In this run, I will use Homo_sapiens.GRCh38.dna.primary_assembly.fa instead of GRCh38.primary_assembly.genome.fa



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
/dev/vdb1       2.0T  1.2T  847G  59% /mnt
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
Receiving objects: 100% (661/661), 793.41 KiB | 5.02 MiB/s, done.
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
{"status":"OK","nsent":2,"apilimit":"1\/1000"}

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

genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
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
old_base=/mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output/splicedice/
new_base=/mnt/splicedice_ir_example/analysis/
cat /mnt/splicedice_ir_example/analysis/bam_manifest.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/_junction_beds/$bed_file_name
old=${old_base}/bamtobed/SSA_junction_beds/$bed_file_name

echo $bed_file_name
# diff --report-identical-files $old $new | sed 's/^.*identical/identical/'
diff --brief --report-identical-files $old $new  | sed 's/^.*differ/differ/'
done
```



all different

find example differences

```
cat /mnt/splicedice_ir_example/analysis/bam_manifest.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/_junction_beds/$bed_file_name
old=${old_base}/bamtobed/SSA_junction_beds/$bed_file_name

echo $bed_file_name
diff --report-identical-files <(head -1755 $old) <( head -1755 $new)
done
```

```
SSA104_S78.filteredAligned.sortedByCoord.out.junc.bed
1752,1755c1752,1755
< chr1  14829   14969   e:2.49:2.59;o:66;m:CT_AC;a:?    43      -
< chr1  15038   15795   e:2.14:2.14;o:69;m:CT_AC;a:?    21      -
< chr1  15175   72308   e:0.00:0.00;o:9;m:CC_TA;a:?     1       -
< chr1  16577   72307   e:0.00:0.00;o:10;m:AT_CT;a:?    1       -
---
> chr1  14829   14969   e:2.13:2.08;o:47;m:NN_NN;a:?    21      +
> chr1  14829   14969   e:2.49:2.59;o:66;m:NN_NN;a:?    22      -
> chr1  15038   15795   e:1.55:1.55;o:68;m:NN_NN;a:?    7       +
> chr1  15038   15795   e:2.14:2.14;o:69;m:NN_NN;a:?    14      -

```



how many differ?



```
cat /mnt/splicedice_ir_example/analysis/bam_manifest.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/_junction_beds/$bed_file_name
old=${old_base}/bamtobed/SSA_junction_beds/$bed_file_name

echo $bed_file_name
# diff --report-identical-files <(head -1755 $old) <( head -1755 $new)
# diff -U 0 $old $new | grep ^@ | head
diff --suppress-common-lines   $old $new | grep "^<" | wc -l
wc -l $old
wc -l $new
done

```



nearly all differ, e.g.

```
SSA101_S67.filteredAligned.sortedByCoord.out.junc.bed
551156
553475 /mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output/splicedice//bamtobed/SSA_junction_beds/SSA101_S67.filteredAligned.sortedByCoord.out.junc.bed
640469 /mnt/splicedice_ir_example/analysis//_junction_beds/SSA101_S67.filteredAligned.sortedByCoord.out.junc.bed


SSA102_S68.filteredAligned.sortedByCoord.out.junc.bed
451704
452953 /mnt/splicedice_ir_example_archives/2025.11.17_18.22.56/analysis/output/splicedice//bamtobed/SSA_junction_beds/SSA102_S68.filteredAligned.sortedByCoord.out.junc.bed
527171 /mnt/splicedice_ir_example/analysis//_junction_beds/SSA102_S68.filteredAligned.sortedByCoord.out.junc.bed


SSA103_S77.filteredAligned.sortedByCoord.out.junc.bed
473105
475249 /mnt
```

