

install gdc-client

per https://gdc.cancer.gov/access-data/gdc-data-transfer-tool

commands

```
wget https://gdc.cancer.gov/system/files/public/file/gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
unzip gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip 
unzip gdc-client_2.3_Ubuntu_x64.zip
./gdc-client
```

output

```
ubuntu@hbeale-mesa:/mnt/scratch$ wget https://gdc.cancer.gov/system/files/public/file/gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
--2025-05-22 20:16:15--  https://gdc.cancer.gov/system/files/public/file/gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
Resolving gdc.cancer.gov (gdc.cancer.gov)... 54.205.137.83, 34.237.153.112
Connecting to gdc.cancer.gov (gdc.cancer.gov)|54.205.137.83|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 21987739 (21M) [application/zip]
Saving to: ‘gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip’

gdc-client_2.3_Ubuntu_x64-py3.8-u 100%[============================================================>]  20.97M  21.8MB/s    in 1.0s    

2025-05-22 20:16:17 (21.8 MB/s) - ‘gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip’ saved [21987739/21987739]

ubuntu@hbeale-mesa:/mnt/scratch$ unzip gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip 
Archive:  gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
  inflating: gdc-client_2.3_Ubuntu_x64.zip  


```

### usage

```
ubuntu@hbeale-mesa:/mnt/scratch$ ./gdc-client
usage: gdc-client [-h] [--version] {download,upload,settings} ...

The Genomic Data Commons Command Line Client

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit

commands:
  {download,upload,settings}
                        for more information, specify -h after a command
    download            download data from the GDC
    upload              upload data to the GDC
    settings            display default settings

gdc-client error: the following arguments are required: command
ubuntu@hbeale-mesa:/mnt/scratch$ 
```

## select TCGA samples

select TCGA-LUAD project

then select the following

* experimental strategy: RNA-Seq
* Data type: aligned reads
* Workflow type: STAR 2-pass Genome
* tissue type: tumor (NOT NORMAL)


not selected:

* tumor descriptor includes primary (539) and recurrnace (2)
* preservation method (12 FFPE, 83 oct, 446 unknown)
* specimen type includes 389 solid tissue, 152 unknown

download "metadata.repository.2025-05-22.json", "gdc_sample_sheet.2025-05-22.tsv", "gdc_manifest.2025-05-22.132704.txt"

copy gdc_manifest.2025-05-22.132704.txt to /mnt/gitCode

```
cd /mnt/gitCode
head -2 gdc_manifest.2025-05-22.132704.txt > gdc_manifest.2_samples.2025-05-22.132704.txt

```

### get gdc token

go to https://portal.gdc.cancer.gov/, login, in user menu (down arrow to the right of e.g. hbeale), select "download token"

copy to open stack server

secure

```
chmod 600 /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt
```



## download 2 samples as tests

command

```
head -2 gdc_manifest.2025-05-22.132704.txt > gdc_manifest.2_samples.2025-05-22.132704.txt

/mnt/scratch/gdc-client download --manifest /mnt/gitCode/gdc_manifest.2_samples.2025-05-22.132704.txt --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt

```


output

```

ubuntu@hbeale-mesa:/mnt/gitCode$ /mnt/scratch/gdc-client download --manifest /mnt/gitCode/gdc_manifest.2_samples.2025-05-22.132704.txt --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt
ERROR: 704d42ab-3e11-4c3b-a74c-b1e6a30e27c5: Unable to connect to API: (('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))). Is this url correct: 'https://api.gdc.cancer.gov/data/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5'? Is there a connection to the API? Is the server running?
 13% [############                                                                                       ] ETA:   0:03:04  45.6 MiB/s 
```

### check file

```
cd /mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5/
b=325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.bam
samtools view $b | less
```

