# 2026_06_11_Compare_splicedice_multi-sample_and_single_sample_approaches



# Setup

## server

ubuntu@hbeale-clin-validation

ssh ubuntu@10.50.100.128



## copy_files from hbeale-mesa

```

f=/mnt/ref/GRCh38.primary_assembly.genome.fa
f=/mnt/ref/GRCh38.primary_assembly.genome.fa.fai
scp ubuntu@10.50.100.135:/$f `dirname $f`

f=/mnt/git_code/gdc-user-token.2026-05-28T20_33_35.481Z.txt
scp ubuntu@10.50.100.135:$f /mnt/git_code/

```





## install gdc-client

or install from download

```
cd /mnt/scratch
wget https://gdc.cancer.gov/system/files/public/file/gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
sudo apt install unzip 
unzip gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
unzip gdc-client_2.3_Ubuntu_x64.zip
./gdc-client
```

(do not do this:

install python

```
sudo apt update && sudo apt upgrade -y 
sudo apt install python3 python3-pip python3-venv python3-dev -y 
```



```
cd /mnt/git_code
git clone https://github.com/NCI-GDC/gdc-client.git
cd gdc-client/bin
./package

```

# Download selected bam files



```
token_file=/mnt/git_code/gdc-user-token.2026-05-28T20_33_35.481Z.txt
manifest=/mnt/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_manifest.2026.05.28.tsv

mkdir -p /mnt/data/tcga/
cat $manifest | head -11 | grep -v filename | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file $token_file $id

else
echo "File  $f is already present. Moving along"
fi

done

~/alert_msg.sh "gdc download of some tcga  data complete"


```

std out

```

567c5d5f-2b27-4070-86c3-3905d06ed02b f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:04:20  43.7 MiB/s 
100% [#############################################################################################################] Time:  0:00:05 948.3 KiB/s 
Successfully downloaded: 1

cae0680e-f7bf-4742-aeca-8fac6d4f4934 2a48ffd2-9212-48f4-a836-7572eb2feffe.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/cae0680e-f7bf-4742-aeca-8fac6d4f4934/2a48ffd2-9212-48f4-a836-7572eb2feffe.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:01:41  59.0 MiB/s 
100% [############################################################################################################] Time:  0:00:04 1008.4 KiB/s 
Successfully downloaded: 1

e5976aee-2a56-457c-80e5-00824254f6f8 461cd8f2-fe53-448d-b6a9-0a95792464c7.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/e5976aee-2a56-457c-80e5-00824254f6f8/461cd8f2-fe53-448d-b6a9-0a95792464c7.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:01:07  58.3 MiB/s 
100% [#############################################################################################################] Time:  0:00:04 782.8 KiB/s 
Successfully downloaded: 1

6dee9448-b65a-498e-9490-7c282fb3b07d 593623b6-0f7d-4089-8697-518c573c86c6.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/6dee9448-b65a-498e-9490-7c282fb3b07d/593623b6-0f7d-4089-8697-518c573c86c6.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:02:52  61.1 MiB/s 
100% [#############################################################################################################] Time:  0:00:04   1.1 MiB/s 
Successfully downloaded: 1

4d6609e2-6ad0-43a1-9bda-fbc4710e1da0 ebf8d429-0437-4987-9bca-89e62910f168.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/4d6609e2-6ad0-43a1-9bda-fbc4710e1da0/ebf8d429-0437-4987-9bca-89e62910f168.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:02:19  59.3 MiB/s 
100% [#############################################################################################################] Time:  0:00:03   1.3 MiB/s 
Successfully downloaded: 1

a6f82885-da83-49d5-ad43-966b9dff4ea5 c6acc762-3909-4cc0-91c7-f66bc3f0e667.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/a6f82885-da83-49d5-ad43-966b9dff4ea5/c6acc762-3909-4cc0-91c7-f66bc3f0e667.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:02:35  59.8 MiB/s 
100% [#############################################################################################################] Time:  0:00:08 573.6 KiB/s 
Successfully downloaded: 1

1f8160a9-4e65-4d8f-a83d-39b6e03b38f3 f6108b9b-e02f-4608-bec3-bcc0112d05b4.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/1f8160a9-4e65-4d8f-a83d-39b6e03b38f3/f6108b9b-e02f-4608-bec3-bcc0112d05b4.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:01:15  58.4 MiB/s 
100% [############################################################################################################] Time:  0:00:03 1008.6 KiB/s 
Successfully downloaded: 1

073e7f71-5583-48fc-a037-4f799ec2d811 6200626d-556e-400d-81f4-e397ce49585f.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/073e7f71-5583-48fc-a037-4f799ec2d811/6200626d-556e-400d-81f4-e397ce49585f.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:01:12  58.6 MiB/s 
100% [#############################################################################################################] Time:  0:00:03   1.1 MiB/s 
Successfully downloaded: 1

af2f19ca-dc08-43b6-ae40-811cb952887a b573a788-d117-48b0-9cab-c4ecbde82706.rna_seq.genomic.gdc_realn.bam
File  /mnt/data/tcga/af2f19ca-dc08-43b6-ae40-811cb952887a/b573a788-d117-48b0-9cab-c4ecbde82706.rna_seq.genomic.gdc_realn.bam  does not exist. Downloading
100% [#############################################################################################################] Time:  0:02:27  59.8 MiB/s 
100% [#############################################################################################################] Time:  0:00:03   1.4 MiB/s 
Successfully downloaded: 1
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
ubuntu@hbeale-clin-validation:/mnt/git_code$ 
```

# MULTI-SAMPLE APPROACH

## Run IP

### Make subset manifest

```
base_code_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
ip_manifest=${base_code_dir}/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
ip_manifest_10=${ip_manifest/.tsv}.10_sample.tsv

cat $ip_manifest | head -11 > $ip_manifest_10

```

### IP script

```
script=${base_code_dir}/run_ip_on_bam_files_v2.sh
bash $script $ip_manifest_10
```

script: https://github.com/hbeale/splicedice_analysis/blob/b795f959e4b0e9557049a6d862def1944b8e67d0/2026-05_TCGA_IP_splicedice_PS_compute/run_ip_on_bam_files_v2.sh

std out

```
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute$ bash $script $ip_manifest_10
intron-prospector 1.5.1 https://github.com/diekhans/intron-prospector
/mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam for TCGA-86-8074-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-86-8074-01A.bed for TCGA-86-8074-01A does not exist
Warning: genomic sequence not found for chr1_KI270706v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available
...

/mnt/data/tcga/cae0680e-f7bf-4742-aeca-8fac6d4f4934/2a48ffd2-9212-48f4-a836-7572eb2feffe.rna_seq.genomic.gdc_realn.bam for TCGA-62-8402-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-62-8402-01A.bed for TCGA-62-8402-01A does not exist
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270713v1_random splice junctions not available
...
/mnt/data/tcga/e5976aee-2a56-457c-80e5-00824254f6f8/461cd8f2-fe53-448d-b6a9-0a95792464c7.rna_seq.genomic.gdc_realn.bam for TCGA-86-8358-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-86-8358-01A.bed for TCGA-86-8358-01A does not exist
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available

...
/mnt/data/tcga/6dee9448-b65a-498e-9490-7c282fb3b07d/593623b6-0f7d-4089-8697-518c573c86c6.rna_seq.genomic.gdc_realn.bam for TCGA-86-8056-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-86-8056-01A.bed for TCGA-86-8056-01A does not exist
Warning: genomic sequence not found for chr1_KI270706v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available
...
Warning: genomic sequence not found for chrUn_JTFH01001330v1_decoy splice junctions not available

/mnt/data/tcga/4d6609e2-6ad0-43a1-9bda-fbc4710e1da0/ebf8d429-0437-4987-9bca-89e62910f168.rna_seq.genomic.gdc_realn.bam for TCGA-78-7158-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-78-7158-01A.bed for TCGA-78-7158-01A does not exist
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270712v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270713v1_random splice junctions not available
...
Warning: genomic sequence not found for chrUn_JTFH01001898v1_decoy splice junctions not available

/mnt/data/tcga/a6f82885-da83-49d5-ad43-966b9dff4ea5/c6acc762-3909-4cc0-91c7-f66bc3f0e667.rna_seq.genomic.gdc_realn.bam for TCGA-49-4507-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-49-4507-01A.bed for TCGA-49-4507-01A does not exist
Warning: genomic sequence not found for chr1_KI270706v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270713v1_random splice junctions not available
...
Warning: genomic sequence not found for chrUn_JTFH01001973v1_decoy splice junctions not available

/mnt/data/tcga/1f8160a9-4e65-4d8f-a83d-39b6e03b38f3/f6108b9b-e02f-4608-bec3-bcc0112d05b4.rna_seq.genomic.gdc_realn.bam for TCGA-49-AARO-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-49-AARO-01A.bed for TCGA-49-AARO-01A does not exist
...
Warning: genomic sequence not found for chrUn_JTFH01001973v1_decoy splice junctions not available

/mnt/data/tcga/073e7f71-5583-48fc-a037-4f799ec2d811/6200626d-556e-400d-81f4-e397ce49585f.rna_seq.genomic.gdc_realn.bam for TCGA-91-8499-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-91-8499-01A.bed for TCGA-91-8499-01A does not exist
...
Warning: genomic sequence not found for chrUn_JTFH01001998v1_decoy splice junctions not available

/mnt/data/tcga/af2f19ca-dc08-43b6-ae40-811cb952887a/b573a788-d117-48b0-9cab-c4ecbde82706.rna_seq.genomic.gdc_realn.bam for TCGA-55-6983-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-55-6983-01A.bed for TCGA-55-6983-01A does not exist
...
Warning: genomic sequence not found for chr1_KI270706v1_random splice junctions not available
/mnt/data/tcga/0fd61331-8363-402b-8d87-88bb39f467d0/534541e5-89a2-46bc-98d3-1fed57d6e4c1.rna_seq.genomic.gdc_realn.bam for TCGA-62-A46Y-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-62-A46Y-01A.bed for TCGA-62-A46Y-01A does not exist
Warning: genomic sequence not found for chr1_KI270706v1_random splice junctions not available
Warning: genomic sequence not found for chr1_KI270711v1_random splice junctions not available


```

## splicedice quant

### make bed manifest

```
base_code_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
ip_manifest=${base_code_dir}/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
ip_manifest_10=${ip_manifest/.tsv}.10_sample.tsv
bed_manifest_10=${ip_manifest_10/intron_prospector/bed}

bed_base=/mnt/data/intron_prospector_runs/common/

cat $ip_manifest_10 | grep -v ^id | cut -f3 | while read TCGA_id; do
echo -e "$TCGA_id\t${bed_base}${TCGA_id}.bed\tother"
done > $bed_manifest_10

```



### Quantify splice junction usage

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
drwxrwxr-x 4 ubuntu ubuntu 38 Jun 12 20:07 ..
drwxrwxr-x 2 ubuntu ubuntu  6 Jun 12 20:07 .


```



```
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest_10 \
-o /mnt/splicedice_ir_example/analysis/
date
 ~/alert_msg.sh "quant run complete"

```

std out

```
Fri Jun 12 20:58:49 UTC 2026
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 10 files...
        Done [0:00:4.96]
Finding clusters from 284452 junctions...
        Done [0:00:2.47]
Writing cluster file...
        Done [0:00:2.62]
Writing junction bed file...
        Done [0:00:1.66]
Gathering junction counts...
        Done [0:00:6.53]
Writing inclusion counts...
        Done [0:00:4.78]
Calculating PS values...
        Done [0:00:6.41]
Writing PS values...
        Done [0:00:4.96]
All done [0:00:34.38]

real    0m47.922s
user    0m0.041s
sys     0m0.053s
Fri Jun 12 20:59:37 UTC 2026
{"status":"OK","nsent":2,"apilimit":"2\/1000"}
```

## intron_coverage

### make bam manifest



```
bam_manifest=${ip_manifest_10/intron_prospector/bam}
cat $ip_manifest_10 | grep -v ^id | while read ugly_id bam_file nice_id; do
bam_file=/mnt/data/tcga/$ugly_id/$bam_file
echo -e "$nice_id\t${bam_file}\tother"
done > $bam_manifest
cat $bam_manifest
cat $bam_manifest | wc -l
```



```
echo "running intron_coverage..."
analysis_base=/mnt/splicedice_ir_example/analysis/
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice intron_coverage \
-b $bam_manifest \
-m ${analysis_base}/_allPS.tsv \
-j ${analysis_base}/_junctions.bed \
-o ${analysis_base}/coverage_output
date
bash ~/alert_msg.sh "intron_coverage complete"


```

std out

```
running intron_coverage...
Fri Jun 12 21:09:52 UTC 2026
getting paths for bam files
creating junction percentiles
Your runtime was 20847.825365304947 seconds.

real    347m33.881s
user    0m1.629s
sys     0m0.162s
Sat Jun 13 02:57:26 UTC 2026
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
```

## ir_table

```
this_docker=splicedice_analysis:latest
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
date
time docker run --rm \
-v /mnt/:/mnt \
$this_docker \
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/
date
bash /mnt/scratch/alert_msg.sh intron_table_creation_complete 

```

std out

```
Sat Jun 13 17:16:19 UTC 2026
Starting ir_table with 10 samples
Loading annotation...
Annotation loaded: 673463 annotated junctions. 64.1s
Gathering inclusion counts and clusters...
Loaded 10 samples and 284452 clusters. 68.7s
Collecting junctions across all samples...
getJunctions complete: 113408 junctions. 12.7s
RSD filtering complete: 47927 junctions retained. 87.1s
Junction collection and RSD filtering complete: 47927 junctions retained. 155.8s
Writing IR table...
IR calculated for 10/10 samples
IR table written. 202.9s
Writing RSD table...
RSD calculated for 10/10 samples
RSD table written. 250.0s
Done. Total runtime: 250.0s

real    4m19.200s
user    0m0.061s
sys     0m0.071s
Sat Jun 13 17:20:38 UTC 2026

```

## Cleanup and Archive

```
cd /mnt
this_commit=3a6b2b0
this_description=multi_sample
this_archive_folder=/mnt/splicedice_ir_example_archives/${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

cp -R /mnt/splicedice_ir_example $this_archive_folder
sudo rm -fr /mnt/splicedice_ir_example/analysis/*
```

/mnt/splicedice_ir_example_archives/multi_sample_3a6b2b0_2026.06.15_16.48.07/



get example data for slides 

```

tcga_id=TCGA-78-7158-01A
head /mnt/data/intron_prospector_runs/common/$tcga_id.bed
```



# SINGLE-SAMPLE APPROACH

```
this_commit=bf27d87
this_description=single_sample

```



## Run IP

### Make subset manifest

```
base_code_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
ip_manifest=${base_code_dir}/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
ip_manifest_10=${ip_manifest/.tsv}.10_sample.tsv

# ip_manifest_10 was created above
```

### IP script

```
script=${base_code_dir}/run_ip_on_single_bam_files.sh
this_ip_manifest=$ip_manifest_10
bed_file_dir=/mnt/data/intron_prospector_runs/${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`//
echo $bed_file_dir
mkdir $bed_file_dir

cat $this_ip_manifest | grep -v ^id | while read ugly_id bam_file tcga_id; do
bash $script $ip_manifest_10 $bed_file_dir $tcga_id
done
~/alert_msg.sh "run_ip_on_single_bam_files complete"


```



```
/mnt/data/intron_prospector_runs/single_sample_bf27d87_2026.06.15_17.03.10/
```



std out

```
Warning: genomic sequence not found for chrUn_JTFH01001143v1_decoy splice junctions not available
Warning: genomic sequence not found for chrUn_JTFH01001252v1_decoy splice junctions not available

intron-prospector 1.5.1 https://github.com/diekhans/intron-prospector
/mnt/data/tcga/e5976aee-2a56-457c-80e5-00824254f6f8/461cd8f2-fe53-448d-b6a9-0a95792464c7.rna_seq.genomic.gdc_realn.bam for TCGA-86-8358-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/single_sample_bf27d87_2026.06.15_17.03.10///TCGA-86-8358-01A.bed for TCGA-86-8358-01A does not exist

```





## splicedice quant

### make bed manifest

```

bed_manifest_10=${ip_manifest_10/intron_prospector/single_sample_bf27d87_bed}

bed_file_dir=/mnt/data/intron_prospector_runs/single_sample_bf27d87_2026.06.15_17.03.10/

bed_base=${bed_file_dir}

cat $ip_manifest_10 | grep -v ^id | cut -f3 | while read TCGA_id; do
echo -e "$TCGA_id\t${bed_file_dir}${TCGA_id}.bed\tother"
done > $bed_manifest_10

```

### Quantify splice junction usage

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
drwxrwxr-x 2 ubuntu ubuntu  6 Jun 15 17:13 .
drwxrwxr-x 4 ubuntu ubuntu 38 Jun 12 20:07 ..

```



```
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest_10 \
-o /mnt/splicedice_ir_example/analysis/
date
 ~/alert_msg.sh "quant run complete"

```

std out

```
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example/git_code/splicedice_analysis$ date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest_10 \
-o /mnt/splicedice_ir_example/analysis/
date
 ~/alert_msg.sh "quant run complete"
Mon Jun 15 17:46:41 UTC 2026
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 10 files...
        Done [0:00:4.90]
Finding clusters from 284452 junctions...
        Done [0:00:2.29]
Writing cluster file...
        Done [0:00:2.63]
Writing junction bed file...
        Done [0:00:1.62]
Gathering junction counts...
        Done [0:00:6.97]
Writing inclusion counts...
        Done [0:00:4.82]
Calculating PS values...
        Done [0:00:6.22]
Writing PS values...
        Done [0:00:4.98]
All done [0:00:34.41]
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)

real    0m42.857s
user    0m0.052s
sys     0m0.050s
Mon Jun 15 17:47:23 UTC 2026
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
```



check output

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
-rw-r--r-- 1 root   root   23M Jun 15 17:47 _allPS.tsv
drwxrwxr-x 2 ubuntu ubuntu  98 Jun 15 17:47 .
-rw-r--r-- 1 root   root   14M Jun 15 17:47 _inclusionCounts.tsv
-rw-r--r-- 1 root   root   15M Jun 15 17:46 _junctions.bed
-rw-r--r-- 1 root   root   31M Jun 15 17:46 _allClusters.tsv
drwxrwxr-x 4 ubuntu ubuntu  38 Jun 12 20:07 ..


```

## intron_coverage

###  bam manifest

```
bam_manifest=${ip_manifest_10/intron_prospector/bam} # already generated
cat $bam_manifest
cat $bam_manifest | wc -l
```

```
script=${base_code_dir}/run_intron_coverage_on_bam_files_by_batch.sh
batch_size=2
bash $script $batch_size $bam_manifest
~/alert_msg.sh "run_ip_on_single_bam_files complete"


```

about 45 minutes per batch; 5 batches

std out

```

=== 10 samples still need intron_coverage ===

========================================================
BATCH 1: 2 samples
========================================================

--- running intron_coverage on 2 samples with 2 threads (batch 1) ---
Mon Jun 15 19:24:40 UTC 2026
getting paths for bam files
creating junction percentiles
TCGA-62-8402-01A starting 4.9429614543914795
TCGA-62-8402-01A collected 1060.1510655879974
TCGA-62-8402-01A counted 1901.140501499176
TCGA-62-8402-01A done 1912.6563501358032
Your runtime was 3017.53959274292 seconds.

real    50m25.558s
user    0m0.244s
sys     0m0.075s
Mon Jun 15 20:15:06 UTC 2026
intron_coverage done for batch 1

--- cleaning up BAMs ---
TCGA-86-8074-01A: output confirmed, deleting BAM
TCGA-62-8402-01A: output confirmed, deleting BAM

batch 1 complete

========================================================
BATCH 2: 2 samples
========================================================

--- running intron_coverage on 2 samples with 2 threads (batch 2) ---
Mon Jun 15 20:15:07 UTC 2026
getting paths for bam files
creating junction percentiles
...
TCGA-78-7158-01A done 2487.094586610794
Your runtime was 2618.7910656929016 seconds.

real    43m43.870s
user    0m0.229s
sys     0m0.070s
Mon Jun 15 21:48:08 UTC 2026
intron_coverage done for batch 3

--- cleaning up BAMs ---
TCGA-78-7158-01A: output confirmed, deleting BAM
TCGA-49-4507-01A: output confirmed, deleting BAM

batch 3 complete

========================================================
BATCH 4: 2 samples
========================================================

--- running intron_coverage on 2 samples with 2 threads (batch 4) ---
Mon Jun 15 21:48:09 UTC 2026
...
TCGA-62-A46Y-01A done 1819.8513112068176
Your runtime was 2464.6521503925323 seconds.

real    41m9.433s
user    0m0.207s
sys     0m0.072s
Mon Jun 15 22:57:42 UTC 2026
intron_coverage done for batch 5

--- cleaning up BAMs ---
TCGA-55-6983-01A: output confirmed, deleting BAM
TCGA-62-A46Y-01A: output confirmed, deleting BAM

batch 5 complete

========================================================
All batches complete.
========================================================
{"status":"OK","nsent":2,"apilimit":"4\/1000"}


```



## ir_table



```
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

this_docker=splicedice_analysis:latest

date
time docker run --rm -it \
-v /mnt/:/mnt/ \
$this_docker \
python -u /usr/local/bin/splicedice ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-n 8 \
-o ${base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"


```

std out

```
/mnt/splicedice_ir_example/analysis/run_ir_table_with_edit.2026.06.15_22.58.27.log
```

```
Mon Jun 15 22:58:51 UTC 2026
Starting ir_table with 10 samples
Loading annotation...
Annotation loaded: 673463 annotated junctions. 63.8s
Gathering inclusion counts and clusters...
Loaded 10 samples and 284452 clusters. 68.5s
Collecting junctions across all samples...
getJunctions complete: 113408 junctions. 7.4s
RSD filtering complete: 47927 junctions retained. 23.0s
Junction collection and RSD filtering complete: 47927 junctions retained. 91.6s
Writing IR table...
IR calculated for 10/10 samples
IR table written. 138.8s
Done. Total runtime: 138.8s

real    2m23.903s
user    0m0.059s
sys     0m0.068s
Mon Jun 15 23:01:15 UTC 2026
{"status":"OK","nsent":2,"apilimit":"5\/1000"}
```

## Cleanup and Archive

```
cd /mnt
this_commit=df3c36
this_description=single_sample
this_archive_folder=/mnt/splicedice_ir_example_archives/${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

cp -R /mnt/splicedice_ir_example $this_archive_folder
sudo rm -fr /mnt/splicedice_ir_example/analysis/*
```

/mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41/



```
cd /mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41/analysis
cp _allPS.tsv single_sample_df3c36.10TCGA.allPS.tsv
gzip !$
cp _intron_retention.tsv single_sample_df3c36.10TCGA.intron_retention.tsv
gzip !$

```





# COMPARE SINGLE AND MULTI_SAMPLE PATHS

```
ss_loc=/mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41/
ms_loc=/mnt/splicedice_ir_example_archives/multi_sample_3a6b2b0_2026.06.15_16.48.07/
```



```
diff <(head -1000 $ss_loc/analysis/_allPS.tsv) \
     <(head -1000 $ms_loc/analysis/_allPS.tsv)
```

no difference reported

```
diff $ss_loc/analysis/_allPS.tsv $ms_loc/analysis/_allPS.tsv
```

no difference reported

```
diff -rq $ss_loc/analysis $ms_loc/analysis
```

```
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41$ diff -rq $ss_loc/analysis $ms_loc/analysis
Files /mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41//analysis/_intron_retention.tsv and /mnt/splicedice_ir_example_archives/multi_sample_3a6b2b0_2026.06.15_16.48.07//analysis/_intron_retention.tsv differ
Only in /mnt/splicedice_ir_example_archives/multi_sample_3a6b2b0_2026.06.15_16.48.07//analysis: _intron_retention_RSD.tsv
Only in /mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41//analysis: run_ir_table_with_edit.2026.06.15_22.58.27.log
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_archives/single_sample_df3c36_2026.06.15_23.03.41$ 
```

investigate 

```
diff <(head -1000 $ss_loc/analysis/_intron_retention.tsv | cut -f1 ) \
     <(head -1000 $ms_loc/analysis/_intron_retention.tsv | cut -f1 )
```

```
diff <(head -1 $ss_loc/analysis/_intron_retention.tsv | cut -f1-6 ) \
     <(head -1 $ms_loc/analysis/_intron_retention.tsv | cut -f1-6 )
```

the column order is different

```
diff \
  <(python3 -c "
import sys, csv
rows = list(csv.DictReader(open('$ss_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
cols = sorted(rows[0].keys())
w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t', extrasaction='ignore')
w.writeheader(); w.writerows(rows[:1000])
") \
  <(python3 -c "
import sys, csv
rows = list(csv.DictReader(open('$ms_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
cols = sorted(rows[0].keys())
w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t', extrasaction='ignore')
w.writeheader(); w.writerows(rows[:1000])
")
```

the results are identical; the only difference in the first 1000 rows is the order of the columns

```
diff \
  <(python3 -c "
import sys, csv
rows = list(csv.DictReader(open('$ss_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
cols = sorted(rows[0].keys())
rows.sort(key=lambda r: [r[c] for c in cols])
w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t')
w.writeheader(); w.writerows(rows)
") \
  <(python3 -c "
import sys, csv
rows = list(csv.DictReader(open('$ms_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
cols = sorted(rows[0].keys())
rows.sort(key=lambda r: [r[c] for c in cols])
w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t')
w.writeheader(); w.writerows(rows)
")
```

make sure the results differ if i compare 1000 rows to all rows

```
diff \
  <(python3 -c "
import sys, csv
rows = list(csv.DictReader(open('$ss_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
cols = sorted(rows[0].keys())
rows.sort(key=lambda r: [r[c] for c in cols])
w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t')
w.writeheader(); w.writerows(rows)
") \
  <(python3 -c "
import sys, csv
rows = list(csv.DictReader(open('$ms_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
cols = sorted(rows[0].keys())
rows.sort(key=lambda r: [r[c] for c in cols])
w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t')
w.writeheader(); w.writerows(rows[:1000])
") | head
```

yes, the results differ in that case; the code works





# conclusion: the files are identical after sorting by column name



