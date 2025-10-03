# make a tiny dataset for testing: chr1:1-100M



chromosome names in bam file are e.g. 1, 2, 3, 

in genes file, they are chr1, chr2, etc

in DNA file, they are 1, 2, 3

it should contain a clear intron retention event and some widely used well-defined junctions

### slice data

````
a="SRR12801019 SRR12801020 SRR12801023 SRR12801024"
pos_name=ch1_100M

for i in $a; do
mkdir -p /mnt/data/bams/$i 
samtools view -b /mnt/output/star_2.7.11b_2024.12.13/${i}/sortedByCoord.md.bam 1:1-100000000 >/mnt/data/bams/${i}/${i}.${pos_name}.bam
done

````

### make manifest

```
bam_manifest=/mnt/data/manifests/SUGP1_kd_${pos_name}_srr_manifest.tsv

a="SRR12801019|control
SRR12801020|SUGP1_kd
SRR12801023|control 
SRR12801024|SUGP1_kd"

for i in $a; do

srr_id=${i/|*}
group=${i/*|}
echo $i $srr_id $group


echo $srr_id /mnt/data/bams/$srr_id/${srr_id}.${pos_name}.bam NA $group | tr " " "\t" >> $bam_manifest

done

```





# Setup (previously run)





this commit is the one after I pulled Dennis's scripts in. I'm marking it so future reviews will know which code I used here

```
cd /mnt/bin
git clone https://github.com/BrooksLabUCSC/splicedice.git 
cd splicedice
git reset --hard da045c486e314e6f7db253998d886a163172295b
python3 -m venv splicedice_env
splicedice_env/bin/pip install .
source /mnt/bin/splicedice/splicedice_env/bin/activate
pip install pysam
splicedice
```

failes with ModuleNotFoundError: No module named 'pysam'

even though pysam installs without error



things that fail

```
git clone --depth=1 --branch da045c4 https://github.com/BrooksLabUCSC/splicedice.git 
```



```



mkdir -p /mnt/splicedice_small_example/analysis

cp -r /mnt/splicedice_ir_example_archives/2025.10.03_22.17.53/git_code /mnt/splicedice_small_example

source /mnt/splicedice_small_example/git_code/splicedice/splicedice_env/bin/activate

```





## Find junctions in bam files

```
bam_manifest=/mnt/data/manifests/SUGP1_kd_${pos_name}_srr_manifest.tsv

cd /mnt/splicedice_small_example/analysis


genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
here=/mnt/splicedice_small_example/analysis/

time splicedice bam_to_junc_bed \
-m $bam_manifest \
-o $here \
--genome $genome \
--annotation $genes \
--number_threads 4

```

duration 2 min

outputs



```
_manifest.txt
_junction_beds/

```

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
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_small_example/analysis$ splicedice quant -m _manifest.txt -o $here
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 4 files...
        Done [0:00:0.06]
Finding clusters from 1368 junctions...
        Done [0:00:0.00]
Writing cluster file...
        Done [0:00:0.01]
Writing junction bed file...
        Done [0:00:0.00]
Gathering junction counts...
        Done [0:00:0.03]
Writing inclusion counts...
        Done [0:00:0.01]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:0.02]
Writing PS values...
        Done [0:00:0.01]
All done [0:00:0.15]


```

## Calculate intron_coverage

```
splicedice intron_coverage \
-b $bam_manifest \
-m _allPS.tsv \
-j _junctions.bed \
-n 4 \
-o coverage_output

```

```
creating junction percentiles
SRR12801019 starting 0.05766940116882324
SRR12801023 starting 0.05849313735961914
SRR12801024 starting 0.05941271781921387
SRR12801020 starting 0.06038165092468262
SRR12801019 collected 4.7865824699401855
SRR12801023 collected 5.178888559341431
SRR12801024 collected 5.934825658798218
SRR12801020 collected 6.639690637588501
SRR12801019 counted 10.630335569381714
SRR12801019 done 10.673582553863525
SRR12801023 counted 11.6811842918396
SRR12801023 done 11.724299192428589
SRR12801024 counted 12.205045223236084
SRR12801024 done 12.245598316192627
SRR12801020 counted 13.4242422580719
SRR12801020 done 13.464926958084106
Your runtime was 13.514312028884888 seconds.


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



```
Gathering inclusion counts and clusters...
Calculating IR values...
Done 44.11564898490906
Writing output...
```



output

```
_intron_retention.tsv
```



## Review results - no intron retention events

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_small_example/analysis$ cat _intron_retention.tsv 
Junction        SRR12801019     SRR12801020     SRR12801024     SRR12801023
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_small_example/analysis$ 

```

# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_small_example_archives/${pos_name}_`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_small_example $this_archive_folder
```

/mnt/splicedice_small_example_archives/chr1_10M_2025.10.03_22.12.47

