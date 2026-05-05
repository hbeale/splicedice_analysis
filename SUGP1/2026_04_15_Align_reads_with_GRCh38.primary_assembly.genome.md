# Summary

This code aligns fastq data available from SRA. 

The data is RNA_seq from experiments comparing HEK293T cells transfected with control siRNA to those transfected with siSUGP1.  There are three  biological replicates of each condition. 

SRR ids: SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028

# Server

hbeale_mesa

10.50.100.135



# Reference data

(Currently already downloaded. Following instructions are if it needs to be re-downloaded)



```
cd /mnt/ref
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf.gz
gzip -d gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf.gz 

wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.primary_assembly.genome.fa.gz
gzip -d GRCh38.primary_assembly.genome.fa.gz
```



# Create index

```
STAR=/mnt/bin/STAR-2.7.11b/source/STAR
mkdir -p /mnt/ref/STAR_GRCh38_gencode_47
fa=/mnt/ref/GRCh38.primary_assembly.genome.fa
gtf=/mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf

$STAR \
--runThreadN 8 \
--runMode genomeGenerate \
--genomeDir /mnt/ref/STAR_GRCh38_gencode_47  \
--genomeFastaFiles $fa \
--sjdbGTFfile $gtf \
--sjdbOverhang 100

# oops
mv /mnt/ref/STAR_GRCh38_gencode_47/ /mnt/ref/STAR_GRCh38_gencode_45/

```

std out

```
ubuntu@hbeale-mesa:/mnt/ref$ $STAR \
--runThreadN 8 \
--runMode genomeGenerate \
--genomeDir /mnt/ref/STAR_GRCh38_gencode_47  \
--genomeFastaFiles $fa \
--sjdbGTFfile $gtf \
--sjdbOverhang 100
        /mnt/bin/STAR-2.7.11b/source/STAR --runThreadN 8 --runMode genomeGenerate --genomeDir /mnt/ref/STAR_GRCh38_gencode_47 --genomeFastaFiles /mnt/ref/GRCh38.primary_assembly.genome.fa --sjdbGTFfile /mnt/ref/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf --sjdbOverhang 100
        STAR version: 2.7.11b   compiled: 2024-12-12T23:32:02+00:00 :/mnt/bin/STAR-2.7.11b/source
Apr 16 23:16:36 ..... started STAR run
Apr 16 23:16:36 ... starting to generate Genome files
Apr 16 23:18:18 ..... processing annotations GTF
Apr 16 23:19:04 ... starting to sort Suffix Array. This may take a long time...
Apr 16 23:19:44 ... sorting Suffix Array chunks and saving them to disk...
Apr 17 00:49:35 ... loading chunks from disk, packing SA...
Apr 17 00:53:13 ... finished generating suffix array
Apr 17 00:53:13 ... generating Suffix Array index
Apr 17 00:59:28 ... completed Suffix Array index
Apr 17 00:59:29 ..... inserting junctions into the genome indices
Apr 17 01:04:59 ... writing Genome to disk ...
Apr 17 01:05:00 ... writing Suffix Array to disk ...
Apr 17 01:09:11 ... writing SAindex to disk
Apr 17 01:09:31 ..... finished successfully
ubuntu@hbeale-mesa:/mnt/ref$ mv /mnt/ref/STAR_GRCh38_gencode_47/ /mnt/ref/STAR_GRCh38_gencode_45/
ubuntu@hbeale-mesa:/mnt/ref$ ls -alth !$
ls -alth /mnt/ref/STAR_GRCh38_gencode_45/
total 28G
drwxrwxrwx 7 ubuntu ubuntu 4.0K Apr 17 16:19 ..
-rw-rw-r-- 1 ubuntu ubuntu  45M Apr 17 01:09 Log.out
drwxrwxr-x 2 ubuntu ubuntu 4.0K Apr 17 01:09 .
-rw-rw-r-- 1 ubuntu ubuntu 1.5G Apr 17 01:09 SAindex
-rw-rw-r-- 1 ubuntu ubuntu  24G Apr 17 01:08 SA
-rw-rw-r-- 1 ubuntu ubuntu 3.0G Apr 17 01:05 Genome
-rw-rw-r-- 1 ubuntu ubuntu  818 Apr 17 01:04 genomeParameters.txt
-rw-rw-r-- 1 ubuntu ubuntu 8.4M Apr 17 00:59 sjdbInfo.txt
-rw-rw-r-- 1 ubuntu ubuntu 7.4M Apr 17 00:59 sjdbList.out.tab
-rw-rw-r-- 1 ubuntu ubuntu 1.2K Apr 16 23:18 chrLength.txt
-rw-rw-r-- 1 ubuntu ubuntu 2.0K Apr 16 23:18 chrName.txt
-rw-rw-r-- 1 ubuntu ubuntu 3.2K Apr 16 23:18 chrNameLength.txt
-rw-rw-r-- 1 ubuntu ubuntu 2.1K Apr 16 23:18 chrStart.txt
-rw-rw-r-- 1 ubuntu ubuntu 9.1M Apr 16 23:18 sjdbList.fromGTF.out.tab
-rw-rw-r-- 1 ubuntu ubuntu  13M Apr 16 23:18 exonInfo.tab
-rw-rw-r-- 1 ubuntu ubuntu 7.6M Apr 16 23:18 transcriptInfo.tab
-rw-rw-r-- 1 ubuntu ubuntu 2.6M Apr 16 23:18 geneInfo.tab
-rw-rw-r-- 1 ubuntu ubuntu  29M Apr 16 23:18 exonGeTrInfo.tab
ubuntu@hbeale-mesa:/mnt/ref$ 

```





