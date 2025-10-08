

[TOC]

# Versions

v2: use the same gtf Javier used to generate the star index

# One-time steps

get gtf 

javier's star index generation script says he used gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf

```
cd /mnt/ref
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf.gz
gzip -d gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf.gz 

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



## Create environment

```
cd /mnt/splicedice_ir_example/git_code/splicedice/
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/activate
pip install pysam
splicedice
```



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

```

outputs

```
_manifest.txt
_junction_beds/

```

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
        Done [0:00:0.06]
Getting all junctions from 20 files...
        Done [0:00:40.18]
Finding clusters from 266569 junctions...
        Done [0:00:2.37]
Writing cluster file...
        Done [0:00:1.63]
Writing junction bed file...
        Done [0:00:1.21]
Gathering junction counts...
        Done [0:00:23.48]
Writing inclusion counts...
        Done [0:00:6.65]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:7.31]
Writing PS values...
        Done [0:00:7.14]
All done [0:01:30.02]

```

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
getting paths for bam files
creating junction percentiles
S65_DMSO_1 starting 3.352123498916626
S66_DMSO_2 starting 3.814159631729126
S75_DMSO_3 starting 4.288445711135864
S76_DMSO_4 starting 4.856794118881226
S73_HB_10001 starting 5.370010614395142
S74_HB_10002 starting 5.779902935028076
S75_DMSO_3 collected 336.1693117618561
S76_DMSO_4 collected 342.52338433265686
S73_HB_10001 collected 366.5080533027649
S74_HB_10002 collected 410.1458761692047
S66_DMSO_2 collected 418.5272943973541
S65_DMSO_1 collected 421.2775113582611
S73_HB_10001 counted 518.4216947555542
S73_HB_10001 done 526.1604709625244
S83_HB_10003 starting 527.2380447387695
S76_DMSO_4 counted 592.6130502223969
S76_DMSO_4 done 601.2207210063934
S84_HB_10004 starting 602.4993793964386
S65_DMSO_1 counted 603.0761744976044
S75_DMSO_3 counted 604.6476693153381
S65_DMSO_1 done 612.048351764679
S75_DMSO_3 done 612.8317892551422
S71_HB_1001 starting 613.1059010028839
S72_HB_1002 starting 614.3132026195526
S74_HB_10002 counted 689.5742435455322
S74_HB_10002 done 698.4964153766632
S81_HB_1003 starting 699.8160660266876
S66_DMSO_2 counted 712.7112572193146
S66_DMSO_2 done 721.6006729602814
S82_HB_1004 starting 722.9863700866699
S83_HB_10003 collected 810.9314434528351
S84_HB_10004 collected 867.7472543716431
S72_HB_1002 collected 1003.460113286972
S81_HB_1003 collected 1040.7654645442963
S83_HB_10003 counted 1043.805424451828
S83_HB_10003 done 1052.5871992111206
S69_SSA_1001 starting 1053.8423743247986
S71_HB_1001 collected 1067.4711451530457
S84_HB_10004 counted 1078.7423317432404
S84_HB_10004 done 1086.3649492263794
S70_SSA_1002 starting 1087.6967833042145
S82_HB_1004 collected 1094.1829142570496
S72_HB_1002 counted 1261.974910736084
S72_HB_1002 done 1270.2228202819824
S79_SSA_1003 starting 1271.4676167964935
S81_HB_1003 counted 1308.316111087799
S81_HB_1003 done 1316.7475364208221
S80_SSA_1004 starting 1318.0628733634949
S82_HB_1004 counted 1380.4394619464874
S71_HB_1001 counted 1381.2922594547272
S82_HB_1004 done 1389.1054937839508
S71_HB_1001 done 1389.816820383072
S67_SSA_101 starting 1390.5104455947876
S68_SSA_102 starting 1391.2600445747375
S70_SSA_1002 collected 1429.7166266441345
S69_SSA_1001 collected 1452.8059232234955
S69_SSA_1001 counted 1617.5670430660248
S69_SSA_1001 done 1626.3025300502777
S77_SSA_103 starting 1627.5535297393799
S80_SSA_1004 collected 1654.0153555870056
S70_SSA_1002 counted 1707.925234079361
S70_SSA_1002 done 1716.5197513103485
S78_SSA_104 starting 1718.224680185318
S68_SSA_102 collected 1745.9149117469788
S67_SSA_101 collected 1801.5729105472565
S80_SSA_1004 counted 1913.7431256771088
S80_SSA_1004 done 1922.4606847763062
S79_SSA_1003 collected 1944.0062556266785
S77_SSA_103 collected 1960.8307268619537
S79_SSA_1003 counted 1982.8268086910248
S79_SSA_1003 done 1990.8453149795532
S68_SSA_102 counted 2014.9835724830627
S68_SSA_102 done 2023.1964118480682
S78_SSA_104 collected 2040.8213119506836
S67_SSA_101 counted 2115.4079892635345
S67_SSA_101 done 2123.031358242035
S77_SSA_103 counted 2196.865911245346
S77_SSA_103 done 2204.424045562744
S78_SSA_104 counted 2289.5728063583374
S78_SSA_104 done 2297.1178028583527
Your runtime was 2298.2842860221863 seconds.

```



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
Done 178.88786339759827
Writing output...


```



output

```
_intron_retention_RSD.tsv
```



## review results

(See intron_retention_results_analysis_2025_10_08.md)



# Cleanup and archive



```
deactivate 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2025.10.08_21.47.01/





