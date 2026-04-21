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
fq2=${fq1/pass_1/pass_2}
ls $fq1
ls $fq2
$STAR --runThreadN 8 \
     --genomeDir /mnt/ref/STAR_GRCh38_gencode_45 \
     --readFilesIn  $fq1 $fq2 \
     --outFileNamePrefix ${bam_output_dir}${id} \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes Standard \
     --quantMode GeneCounts \
     --twopassMode Basic \
     --readFilesCommand zcat
done 
/home/ubuntu/alert_msg.sh alignments_complete

for id in $ids; do
mv /mnt/output/${version}/$id/${id}Aligned.sortedByCoord.out.bam /mnt/output/${version}/$id/${id}.bam
done

```

something weird happened; the output files are really small, like 50MB



```
for i in `find . -iname Log.final.out`; do  echo $i; cat $i | grep "reads unmapped: too short" ; echo;  done
```





```
./SRR12801019/SRR12801019_STARpass1/Log.final.out
            Number of reads unmapped: too short |       34041211
                 % of reads unmapped: too short |       99.09%

./SRR12801020/SRR12801020_STARpass1/Log.final.out
            Number of reads unmapped: too short |       46359594
                 % of reads unmapped: too short |       99.12%

./SRR12801023/SRR12801023_STARpass1/Log.final.out
            Number of reads unmapped: too short |       36057547
                 % of reads unmapped: too short |       99.07%

./SRR12801024/SRR12801024_STARpass1/Log.final.out
            Number of reads unmapped: too short |       43768151
                 % of reads unmapped: too short |       99.17%

./SRR12801027/SRR12801027_STARpass1/Log.final.out
            Number of reads unmapped: too short |       43329512
                 % of reads unmapped: too short |       99.05%

./SRR12801028/SRR12801028_STARpass1/Log.final.out
            Number of reads unmapped: too short |       45649537
                 % of reads unmapped: too short |       99.15%
```



per https://github.com/alexdobin/STAR/issues/169, check that reads are in correct order 



```
id=SRR12801027
fq1=/mnt/data/fastq/${id}/${id}*_1.fastq.gz
fq2=${fq1/_1/_2}
ls $fq2

zcat  $fq1  | head
zcat  $fq2 | head



```



blat

```
GNCTGCTTTTCCCCTATGATTTAAAAATTCCAATGACTTTCGCCCTTGGGAGAAATTTCCAAGGAAATCTCTCTCGCTCGCTCTCTCCGTTTTCCTTTGTG
```

```
   ACTIONS                  QUERY   SCORE START   END QSIZE IDENTITY  CHROM                STRAND  START       END   SPAN
--------------------------------------------------------------------------------------------------------------------------
browser new tab details YourSeq   100     1   101   101   100.0%  chr20                +    47657970  47658070    101
```



```
   ACTIONS                  QUERY   SCORE START   END QSIZE IDENTITY  CHROM                STRAND  START       END   SPAN
--------------------------------------------------------------------------------------------------------------------------
browser new tab details YourSeq    99     2   100   100   100.0%  chr20                -    47658027  47658125     99
```



# Align it to the old indices to see if that's any better

STAR_Homo_sapiens_GRCh38_gencode_47



```
this_ref=STAR_Homo_sapiens_GRCh38_gencode_47
ids="SRR12801019 SRR12801020 SRR12801023 SRR12801024 SRR12801027 SRR12801028"
STAR=/mnt/bin/STAR-2.7.11b/source/STAR
version=star_2.7.11b_2026.04.20_09.27.43


for id in $ids; do
fastq_dir=/mnt/data/fastq/
bam_output_dir=/mnt/output/${version}/$id/
mkdir -p $bam_output_dir
fq1=${fastq_dir}${id}/${id}_*1.fastq.gz
fq2=${fq1/pass_1/pass_2}
ls $fq1
ls $fq2
$STAR --runThreadN 8 \
     --genomeDir /mnt/ref/$this_ref \
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



Nope; still very few reads aligned

read length is 100 bases

```
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/fastq$ ls -aRlth /mnt/output/star_2.7.11b_2026.04.20_09.27.43/ | grep out.bam
-rw-rw-r-- 1 ubuntu ubuntu  46M Apr 20 18:32 SRR12801028_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu  49M Apr 20 18:10 SRR12801027_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu  43M Apr 20 17:50 SRR12801024_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu  41M Apr 20 17:29 SRR12801023_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu  49M Apr 20 17:10 SRR12801020_Aligned.sortedByCoord.out.bam
-rw-rw-r-- 1 ubuntu ubuntu  38M Apr 20 16:48 SRR12801019_Aligned.sortedByCoord.out.bam
(splicedice_env) ubuntu@hbeale-mesa:/mnt/data/fastq$ 

```



# try aligning different data



```
id=ERR2178362
STAR=/mnt/bin/STAR-2.7.11b/source/STAR
version=star_2.7.11b_2026.04.16


#for id in $ids; do
fastq_dir=/mnt/data/fastq/
bam_output_dir=/mnt/output/${version}/$id/
mkdir -p $bam_output_dir
fq1=${fastq_dir}${id}/${id}_*1.fastq.gz
fq2=${fq1/_1/_sdfdsf2}
ls $fq1
ls $fq2


if [[ -f "$fq1" && -f "$fq2" ]]; then
    echo "Both files exist"
    $STAR --runThreadN 8 \
     --genomeDir /mnt/ref/STAR_GRCh38_gencode_45 \
     --readFilesIn  $fq1 $fq2 \
     --outFileNamePrefix ${bam_output_dir}${id}_ \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes Standard \
     --quantMode GeneCounts \
     --twopassMode Basic \
     --readFilesCommand zcat
else
    echo "fastq files do not exist"
fi
#done 
/home/ubuntu/alert_msg.sh alignments_complete




```

# OK, i think i understand now



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

something weird happened; the output files are really small, like 50MB