## download more sequences

### install sra-tools

```
cd /mnt/scratch
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.4.1/setup-apt.sh
sudo bash ./setup-apt.sh
source /etc/profile.d/sra-tools.sh
cd /usr/local/ncbi/sra-tools/bin
./vdb-config -i

```



### config sra-tools

user-repository

/mnt/scratch/sra_tools_cache

process-local location

/mnt/scratch/sra_tools_process_local





```
 location of user-repository:                                                                                          
   [ choose ]   /mnt/scratch/sra_tools_cache                                                                 
   
  process-local location:                                                                                               
   [ choose ]   /mnt/scratch/sra_tools_process_local                                                                 

```

test

```
fastq-dump --stdout -X 2 SRR390728
```

```
2026-04-17T16:36:24 fastq-dump.3.4.1 int: timeout exhausted while reading file within network system module - cannot Get Cloud Location
Read 2 spots for SRR390728
Written 2 spots for SRR390728
@SRR390728.1 1 length=72
CATTCTTCACGTAGTTCTCGAGCCTTGGTTTTCAGCGATGGAGAATGACTTTGACAAGCTGAGAGAAGNTNC
+SRR390728.1 1 length=72
;;;;;;;;;;;;;;;;;;;;;;;;;;;9;;665142;;;;;;;;;;;;;;;;;;;;;;;;;;;;;96&&&&(
@SRR390728.2 2 length=72
AAGTAGGTCTCGTCTGTGTTTTCTACGAGCTTGTGTTCCAGCTGACCCACTCCCTGGGTGGGGGGACTGGGT
+SRR390728.2 2 length=72
;;;;;;;;;;;;;;;;;4;;;;3;393.1+4&&5&&;;;;;;;;;;;;;;;;;;;;;<9;<;;;;;464262
ubuntu@hbeale-mesa:/mnt/scratch$ 

```



### download

```
SRR12801027 
SRR12801028
```