### what chromosomes are present?
```
ubuntu@hbeale-mesa:/mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5$ samtools view -H $b | grep "^@SQ" | wc -l
2779
ubuntu@hbeale-mesa:/mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5$ samtools view -H $b | grep "^@SQ" | grep decoy | wc -l
2385
ubuntu@hbeale-mesa:/mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5$ samtools view -H $b | grep "^@SQ" | grep HPV | wc -l
189
ubuntu@hbeale-mesa:/mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5$ samtools view -H $b | grep "^@SQ" | grep -v HPV | grep -v decoy| grep chrUn | wc -l
127
ubuntu@hbeale-mesa:/mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5$ samtools view -H $b | grep "^@SQ" | grep -v HPV | grep -v decoy| grep -v chrUn  | grep random | wc -l
42
ubuntu@hbeale-mesa:/mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5$ samtools view -H $b | grep "^@SQ" | grep -v HPV | grep -v decoy| grep -v chrUn  | grep -v random 
@SQ     SN:chr1 LN:248956422
@SQ     SN:chr2 LN:242193529
@SQ     SN:chr3 LN:198295559
@SQ     SN:chr4 LN:190214555
@SQ     SN:chr5 LN:181538259
@SQ     SN:chr6 LN:170805979
@SQ     SN:chr7 LN:159345973
@SQ     SN:chr8 LN:145138636
@SQ     SN:chr9 LN:138394717
@SQ     SN:chr10        LN:133797422
@SQ     SN:chr11        LN:135086622
@SQ     SN:chr12        LN:133275309
@SQ     SN:chr13        LN:114364328
@SQ     SN:chr14        LN:107043718
@SQ     SN:chr15        LN:101991189
@SQ     SN:chr16        LN:90338345
@SQ     SN:chr17        LN:83257441
@SQ     SN:chr18        LN:80373285
@SQ     SN:chr19        LN:58617616
@SQ     SN:chr20        LN:64444167
@SQ     SN:chr21        LN:46709983
@SQ     SN:chr22        LN:50818468
@SQ     SN:chrX LN:156040895
@SQ     SN:chrY LN:57227415
@SQ     SN:chrM LN:16569
@SQ     SN:chrEBV       LN:171823
@SQ     SN:CMV  LN:235646
@SQ     SN:HBV  LN:3215
@SQ     SN:HCV-1        LN:9646
@SQ     SN:HCV-2        LN:9711
@SQ     SN:HIV-1        LN:9181
@SQ     SN:HIV-2        LN:10359
@SQ     SN:KSHV LN:137969
@SQ     SN:HTLV-1       LN:8507
@SQ     SN:MCV  LN:5387
@SQ     SN:SV40 LN:5243

```

### metadata (alignment methods)

command
```
samtools view -h $b | grep -v "^@SQ" | less
```

