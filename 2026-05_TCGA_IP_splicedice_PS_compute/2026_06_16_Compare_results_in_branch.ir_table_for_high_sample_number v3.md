# 2026_06_16_Compare_results_in_branch.ir_table_for_high_sample_number - v3



Most of the code in this is from "2026_06_11_Compare_splicedice_multi-sample_and_single_sample_approaches.md"

**Generate ir from before "ir_table_for_high_sample_number"** is from v1

Multi-sample approach is updated







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

# MULTI-SAMPLE APPROACH part 1 - unchanged

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

# MULTI-SAMPLE APPROACH part 2 - updated

## ir_table



## Setup

### define location

```
this_commit=c1048af
this_description=ir_table_for_high_sample_number_branch
this_base_dir=/mnt/splicedice_ir_example_${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`/
mkdir $this_base_dir
echo $this_base_dir
```

std out

```
/mnt/splicedice_ir_example_ir_table_for_high_sample_number_branch_c1048af_2026.06.16_19.04.50/
```



if you need to redefine this_base_dir in another window:

```
this_base_dir=/mnt/splicedice_ir_example_ir_table_for_high_sample_number_branch_c1048af_2026.06.16_19.04.50/

```

### copy files

```
mkdir -p ${this_base_dir}/analysis
files="_inclusionCounts.tsv _allClusters.tsv coverage_output"
for f in $files; do
echo sudo cp -r /mnt/splicedice_ir_example/analysis/${f} ${this_base_dir}/analysis/
sudo cp -r /mnt/splicedice_ir_example/analysis/${f} ${this_base_dir}/analysis/
done
cp -r /mnt/splicedice_ir_example/git_code ${this_base_dir}/
```



### Update dockerfile

```
cd ${this_base_dir}/git_code/splicedice_analysis/code

```



### Build docker

```
cd ${this_base_dir}/git_code/splicedice_analysis/code
this_dockerfile=Dockerfile_ir_table_for_high_sample_number
this_docker="splicedice_analysis:${this_description}_${this_commit}"
docker build --build-arg CACHE_BUST=$(date +%s) -t $this_docker -f $this_dockerfile .
bash ~/alert_msg.sh "docker build complete"

```

## ir_table

### confirm that it's the new code

```bash
docker run --rm \
$this_docker \
grep -n "getInclusionCounts(countFile)" /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py
```

std out

```bash
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_ir_table_for_high_sample_number_branch_c1048af_2026.06.16_19.04.50/git_code/splicedice_analysis/code$ docker run --rm \
$this_docker \
grep -n "getInclusionCounts(countFile)" /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py
233:    counts = getInclusionCounts(countFile)
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_ir_table_for_high_sample_number_branch_c1048af_2026.06.16_19.04.50/git_code/splicedice_analysis/co
```



### run ir_table

```
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
date
time docker run --rm \
-v /mnt/:/mnt \
$this_docker \
splicedice ir_table \
--annotation $genes \
-i ${this_base_dir}/analysis/_inclusionCounts.tsv \
-c ${this_base_dir}/analysis/_allClusters.tsv \
-d ${this_base_dir}/analysis/coverage_output \
-n 8 \
-o ${this_base_dir}/analysis/
date
bash /mnt/scratch/alert_msg.sh intron_table_creation_complete 

```

std out

```
Tue Jun 16 19:14:15 UTC 2026
Starting ir_table with 10 samples
Loading annotation...
Annotation loaded: 528735 annotated junctions. 54.6s
Gathering inclusion counts and clusters...
Loaded 10 samples and 284452 clusters. 61.2s
Collecting junctions across all samples...
getJunctions complete: 225359 junctions. 6.9s
RSD filtering complete: 94429 junctions retained. 38.7s
Junction collection and RSD filtering complete: 94429 junctions retained. 99.9s
Writing IR table...
IR calculated for 10/10 samples
IR table written. 190.1s
Done. Total runtime: 190.1s

