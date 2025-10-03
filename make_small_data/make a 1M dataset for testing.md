# make a tiny dataset for testing: chr1:1-1M





Id like it to work on intron retention and splice junctions quantification

consider using the SRR12801019 & co datasets; they're small



it should contain a clear intron retention event and some widely used well-defined junctions

### slice data

````
a="SRR12801019 SRR12801020 SRR12801023 SRR12801024"

for i in $a; do
mkdir /mnt/data/bams/$i 
samtools view -b /mnt/output/star_2.7.11b_2024.12.13/${i}/sortedByCoord.md.bam 1:1-1000000 >/mnt/data/bams/${i}/${i}.ch1_1M.bam
done

````

### make manifest

```
bam_manifest=/mnt/data/manifests/SUGP1_kd_srr_manifest.tsv

a="SRR12801019|control
SRR12801020|SUGP1_kd
SRR12801023|control 
SRR12801024|SUGP1_kd"

for i in $a; do

srr_id=${i/|*}
group=${i/*|}
echo $i $srr_id $group


echo $srr_id /mnt/data/bams/$srr_id/${srr_id}.ch1_1M.bam NA $group | tr " " "\t" >> $bam_manifest

done

```



# Setup (using existing one)

```
source /mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/bin/activate
cd /mnt/splicedice_small_example
```





## Find junctions in bam files

```
bam_manifest=/mnt/data/manifests/SUGP1_kd_srr_manifest.tsv

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
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 4 files...
        Done [0:00:0.01]
Finding clusters from 270 junctions...
        Done [0:00:0.00]
Writing cluster file...
        Done [0:00:0.00]
Writing junction bed file...
        Done [0:00:0.00]
Gathering junction counts...
        Done [0:00:0.01]
Writing inclusion counts...
        Done [0:00:0.00]
Calculating PS values...
/mnt/splicedice_ir_example/git_code/splicedice/splicedice_env/lib/python3.12/site-packages/splicedice/SPLICEDICE.py:306: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
        Done [0:00:0.02]
Writing PS values...
        Done [0:00:0.00]
All done [0:00:0.05]


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
SRR12801019 starting 0.049210548400878906
SRR12801020 starting 0.05065011978149414
SRR12801023 starting 0.05161762237548828
SRR12801024 starting 0.05161166191101074
SRR12801019 collected 2.0765535831451416
SRR12801023 collected 2.3516759872436523
SRR12801020 collected 2.377044439315796
SRR12801024 collected 2.4270472526550293
SRR12801019 counted 3.378032684326172
SRR12801019 done 3.3888442516326904
SRR12801020 counted 3.623176336288452
SRR12801020 done 3.6325602531433105
SRR12801024 counted 3.6372740268707275
SRR12801024 done 3.6481776237487793
SRR12801023 counted 3.815593957901001
SRR12801023 done 3.825488805770874
Your runtime was 3.8479256629943848 seconds.

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



# RESUME HERE

## Review results - nothing interesting

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_small_example/analysis$ cat _intron_retention.tsv 
Junction        SRR12801019     SRR12801020     SRR12801024     SRR12801023
(splicedice_env) ubuntu@hbeale-mesa:/mnt/splicedice_small_example/analysis$ 

```

# Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_small_example_archives/chr1_1M_`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder
mv /mnt/splicedice_small_example $this_archive_folder
```

/mnt/splicedice_small_example_archives/chr1_1M_2025.10.03_21.50.47/