```
@HD     VN:1.4  SO:coordinate
@RG     ID:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007       SM:TCGA-44-2659-01A-01R-0946-07 LB:TCGA-44-2659-01A-01R-0946-07 PU:1111
30_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007      PL:ILLUMINA
@PG     ID:STAR PN:STAR VN:2.7.5c       CL:STAR   --runThreadN 8   --genomeDir /var/lib/cwl/stg87825441-3187-4227-8d2e-8346590bc8c3/sta
r-2.7.5c_GRCh38.d1.vd1_gencode.v36   --genomeLoad NoSharedMemory   --readFilesIn /var/lib/cwl/stgdbf1c204-6dee-44a4-a1f2-08bfa3b64f3e/1
11130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007_1P.fq.gz   /var/lib/cwl/stgdbb29cf5-c300-47c9-961a-1a2936f9add3/111130_UNC10-SN254_0310_B
C06BYACXX_GATCAG_L007_2P.fq.gz      --readFilesCommand zcat      --limitSjdbInsertNsj 1200000   --outFileNamePrefix 325c7d6b-292d-46e5-
85d1-785ae8a48c33.pe.   --outSAMtype BAM   Unsorted      --outSAMstrandField intronMotif   --outSAMattributes NH   HI   AS   nM   NM   
ch      --outSAMunmapped Within      --outSAMattrRGline ID:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007   SM:TCGA-44-2659-01A-01R-094
6-07   LB:TCGA-44-2659-01A-01R-0946-07   PU:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007   PL:ILLUMINA      --outFilterType BySJout  
 --outFilterMultimapNmax 20   --outFilterScoreMinOverLread 0.33   --outFilterMatchNminOverLread 0.33   --outFilterMismatchNmax 999   --
outFilterMismatchNoverLmax 0.1   --outFilterIntronMotifs None   --alignIntronMin 20   --alignIntronMax 1000000   --alignMatesGapMax 100
0000   --alignSJoverhangMin 8   --alignSJDBoverhangMin 1   --alignSoftClipAtReferenceEnds Yes   --chimSegmentMin 15   --chimMainSegment
MultNmax 1   --chimJunctionOverhangMin 15   --chimOutType Junctions   SeparateSAMold   WithinBAM   SoftClip      --chimOutJunctionForma
t 1      --quantMode TranscriptomeSAM   GeneCounts      --twopassMode Basic
@PG     ID:samtools     PN:samtools     PP:STAR VN:1.19.2       CL:samtools view -h 325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomi
c.gdc_realn.bam
@CO     user command line: STAR --readFilesIn /var/lib/cwl/stgdbf1c204-6dee-44a4-a1f2-08bfa3b64f3e/111130_UNC10-SN254_0310_BC06BYACXX_G
ATCAG_L007_1P.fq.gz /var/lib/cwl/stgdbb29cf5-c300-47c9-961a-1a2936f9add3/111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007_2P.fq.gz --outSAMattrRGline ID:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007 SM:TCGA-44-2659-01A-01R-0946-07 LB:TCGA-44-2659-01A-01R-0946-07 PU:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007 PL:ILLUMINA --alignIntronMax 1000000 --alignIntronMin 20 --alignMatesGapMax 1000000 --alignSJDBoverhangMin 1 --alignSJoverhangMin 8 --alignSoftClipAtReferenceEnds Yes --chimJunctionOverhangMin 15 --chimMainSegmentMultNmax 1 --chimOutJunctionFormat 1 --chimOutType Junctions SeparateSAMold WithinBAM SoftClip --chimSegmentMin 15 --genomeDir /var/lib/cwl/stg87825441-3187-4227-8d2e-8346590bc8c3/star-2.7.5c_GRCh38.d1.vd1_gencode.v36 --genomeLoad NoSharedMemory --limitSjdbInsertNsj 1200000 --outFileNamePrefix 325c7d6b-292d-46e5-85d1-785ae8a48c33.pe. --outFilterIntronMotifs None --outFilterMatchNminOverLread 0.33 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.1 --outFilterMultimapNmax 20 --outFilterScoreMinOverLread 0.33 --outFilterType BySJout --outSAMattributes NH HI AS nM NM ch --outSAMstrandField intronMotif --outSAMtype BAM Unsorted --outSAMunmapped Within --quantMode TranscriptomeSAM GeneCounts --readFilesCommand zcat --runThreadN 8 --twopassMode Basic

```

note @PG indciates the program used as reocrded by STAR, while @CO is a text comment added by the user. here they seem very similar

### conclusions
reads were aligned with STAR 2.7.5c to indices created from GRCh38 and gencode 36. Basic two pass alignment was used. 


### read data example

```

UNC10-SN254:310:C06BYACXX:7:1108:19446:116662   163     chr1    10282   255     12M36S  =       633893  623659  CCCTAACCCCAAATATCTCATCAAAAACCGTCTAATCACCACCCACCA       BB8=D?D+A@?D?EHBB<FHI>HH9CG8E888?D*?9BD?GHHIG1DF        NH:i:1  HI:i:1  AS:i:53 nM:i:1  NM:i:0  RG:Z:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007
UNC10-SN254:310:C06BYACXX:7:2104:6409:32452     89      chr1    10562   1       48M     *       0       0       ACGCAGCTCCGCCCTCGCGGTGCTCTCCGGGTCTGTGCTGAGGAGAAC       DDDDDDD@DHJJJJJJIJJJJJJIJJIJIJJIJJJHHHHHFFFFFCCC        NH:i:3  HI:i:1  AS:i:47 nM:i:0  NM:i:0  RG:Z:111130_UNC10-SN254_0310_BC06BYACXX_GATCAG_L007
```

