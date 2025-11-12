

[TOC]

# Versions

2025_11_07_intron_retention_replication_retry.md: use this commit: 0f59716

"Updated simliarity score to not include nan values in denominator", by dennisrm 9/22/2022



# Server

hbeale-mesa

ssh ubuntu@10.50.100.135



# Copy Javier's data from mustard

Do i have lots of space on hbeale-mesa

```
df -h | grep mnt
# /dev/vdb1       2.0T  1.2T  916G  56% /mnt
```

mkdir on hbeale-mesa

```
mkdir /mnt/mustard_scratch/erj_public/
```

copy from mustard

```
scp -r /scratch/erj_public/Jurica_SSA ubuntu@10.50.100.135:/mnt/mustard_scratch/erj_public/
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





# Directory setup

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
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis

```

Exit python environments if you're in one

```
deactivate
```



## Download repo

```
SHA1=0f59716aada7f496e10aa302c2b432feca79677a
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/BrooksLabUCSC/splicedice.git 
cd splicedice
ls
git reset --hard $SHA1
ls

```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ ls
LICENSE  MANIFEST.in  Pipfile  README.md  data  docs  requirements.txt  scripts  setup.py  splicedice
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ git reset --hard $SHA1
HEAD is now at 0f59716 Updated simliarity score to not include nan values in denominator
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ ls
LICENSE  MANIFEST.in  Pipfile  README.md  data  docs  mesa  requirements.txt  scripts  setup.py
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ 

```



## Create environment

```
cd /mnt/splicedice_ir_example/git_code/splicedice/
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/activate
pip install pysam
mesa
```



std out

```
...
Building wheels for collected packages: mesa
  Building wheel for mesa (pyproject.toml) ... done
  Created wheel for mesa: filename=mesa-0.0.1-py3-none-any.whl size=30080 sha256=8dc31f4d16c8fca7c1ddd9f198677a08a0000e0c77fa56bf119e1a64a3117b43
  Stored in directory: /tmp/pip-ephem-wheel-cache-zw_8m_g_/wheels/19/d3/c4/90ca0f901e487f4948ae8924985f520d0d66becafe891559c1
Successfully built mesa
...
usage: mesa [-h]
            {bam_to_junc_bed,quant,intron_coverage,ir_table,compare_sample_sets,pairwise,findOutliers,subset,similarity,select,counts_to_ps}
            ...

```

# bam to bed

modify javier's manifest

```
cat /mnt/mustard_scratch/erj_public/Jurica_SSA/scripts/Manifest_file.txt | sed 's|/data/scratch/javi/Jurica_SSA|/mnt/mustard_scratch/erj_public/Jurica_SSA|' > /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt
```



make a script using the same format as Javier's

/mnt/splicedice_ir_example/analysis/scripts/SSA100_mesa.sh

```

output="/mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
genome="/mnt/ref/GRCh38.primary_assembly.genome.fa"
mkdir -p `dirname $output`
mesa bam_to_junc_bed \
-m /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt \
--output_prefix ${output} \
--annotation ${gtf} \
--genome ${genome}
```

std out

```
Finding junctions from 20 BAM files...
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/DMSO1_S65.filteredAligned.sortedByCoord.out.bam
number of junctions found: 339427
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/DMSO1_S65.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/DMSO2_S66.filteredAligned.sortedByCoord.out.bam
number of junctions found: 509493
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/DMSO2_S66.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/DMSO3_S75.filteredAligned.sortedByCoord.out.bam
number of junctions found: 501798
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/DMSO3_S75.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/DMSO4_S76.filteredAligned.sortedByCoord.out.bam
number of junctions found: 458967
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/DMSO4_S76.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB10001_S73.filteredAligned.sortedByCoord.out.bam
number of junctions found: 270340
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/HB10001_S73.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB10002_S74.filteredAligned.sortedByCoord.out.bam
number of junctions found: 500652
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/HB10002_S74.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB10003_S83.filteredAligned.sortedByCoord.out.bam
number of junctions found: 439690
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/HB10003_S83.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB10004_S84.filteredAligned.sortedByCoord.out.bam
number of junctions found: 422311
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/HB10004_S84.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB1001_S71.filteredAligned.sortedByCoord.out.bam
number of junctions found: 511489
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/HB1001_S71.filteredAligned.sortedByCoord.out.junc.bed
bam: /mnt/mustard_scratch/erj_public/Jurica_SSA/output/STAR/HB1002_S72.filteredAligned.sortedByCoord.out.bam
number of junctions found: 449662
saved to bed: /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/HB1002_S72.filteredAligned.sortedByCoord.out.junc.bed