SRR12801027 HEK293T cells transfected with siRNA Control (replicate #3)
SRR12801028 HEK293T cells transfected with siSUGP1 (replicate #3)



```
fastq_dir=/mnt/data/fastq/

srr=SRR12801027
fastq-dump --skip-technical --readids  --origfmt --split-3 --clip $srr
pigz ${srr}_2.fastq
pigz ${srr}_1.fastq

mkdir $fastq_dir/$srr
mv ${srr}_1.fastq.gz $fastq_dir/$srr/
mv ${srr}_2.fastq.gz $fastq_dir/$srr/


srr=SRR12801028
fastq-dump --skip-technical --readids  --origfmt --split-3 --clip $srr
pigz ${srr}_2.fastq
pigz ${srr}_1.fastq

mkdir $fastq_dir/$srr
mv ${srr}_1.fastq.gz $fastq_dir/$srr/
mv ${srr}_2.fastq.gz $fastq_dir/$srr/



```

in progress 2026.04.17_11.08.34



```
ubuntu@hbeale-mesa:/mnt/scratch$ fastq-dump --skip-technical --readids  --origfmt --split-3 --clip $srr
Read 43744871 spots for SRR12801027
Written 43744871 spots for SRR12801027
Read 46038861 spots for SRR12801028
Written 46038861 spots for SRR12801028
```



```

```



# Align sequences

for consistency, based on /mnt/mustard_scratch/erj_public/Jurica_SSA/scripts/SSA100_star.sh

NEXT TIME, ADD SEPARATION TO outFileNamePrefix, E.G. CHANGE --outFileNamePrefix ${bam_output_dir}${id}  to --outFileNamePrefix ${bam_output_dir}${id}_

add [SRR12801027](https://trace.ncbi.nlm.nih.gov/Traces/sra?run=SRR12801027) and [SRR12801028](https://trace.ncbi.nlm.nih.gov/Traces/sra?run=SRR12801028)

note, this version of the star alignment process uses Brooks lab standard references: GRCh38.primary_assembly.genome.fa.gz https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.primary_assembly.genome.fa.gz and gencode.v45.chr_patch_hapl_scaff.annotation.gtf from  https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.chr_patch_hapl_scaff.annotation.gtf.gz

```
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
STAR=/mnt/bin/STAR-2.7.11b/source/STAR
version=star_2.7.11b_2026.04.16


for id in $ids; do
fastq_dir=/mnt/data/fastq/
bam_output_dir=/mnt/output/${version}/$id/
mkdir -p $bam_output_dir
fq1=${fastq_dir}${id}/${id}_*1.fastq.gz
fq2=${fq1/1.fastq.gz/2.fastq.gz}
ls $fq1
ls $fq2
$STAR --runThreadN 8 \
     --genomeDir /mnt/ref/STAR_GRCh38_gencode_45 \
     --readFilesIn  $fq1 $fq2 \
     --outFileNamePrefix ${bam_output_dir}${id}_ \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes Standard \
     --quantMode GeneCounts \
     --twopassMode Basic \
     --readFilesCommand zcat
done 
/home/ubuntu/alert_msg.sh alignments_complete



```

```
...
Apr 21 03:17:40 ..... finished mapping
Apr 21 03:17:44 ..... started sorting BAM
Apr 21 03:20:32 ..... finished successfully
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/fastq$ 
```



## check file sizes

```

ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
for id in $ids; do 
ls -aRlth /mnt/output/star_2.7.11b_2026.04.16/${id}/*.bam
done



```

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch$ for id in $ids; do 
ls -aRlth /mnt/output/star_2.7.11b_2026.04.16/${id}/*.bam
done
-rw-rw-r-- 1 ubuntu ubuntu 2.6G Apr 21 00:02 /mnt/output/star_2.7.11b_2026.04.16/SRR12801019/SRR12801019_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu 3.4G Apr 21 00:44 /mnt/output/star_2.7.11b_2026.04.16/SRR12801020/SRR12801020_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu 2.8G Apr 21 01:18 /mnt/output/star_2.7.11b_2026.04.16/SRR12801023/SRR12801023_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu 3.2G Apr 21 01:59 /mnt/output/star_2.7.11b_2026.04.16/SRR12801024/SRR12801024_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu 3.1G Apr 21 02:37 /mnt/output/star_2.7.11b_2026.04.16/SRR12801027/SRR12801027_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu 3.3G Apr 21 03:19 /mnt/output/star_2.7.11b_2026.04.16/SRR12801028/SRR12801028_Aligned.sortedByCoord.out.bam
(splicedice_env) ubuntu@hbeale-mesa:/mnt/scratch$ 

```



```
for i in `find /mnt/output/star_2.7.11b_2026.04.16/ -iname Log.final.out`; do  echo $i; cat $i | grep "reads unmapped: too short" ; echo;  done
```





# rename bam files, index them and put them on public

```
cat $bam_manifest | cut -f1,2 | while read id bam_file; do
echo $id
#ls -alth /mnt/output/star_2.7.11b_2026.04.16/$id/${id}.*bam*
new_bam_name=/mnt/output/star_2.7.11b_2026.04.16/$id/${id}.bam
if [ -e  $bam_file ];
then
echo gotta move the file
mv $bam_file  /mnt/output/star_2.7.11b_2026.04.16/$id/${id}.bam
fi
if [ ! -e  ${new_bam_name}.bai ]
then
echo no index yet
samtools index $new_bam_name
fi
done


```

## tar up bam files

```
cat $bam_manifest | cut -f1,2 | while read id bam_file; do
echo -n /mnt/output/star_2.7.11b_2026.04.16/$id/${id}.bam.bai /mnt/output/star_2.7.11b_2026.04.16/$id/${id}.bam " "
done

```

/mnt/output/star_2.7.11b_2026.04.16/SRR12801019/SRR12801019.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801020/SRR12801020.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801023/SRR12801023.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801024/SRR12801024.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801027/SRR12801027.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801028/SRR12801028.bam

```
cd /mnt/scratch 
tar -cvzf SRP286876_bams.tgz  /mnt/output/star_2.7.11b_2026.04.16/SRR12801019/SRR12801019.bam.bai /mnt/output/star_2.7.11b_2026.04.16/SRR12801019/SRR12801019.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801020/SRR12801020.bam.bai /mnt/output/star_2.7.11b_2026.04.16/SRR12801020/SRR12801020.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801023/SRR12801023.bam.bai /mnt/output/star_2.7.11b_2026.04.16/SRR12801023/SRR12801023.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801024/SRR12801024.bam.bai /mnt/output/star_2.7.11b_2026.04.16/SRR12801024/SRR12801024.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801027/SRR12801027.bam.bai /mnt/output/star_2.7.11b_2026.04.16/SRR12801027/SRR12801027.bam /mnt/output/star_2.7.11b_2026.04.16/SRR12801028/SRR12801028.bam.bai /mnt/output/star_2.7.11b_2026.04.16/SRR12801028/SRR12801028.bam 
```

## transfer

```
scp /mnt/scratch/SRP286876_bams.tgz hcbeale@courtyard.gi.ucsc.edu:/public/groups/treehouse/public_html/SRP286876/
```



## untar

```
tar -tf SRP286876_bams.tgz
tar -tf SRP286876_bams.tgz --strip-components 4 --show-transformed
tar -t --strip-components 4 -xf SRP286876_bams.tgz

```

 # 