## what happens if you try to re-download a file
hopefully it ignores it,
no, it takes a minute to check it



## download 10 more samples as tests

move manifests around
```
cd /mnt/gitCode/
mkdir  /mnt/gitCode/gdc_manifests
mv gdc_manifest.* gdc_manifests
cd  /mnt/gitCode/gdc_manifests
head -1 gdc_manifest.2025-05-22.132704.txt > gdc_manifest.header.2025-05-22.132704.txt 
```

command

```

head -12 gdc_manifest.2025-05-22.132704.txt > gdc_manifest.12_samples.2025-05-22.132704.txt
```

command

```
head -3 gdc_manifest.12_samples.2025-05-22.132704.txt | grep -v filename | while read id filename other; do 

echo $id $filename
# ls /mnt/data/tcga/$id/$filename; 
if ! [ -f /path/to/file ]; then
echo "File /mnt/data/tcga/$id/$filename does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
echo "File /mnt/data/tcga/$id/$filename is already present. Moving along"

fi

done

```

std out

```
done
704d42ab-3e11-4c3b-a74c-b1e6a30e27c5 325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.bam
File /mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5/325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.bam does not exist. Downloading
ERROR: 704d42ab-3e11-4c3b-a74c-b1e6a30e27c5: Unable to connect to API: (('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))). Is this url correct: 'https://api.gdc.cancer.gov/data/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5'? Is there a connection to the API? Is the server running?
Successfully downloaded: 1
d1945e55-eaa9-41f3-8017-380ccd112dfc 59a0b90e-8b8b-41b8-95f0-d51961a94be5.rna_seq.genomic.gdc_realn.bam
File /mnt/data/tcga/d1945e55-eaa9-41f3-8017-380ccd112dfc/59a0b90e-8b8b-41b8-95f0-d51961a94be5.rna_seq.genomic.gdc_realn.bam does not exist. Downloading
ERROR: d1945e55-eaa9-41f3-8017-380ccd112dfc: Unable to connect to API: (('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))). Is this url correct: 'https://api.gdc.cancer.gov/data/d1945e55-eaa9-41f3-8017-380ccd112dfc'? Is there a connection to the API? Is the server running?
100% [###################################################################################################] Time:  0:01:22  38.8 MiB/s
100% [###################################################################################################] Time:  0:00:05 735.4 KiB/s
ERROR: ('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))
WARNING: Unable to download annotations for d1945e55-eaa9-41f3-8017-380ccd112dfc: 'NoneType' object has no attribute 'raise_for_status'
Successfully downloaded: 1
ubuntu@hbeale-mesa:/mnt/gitCode/gdc_manifests$ 

```

see if command is working as expected - nope, now it's fixed

```
head -3 gdc_manifest.12_samples.2025-05-22.132704.txt | grep -v filename | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo $id $filename
# ls $f  
if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

# /mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
echo "File  $f is already present. Moving along"

fi

done

```

## download 50 samples

commands

```
n=50
manifest_dir=/mnt/gitCode/gdc_manifests
base_manifest=${manifest_dir}/gdc_manifest.2025-05-22.132704.txt
this_manifest=${manifest_dir}/gdc_manifest.${n}_samples.2025-05-22.132704.txt


head -${n} $base_manifest > $this_manifest

cat $this_manifest | grep -v filename | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

# ls $f  

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
echo "File  $f is already present. Moving along"

fi

done

```


output