```



### compare outputs



compare output from one bam file

```

old="/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/bamtobed/SSA_junction_beds/DMSO4_S76.filteredAligned.sortedByCoord.out.junc.bed"
new="/mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/DMSO4_S76.filteredAligned.sortedByCoord.out.junc.bed"
diff --report-identical-files $old $new
```

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt$ diff --report-identical-files $old $new
Files /mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/bamtobed/SSA_junction_beds/DMSO4_S76.filteredAligned.sortedByCoord.out.junc.bed and /mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/DMSO4_S76.filteredAligned.sortedByCoord.out.junc.bed are identical
(splicedice_env) ubuntu@hbeale-mesa:/mnt$ 
```



compare all

```
new_base=/mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_junction_beds/
old_base=/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/bamtobed/SSA_junction_beds/

cat /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt | cut -f2 | while read bam; do
echo 
echo
bed_file_name=`basename $bam | sed 's|.bam|.junc.bed|'`
new=${new_base}/$bed_file_name
old=${old_base}/$bed_file_name

echo $bed_file_name
diff --report-identical-files $old $new | sed 's/^.*identical/identical/'
done

```



results: all bed files are identical



# QUANT 

/mnt/splicedice_ir_example/analysis/scripts/SSA100_mesa_quant.sh

```

BDMF="/mnt/splicedice_ir_example/analysis/output/mesa/bamtobed/SSA_manifest.txt"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
genome="/mnt/ref/GRCh38.primary_assembly.genome.fa"
out="/mnt/splicedice_ir_example/analysis/output/mesa/quant/SSA_Jurica"
mkdir -p `dirname $out`
mesa quant \
-m ${BDMF} \
-o ${out}

```



std out

```
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 20 files...
        Done [0:00:33.38]
Finding clusters from 189859 junctions...
        Done [0:00:1.52]
Writing cluster file...
        Done [0:00:1.09]
Writing junction bed file...
        Done [0:00:0.83]
Gathering junction counts...
        Done [0:00:19.52]
Writing inclusion counts...
        Done [0:00:4.92]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/MESA.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:4.75]
Writing PS values...
        Done [0:00:5.19]
All done [0:01:11.18]
```



### compare outputs



compare output from one bam file

```
old="/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/quant/SSA_Jurica_allPS.tsv"
new="/mnt/splicedice_ir_example/analysis/output/mesa/quant/SSA_Jurica_allPS.tsv"
diff --report-identical-files $old $new
```

```
identical
```



## Calculate intron_coverage for each sample

/mnt/splicedice_ir_example/analysis/scripts/SSA100_mesa_IRcoverage.sh

```
project="/mnt/splicedice_ir_example/analysis/output/mesa/quant/"
output="/mnt/splicedice_ir_example/analysis/output/mesa/IR_coverage/"
mkdir -p $output
mesa intron_coverage \
-b /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt \
-m ${project}SSA_Jurica_allPS.tsv \
-j ${project}SSA_Jurica_junctions.bed \
-o ${output}SSA_Jurica 
~/alert_msg.sh "intron_coverage complete"

```



```
getting paths for bam files
creating junction percentiles
...
S78_SSA done 10994.552186727524
Your runtime was 10995.562909603119 seconds.
```



### compare outputs



compare output from one bam file



compare all

```
new_base=/mnt/splicedice_ir_example/analysis/output/mesa/IR_coverage/SSA_Jurica/
old_base=/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/IR_coverage/SSA_Jurica/

cat /mnt/splicedice_ir_example/analysis/scripts/Manifest_file.txt | cut -f1 | while read id; do
echo 
echo $id
new=${new_base}/${id}_intron_coverage.txt
old=${old_base}/${id}_intron_coverage.txt

diff --report-identical-files $old $new | sed 's/^.*identical/identical/'
done

```



# Combine IR coverage into table

SSA100_mesa_IRtable.sh

```
new_script_base=/mnt/splicedice_ir_example/analysis/scripts/
javier_script_base=/mnt/mustard_scratch/erj_public/Jurica_SSA/scripts
this_script=SSA100_mesa_IRtable.sh
cat ${javier_script_base}/SSA100_mesa_IRtable.sh

nano ${new_script_base}/$this_script
```



script contents

