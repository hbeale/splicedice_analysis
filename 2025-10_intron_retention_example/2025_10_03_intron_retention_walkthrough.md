

[TOC]

# Change on next run

The bam_files dir isn't necessary



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
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
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

duration: 30 min

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
-n 4 \
-o coverage_output

```

std out

```
getting paths for bam files
creating junction percentiles
S65_DMSO_1 starting 3.476881504058838
S66_DMSO_2 starting 3.9906177520751953
S75_DMSO_3 starting 4.507047176361084
S76_DMSO_4 starting 4.955935955047607
S76_DMSO_4 collected 341.4590220451355
S75_DMSO_3 collected 343.5644338130951
S66_DMSO_2 collected 405.26591777801514
S65_DMSO_1 collected 415.6900224685669
S65_DMSO_1 counted 609.6573734283447
S76_DMSO_4 counted 616.6582903862
S65_DMSO_1 done 618.0017981529236
S73_HB_10001 starting 619.0335693359375
S76_DMSO_4 done 625.0715811252594
S74_HB_10002 starting 626.3180384635925
S75_DMSO_3 counted 628.5916385650635
S75_DMSO_3 done 637.1337792873383
S83_HB_10003 starting 638.6381990909576
S66_DMSO_2 counted 716.2951836585999
S66_DMSO_2 done 725.2974667549133
S84_HB_10004 starting 726.8434374332428
S83_HB_10003 collected 921.6967115402222
S73_HB_10001 collected 975.1271755695343
S84_HB_10004 collected 986.6086084842682
S74_HB_10002 collected 1012.0147318840027
S73_HB_10001 counted 1145.0006740093231
S73_HB_10001 done 1154.0125942230225
S71_HB_1001 starting 1155.050444841385
S83_HB_10003 counted 1169.030017375946
S83_HB_10003 done 1177.620857000351
S72_HB_1002 starting 1178.9372205734253
S84_HB_10004 counted 1218.742280960083
S84_HB_10004 done 1227.8564054965973
S81_HB_1003 starting 1229.0696465969086
S74_HB_10002 counted 1309.8238334655762
S74_HB_10002 done 1318.5644264221191
S82_HB_1004 starting 1319.8936522006989
S81_HB_1003 collected 1555.706955909729
S72_HB_1002 collected 1566.5090930461884
S71_HB_1001 collected 1604.451630115509
S82_HB_1004 collected 1674.8645803928375
S81_HB_1003 counted 1826.8560597896576
S81_HB_1003 done 1836.2295184135437
S69_SSA_1001 starting 1837.5923676490784
S72_HB_1002 counted 1843.8651976585388
S72_HB_1002 done 1853.4335632324219
S70_SSA_1002 starting 1854.7594978809357
S71_HB_1001 counted 1939.8004961013794
S71_HB_1001 done 1949.0255942344666
S79_SSA_1003 starting 1950.5263254642487
S82_HB_1004 counted 1989.6690430641174
S82_HB_1004 done 1998.920438528061
S80_SSA_1004 starting 2000.3175973892212
S70_SSA_1002 collected 2221.1781895160675
S69_SSA_1001 collected 2250.1501083374023
S80_SSA_1004 collected 2330.051846265793
S69_SSA_1001 counted 2429.319020986557
S69_SSA_1001 done 2437.609377384186
S67_SSA_101 starting 2438.846391916275
S70_SSA_1002 counted 2518.973137617111
S70_SSA_1002 done 2527.8054707050323
S68_SSA_102 starting 2529.2026586532593
S79_SSA_1003 collected 2601.0700356960297
S80_SSA_1004 counted 2609.6486599445343
S80_SSA_1004 done 2618.305115222931
S77_SSA_103 starting 2619.609207868576
S79_SSA_1003 counted 2645.1932184696198
S79_SSA_1003 done 2654.657876729965
S78_SSA_104 starting 2655.3401594161987
S67_SSA_101 collected 2825.527834415436
S68_SSA_102 collected 2860.5397918224335
S77_SSA_103 collected 2961.581933736801
S78_SSA_104 collected 2974.85764169693
S68_SSA_102 counted 3148.144286632538
S68_SSA_102 done 3156.534029483795
S67_SSA_101 counted 3159.0709285736084
S67_SSA_101 done 3167.6757576465607
S77_SSA_103 counted 3238.740880012512
S77_SSA_103 done 3247.0490975379944
S78_SSA_104 counted 3265.7188572883606
S78_SSA_104 done 3273.7690994739532
Your runtime was 3274.993114233017 seconds.

```



## Generate inclusion count table

```
splicedice ir_table \
--annotation $genes \
-i _inclusionCounts.tsv \
-c _allClusters.tsv \
-d coverage_output \
-o ${here}
```



failed. 



error

```
Gathering inclusion counts and clusters...
Calculating IR values...
Traceback (most recent call last):
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/splicedice", line 8, in <module>
    sys.exit(main())
             ^^^^^^
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/__main__.py", line 59, in main
    args.main(args)
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/ir_table.py", line 191, in run_with
    junctions, IR, RSD = calculateIR(samples,coverageDirectory,counts,clusters,annotated,args)
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/ir_table.py", line 140, in calculateIR
    if RSD[sample][junction] < args.RSDthreshold:
       ~~~~~~~~~~~^^^^^^^^^^