```
704d42ab-3e11-4c3b-a74c-b1e6a30e27c5 325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/704d42ab-3e11-4c3b-a74c-b1e6a30e27c5/325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.bam is already present. Moving along

d1945e55-eaa9-41f3-8017-380ccd112dfc 59a0b90e-8b8b-41b8-95f0-d51961a94be5.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/d1945e55-eaa9-41f3-8017-380ccd112dfc/59a0b90e-8b8b-41b8-95f0-d51961a94be5.rna_seq.genomic.gdc_realn.bam is already present. Moving along

44a3eb8c-135f-44f4-82bd-86fb6104a4e8 f3d482bb-14e8-4569-bee4-22d7d2a027ea.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/44a3eb8c-135f-44f4-82bd-86fb6104a4e8/f3d482bb-14e8-4569-bee4-22d7d2a027ea.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
```

review downloads

```


```

output
```
ubuntu@hbeale-mesa:/mnt/data/tcga$ du -sh 
314G    .
```

next

## bam_to_junc_bed

which TCGA samples have u2af1 mutations?

### make bam manifest
example contents

```
ubuntu@hbeale-mesa:/mnt/data/tcga$ cat ../manifests/bam_manifest.txt
A       /mnt/data/bams/A_U2AF1-KRAS.chr21.bam   WT      LacZ
G       /mnt/data/bams/G_U2AF1-KRAS.chr21.bam   WT      LacZ
M       /mnt/data/bams/M_U2AF1-KRAS.chr21.bam   WT      LacZ
B       /mnt/data/bams/B_U2AF1-KRAS.chr21.bam   MUT     LacZ
H       /mnt/data/bams/H_U2AF1-KRAS.chr21.bam   MUT     LacZ
N       /mnt/data/bams/N_U2AF1-KRAS.chr21.bam   MUT     LacZ
ubuntu@hbeale-mesa:/mnt/data/tcga$ 
```

create manifest containing all samples in gdc manifest

see "analyze manifest downloaded from gdc.md"

output name: bam_manifest.tcga.541_bam_files.tsv

copied to open stack server in /mnt/data/manifests


### select from manifest

```

primary_bam_manifest=/mnt/data/manifests/bam_manifest.tcga.541_bam_files.tsv
this_manifest=/mnt/data/manifests/tcga_1_bams.`date "+%Y.%m.%d_%H.%M.%S"`.txt
echo $this_manifest

```

/mnt/data/manifests/tcga_1_bams.2025.05.28_16.22.21.txt

```
rm -f $this_manifest
cd /mnt/data/tcga
for i in *; do 
expected_file=`cat $primary_bam_manifest | grep $i | cut -f2`
echo $expected_file
if [ -e $expected_file ]; then 
echo file exists
cat $primary_bam_manifest | grep $i >> $this_manifest
fi
done

```

### run bam_to_junc_bed

```

source /mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/bin/activate

this_bam_manifest=/mnt/data/manifests/tcga_1_bams.2025.05.28_16.22.21.txt
genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

new_timestamp=`~/d`
echo $new_timestamp
splicedice_out=/mnt/output/splicedice_${new_timestamp}/ 
mkdir -p $splicedice_out
echo $splicedice_out

time splicedice bam_to_junc_bed -m $this_bam_manifest -o $splicedice_out --genome $genome --annotation $genes --number_threads 4
ls -alth $splicedice_out
bash ~/alertme.sh

```

output

```
/mnt/output/splicedice_2025.05.28_16.35.55/
...
new manifest written to: /mnt/output/splicedice_2025.05.28_16.35.55/_manifest.txt

real    166m20.200s
user    591m1.270s
sys     7m33.580s
total 28K
drwxrwxr-x  3 ubuntu ubuntu   49 May 28 19:22 .
-rw-rw-r--  1 ubuntu ubuntu 9.8K May 28 19:22 _manifest.txt
drwxrwxr-x  2 ubuntu ubuntu 8.0K May 28 19:22 _junction_beds
drwxrwxrwx 16 ubuntu ubuntu 4.0K May 28 16:35 ..
{"status":"OK","nsent":2,"apilimit":"1\/1000"}
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$ 

```

clear disk space

```
cd /mnt/data/tcga
rm -fr *
```


# Batch 2
## download 50 samples