```
output="/mnt/splicedice_ir_example/analysis/output/mesa/IR_table/"
project="/mnt/splicedice_ir_example/analysis/output/mesa/quant/"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
mesa ir_table -i ${project}SSA_Jurica_inclusionCounts.tsv \
-c ${project}SSA_Jurica_allClusters.tsv \
-d /mnt/splicedice_ir_example/analysis/output/mesa/IR_coverage/SSA_Jurica \
-o ${output}SSA_Jurica \
-a $gtf \
-r
~/alert_msg.sh "intron_coverage complete"
```



run script

```
bash ${new_script_base}/$this_script
```



std out

```
Gathering inclusion counts and clusters...
```



### Error AttributeError: module 'numpy' has no attribute 'float'.

#### planned fix

fix: change line 118 of /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py

covArray = np.array(coverage[sample][cluster]).astype(np.float)

to covArray = np.array(coverage[sample][cluster]).astype(float)

```
nano /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py
```

esc, n shows numbers

(I first changed nano mesa/ir_table.py and still got the error)



### another error: TypeError: expected str, bytes or os.PathLike object, not NoneType

```
Traceback (most recent call last):
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/mesa", line 8, in <module>
    sys.exit(main())
             ^^^^^^
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/__main__.py", line 59, in main
    args.main(args)
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py", line 178, in run_with
    counts = getInclusionCounts(countFile)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py", line 73, in getInclusionCounts
    with open(filename) as inclusionCounts:
         ^^^^^^^^^^^^^^
TypeError: expected str, bytes or os.PathLike object, not NoneType

```



try changing -r to --makeRSDtable



new script contents

```
output="/mnt/splicedice_ir_example/analysis/output/mesa/IR_table/"
project="/mnt/splicedice_ir_example/analysis/output/mesa/quant/"
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
mesa ir_table -i ${project}SSA_Jurica_inclusionCounts.tsv \
-c ${project}SSA_Jurica_allClusters.tsv \
-d /mnt/splicedice_ir_example/analysis/output/mesa/IR_coverage/SSA_Jurica \
-o ${output}SSA_Jurica \
-a $gtf \
--makeRSDtable  
~/alert_msg.sh "intron_coverage complete"

```

### another error: No such file or directory

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice$ bash ${new_script_base}/$this_script
Gathering inclusion counts and clusters...
Calculating IR values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Done 167.94038319587708
Writing output...
Traceback (most recent call last):
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/mesa", line 8, in <module>
    sys.exit(main())
             ^^^^^^
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/__main__.py", line 59, in main
    args.main(args)
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py", line 194, in run_with
    writeIRtable(samples, outputPrefix, junctions, IR)
  File "/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py", line 149, in writeIRtable
    with open(f"{outputPrefix}_intron_retention.tsv","w") as irTable:
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
FileNotFoundError: [Errno 2] No such file or directory: '/mnt/splicedice_ir_example/analysis/output/mesa/IR_table/SSA_Jurica_intron_retention.tsv'

```





try making the dir first



```
mkdir /mnt/splicedice_ir_example/analysis/output/mesa/IR_table/
```







### re-run  script

```
bash ${new_script_base}/$this_script
```

### Success! 

std out



```
Gathering inclusion counts and clusters...
Calculating IR values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/mesa/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Done 171.2182433605194
Writing output...
{"status":"OK","nsent":2,"apilimit":"1\/1000"}


```



### update script to include output dir creation

```
 nano ${new_script_base}/$this_script
```



new script contents

```
output="/mnt/splicedice_ir_example/analysis/output/mesa/IR_table/"
project="/mnt/splicedice_ir_example/analysis/output/mesa/quant/"
mkdir $output
gtf="/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
mesa ir_table -i ${project}SSA_Jurica_inclusionCounts.tsv \
-c ${project}SSA_Jurica_allClusters.tsv \
-d /mnt/splicedice_ir_example/analysis/output/mesa/IR_coverage/SSA_Jurica \
-o ${output}SSA_Jurica \
-a $gtf \
--makeRSDtable  
~/alert_msg.sh "intron_coverage complete"

```

### 

### compare outputs



compare output from one bam file

```
old="/mnt/mustard_scratch/erj_public/Jurica_SSA/output/mesa/IR_table/SSA_Jurica_intron_retention.tsv"
new="/mnt/splicedice_ir_example/analysis/output/mesa/IR_table/SSA_Jurica_intron_retention.tsv"
diff --report-identical-files $old $new
```

```
identical
```



## 

# Cleanup and archive



```
deactivate 
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2025.11.12_19.34.47/