real    3m15.502s
user    0m0.058s
sys     0m0.057s
Tue Jun 16 19:17:30 UTC 2026
{"status":"OK","nsent":2,"apilimit":"12\/1000"}



```



## Cleanup and Archive

```
sudo mv ${this_base_dir} /mnt/splicedice_ir_example_archives/
ls /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
echo /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
```



# attempt 1 - Generate ir from before "ir_table_for_high_sample_number" 

failed because I hadn't pushed the command that fixed negative strand introns

## Setup

### define location

```
this_commit=9a38bc2
this_description=main_branch_multi_sample
this_base_dir=/mnt/splicedice_ir_example_${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`/
mkdir $this_base_dir
echo $this_base_dir
```

std out

```
/mnt/splicedice_ir_example_main_branch_multi_sample_9a38bc2_2026.06.16_16.57.58
```



if you need to redefine this_base_dir in another window:

```
this_base_dir=/mnt/splicedice_ir_example_main_branch_multi_sample_9a38bc2_2026.06.16_16.58.40/
```

### Download repo



```
mkdir -p ${this_base_dir}/git_code ${this_base_dir}/analysis
cd ${this_base_dir}/git_code
git clone https://github.com/hbeale/splicedice_analysis.git

```



### Update dockerfile

```
cd ${this_base_dir}/git_code/splicedice_analysis/code
cat Dockerfile_ir_table_for_high_sample_number | sed 's/branch ir_table_for_high_sample_number/branch master/' > Dockerfile_master_branch
cat Dockerfile_master_branch
```



### Build docker

```
cd ${this_base_dir}/git_code/splicedice_analysis/code
this_dockerfile=Dockerfile_master_branch
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f $this_dockerfile .
bash ~/alert_msg.sh "docker build complete"
```

### copy input

```
files="_inclusionCounts.tsv _allClusters.tsv coverage_output"
for f in $files; do
echo sudo cp -r /mnt/splicedice_ir_example/analysis/${f} ${this_base_dir}/analysis/
sudo cp -r /mnt/splicedice_ir_example/analysis/${f} ${this_base_dir}/analysis/
done
```



## ir_table

### setup

```
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${this_base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

this_docker=splicedice_analysis:latest
```

### run with new argument to confirm that this is old code

```
docker run --rm -it \
-v /mnt/:/mnt/ \
$this_docker \
python -u /usr/local/bin/splicedice ir_table \
--annotation $genes \
-i ${this_base_dir}/analysis/_inclusionCounts.tsv \
-c ${this_base_dir}/analysis/_allClusters.tsv \
-d ${this_base_dir}/analysis/coverage_output \
-n 8 \
-o ${this_base_dir}/ 
```

expected:

splicedice: error: unrecognized arguments: -n 8

### run 

```

date
time docker run --rm -it \
-v /mnt/:/mnt/ \
$this_docker \
python -u /usr/local/bin/splicedice ir_table \
--annotation $genes \
-i ${this_base_dir}/analysis/_inclusionCounts.tsv \
-c ${this_base_dir}/analysis/_allClusters.tsv \
-d ${this_base_dir}/analysis/coverage_output \
-o ${this_base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"

```

std out

```
Tue Jun 16 17:15:14 UTC 2026
Gathering inclusion counts and clusters...

Calculating IR values...
Traceback (most recent call last):
  File "/usr/local/bin/splicedice", line 8, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.8/site-packages/splicedice/__main__.py", line 57, in main
    args.main(args)
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 191, in run_with
    junctions, IR, RSD = calculateIR(samples,coverageDirectory,counts,clusters,annotated,args)
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 140, in calculateIR
    if RSD[sample][junction] < args.RSDthreshold:
KeyError: 'chrX:105755348-105766963:+'

```



# attempt 2 - Generate ir from before "ir_table_for_high_sample_number" 

## Setup

define location

    this_commit=548af48
    this_description=main_branch_multi_sample
    this_base_dir=/mnt/splicedice_ir_example_${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`/
    mkdir $this_base_dir
    echo $this_base_dir

std out

    /mnt/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13/



if you need to redefine this_base_dir in another window:

    this_base_dir=/mnt/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13/

## Download repo



    mkdir -p ${this_base_dir}/git_code ${this_base_dir}/analysis
    cd ${this_base_dir}/git_code
    git clone https://github.com/hbeale/splicedice_analysis.git



## Update dockerfile

    cd ${this_base_dir}/git_code/splicedice_analysis/code
    cat Dockerfile_ir_table_for_high_sample_number | sed 's/branch ir_table_for_high_sample_number/branch master/' > Dockerfile_master_branch
    cat Dockerfile_master_branch
    
    git add Dockerfile_master_branch 
    git commit -m Dockerfile_master_branch
    git push




std out

```

ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13/git_code/splicedice_analysis/code$ git add Dockerfile_master_branch 
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13/git_code/splicedice_analysis/code$ git commit -m Dockerfile_master_branch 
[main d909fcb] Dockerfile_master_branch
 1 file changed, 29 insertions(+)
 create mode 100644 code/Dockerfile_master_branch
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13/git_code/splicedice_analysis/code$ git push
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 12 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 715 bytes | 715.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/hbeale/splicedice_analysis.git
   bbecf36..d909fcb  main -> main
```



## Build docker

    cd ${this_base_dir}/git_code/splicedice_analysis/code
    this_dockerfile=Dockerfile_master_branch
    docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f $this_dockerfile .
    bash ~/alert_msg.sh "docker build complete"

## copy input

    files="_inclusionCounts.tsv _allClusters.tsv coverage_output"
    for f in $files; do
    echo sudo cp -r /mnt/splicedice_ir_example/analysis/${f} ${this_base_dir}/analysis/
    sudo cp -r /mnt/splicedice_ir_example/analysis/${f} ${this_base_dir}/analysis/
    done



## ir_table

### setup

    genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
    log_file=${this_base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
    echo $log_file
    
    this_docker=splicedice_analysis:latest

```
/mnt/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13//run_ir_table_with_edit.2026.06.16_17.38.11.log
```





### run with new argument to confirm that this is old code

    docker run --rm -it \
    -v /mnt/:/mnt/ \
    $this_docker \
    python -u /usr/local/bin/splicedice ir_table \
    --annotation $genes \
    -i ${this_base_dir}/analysis/_inclusionCounts.tsv \
    -c ${this_base_dir}/analysis/_allClusters.tsv \
    -d ${this_base_dir}/analysis/coverage_output \
    -n 8 \
    -o ${this_base_dir}/ 

expected:

splicedice: error: unrecognized arguments: -n 8



## attempt 2a

### 

    date
    time docker run --rm -it \
    -v /mnt/:/mnt/ \
    $this_docker \
    python -u /usr/local/bin/splicedice ir_table \
    --annotation $genes \
    -i ${this_base_dir}/analysis/_inclusionCounts.tsv \
    -c ${this_base_dir}/analysis/_allClusters.tsv \
    -d ${this_base_dir}/analysis/coverage_output \
    -o ${this_base_dir}/ 2>&1 | tee $log_filedate
    date
    /mnt/bin/alert_msg.sh "ir_table complete"




```
Traceback (most recent call last):
  File "/usr/local/bin/splicedice", line 8, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.8/site-packages/splicedice/__main__.py", line 57, in main
    args.main(args)
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 192, in run_with
    junctions, IR, RSD = calculateIR(samples,coverageDirectory,counts,clusters,annotated,args)
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 141, in calculateIR
    if RSD[sample][junction] < args.RSDthreshold:
KeyError: 'chr1:1243553-1243953:-'

```

(I realized that the problem is that i wasn't using the rdstable flag)

### attempt 2b - success

    date
    time docker run --rm -it \
    -v /mnt/:/mnt/ \
    $this_docker \
    python -u /usr/local/bin/splicedice ir_table \
    --annotation $genes \
    --makeRSDtable \
    -i ${this_base_dir}/analysis/_inclusionCounts.tsv \
    -c ${this_base_dir}/analysis/_allClusters.tsv \
    -d ${this_base_dir}/analysis/coverage_output \
    -o ${this_base_dir}/ 2>&1 | tee $log_filedate
    date
    /mnt/bin/alert_msg.sh "ir_table complete"


std out

    Tue Jun 16 17:42:33 UTC 2026
    Gathering inclusion counts and clusters...
    Calculating IR values...
    /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:121: RuntimeWarning: invalid value encountered in scalar divide
      RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
    Done 318.9546172618866
    Writing output...
    
    real    5m28.098s
    user    0m0.075s
    sys     0m0.065s
    Tue Jun 16 17:48:01 UTC 2026
    {"status":"OK","nsent":2,"apilimit":"7\/1000"}





## Cleanup and Archive

```
sudo mv ${this_base_dir} /mnt/splicedice_ir_example_archives/
ls /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
echo /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
```

oops

```bash
cd /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
mv _intron_retention* analysis/

```



# COMPARE before and after ir_table_for_high_sample_number

```
before_loc=/mnt/splicedice_ir_example_archives/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13
after_loc=/mnt/splicedice_ir_example_archives/splicedice_ir_example_ir_table_for_high_sample_number_branch_c1048af_2026.06.16_19.04.50
before_ir=${before_loc}/analysis/_intron_retention.tsv
after_ir=${after_loc}/analysis/_intron_retention.tsv
```

## investigate _intron_retention.tsv



## check line numbers

```bash
wc -l $before_ir
wc -l $after_ir
```

```bash
94430 /mnt/splicedice_ir_example_archives/splicedice_ir_example_main_branch_multi_sample_548af48_2026.06.16_17.31.13/analysis/_intron_retention.tsv
94430 /mnt/splicedice_ir_example_archives/splicedice_ir_example_ir_table_for_high_sample_number_branch_c1048af_2026.06.16_19.04.50/analysis/_intron_retention.tsv

```



## investigate _intron_retention.tsv

are the headings in the same order? yes

```bash
diff <(head -1 $after_loc/analysis/_intron_retention.tsv | cut -f1-6 ) \
     <(head -1 $before_loc/analysis/_intron_retention.tsv | cut -f1-6 )
```



## are the first 1000 rows different? no!

    diff \
      <(python3 -c "
    import sys, csv
    rows = list(csv.DictReader(open('$after_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
    cols = sorted(rows[0].keys())
    w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t', extrasaction='ignore')
    w.writeheader(); w.writerows(rows[:1000])
    ") \
      <(python3 -c "
    import sys, csv
    rows = list(csv.DictReader(open('$before_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
    cols = sorted(rows[0].keys())
    w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t', extrasaction='ignore')
    w.writeheader(); w.writerows(rows[:1000])
    ") | head

## are any rows different? no!

    diff \
      <(python3 -c "
    import sys, csv
    rows = list(csv.DictReader(open('$after_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
    cols = sorted(rows[0].keys())
    w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t', extrasaction='ignore')
    w.writeheader(); w.writerows(rows)
    ") \
      <(python3 -c "
    import sys, csv
    rows = list(csv.DictReader(open('$before_loc/analysis/_intron_retention.tsv'), delimiter='\t'))
    cols = sorted(rows[0].keys())
    w = csv.DictWriter(sys.stdout, fieldnames=cols, delimiter='\t', extrasaction='ignore')
    w.writeheader(); w.writerows(rows)
    ") | head



### zoom in

```bash


pos=chr10:100190969-100193297
f=$after_ir
cat $f | grep $pos | cut -f1,3
f=$before_ir
cat $f | grep $pos | cut -f1,3
```

 ````
 chr10:100190969-100193297:-     0.021
 chr10:100190969-100193297:-     0.021
 ````





# Conclusion

now, with commit c1048af, results from ir_table are identical. 



I need to rerun ir_table for the big TCGA run