gdc_manifest.50_samples.batch2.2025-05-28.txt created with "analyze manifest downloaded from gdc.qmd" and copied to /mnt/gitCode/gdc_manifests



```
manifest_dir=/mnt/gitCode/gdc_manifests
this_manifest=${manifest_dir}/gdc_manifest.50_samples.batch2.2025-05-28.txt

cat $this_manifest | grep -v filename | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

# ls $f  

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
echo "File  $f is already present. Moving along"

fi

done

```

## check file size and available space


```
du -sh /mnt/data/tcga
df -h | grep "/mnt"


```


output
```
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$  du -sh /mnt/data/tcga
293G    /mnt/data/tcga
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$  df -h | grep "/mnt"
/dev/vdb1       2.0T 1014G  1.1T  50% /mnt


```




### check if the mutant bams were downloaded

```
mutant_ids="33c16d35-96da-4400-9f48-1fc7567e30a4 16b44441-90d4-4289-8248-d31251f49f2b 9eeae6b9-2031-47fa-80db-e04d53f0bfbd 3dbc67a1-c49d-407c-867b-dc453f3aebc0 99c213ba-55b9-42b6-9546-62b8d3f6c284 6f343aec-65e1-44ad-b4db-339d4ed62373 63da5a36-0ec0-4d89-be9d-7319f0eae8ed 0ebf5cc5-f242-45ef-821a-939b51dc95a2 eae099b8-7486-42dc-9565-c875662eb729 e161311b-eb34-42fd-b906-d0b4cfb7c15a aa7245fd-7073-4ff9-88cc-648a2c9f1f60 86c05b02-68d0-473d-8aea-ab501cb40d29"
```

survey

```
for m in $mutant_ids; do echo $m;

if [ -e   /mnt/data/tcga/$m  ]; then
echo "Directory exists. Listing files..."
ls /mnt/data/tcga/$m

else
echo "Directory  $m does not exist"

fi

done

```


short survey

```
for m in $mutant_ids; do 
# echo $m;

if ! [ -e   /mnt/data/tcga/$m  ]; then
echo "Directory  $m does not exist"

fi

done

```

output
```
Directory  e161311b-eb34-42fd-b906-d0b4cfb7c15a does not exist
```


note

```
cat 63da5a36-0ec0-4d89-be9d-7319f0eae8ed/annotations.txt
id      submitter_id    entity_type     entity_id       category        classification  created_datetime        status  notes
2a7c8d73-5b1b-5741-a54a-07224a4b7d05    11951   case    d31aeefc-b59b-42e9-9919-750b17a70a3d    History of acceptable prior treatment related to a prior/other malignancy      Notification    2012-11-10T00:00:00     Approved        Prior malignancy of R breast cancer treated with locoregional radiation. (TCGA tumor from L lung.)
348b0f04-2759-5bb9-985f-bc13df75b529    662     case    d31aeefc-b59b-42e9-9919-750b17a70a3d    Prior malignancy        Notification  2010-09-15T00:00:00      Approved        [intgen.org]: Prior Malignancy(splicedice_env8)
```

### try redownloading failed mutant sample
```

manifest_dir=/mnt/gitCode/gdc_manifests
this_manifest=${manifest_dir}/gdc_manifest.50_samples.batch2.2025-05-28.txt

cat $this_manifest | grep e161311b-eb34-42fd-b906-d0b4cfb7c15a | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

# ls $f  

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
echo "File  $f is already present. Moving along"

fi

done


```

### nope, it still failed

output