KeyError: 'chr11:130070014-130109428:+'

```



what does data look like?

```
cat coverage_output/* | grep "130070014" | head
```

nothing jumps out at me.



this is an error described at https://github.com/BrooksLabUCSC/splicedice/issues/10#issuecomment-2529672705



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





```
Gathering inclusion counts and clusters...
Calculating IR values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Done 231.3994653224945
Writing output...

```



## review results

```
head -5 _intron_retention_RSD.tsv | cut -f1-5
Junction        S65_DMSO_1_RSD  S76_DMSO_4_RSD  S75_DMSO_3_RSD  S66_DMSO_2_RSD
GL000008.2:155531-156720:+      1.225   1.225   1.333   2.000
GL000195.1:138140-140386:+      nan     2.000   1.069   1.333
GL000195.1:138140-140413:+      nan     2.000   1.091   0.927
GL000195.1:138140-140424:+      nan     2.000   1.091   1.020

```

```
head -5 _intron_retention.tsv | cut -f1-5
Junction        S65_DMSO_1      S76_DMSO_4      S75_DMSO_3      S66_DMSO_2
GL000008.2:155531-156720:+      nan     nan     nan     nan
GL000195.1:138140-140386:+      0.000   0.000   0.027   0.000
GL000195.1:138140-140413:+      0.000   0.000   0.027   0.050
GL000195.1:138140-140424:+      0.000   0.000   0.027   0.050

```



## Compare with results from Javier

```
cat SSA_Jurica_intron_retention_RSD.tsv | cut -f1-5 | head -5
Junction	S65_DMSO_RSD	S66_DMSO_RSD	S75_DMSO_RSD	S76_DMSO_RSD
KI270721.1:7404-7976:+	1.761	2.000	1.225	2.000
KI270721.1:8050-11450:+	1.225	1.736	1.651	1.549
KI270734.1:131996-135442:+	2.000	2.000	0.972	nan
chr10:1000868-1000947:+	0.551	0.787	0.500	0.534

```

KI270721.1 is Homo sapiens chromosome 11 unlocalized genomic contig, GRCh38 reference https://www.ebi.ac.uk/ena/browser/view/KI270721.1

equivalents are not there

```
(base) 15:20 [OSX-Pomone.local:IR_table]$ cat SSA_Jurica_intron_retention_RSD.tsv | grep "GL000008.2:155531-156720:+"
(base) 15:21 [OSX-Pomone.local:IR_table]$ cat SSA_Jurica_intron_retention_RSD.tsv | grep "GL000008.2"

```

GL000008.2 is chr 4



Check bam and refs

```
/mnt/data/bams/javier_erj_jurica_ssa/javier_erj_jurica_ssa_bam_manifest.txt
f=/mnt/data/bams/javier_erj_jurica_ssa/S69_SSA_1001/SSA1001_S69.filteredAligned.sortedByCoord.out.bam
samtools view $f | less
samtools view $f | grep KI270721 | less
```

chr names are .e.g chr1

chr names in Javier data

```
cat $f | cut -f1-5 | sed 's/:.*//' | sort | uniq -c
f=SSA_Jurica_intron_retention.tsv

2 KI270721.1
   1 KI270734.1
3673 chr1
1461 chr10
2260 chr11
2042 chr12
 576 chr13
1169 chr14
1218 chr15
1962 chr16
2387 chr17
 471 chr18
2196 chr19
2453 chr2
1007 chr20
 323 chr21
 659 chr22
2039 chr3
 966 chr4
1866 chr5
1640 chr6
1642 chr7
1084 chr8
1306 chr9
1254 chrX
  37 chrY

```



```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example_archives/2025.10.03_22.17.53/analysis$ cat _intron_retention.tsv |  cut -f1-5 | sed 's/:.*//' | sort | uniq -c
      1 GL000008.2
     25 GL000195.1
      9 GL000214.1
      1 Junction        S65_DMSO_1      S76_DMSO_4      S75_DMSO_3      S66_DMSO_2
     14 KI270706.1
      2 KI270721.1
      1 KI270733.1
      1 KI270734.1
      1 KI270742.1
      2 KI270744.1
      9 KI270751.1
   4623 chr1
   1803 chr10
   2860 chr11
   2683 chr12
    738 chr13
   1554 chr14
   1589 chr15
   2519 chr16
   3003 chr17
    632 chr18
   2686 chr19
   3118 chr2
   1285 chr20
    452 chr21
    843 chr22
   2632 chr3
   1197 chr4
   2399 chr5
   1954 chr6
   2149 chr7
   1406 chr8
   1689 chr9
   1522 chrX
     56 chrY

```



# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2025.10.03_22.17.53/



# More analysis

```
f=/mnt/splicedice_ir_example_archives/2025.10.03_22.17.53/analysis/_intron_retention.tsv
cat $f | grep "chr1: | less
```

