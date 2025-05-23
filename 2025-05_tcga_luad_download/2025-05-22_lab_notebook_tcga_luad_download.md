

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