```
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$ 
manifest_dir=/mnt/gitCode/gdc_manifests
this_manifest=${manifest_dir}/gdc_manifest.50_samples.batch2.2025-05-28.txt

cat $this_manifest | grep e161311b-eb34-42fd-b906-d0b4cfb7c15a | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

# ls $f  

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
done "File  $f is already present. Moving along"

e161311b-eb34-42fd-b906-d0b4cfb7c15a bae79640-8273-42a2-913e-3d29e00ccc4f.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/e161311b-eb34-42fd-b906-d0b4cfb7c15a/bae79640-8273-42a2-913e-3d29e00ccc4f.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
ERROR: e161311b-eb34-42fd-b906-d0b4cfb7c15a: Unable to connect to API: (('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))). Is this url correct: 'https://api.gdc.cancer.gov/data/e161311b-eb34-42fd-b906-d0b4cfb7c15a'? Is there a connection to the API? Is the server running?
ERROR: e161311b-eb34-42fd-b906-d0b4cfb7c15a: Unable to connect to API: (('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))). Is this url correct: 'https://api.gdc.cancer.gov/data/e161311b-eb34-42fd-b906-d0b4cfb7c15a'? Is there a connection to the API? Is the server running?
ERROR: Unable to download file https://api.gdc.cancer.gov/data/e161311b-eb34-42fd-b906-d0b4cfb7c15a
Successfully downloaded: 0
Failed downloads: 1

```





## create bam manifest from gdc manifest

```
manifest_dir=/mnt/gitCode/gdc_manifests
this_gdc_manifest=${manifest_dir}/gdc_manifest.50_samples.batch2.2025-05-28.txt

```


```

primary_bam_manifest=/mnt/data/manifests/bam_manifest.tcga.541_bam_files.tsv
this_manifest=/mnt/data/manifests/tcga_bams.50_samples.batch2.`date "+%Y.%m.%d_%H.%M.%S"`.txt
echo $this_manifest
this_manifest=/mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt
```

/mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt

```
wc -l $this_manifest
rm -f $this_manifest
wc -l $this_manifest
cd /mnt/data/tcga
for i in *; do 
expected_file=`cat $primary_bam_manifest | grep $i | cut -f2`
echo $expected_file
if [ -e $expected_file ]; then 
echo file exists
cat $primary_bam_manifest | grep $i >> $this_manifest
fi
done
wc -l $this_manifest
head -2 $this_manifest
```

some output

```
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$ wc -l $this_manifest
head -2 $this_manifest
46 /mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt
TCGA-67-6215-01A 0a26152a-462f-4895-8fe8-15fcdcc56e16   /mnt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam unknown solid_tissue
TCGA-86-8075-01A 0c633b9e-3303-4625-b59d-02102d8bf981   /mnt/data/tcga/0c633b9e-3303-4625-b59d-02102d8bf981/5158a031-b856-4423-9418-031b3107e88f.rna_seq.genomic.gdc_realn.bam unknown solid_tissue
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$ 

```


## bam_to_junc_bed

```

source /mnt/scratch_2024.12.09_21.02.52/splicedice/splicedice_env8/bin/activate

this_bam_manifest=/mnt/data/manifests/tcga_bams.50_samples.batch2.2025.05.29_16.01.35.txt
genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

new_timestamp=`~/d`
echo $new_timestamp
splicedice_out=/mnt/output/splicedice_${new_timestamp}/ 
mkdir -p $splicedice_out
echo $splicedice_out

time splicedice bam_to_junc_bed -m $this_bam_manifest -o $splicedice_out --genome $genome --annotation $genes --number_threads 4
ls -alth $splicedice_out
bash ~/alertme.sh

```

output

```
/mnt/output/splicedice_2025.05.29_17.33.38/
...
new manifest written to: /mnt/output/splicedice_2025.05.28_16.35.55/_manifest.txt

real    166m20.200s
user    591m1.270s
sys     7m33.580s
total 28K
drwxrwxr-x  3 ubuntu ubuntu   49 May 28 19:22 .
-rw-rw-r--  1 ubuntu ubuntu 9.8K May 28 19:22 _manifest.txt
drwxrwxr-x  2 ubuntu ubuntu 8.0K May 28 19:22 _junction_beds
drwxrwxrwx 16 ubuntu ubuntu 4.0K May 28 16:35 ..
{"status":"OK","nsent":2,"apilimit":"1\/1000"}
(splicedice_env8) ubuntu@hbeale-mesa:/mnt/data/tcga$ 

```
