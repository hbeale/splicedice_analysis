

# 2026-05-28_process_TCGA_LUAD_with_splicedice_pipeline



# Goal

* generate a TCGA LUAD demo dataset and resource with percent spliced and intron retention results

## next question:

does the distributed strategy produce identical results to the parallel strategy?



# Strategies

there isn't enough space on my server to download all the bam files at once. 

we need to find introns for each sample (requires bam file; generates bed file), calculate PS values (requires bed files only), then calculate intron coverage (requires bam files and PS file). 

I download each bam file, find introns with intron prospector, and then delete the bam file. 

Then I calculate PS values from the whole cohort at once from the bed files

Then I re-download each bam file, calculate intron coverage, and then delete the bam file. 

Then I calculate intron retention values from the whole cohort at once from the intron coverage files

it's imperfect to download the bam files twice, but it's necessary  given my current constraints





# Server

hbeale-mesa

ssh ubuntu@10.50.100.135

### check space



```
df -h | grep mnt
/dev/vdb1       2.0T  1.5T  607G  71% /mnt
```

## Check reference files

```
ls /mnt/ref/GRCh38.primary_assembly.genome.fa
ls /mnt/ref/gencode.v47.primary_assembly.annotation.gtf

```

if they are not present, obtain them as described in https://github.com/hbeale/splicedice_analysis/blob/main/misc/reference_file_sources.md



# Reset from any previous runs

Confirm example directory space is empty

```
ls -alth /mnt/splicedice_example/ /mnt/splicedice_ir_example
```

consider archiving

```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

mv  /mnt/splicedice_ir_example $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.05.28_21.25.54/



or delete 

```
rm -r /mnt/splicedice_example/
sudo rm -r /mnt/splicedice_ir_example/
```



## Download repo

### splicedice_analysis

```
mkdir -p /mnt/splicedice_ir_example/git_code /mnt/splicedice_ir_example/analysis
cd /mnt/splicedice_ir_example/git_code
git clone https://github.com/hbeale/splicedice_analysis.git


```



## Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -t splicedice_analysis:latest .
```

completed without error



## Identify existing intron-prospector output

```
find /mnt/data/intron_prospector_runs/ -iname "*TCGA*"
# e.g. /mnt/data/intron_prospector_runs/2026-04-01_21-53-28/TCGA-62-8397-01Ab7dfe7a7-b569-4532-bc55-02665f4979e1.bed
```



normalize structure

```

old_dir=/mnt/data/intron_prospector_runs/2026-04-01_21-53-28/
new_dir=/mnt/data/intron_prospector_runs/common/
for i in `ls $old_dir`; do
old_name=${old_dir}${i}
new_base_name=`echo $i | cut -c1-16`
new_name=${new_dir}${new_base_name}.bed
ln -s $old_name $new_name
done

```



## remove bam files when we have IP output



### v1



create remove_processed_bam_files.sh

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

bed_base=/mnt/data/intron_prospector_runs/common/


cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$bed_base/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

# ls $bed_file
# ls $bam_file

if [[ -f "$bed_file" && -f "$bam_file" ]]; then
echo "Deleting $bam_file (bed file $bed_file exists)"
rm "$bam_file"
else
echo "Skipping: bed=$bed_file exists=$([ -f "$bed_file" ] && echo yes || echo no), bam exists=$([ -f "$bam_file" ] && echo yes || echo no)"
fi
    
echo 

done


```

```
bash /mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/remove_processed_bam_files.sh
```

out

```
 
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute$ df -h | grep /mnt
/dev/vdb1       2.0T  1.5T  538G  74% /mnt
...
# a bunch of lines like
Skipping: bed=/mnt/data/intron_prospector_runs/common//TCGA-49-4494-01A.bed exists=no, bam exists=no

Deleting /mnt/data/tcga/7c8cde36-afef-49e3-a389-6aa07fdf0d88/32675d71-6f79-4b8f-ab7c-e2350b15875c.rna_seq.genomic.gdc_realn.bam (bed file /mnt/data/intron_prospector_runs/common//TCGA-44-A47G-01A.bed exists)
...
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute$ df -h | grep /mnt
/dev/vdb1       2.0T  1.2T  829G  60% /mnt

```



### v2

require that the file was most recently modified more than 1 hour ago

```
script=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/remove_processed_bam_files.sh

```

```
rm $script; nano $script
```





create remove_processed_bam_files.sh

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

bed_base=/mnt/data/intron_prospector_runs/common/


cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$bed_base/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

# ls $bed_file
# ls $bam_file

if [[ -f "$bed_file" && -f "$bam_file" && $(find "$bed_file" -mmin +60) ]]; then
echo "Deleting $bam_file (bed file $bed_file exists)"
echo rm "$bam_file"
echo 

# else
# echo "Skipping: bed=$bed_file exists=$([ -f "$bed_file" ] && echo yes || echo no), bam exists=$([ -f "$bam_file" ] && echo yes || echo no)"
fi

done


```

```
bash $script
```



## Attempt v3

updated script to add dry run

5973790162eaa68a6398aea84f4d493379a82d4e

https://github.com/hbeale/splicedice_analysis/commit/5973790162eaa68a6398aea84f4d493379a82d4e

require that the file was most recently modified more than 1 hour ago

```
script=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/remove_processed_bam_files.sh

```



create remove_processed_bam_files.sh

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

bed_base=/mnt/data/intron_prospector_runs/common/


cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$bed_base/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

# ls $bed_file
# ls $bam_file

if [[ -f "$bed_file" && -f "$bam_file" && $(find "$bed_file" -mmin +60) ]]; then
echo "Deleting $bam_file (bed file $bed_file exists)"
echo rm "$bam_file"
echo 

# else
# echo "Skipping: bed=$bed_file exists=$([ -f "$bed_file" ] && echo yes || echo no), bam exists=$([ -f "$bam_file" ] && echo yes || echo no)"
fi

done


```

```
bash $script dryrun
bash $script
```



```
/dev/vdb1       2.0T  924G  1.1T  46% /mnt
```





# Run intron prospector on bam files without bed files



## Attempt 1



```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}run_ip_on_bam_files.sh
log_file=${base_note_dir}run_ip_on_bam_files.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/run_ip_on_bam_files.2026.05.28_22.51.34.log

create 

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

ip_run_dir=/mnt/data/intron_prospector_runs/common/

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

if [[ -f "$bam_file" && $(find "$bam_file" -mmin +60) ]]; then
echo "$bam_file for $nice_id exists and not modified in the last hour"
if [[ ! -f "$bed_file" ]]; then
echo "bed file $bed_file for $nice_id does not exist"
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
$bam_file

fi
echo 
fi
done

```

```

bash $script | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
```

alignment info according to the bam files:

star-2.7.5c_GRCh38.d1.vd1_gencode.v36



### error

```

ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute$ bash $script | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
intron-prospector 1.5.1 https://github.com/diekhans/intron-prospector
/mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam for TCGA-86-8074-01A exists and not modified in the last hour
bed file /mnt/data/intron_prospector_runs/common//TCGA-86-8074-01A.bed for TCGA-86-8074-01A does not exist
[E::faidx_adjust_position] The sequence "chr1_KI270706v1_random" was not found
Error: can't load genome sequence for: chr1_KI270706v1_random:71659-71661
Use --help to get usage
{"status":"OK","nsent":2,"apilimit":"2\/1000"}
ubuntu
```

### look at documentation

```
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector --help
```



### see if --skip-missing-targets helps

```

bed_file=/mnt/data/intron_prospector_runs/common//TCGA-86-8074-01A.bed
bam_file=/mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file


```



i still get a warning message

```

Warning: genomic sequence not found for chrUn_JTFH01001057v1_decoy splice junctions not available

```



## Attempt 2 - uses --skip-missing-targets



```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}run_ip_on_bam_files.sh
log_file=${base_note_dir}run_ip_on_bam_files.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/run_ip_on_bam_files.2026.05.28_23.26.43.log



rm $script; nano $script

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

ip_run_dir=/mnt/data/intron_prospector_runs/common/

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

if [[ -f "$bam_file" && $(find "$bam_file" -mmin +60) ]]; then
echo "$bam_file for $nice_id exists and not modified in the last hour"
if [[ ! -f "$bed_file" ]]; then
echo "bed file $bed_file for $nice_id does not exist"
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file

fi
echo 
fi
done

```

```
bash $script | grep -v "genomic sequence not found" | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
```

alignment info according to the bam files:

star-2.7.5c_GRCh38.d1.vd1_gencode.v36



```
ip_run_dir=/mnt/data/intron_prospector_runs/common/

find $ip_run_dir -iname *.bed -mmin -60
```



## Attempt 3 - after overnight crash



```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}run_ip_on_bam_files.sh
log_file=${base_note_dir}run_ip_on_bam_files.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/run_ip_on_bam_files.2026.05.29_18.23.00.log

rm $script; nano $script

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

ip_run_dir=/mnt/data/intron_prospector_runs/common/

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

if [[ -f "$bam_file" && $(find "$bam_file" -mmin +60) ]]; then
echo "$bam_file for $nice_id exists and not modified in the last hour"
if [[ ! -f "$bed_file" ]]; then
echo "bed file $bed_file for $nice_id does not exist"
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file

fi
echo 
fi
done

```

```
bash $script | grep -v "genomic sequence not found" | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
```

all are complete 



## Attempt 4 - include download and deletion



```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}download_and_run_ip_on_bam_files.sh
log_file=${base_note_dir}download_and_run_ip_on_bam_files.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_ip_on_bam_files.2026.05.29_19.59.48.log

rm $script; nano $script

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

ip_run_dir=/mnt/data/intron_prospector_runs/common/

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v

cat $ip_manifest | grep -v ^id | while read ugly_id bam_file nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=/mnt/data/tcga/$ugly_id/$bam_file

if [[ -f "$bam_file" && $(find "$bam_file" -mmin +60) ]]; then
echo "$bam_file for $nice_id exists and not modified in the last hour"
if [[ ! -f "$bed_file" ]]; then
echo "bed file $bed_file for $nice_id does not exist"
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file

fi
echo 
fi
done

```

```
bash $script | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
```





## Attempt 5 - include download and deletion

servers restrated...



i launched this Tue Jun  2 

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}download_and_run_ip_on_bam_files.sh
log_file=${base_note_dir}download_and_run_ip_on_bam_files.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_ip_on_bam_files.2026.06.02_19.16.47.logrm $script; nano $script

```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

genome=/mnt/ref/GRCh38.primary_assembly.genome.fa

token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt

ip_run_dir=/mnt/data/intron_prospector_runs/common/
bam_base=/mnt/data/tcga

# document IP version
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector -v


cat $ip_manifest | grep -v ^id | while read ugly_id bam_file_basename nice_id; do
# echo echo ugly_id is $ugly_id
# echo bam file is $bam_file
# echo nice_id is $nice_id

bed_file=$ip_run_dir/${nice_id}.bed 
bam_file=${bam_base}/$ugly_id/$bam_file_basename

echo
echo checking $nice_id
if [[ ! -f "$bed_file" && ! -f "$bam_file" ]]; then 
echo "neither bed or bam file exists"

# download bam file
echo "downloading bam file..."
mkdir -p ${bam_base}/$ugly_id
/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file $token_file $ugly_id

fi

if [[ ! -f "$bed_file" && -f "$bam_file" ]]; then 
echo "bam file exists but bed file does not"

# run IP
echo "running intron-prospector..."
docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
intron-prospector \
--genome-fasta=$genome \
--intron-bed6=$bed_file \
--skip-missing-targets \
$bam_file
fi

# delete bam file...
if [[ -f "$bam_file"  && -f "$bed_file" ]]; then 
echo "both bed and bam files now exist"
echo "deleting bam file"
rm $bam_file 
fi

done


```

```
bash $script | tee $log_file ; bash ~/alert_msg.sh "IP run complete"
```



## Summarize status

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}bed_and_bam_file_status.sh

```



```
#!/usr/bin/env bash
set -euo pipefail

ip_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
bed_base=/mnt/data/intron_prospector_runs/common/
bam_base=/mnt/data/tcga

output=/mnt/data/file_status_$(date +%Y%m%d_%H%M%S).tsv
echo $output

echo -e "nice_id\tugly_id\tbed_exists\tbam_exists" > "$output"

grep -v ^id "$ip_manifest" | while read ugly_id bam_file nice_id; do
    bed_file=${bed_base}/${nice_id}.bed
    bam_file=${bam_base}/$ugly_id/$bam_file

    [[ -f "$bed_file" ]] && bed=yes || bed=no
    [[ -f "$bam_file" ]] && bam=yes || bam=no

    echo -e "${nice_id}\t${ugly_id}\t${bed}\t${bam}"
done >> "$output"

echo "Written to $output"

awk -F'\t' 'NR>1 {
    if ($3=="yes" && $4=="yes") both++
    if ($3=="yes" && $4=="no")  bed_only++
    if ($3=="no"  && $4=="yes") bam_only++
    if ($3=="no"  && $4=="no")  neither++
} END {
    print "both:     " both+0
    print "bed only: " bed_only+0
    print "bam only: " bam_only+0
    print "neither:  " neither+0
}' $output
df -h | grep mnt

```

```
bash $script
```



```
Tue Jun  2 19:41:42 UTC 2026
both:     0
bed only: 152
bam only: 0
neither:  343

```

```
Written to /mnt/data/file_status_20260602_194350.tsv
both:     0
bed only: 154
bam only: 0
neither:  341
```

```
Written to /mnt/data/file_status_20260602_200742.tsv
both:     0
bed only: 158
bam only: 0
neither:  337
```

```
Written to /mnt/data/file_status_20260602_202217.tsv
both:     0
bed only: 162
bam only: 0
neither:  333
/dev/vdb1       2.0T  928G  1.1T  46% /mnt

```

```
Written to /mnt/data/file_status_20260603_194941.tsv
both:     0
bed only: 484
bam only: 0
neither:  11
/dev/vdb1       2.0T  935G  1.1T  46% /mnt


```

```
Written to /mnt/data/file_status_20260603_213615.tsv
both:     0
bed only: 495
bam only: 0
neither:  0
/dev/vdb1       2.0T  928G  1.1T  46% /mnt
```



## Misc QC

## check the most recent bed files

```
library(tidyverse)

bed_dir <- "/mnt/data/intron_prospector_runs/common"

bed_files <- list.files(bed_dir, pattern = "\\.bed$", full.names = TRUE)

file_info <- tibble(
  path = bed_files,
  filename = basename(bed_files),
  created = file.info(bed_files)$mtime,  # Linux has no ctime; mtime is best proxy
  n_lines = map_int(bed_files, \(f) as.integer(system2("wc", c("-l", f), stdout = TRUE) |> str_extract("^\\d+")))
)

ggplot(file_info, aes(x = created, y = n_lines)) +
  geom_point(alpha = 0.6, size = 1.5) +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Intron-prospector BED file line counts by creation date",
    x = "File modification time",
    y = "Number of lines"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("/mnt/data/bed_line_counts.png", width = 10, height = 5, dpi = 150)
```



## see if any bed files are missing major chromosomes 

```
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"

for f in /mnt/data/intron_prospector_runs/common/*.bed; do
    missing=$(comm -23 \
        <(echo "$expected" | tr ' ' '\n' | sort) \
        <(cut -f1 "$f" | sort -u)) 
    [[ -n "$missing" ]] && echo "$(basename $f): MISSING: $missing" || echo "$(basename $f): OK"
done

```

to confirm that this works:

```
head -19 TCGA-44-6774-01A.bed > TCGA-44-6774-01A.test.bed
```

expected output with "bad" test case:

```
TCGA-44-6774-01A.test.bed: MISSING: chr10
chr11
...

```

download and ip complete for 495  samples  6/3/2026



# 



# splicedice quant

## make bed manifest

```

repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
ip_manifest=${repo_base}2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 
u2af1_info=${repo_base}/2025-12_tcga_luad_reproducible_example/bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv

bed_base=/mnt/data/intron_prospector_runs/common/

cat $u2af1_info | grep s34f | cut -c1-16 > /mnt/tmp/u2af1_samples.txt


bed_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bed_manifest_2026.06.03_15.06.58.tsv


cat $ip_manifest | grep -v ^id | while read id bam_basename sample_id_key ; do
if grep -qw "$sample_id_key" /mnt/tmp/u2af1_samples.txt; then
pheno=u2af1
else
pheno=other
fi
echo -e "$sample_id_key\t${bed_base}${sample_id_key}.bed\t$pheno"
done > $bed_manifest


```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis$ cat $bed_manifest | cut -f3 | sort | uniq -c
    484 other
     11 u2af1
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis$ 

```





## Quantify splice junction usage

```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
drwxrwxr-x 2 ubuntu ubuntu  6 May  5 20:21 .
drwxrwxr-x 4 ubuntu ubuntu 38 May  5 20:21 ..

```



```
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice quant -m $bed_manifest \
-o /mnt/splicedice_ir_example/analysis/
date
 ~/alert_msg.sh "quant run complete"

```

std out

```
Wed Jun  3 22:17:09 UTC 2026
/usr/local/lib/python3.8/site-packages/splicedice/SPLICEDICE.py:213: RuntimeWarning: invalid value encountered in divide
  psi[self.junctionIndex[junction],:] = inclusions / (inclusions + exclusions)
Parsing manifest...
        Done [0:00:0.00]
Getting all junctions from 495 files...
        Done [0:03:34.92]
Finding clusters from 800411 junctions...
        Done [0:00:36.28]
Writing cluster file...
        Done [0:01:30.31]
Writing junction bed file...
        Done [0:00:5.74]
Gathering junction counts...
        Done [0:05:40.77]
Writing inclusion counts...
        Done [0:06:19.45]
Calculating PS values...
        Done [0:05:14.30]
Writing PS values...
        Done [0:06:54.48]
All done [0:29:56.25]

real    30m15.454s
user    0m0.179s
sys     0m0.057s
Wed Jun  3 22:47:24 UTC 2026
{"status":"OK","nsent":2,"apilimit":"2\/1000"}
```



```
Wed Jun  3 22:17:09 UTC 2026
```

```
Wed Jun  3 22:47:24 UTC 2026
```





performance note

from spot-checking, only one processor is in use. claude says "Looking at `SPLICEDICE.py`, there's no multithreading built in — it's all single-threaded Python. ...**Parallelize `getAllJunctions` and `getJunctionCounts` yourself** using `concurrent.futures.ThreadPoolExecutor` or `ProcessPoolExecutor`. Since the bottleneck is file I/O, threads would likely help (no GIL issue for I/O-bound work). Each worker could handle one sample's BED file, then results get merged."





```
ls -alth /mnt/splicedice_ir_example/analysis/
```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ ls -alth /mnt/splicedice_ir_example/analysis/
total 87M
-rw-r--r-- 1 root   root   20M May  5 21:07 _allPS.tsv
drwxrwxr-x 2 ubuntu ubuntu  98 May  5 21:07 .
-rw-r--r-- 1 root   root   14M May  5 21:07 _inclusionCounts.tsv
-rw-r--r-- 1 root   root   18M May  5 21:07 _junctions.bed
-rw-r--r-- 1 root   root   37M May  5 21:07 _allClusters.tsv
drwxrwxr-x 4 ubuntu ubuntu  38 May  5 20:21 ..
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ 

```



# Calculate intron_coverage

this requires bam files, but I can't store all on the computer at the same time.



## make bam manifest for all samples

```

repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/

ip_manifest=${repo_base}2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv 

bam_base=/mnt/data/tcga

bam_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bam_manifest_2026.06.03_15.06.58.tsv

cat $ip_manifest | grep -v ^id | while read id bam_basename sample_id_key ; do
if grep -qw "$sample_id_key" /mnt/tmp/u2af1_samples.txt; then
pheno=u2af1
else
pheno=other
fi
bam=${bam_base}/$id/$bam_basename

echo -e "$sample_id_key\t${bam}\t$pheno"
done > $bam_manifest


```



check that the phenotypes are as expected

```
cat $bam_manifest | cut -f3 | sort | uniq -c
```

```
    484 other
     11 u2af1
```

## attempt 1: calculate intron_coverage on one sample at a time - too slow

set up script

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=download_and_run_intron_coverage_on_bam_files.sh
script=${base_note_dir}${script_basename}
log_file=${base_note_dir}${script_basename/.sh}.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files.2026.06.04_16.54.12.log

### walk through it manually

```
id=TCGA-86-8074-01A
bam_file=/mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam

```



```
if [[ -f "$bam_file" ]]; then
echo "bam file exists"

echo "running intron_coverage..."
date
time docker run --rm \
-v /mnt/:/mnt \
splicedice_analysis:latest \
splicedice intron_coverage \
-b /mnt/scratch/tmp/${id}_bam_manifest.tsv \
-m ${analysis_base}/_allPS.tsv \
-j ${analysis_base}/_junctions.bed \
-o ${analysis_base}/coverage_output
date
fi

```



```
Thu Jun  4 17:41:48 UTC 2026
getting paths for bam files
creating junction percentiles
[W::hts_idx_load3] The index file is older than the data file: /mnt/data/tcga/567c5d5f-2b27-4070-86c3-3905d06ed02b/f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam.bai
Your runtime was 3310.5005781650543 seconds.

real    55m16.343s
user    0m0.303s
sys     0m0.098s
Thu Jun  4 18:37:05 UTC 2026
```



problem:

running intron coverage for one sample takes 55 minutes; so running it on all samples one at a time would take 20 days

i think i have 8 processers on this computer, so i could run 8 at a time, which would theoretically  take 2.5 days (probably more)

## attempt 2: calculate intron_coverage on 8 samples at a time - faster

### 

set up script

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=download_and_run_intron_coverage_on_bam_files_v2.sh
script=${base_note_dir}${script_basename}
log_file=${base_note_dir}${script_basename/.sh}.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_v2.2026.06.04_19.56.59.log

```
bash $script | tee $log_file ; bash ~/alert_msg.sh "intron_coverage run complete"
```





### run for all samples

```
bash $script | tee $log_file ; bash ~/alert_msg.sh "intron_coverage run complete"
```



started 6/4



assess progress

```
cat $this_log | grep -v "ETA:"
```

it took 3583 seconds for 8 samples; that's good, it took 3310 for one sample

i should figure out how long it takes for 16 samples 

## attempt 3: calculate intron_coverage on 16 samples at a time 

### 

### set up script

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=download_and_run_intron_coverage_on_bam_files_v3.sh
script=${base_note_dir}${script_basename}
log_file=${base_note_dir}${script_basename/.sh}.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_v3.2026.06.04_21.18.44.log

```
bash $script | tee $log_file ; bash ~/alert_msg.sh "intron_coverage run complete"
```





```
this_log=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_v3.2026.06.04_21.18.44.log
cat $this_log | grep -v "ETA:"
```



### errors

first error:

```
Fri Jun  5 00:02:03 UTC 2026
100% [############################################] Time:  0:02:05  55.1 MiB/s
WARNING: Unable to download related files for 14214c45-8108-41cd-b07d-e020e8436f7b: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/57d0f0fc-5067-4af7-8bc9-52b2e50425b8: {"message":"Internal server error: Failed to get user projects."}

ERROR: Max retries exceeded.
ERROR: Max retries exceeded.
ERROR: Max retries exceeded.
100% [############################################] Time:  0:01:41  57.8 MiB/s
WARNING: Unable to download related files for dcde3fba-f8c6-4c0b-8540-5abd036db6c8: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/49081d00-3028-4af1-8af5-d96b24ca70f0: {"message":"Internal server error: Failed to get user projects."}
```

last errors:

```
ERROR: 73898db7-1015-4a90-a6b8-3fb68d9a9287: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/73898db7-1015-4a90-a6b8-3fb68d9a9287: {"message":"Internal server error: Failed to get user projects."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/73898db7-1015-4a90-a6b8-3fb68d9a9287
ERROR: dad25a07-fb2a-42d0-95b6-b072afbdaa7c: 503 Server Error: SERVICE UNAVAILABLE for url: https://api.gdc.cancer.gov/data/dad25a07-fb2a-42d0-95b6-b072afbdaa7c: {"error":"Auth service unavailable."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/dad25a07-fb2a-42d0-95b6-b072afbdaa7c
ERROR: 58602df8-a37a-4fe4-9c80-7b79ac0c3e18: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/58602df8-a37a-4fe4-9c80-7b79ac0c3e18: {"message":"Internal server error: Failed to get user projects."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/58602df8-a37a-4fe4-9c80-7b79ac0c3e18
ERROR: 55acf78f-4a64-44c0-a276-510c279cf861: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/55acf78f-4a64-44c0-a276-510c279cf861: {"message":"Internal server error: Failed to get user projects."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/55acf78f-4a64-44c0-a276-510c279cf861
ERROR: 65e3ebf4-fd52-4b03-8c00-6b4ff514f135: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/65e3ebf4-fd52-4b03-8c00-6b4ff514f135: {"message":"Internal server error: Failed to get user projects."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/65e3ebf4-fd52-4b03-8c00-6b4ff514f135
ERROR: b2926c07-53fd-43ca-a2e3-70c4d6f62bb0: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/b2926c07-53fd-43ca-a2e3-70c4d6f62bb0: {"message":"Internal server error: Failed to get user projects."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/b2926c07-53fd-43ca-a2e3-70c4d6f62bb0
ERROR: 674b9bdd-c5e2-4539-802c-734f69b58097: 500 Server Error: INTERNAL SERVER ERROR for url: https://api.gdc.cancer.gov/data/674b9bdd-c5e2-4539-802c-734f69b58097: {"message":"Internal server error: Failed to get user projects."}

ERROR: Unable to download file https://api.gdc.cancer.gov/data/674b9bdd-c5e2-4539-802c-734f69b58097
Successfully downloaded: -180
Failed downloads: 196
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis$ 

```

## attempt 4: retry - calculate intron_coverage on 16 samples at a time 

### 

### define script

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=download_and_run_intron_coverage_on_bam_files_v3.sh
script=${base_note_dir}${script_basename}
log_file=${base_note_dir}${script_basename/.sh}.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```

/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_v3.2026.06.05_15.53.13.log



### make sure there is still enough space

```
 df -h  | grep mnt
```



```
/dev/vdb1       2.0T  985G  1.1T  49% /mnt
```

### start script

```
bash $script | tee $log_file ; bash ~/alert_msg.sh "intron_coverage run complete"
```



selected std out

```
TCGA-69-7761-01A: BAM already present, skipping download
TCGA-78-7156-01A: queuing 54839351-9668-45b4-baf5-6497550f35a1 for download
TCGA-44-A47A-01A: queuing dcde3fba-f8c6-4c0b-8540-5abd036db6c8 for download
TCGA-MP-A4TJ-01A: queuing 65e3ebf4-fd52-4b03-8c00-6b4ff514f135 for download
TCGA-78-7161-01A: BAM already present, skipping download

```

### check that bams are intact

```
repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
analysis_base=/mnt/splicedice_ir_example/analysis/
bam_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bam_manifest_2026.06.03_15.06.58.tsv
ip_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv

ids="TCGA-69-7761-01A TCGA-78-7161-01A"
for id in $ids; do
echo
echo $id
bam_file=`cat $bam_manifest | grep $id | cut -f2`
ls -alth $bam_file
samtools view $bam_file | head -2
done
```

results look promising

```

TCGA-69-7761-01A
-rw-rw-r-- 1 ubuntu ubuntu 6.8G Jun  5 00:04 /mnt/data/tcga/14214c45-8108-41cd-b07d-e020e8436f7b/eaaacefc-a798-4b6e-8471-0fde96a80bb9.rna_seq.genomic.gdc_realn.bam
UNC9-SN296:290:C0M6TACXX:4:1104:8485:12716      163     chr1    10318   255     37S11M  =       629348  619078  TACAAAATTTCTAAGAAAAAAAAAATAAGCACTCTCCCCCCAACCCTA       11+=B###########################################        NH:i:1  HI:i:1  AS:i:52 nM:i:1  NM:i:0  RG:Z:120402_UNC9-SN296_0290_BC0M6TACXX_TGACCA_L004
UNC9-SN296:290:C0M6TACXX:4:2103:1935:32675      153     chr1    10573   0       48M     *       0       0       CCCTCGCGGTGCTCTCCGGGTCTGTGCTGAGGAGAACGCAACTCCGCC       ;><9E;A9GGFB0D?D@HFF@GGGGHEG@GHBGBIHFD?C<AFDD;?B        NH:i:16 HI:i:4  AS:i:47 nM:i:0  NM:i:0  RG:Z:120402_UNC9-SN296_0290_BC0M6TACXX_TGACCA_L004

TCGA-78-7161-01A
-rw-rw-r-- 1 ubuntu ubuntu 8.7G Jun  5 00:09 /mnt/data/tcga/41c72749-b512-4930-9ad1-9fd59c8f90c5/35fc369e-6f16-415b-badb-380eedb2157b.rna_seq.genomic.gdc_realn.bam
UNC14-SN744:200:C0F4CACXX:1:1106:13255:170902   345     chr1    10544   0       48M     *       0       0       AAATCTGTGCAGAGGAGAACGCAGCTCCGCCCTCGCGGTGCTCTCCGG       CCDCCDDDDCCDCDECBA?FFHEGGGJJFIJIDJJHHHHHFFDDF@CC        NH:i:14 HI:i:2  AS:i:45 nM:i:1  NM:i:1  RG:Z:120113_UNC14-SN744_0200_AC0F4CACXX_TAGCTT_L001
UNC14-SN744:200:C0F4CACXX:1:1306:6867:91810     345     chr1    10547   0       48M     *       0       0       TCTGTGCAGAGGAGAACGCAGCTCCGCCCTCGCGGTGCTCTCCGGGTC       ?DDCDCACC@>5DBB?DECBDFHHGEIHBEIIIIIGHGHGFFFDF@<@        NH:i:15 HI:i:4  AS:i:45 nM:i:1  NM:i:1  RG:Z:120113_UNC14-SN744_0200_AC0F4CACXX_TAGCTT_L001
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis$ 

```



### check log output

```
this_log=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_v3.2026.06.05_15.53.13.log
cat $this_log | grep -v "ETA:"
```



## check intron_coverage status





```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script=${base_note_dir}intron_coverage_file_status.sh
date
bash $script 

```



```
Written to /mnt/data/intron_coverage_file_status_20260604_175851.tsv
both:     0
intron_coverage only: 0
bam only: 1
neither:  494

```

```
Written to /mnt/data/intron_coverage_file_status_20260604_194837.tsv
both:     1
intron_coverage only: 0
bam only: 0
neither:  494
/dev/vdb1       2.0T  944G  1.1T  47% /mnt
```

```
Written to /mnt/data/intron_coverage_file_status_20260604_200942.tsv
both:     1
intron_coverage only: 0
bam only: 8
neither:  486
/dev/vdb1       2.0T  998G  1.1T  49% /mnt

```

```
Written to /mnt/data/intron_coverage_file_status_20260604_220449.tsv
both:     1
intron_coverage only: 8
bam only: 14
neither:  472
/dev/vdb1       2.0T  1.1T 1008G  51% /mnt
```

```
Written to /mnt/data/intron_coverage_file_status_20260605_155211.tsv
both:     1
intron_coverage only: 24
bam only: 2
neither:  468
/dev/vdb1       2.0T  985G  1.1T  49% /mnt

```

```
Fri Jun  5 22:09:21 UTC 2026
/mnt/data/intron_coverage_file_status_20260605_220921.tsv
Written to /mnt/data/intron_coverage_file_status_20260605_220921.tsv
both:     1
intron_coverage only: 40
bam only: 2
neither:  452
/dev/vdb1       2.0T  959G  1.1T  47% /mnt

```



```
Written to /mnt/data/intron_coverage_file_status_20260606_012609.tsv
both:     5
intron_coverage only: 56
bam only: 12
neither:  422
/dev/vdb1       2.0T  1.1T 1009G  51% /mnt
Sat Jun  6 01:26:09 UTC 2026

```

```
Written to /mnt/data/intron_coverage_file_status_20260608_161049.tsv
both:     9
intron_coverage only: 424
bam only: 8
neither:  54
/dev/vdb1       2.0T  1.1T  977G  53% /mnt
Mon Jun  8 16:10:49 UTC 2026
```

```
Written to /mnt/data/intron_coverage_file_status_20260608_180140.tsv
both:     1
intron_coverage only: 440
bam only: 16
neither:  38
/dev/vdb1       2.0T  1.1T  958G  54% /mnt
Mon Jun  8 18:01:41 UTC 2026
```

```
Written to /mnt/data/intron_coverage_file_status_20260608_195359.tsv
both:     16
intron_coverage only: 440
bam only: 1
neither:  38
/dev/vdb1       2.0T  1.1T  957G  54% /mnt
Mon Jun  8 19:54:00 UTC 2026

```

```
Written to /mnt/data/intron_coverage_file_status_20260608_213826.tsv
both:     7
intron_coverage only: 456
bam only: 10
neither:  22
/dev/vdb1       2.0T  1.1T  956G  54% /mnt
Mon Jun  8 21:38:26 UTC 2026
```

```
Written to /mnt/data/intron_coverage_file_status_20260608_234549.tsv
both:     1
intron_coverage only: 472
bam only: 16
neither:  6
/dev/vdb1       2.0T  1.1T  966G  53% /mnt
Mon Jun  8 23:45:49 UTC 2026
```

```
Written to /mnt/data/intron_coverage_file_status_20260609_175105.tsv
both:     1
intron_coverage only: 494
bam only: 0
neither:  0
/dev/vdb1       2.0T  976G  1.1T  48% /mnt
Tue Jun  9 17:51:05 UTC 2026

```



## parse log

```
latest_base_bame=download_and_run_intron_coverage_on_bam_files_v2.2026.06.04_19.56.59.log
latest_base_bame=download_and_run_intron_coverage_on_bam_files_v3.2026.06.05_15.53.13.log

this_log=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/$latest_base_bame

cat $this_log | grep -v "ETA:"
```

## see if any bed files are missing major chromosomes 

```
analysis_base=/mnt/splicedice_ir_example/analysis/
output_file=/mnt/splicedice_ir_example/analysis/intron_coverage_survey.txt

expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"

for f in ${analysis_base}/coverage_output/*_intron_coverage.txt; do
    missing=$(comm -23 \
        <(echo "$expected" | tr ' ' '\n' | sort) \
        <(cut -f1 "$f" | sort -u)) 
    [[ -n "$missing" ]] && echo "$(basename $f): MISSING: $missing" || echo "$(basename $f): OK"
done > $output_file

```

result

```
ubuntu@hbeale-mesa:~$ cat $output_file  | grep -v OK | wc -l
0

```

look at a couple of individual files

```
ls -l ${analysis_base}/coverage_output/*_intron_coverage.txt
f=/mnt/splicedice_ir_example/analysis//coverage_output/TCGA-05-4390-01A_intron_coverage.txt
```

### repeat, considering only rows with coverage

a lot of entries in the bed files have zero coverage in introns, but they're included because its a known intron

```
analysis_base=/mnt/splicedice_ir_example/analysis/
output_file=/mnt/splicedice_ir_example/analysis/intron_coverage_survey_2026.06.09_11.56.13.txt
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"
for f in ${analysis_base}/coverage_output/*_intron_coverage.txt; do
    missing=$(comm -23 \
        <(echo "$expected" | tr ' ' '\n' | sort) \
        <(awk -F'\t' '$5 != "0.0"' "$f" | cut -f1 | sort -u))
    [[ -n "$missing" ]] && echo "$(basename $f): MISSING: $missing" || echo "$(basename $f): OK"
done > $output_file
```

looks like all samples have intron coverage on all chromosomes:

```
ubuntu@hbeale-mesa:~$ head $output_file 
TCGA-05-4244-01A_intron_coverage.txt: OK
TCGA-05-4249-01A_intron_coverage.txt: OK
TCGA-05-4250-01A_intron_coverage.txt: OK
TCGA-05-4382-01A_intron_coverage.txt: OK
TCGA-05-4384-01A_intron_coverage.txt: OK
TCGA-05-4389-01A_intron_coverage.txt: OK
TCGA-05-4390-01A_intron_coverage.txt: OK
TCGA-05-4395-01A_intron_coverage.txt: OK
TCGA-05-4396-01A_intron_coverage.txt: OK
TCGA-05-4397-01A_intron_coverage.txt: OK
ubuntu@hbeale-mesa:~$ cat $output_file | grep -v OK
ubuntu@hbeale-mesa:~$ 
```

#### report the number of entries on chr21 that don't have 0 in the 5th column

```
analysis_base=/mnt/splicedice_ir_example/analysis/
output_file=/mnt/splicedice_ir_example/analysis/intron_coverage_survey_2026.06.09_15.57.24.txt
for f in ${analysis_base}/coverage_output/*_intron_coverage.txt; do
    count=$(awk -F'\t' '$1 == "chr21" && $5 != "0.0"' "$f" | wc -l)
    echo "$(basename $f): $count"
done > $output_file
```

```
ubuntu@hbeale-mesa:~$ head $output_file 
TCGA-05-4244-01A_intron_coverage.txt: 4857
TCGA-05-4249-01A_intron_coverage.txt: 3516
TCGA-05-4250-01A_intron_coverage.txt: 2872
TCGA-05-4382-01A_intron_coverage.txt: 4471
TCGA-05-4384-01A_intron_coverage.txt: 3424
TCGA-05-4389-01A_intron_coverage.txt: 2594
TCGA-05-4390-01A_intron_coverage.txt: 2186
TCGA-05-4395-01A_intron_coverage.txt: 3063
TCGA-05-4396-01A_intron_coverage.txt: 2551
TCGA-05-4397-01A_intron_coverage.txt: 4512

```

I eyeballed the rest of the file, and no values looked unusual compared to the first 10 lines

# intron_coverage performance

Assess durations of different intron_coverage processing approaches



```

all_ic_logs=`ls /mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_*log`

for ic_log in $all_ic_logs;
do 
echo $(basename $ic_log)
cat $ic_log | grep "Your runtime was\|running intron_coverage on\|all downloads\| Jun "
done
```



directly obserbved:

running intron_coverage on one sample (TCGA-86-8074-01A) took Your runtime was 3310.5005781650543 seconds.



```
download_and_run_intron_coverage_on_bam_files_v2.2026.06.04_19.56.59.log
--- running intron_coverage on 8 samples (batch 1) ---
Your runtime was 3583.78155374527 seconds.
download_and_run_intron_coverage_on_bam_files_v3.2026.06.04_21.18.44.log
--- running intron_coverage on 16 samples with 8 threads (batch 1) ---
Your runtime was 6694.841159820557 seconds.
download_and_run_intron_coverage_on_bam_files_v3.2026.06.05_15.53.13.log

```

n	seconds

1	3311

8	3584

16	6695

16	6490



## overall progress

```

all_ic_logs=`ls /mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/download_and_run_intron_coverage_on_bam_files_*log`

for ic_log in $all_ic_logs;
do 
echo $(basename $ic_log)
cat $ic_log | grep "Your runtime was\|running intron_coverage on"
done
```



# ir_table

## note; this is single threaded

(note this is running on a single processor. I asked claude "is splicedice ir_table multithreaded?"

Claude responded: Let me check — I already fetched introncoverage.

Let me check — I already fetched `intron_coverage.py` earlier but not `ir_table.py`.

Fetched: https://public.gi.ucsc.edu/~hcbeale/splicedice/splicedice/ir_table.py

No — `ir_table.py` is single-threaded. There's no `multiprocessing` or `threading` import, and `calculateIR()` iterates over samples sequentially in a plain for loop. Unlike `intron_coverage.py` which has `-n`/`--numThreads` and uses `multiprocessing.Pool`, `ir_table` has no threading arguments at all.

The main bottleneck in `ir_table` is the `calculateIR()` function, where for each sample it opens and reads the entire `_intron_coverage.txt` file. That loop over samples would be the natural place to parallelize if you wanted to add it.

## attempt 1

### Generate inclusion count table

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
Tue Jun  9 23:00:39 UTC 2026
...
cluster TCGA-49-4494-01A chr1:11844-12009:+
Done 643.6253461837769
Writing output...
Traceback (most recent call last):
  File "/usr/local/bin/splicedice", line 8, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.8/site-packages/splicedice/__main__.py", line 57, in main
    args.main(args)
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 194, in run_with
    writeIRtable(samples, outputPrefix, junctions, IR)
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 152, in writeIRtable
    irValues = [f"{IR[sample][junction]:0.03f}" for sample in samples]
  File "/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py", line 152, in <listcomp>
    irValues = [f"{IR[sample][junction]:0.03f}" for sample in samples]
KeyError: 'chr1:11844-12009:+'

real    12m6.016s
user    0m0.087s
sys     0m0.079s
Tue Jun  9 23:12:45 UTC 2026
{"status":"OK","nsent":2,"apilimit":"1\/1000"}

```



### claude analysis of the error

The error is in `writeIRtable` — it tries to format `IR[sample][junction]` for every sample × junction combination, but a junction can end up in `junctions` (the set) without having an entry in `IR[sample]` for every sample.

... it suggests that sample's inclusion counts are missing junctions that appear in its coverage file

### request to claude:  check if a sample's inclusion counts are missing junctions that appear in its coverage file,

```
sample="TCGA-49-4494-01A"
base_dir=/mnt/splicedice_ir_example/analysis


coverage_dir=${base_dir}/coverage_output
inclusion_counts=${base_dir}/_inclusionCounts.tsv

comm -23 \
  <(awk -F'\t' '{print $1":"$2"-"$3":"$6}' ${coverage_dir}/${sample}_intron_coverage.txt | sort) \
  <(tail -n +2 $inclusion_counts | cut -f1 | sort) | head
```



```
    chr10:100003023-100006236:-
    chr10:100003023-100009837:-
    chr10:100024607-100030242:+
    chr10:100031074-100048757:-
    chr10:100040173-100048757:-
    chr10:100042573-100048757:-
    chr10:100042573-100048840:-
    chr10:100042573-100054346:-
    chr10:100048876-100054346:-
    chr10:100054446-100057012:-
```



claude says this error is due to a bug

These are junctions that appear in `TCGA-49-4494-01A`'s `_intron_coverage.txt` file but are **absent from the inclusion counts TSV** (i.e. they weren't observed in the `splicedice quant` step).

This would happen if the BAM file used for `intron_coverage` and the junction BED file used for `quant` came from different sets of samples or different runs — the coverage step samples positions along *all* junctions in the junction BED, including junctions from other samples that this particular sample never had reads crossing. So `intron_coverage` produces entries for every junction in the BED, but `inclusionCounts.tsv` only has rows for junctions where at least one sample had reads.

In other words: **this is expected behavior**, not a data mismatch bug. The `break` in `calculateIR()` is the actual bug — it should be a `continue` so it skips missing junctions gracefully instead of aborting early for that sample. The missing junctions are legitimately absent (zero reads) and should just get `NaN` or be skipped.



## attempt 2

### try replacing break with continue interactively 

start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```



changes

```
Line 135: break → continue — so a missing junction in counts[sample] skips that junction for that sample instead of aborting the whole sample's coverage file loop
```

```
python3 -c "
with open('/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py', 'r') as f:
    lines = f.readlines()
lines[134] = lines[134].replace('break', 'continue')
with open('/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py', 'w') as f:
    f.writelines(lines)
"
```



```
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf

date
time
splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}
date
```

oops, i put time on a separate line

std out			

```
Tue Jun  9 23:59:56 UTC 2026

real    0m0.000s
user    0m0.000s
sys     0m0.000s
Gathering inclusion counts and clusters...
cluster TCGA-05-4418-01A chr15:20154667-20157372:+
cluster TCGA-05-4418-01A chr15:20157605-20157689:+
cluster TCGA-05-4418-01A chr15:20157870-20158116:+
Killed

```

the terminal window kept getting beachball of death

## attempt 3

same as #2 after restarting terminal 

start docker interactively (already done in attempt 2)

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```



```
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir} > $log_file
date
```



std out

```
/mnt/splicedice_ir_example/analysisrun_ir_table_with_edit.2026.06.10_21.17.01.log
Wed Jun 10 21:17:14 UTC 2026
...

```



keep an eye:

```
this_log=/mnt/splicedice_ir_example/analysisrun_ir_table_with_edit.2026.06.10_21.17.01.log
tail -f $this_log
```

## attempt 4 - "killed"

remove cluster print out statements



i filled disk space, so i had to clean up /var/lib/docker



```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```



### edits

change line 134 from print("cluster",sample,cluster) to pass, and 135 from break to continue

from

```
except KeyError:
    print("cluster",sample,cluster)
    break
```

to

```
except KeyError:
    pass
    continue
```

check current code

```
sed -n '130,145p' /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py
```

change code

```
python3 -c "
with open('/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py', 'r') as f:
    lines = f.readlines()
lines[133] = '                    pass\n'
lines[134] = '                    continue\n'
with open('/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py', 'w') as f:
    f.writelines(lines)
"
```

check current code again, expect the changes to be implemented

```
sed -n '130,145p' /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py
```



```
base_dir=/mnt/splicedice_ir_example/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir} > $log_file
date
```



std out

```
/mnt/splicedice_ir_example/analysisrun_ir_table_with_edit.2026.06.10_21.46.26.log
Wed Jun 10 21:46:40 UTC 2026
/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)

```

```
this_log=/mnt/splicedice_ir_example/analysisrun_ir_table_with_edit.2026.06.10_21.46.26.log
tail -f $this_log
```

```
Wed Jun 10 21:46:40 UTC 2026
/usr/local/lib/python3.8/site-packages/splicedice/ir_table.py:120: RuntimeWarning: invalid value encountered in scalar divide
  RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
Killed

real    156m54.524s
user    153m39.278s
sys     2m31.096s
Thu Jun 11 00:23:35 UTC 2026

```



### troubleshooting with claude

```
wc -l /path/to/junctions.bed
```

Are all 495 samples in the coverage directory? If so, running in batches won't help since `ir_table` needs all samples together to build the output matrix. The real fix would be to refactor `calculateIR()` to compute and discard per-sample coverage arrays immediately rather than storing them all, but that's a more involved code change.



#### You said: How would I to refactor calculateIR() to compute and discard per-sample coverage arrays immediately rather than storing them all?

How would I to refactor `calculateIR()` to compute and discard per-sample coverage arrays immediately rather than storing them all? Use the code at https://public.gi.ucsc.edu/~hcbeale/splicedice/ as a reference

9:23 AM

#### Claude responded: The code is already in my context from earlier.

The code is already in my context from earlier. The key change is to never store `coverage[sample]` at all — compute the RSD inline and immediately discard the array:

**Current code (memory-heavy):**

python

```python
coverage[sample][cluster] = row[-1].split(",")
covArray = np.array(coverage[sample][cluster]).astype(float)
if args.makeRSDtable:
    RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
```

**Refactored — drop the `coverage` dict entirely:**

python

```python
covArray = np.array(row[-1].split(","), dtype=float)
mean = np.mean(covArray)
RSD[sample][cluster] = np.std(covArray) / mean if mean > 0 else np.nan
```

Here's the full refactored `calculateIR()`:

python

```python
def calculateIR(samples, coverageDirectory, counts, clusters, annotated, args):
    IR = {}
    junctions = set()
    RSD = {}
    for sample in samples:
        filename = os.path.join(coverageDirectory, f"{sample}_intron_coverage.txt")

        IR[sample] = {}
        RSD[sample] = {}

        with open(filename) as percentileCoverage:
            for line in percentileCoverage:
                row = line.strip().split("\t")
                cluster = f"{row[0]}:{row[1]}-{row[2]}:{row[5]}"

                if not args.allJunctions and cluster not in annotated:
                    continue

                junctions.add(cluster)
                median = float(row[4])

                # Compute and discard coverage array immediately
                covArray = np.array(row[-1].split(","), dtype=float)
                mean = np.mean(covArray)
                RSD[sample][cluster] = np.std(covArray) / mean if mean > 0 else np.nan

                try:
                    intronCount = counts[sample][cluster]
                    if not args.singleJunctionCalculation:
                        for mxCluster in clusters[cluster]:
                            try:
                                intronCount += counts[sample][mxCluster]
                            except KeyError:
                                pass
                    try:
                        IR[sample][cluster] = median / (median + intronCount)
                    except ZeroDivisionError:
                        IR[sample][cluster] = np.nan
                except KeyError:
                    pass

    filtered_junctions = []
    for junction in junctions:
        for sample in samples:
            if RSD[sample][junction] < args.RSDthreshold:
                filtered_junctions.append(junction)
                break

    return filtered_junctions, IR, RSD
```

Key changes:

1. **`coverage` dict removed entirely** — was the biggest memory consumer

2. **`covArray` is a local variable** — computed and garbage collected each iteration

3. **Division by zero guard on RSD** — the original `np.std/np.mean` would produce `nan` or `inf` when mean is 0, now handled explicitly

4. **Removed the `print` + `pass`** for the KeyError since you already patched that

5. **`if args.makeRSDtable` check removed** — RSD is always computed now since it's cheap (no storage cost), and `filtered_junctions` needs it regardless

   ##

## refactor ir_table

I updated ir_table.py with suggested changes into branch "ir_table_for_high_sample_number"

next steps:

1) run it on a small number of samples to see if it runs without error
2) run it on the full sample size to see if it runs without error
3) run it on a previously run sample to see if it generates the same output



## Attempt 5 - run refactor ir_table on a few samples

does it run  without error?

update docker to use branch

regenerate docker

### create Dockerfile_ir_table_for_high_sample_number

### Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f Dockerfile_ir_table_for_high_sample_number .
```

completed without error

create parallel dir with only a few coverage files

```
cp -r /mnt/splicedice_ir_example /mnt/splicedice_ir_example2
cd /mnt/splicedice_ir_example2/analysis/coverage_output
ls /mnt/splicedice_ir_example2/analysis/coverage_output/* | wc -l
sudo rm -fr /mnt/splicedice_ir_example2/analysis/coverage_output/*
# find a few files to copy over
ls /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* | wc -l
sudo cp /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* /mnt/splicedice_ir_example2/analysis/coverage_output/ 
```

std out

```

ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis/coverage_output$ ls TCGA-05-43[89]* | wc -l
8
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis/coverage_output$ sudo cp /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* /mnt/splicedice_ir_example2/analysis/coverage_output/
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis/coverage_output$ ls -alth !$
ls -alth /mnt/splicedice_ir_example2/analysis/coverage_output/
total 540M
drwxr-xr-x 2 ubuntu ubuntu 4.0K Jun 11 16:48 .
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4396-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4397-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4398-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4384-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4389-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4390-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4395-01A_intron_coverage.txt
-rw-r--r-- 1 root   root    68M Jun 11 16:48 TCGA-05-4382-01A_intron_coverage.txt
drwxrwxr-x 3 ubuntu ubuntu  292 Jun 11 16:43 ..
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/analysis/coverage_output$ 

```

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

confirm that updates are present in calculateIR

```
cat /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py | grep -A50 "def calculateIR"
```



### run ir_table in splicedice_ir_example2

```
base_dir=/mnt/splicedice_ir_example2/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time splicedice ir_table \
--makeRSDtable \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir} > $log_file
date

```

```
/mnt/splicedice_ir_example2/analysisrun_ir_table_with_edit.2026.06.11_17.10.24.log
Thu Jun 11 17:11:53 UTC 2026
real    13m8.848s
user    11m58.567s
sys     1m3.759s
Thu Jun 11 17:25:02 UTC 2026
root@049b9f4b5892:/opt# 
```

#### watch std out log

```
tail -f /mnt/splicedice_ir_example2/analysisrun_ir_table_with_edit.2026.06.11_17.10.24.log

```



```
Gathering inclusion counts and clusters...
Calculating IR values...
Done 729.941855430603
Writing output...
```



#### keep an eye on memory

```
base_dir=/mnt/splicedice_ir_example2/analysis
mem_log_file=${base_dir}/mem_log_for_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $mem_log_file

while true; do
    ps -o pid,vsz,rss,%mem,etime -p $(pgrep splicedice) | tail -1 | \
    awk -v ts="$(date '+%H:%M:%S')" '{print ts, $0}' >> $mem_log_file
    sleep 30
done
```

```
tail -f /mnt/splicedice_ir_example2/analysis/mem_log_for_ir_table_with_edit.2026.06.11_17.20.51.log
```

```
ubuntu@hbeale-mesa:~$ tail -f /mnt/splicedice_ir_example2/analysis/mem_log_for_ir_table_with_edit.2026.06.11_17.20.51.log
17:21:18  208232 34337716 33361180 50.6  09:25
17:21:48  208232 35156404 34179568 51.9  09:55
17:22:18  208232 39600932 38624348 58.6  10:25
17:22:48  208232 39944296 38967476 59.1  10:55
17:23:18  208232 40023912 39047156 59.3  11:25
17:23:48  208232 40089704 39112824 59.4  11:55
17:24:18  208232 35246988 34270308 52.0  12:25
17:24:48  208232 23654176 22677496 34.4  12:55

```

#### check output

```
base_dir=/mnt/splicedice_ir_example2/analysis
head /mnt/splicedice_ir_example2/analysis_intron_retention_RSD.tsv | cut -f1-4
head /mnt/splicedice_ir_example2/analysis_intron_retention.tsv | cut -f1-4

```



```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example2$ head analysis_intron_retention_RSD.tsv | cut -f1-4
Junction        TCGA-05-4382-01A_RSD    TCGA-05-4384-01A_RSD    TCGA-05-4389-01A_RSD
chr10:1000869-1000947:+ 1.225   nan     2.000
chr10:100190165-100190298:+     1.095   0.571   0.816
chr10:100233444-100233952:+     0.972   0.500   0.935
chr10:100348347-100352365:+     1.225   nan     2.000
chr10:100352497-100354426:+     0.935   2.000   2.000
chr10:100356765-100360733:+     0.816   0.935   2.000
chr10:100373230-100381215:+     0.816   2.000   2.000
chr10:100374013-100380894:+     1.016   0.935   0.972

```

```
f=/mnt/splicedice_ir_example2/analysis_intron_retention.tsv
cut -f1 $f | grep -o '^chr[^:]*' | sort -u
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"
    missing=$(comm -23 \
        <(echo "$expected" | tr ' ' '\n' | sort) \
        <(
        awk -F'\t' '$5 != "0.0"' "$f" | cut -f1 | sort -u))
    [[ -n "$missing" ]] && echo "$(basename $f): MISSING: $missing" || echo "$(basename $f): OK"
done > $output_file
```



## Attempt 6 - run refactor v2 ir_table on a few samples

this refactor is intended to make it possible to run 495 samples, but first check if i get the same results

commit id d9d93bad274be55695db568ecb81644ea6b27591



### Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f Dockerfile_ir_table_for_high_sample_number .
```

completed without error

create parallel dir with only a few coverage files

```
new_dir=splicedice_ir_example3
cp -r /mnt/splicedice_ir_example /mnt/${new_dir}
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
# find a few files to copy over
ls /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* | wc -l
sudo cp /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example/git_code/splicedice_analysis/code$ new_dir=splicedice_ir_example3
cp -r /mnt/splicedice_ir_example /mnt/${new_dir}
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
495
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example3/analysis/coverage_output$ sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example3/analysis/coverage_output$ ls /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* | wc -l
8
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example3/analysis/coverage_output$ sudo cp /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example3/analysis/coverage_output$ ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
8
ubunt

```

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

confirm that updates are present in calculateIR

```
cat /usr/local/lib/python3.8/site-packages/splicedice/ir_table.py | grep -A50 "def calculateIR"
```

(look for getJunctions, which only exists in the new code)

### run ir_table in new dir - 

i should no longer need makeRSDtable

```
new_dir=splicedice_ir_example3
base_dir=/mnt/${new_dir}/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time splicedice ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/ > $log_file
date

```

```
/mnt/splicedice_ir_example3/analysisrun_ir_table_with_edit.2026.06.11_18.19.17.log
Thu Jun 11 18:19:29 UTC 2026

real    14m0.180s
user    12m53.244s
sys     0m59.956s
Thu Jun 11 18:33:29 UTC 2026
root@f092ab909ee7:/opt# 


```

#### watch std out log

```
tail -f /mnt/splicedice_ir_example3/analysisrun_ir_table_with_edit.2026.06.11_18.19.17.log

```



```
Gathering inclusion counts and clusters...
Getting filtered junctions...
Done 724.6674153804779
Writing output...
Writing IR for TCGA-05-4382-01A
Writing IR for TCGA-05-4384-01A
Writing IR for TCGA-05-4389-01A
Writing IR for TCGA-05-4390-01A
Writing IR for TCGA-05-4395-01A
Writing IR for TCGA-05-4396-01A
Writing IR for TCGA-05-4397-01A
Writing IR for TCGA-05-4398-01A
Done 781.8313264846802

```



#### keep an eye on memory - not done

```
base_dir=/mnt/splicedice_ir_example2/analysis
mem_log_file=${base_dir}/mem_log_for_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $mem_log_file

while true; do
    ps -o pid,vsz,rss,%mem,etime -p $(pgrep splicedice) | tail -1 | \
    awk -v ts="$(date '+%H:%M:%S')" '{print ts, $0}' >> $mem_log_file
    sleep 30
done
```

```
tail -f /mnt/splicedice_ir_example2/analysis/mem_log_for_ir_table_with_edit.2026.06.11_17.20.51.log
```

```


```

## Attempt 7 - run refactor updated ir_table on a few samples

this refactor is intended to make it possible to run 495 samples, but first check if i get the same results

commit id 952dc45



### Build docker

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
git pull # to get updated dockerfile that installs less nano and curl
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f Dockerfile_ir_table_for_high_sample_number .
~/alert_msg.sh "docker build complete"
```

completed without error

create parallel dir with only a few coverage files

```
new_dir=splicedice_ir_example4
cp -r /mnt/splicedice_ir_example /mnt/${new_dir}
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
# find a few files to copy over
ls /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* | wc -l
sudo cp /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example3/analysis/coverage_output$ new_dir=splicedice_ir_example4
cp -r /mnt/splicedice_ir_example /mnt/${new_dir}
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
495
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example4/analysis/coverage_output$ sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example4/analysis/coverage_output$ ls /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* | wc -l
8
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example4/analysis/coverage_output$ sudo cp /mnt/splicedice_ir_example/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
8
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example4/analysis/coverage_output$ 


```

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

### run ir_table in new dir - 

one time only: copy file to /mnt

```
cp ~/alert_msg.sh /mnt/bin/
```

note: next time add -u so it's not buffering

```
new_dir=splicedice_ir_example4
base_dir=/mnt/${new_dir}/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time splicedice ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"

```

```
/mnt/splicedice_ir_example4/analysis/run_ir_table_with_edit.2026.06.11_19.25.57.log
...
Thu Jun 11 19:26:09 UTC 2026
Starting ir_table with 8 samples
Gathering inclusion counts and clusters...
Loaded 495 samples and 800411 clusters. 573.6s
Annotation loaded: 673463 annotated junctions. 631.1s
Collecting junctions across all samples...
Junction collection and RSD filtering complete: 58609 junctions retained. 745.9s
Writing IR table...
IR calculated for 8/8 samples
IR table written. 804.7s
Done. Total runtime: 804.7s

real    14m25.665s
user    13m15.308s
sys     1m2.869s
Thu Jun 11 19:40:35 UTC 2026


```

#### watch std out log

```
tail -f /mnt/splicedice_ir_example4/analysis/run_ir_table_with_edit.2026.06.11_19.25.57.log
```

The process is running but output is being buffered — Python buffers stdout when it's piped through `tee`. Add `-u` to force unbuffered output:

```
time python -u $(which splicedice) ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/ 2>&1 | tee $log_file
```



#### keep an eye on memory 

```
base_dir=/mnt/splicedice_ir_example2/analysis
mem_log_file=${base_dir}/mem_log_for_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $mem_log_file

echo "time pid vsz_GB rss_GB %mem etime" >> $mem_log_file
while true; do
    ps -o pid,vsz,rss,%mem,etime -p $(pgrep splicedice) | tail -1 | \
    awk -v ts="$(date '+%H:%M:%S')" '{printf "%s %s %6.1fG %6.1fG %s %s\n", ts, $1, $2/1024/1024, $3/1024/1024, $4, $5}' >> $mem_log_file
    sleep 30
done
```

```
tail -f /mnt/splicedice_ir_example2/analysis/mem_log_for_ir_table_with_edit.2026.06.11_19.32.59.log
```

```
19:36:20 213879   38.2G   37.3G 59.4 10:10
19:36:50 213879   38.1G   37.1G 59.1 10:40
19:37:20 213879   38.1G   37.1G 59.1 11:11
19:37:50 213879   38.1G   37.1G 59.1 11:41
19:38:20 213879   38.1G   37.1G 59.1 12:11
19:38:50 213879   38.1G   37.1G 59.1 12:41
19:39:20 213879   38.1G   37.2G 59.1 13:11
19:39:50 213879   32.4G   31.5G 50.1 13:41
time pid vsz_GB rss_GB %mem etime
19:39:54 213879   31.1G   30.2G 48.1 13:44


```



Check if i get the same results

```
diff -q /mnt/splicedice_ir_example4/analysis/_intron_retention.tsv /mnt/splicedice_ir_example/analysis/_intron_retention.tsv
```

nope

```
ubuntu@hbeale-mesa:~$ diff -q /mnt/splicedice_ir_example4/analysis/_intron_retention.tsv /mnt/splicedice_ir_example/analysis/_intron_retention.tsv
Files /mnt/splicedice_ir_example4/analysis/_intron_retention.tsv and /mnt/splicedice_ir_example/analysis/_intron_retention.tsv differ
ubuntu@hbeale-mesa:~$ 

```

look for specific differences

```
f1=/mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
f2=/mnt/splicedice_ir_example/analysis/_intron_retention.tsv
wc -l $f1
wc -l $f2
```

splicedice_ir_example  failed

```
58610 /mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
1 /mnt/splicedice_ir_example/analysis/_intron_retention.tsv
```

try splicedice_ir_example2



```
f1=/mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
f2=/mnt/splicedice_ir_example2/analysis/_intron_retention.tsv
wc -l $f1
wc -l $f2
```

splicedice_ir_example2  failed

```
ubuntu@hbeale-mesa:~$ f1=/mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
f2=/mnt/splicedice_ir_example2/analysis/_intron_retention.tsv
wc -l $f1
wc -l $f2
58610 /mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
1 /mnt/splicedice_ir_example2/analysis/_intron_retention.tsv
ubuntu@hbeale-mesa:~$ 
```



try splicedice_ir_example3



```
f1=/mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
f2=/mnt/splicedice_ir_example3/analysis/_intron_retention.tsv
wc -l $f1
wc -l $f2
```

same # of lines

```
58610 /mnt/splicedice_ir_example4/analysis/_intron_retention.tsv
58610 /mnt/splicedice_ir_example3/analysis/_intron_retention.tsv
```

Check if i get the same results - yes!!!

```
diff -q $f1 $f2
```

the log started to list every junction not present, which would explode storage



```
mxCluster TCGA-05-4395-01A chr1:44213663-44213748:+ chr1:44213550-44213708:+
mxCluster TCGA-05-4395-01A chr1:44213663-44213748:+ chr1:44213550-44213662:+
mxCluster TCGA-05-4395-01A chr1:44213859-44214349:+ chr1:44213859-44214702:+
^C^C

real    6m42.758s
user    7m15.402s
sys     1m39.545s
Thu Jun 11 22:28:04 UTC 2026
```



## Attempt 8 - run refactor updated ir_table on all samples

test the refactoron 495 samples

commit id 952dc45

create parallel dir; keep all coverage files

```
new_dir=splicedice_ir_example5
cp -r /mnt/splicedice_ir_example /mnt/${new_dir}
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l

```

std out

```
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example5/analysis/coverage_output$ new_dir=splicedice_ir_example5
cp -r /mnt/splicedice_ir_example /mnt/${new_dir}
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example5/analysis/coverage_output$ cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
495
ubuntu@hbeale-mesa:/mnt/splicedice_ir_example5/analysis/coverage_output$ 


```

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

### run ir_table in new dir - 

note: next time add -u so it's not buffering

```
new_dir=splicedice_ir_example5
base_dir=/mnt/${new_dir}/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time python -u $(which splicedice) ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-o ${base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"

```







```
/mnt/splicedice_ir_example5/analysis/run_ir_table_with_edit.2026.06.11_19.45.52.log...
Thu Jun 11 19:46:13 UTC 2026
Starting ir_table with 495 samples
Gathering inclusion counts and clusters...
Loaded 495 samples and 800411 clusters. 569.9s
Annotation loaded: 673463 annotated junctions. 628.1s
Collecting junctions across all samples...
Junction collection and RSD filtering complete: 126568 junctions retained. 7604.6s
Writing IR table...
        IR calculated for 50/495 samples
IR calculated for 100/495 samples
IR calculated for 150/495 samples
IR calculated for 200/495 samples
IR calculated for 250/495 samples
IR calculated for 300/495 samples
IR calculated for 350/495 samples
IR calculated for 400/495 samples
IR calculated for 450/495 samples
IR calculated for 495/495 samples
IR table written. 13135.4s
Done. Total runtime: 13135.4s

real    219m57.008s
user    214m26.875s
sys     3m25.406s
Thu Jun 11 23:26:10 UTC 2026
{"status":"OK","nsent":2,"apilimit":"6\/1000"}
root@c0393a466675:/opt# 


```



#### keep an eye on memory 

```
base_dir=/mnt/splicedice_ir_example5/analysis
mem_log_file=${base_dir}/mem_log_for_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $mem_log_file

echo "time pid vsz_GB rss_GB %mem etime" >> $mem_log_file
while true; do
    ps -o pid,vsz,rss,%mem,etime -p $(pgrep python) | tail -1 | \
    awk -v ts="$(date '+%H:%M:%S')" '{printf "%s %s %6.1fG %6.1fG %s %s\n", ts, $1, $2/1024/1024, $3/1024/1024, $4, $5}' >> $mem_log_file
    sleep 30
done
```

```
tail -f /mnt/splicedice_ir_example5/analysis/mem_log_for_ir_table_with_edit.2026.06.11_19.47.01.log
```

```
time pid vsz_GB rss_GB %mem etime
19:48:12 214426    8.8G    7.9G 12.5 01:59
19:48:42 214426    9.6G    8.7G 13.8 02:29
19:49:12 214426   10.4G    9.5G 15.0 02:59
19:49:42 214426   11.1G   10.2G 16.1 03:29
19:50:12 214426   16.4G   15.5G 24.6 03:59
19:50:42 214426   17.2G   16.3G 25.9 04:29
19:51:13 214426   18.0G   17.1G 27.1 04:59
19:51:43 214426   18.7G   17.8G 28.3 05:30
19:52:13 214426   19.4G   18.5G 29.4 06:00
19:52:43 214426   20.2G   19.2G 30.6 06:30
19:53:13 214426   20.8G   19.9G 31.6 07:00
19:53:43 214426   23.4G   22.5G 35.8 07:30
19:54:13 214426   31.1G   30.2G 48.0 08:00
19:54:43 214426   31.9G   31.0G 49.3 08:30
19:55:13 214426   33.5G   32.5G 51.8 09:00
19:55:43 214426   37.9G   36.9G 58.8 09:30
19:55:43 214426   37.9G   36.9G 58.8 09:30
19:56:14 214426   38.2G   37.3G 59.3 10:01
19:56:44 214426   38.0G   37.1G 59.0 10:31
19:57:14 214426   38.1G   37.1G 59.1 11:01

...
20:37:52 214426   38.1G   37.1G 59.1 51:39
20:38:22 214426   38.1G   37.1G 59.1 52:09
20:38:52 214426   38.1G   37.1G 59.1 52:39
20:39:23 214426   38.1G   37.1G 59.1 53:09
20:39:53 214426   38.1G   37.1G 59.1 53:40
20:40:23 214426   38.1G   37.1G 59.1 54:10
20:40:53 214426   38.1G   37.1G 59.1 54:40
20:41:23 214426   38.1G   37.1G 59.1 55:10
20:41:53 214426   38.1G   37.1G 59.1 55:40
20:42:23 214426   38.1G   37.1G 59.1 56:10
20:42:53 214426   38.1G   37.1G 59.1 56:40
20:43:23 214426   38.1G   37.1G 59.1 57:10
20:43:53 214426   38.1G   37.1G 59.1 57:40
20:44:24 214426   38.1G   37.1G 59.1 58:10
...

22:57:51 214426   44.3G   43.3G 69.0 03:11:38
22:58:21 214426   44.3G   43.4G 69.0 03:12:08
22:58:51 214426   44.4G   43.4G 69.1 03:12:38

```



### check output

```
new_dir=splicedice_ir_example5
ls /mnt/${new_dir}/analysis
```

```
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_vA10/analysis$ head /mnt/${new_dir}/analysis/_intron_retention.tsv | cut -f1-5 
Junction        TCGA-78-7166-01A        TCGA-78-7167-01A        TCGA-78-7220-01A        TCGA-78-7535-01A
chr10:1000869-1000947:+ 0.000   0.008   0.006   0.000
chr10:1001014-1005817:+ 0.000   0.000   0.000   0.000
chr10:100190165-100190298:+     nan     1.000   1.000   nan
chr10:100229725-100231014:+     nan     nan     nan     nan
chr10:100233444-100233952:+     1.000   1.000   1.000   1.000
chr10:100347532-100348063:+     0.000   0.000   0.003   0.000
chr10:100348347-100352365:+     0.000   0.000   0.003   0.000
chr10:100352497-100354426:+     0.000   0.000   0.000   0.000
chr10:100354633-100356531:+     0.000   0.000   0.000   0.000

```



```
less -N -S _intron_retention.sorted.tsv
```



```
180 chr1:1060394-1065948:+  1.000   0.000   0.222   0.111   nan     nan     0.100 >
    181 chr1:1061118-1063078:+  nan     0.000   0.000   0.091   nan     nan     0.103 >
    182 chr1:1063202-1064205:+  nan     0.000   0.000   0.040   nan     nan     0.107 >
    183 chr1:1063202-1065829:+  nan     0.200   0.125   0.111   nan     nan     0.107 >
    184 chr1:1063202-1065833:+  nan     0.200   0.125   0.111   nan     nan     0.107 >
    185 chr1:1063202-1065948:+  nan     0.200   0.125   0.111   nan     nan     0.107 >
    186 chr1:1063315-1065829:+  1.000   0.000   0.000   0.220   nan     nan     0.167 >
    187 chr1:1063318-1064205:+  1.000   0.000   0.000   0.111   nan     nan     0.107 >
    188 chr1:1063318-1065829:+  1.000   0.000   0.000   0.158   nan     nan     0.167 >
    189 chr1:1063318-1065833:+  1.000   0.000   0.000   0.158   nan     nan     0.138 >
    190 chr1:1064402-1065829:+  nan     0.000   0.000   0.000   nan     nan     0.000 >
    191 chr1:1064590-1065829:+  1.000   0.000   0.000   0.111   nan     nan     0.138 >
    192 chr1:1064590-1065948:+  1.000   0.000   0.125   0.111   nan     nan     0.138 >
    193 chr1:1098114-1104032:+  nan     nan     nan     nan     nan     nan     nan   >
    194 chr1:1173927-1174215:+  nan     nan     nan     nan     nan     nan     nan   >
    195 chr1:1173927-1174284:+  nan     nan     nan     nan     nan     nan     nan   >
    196 chr1:1173927-1174520:+  nan     0.000   nan     nan     nan     nan     nan   >
    197 chr1:1174322-1174423:+  nan     0.000   nan     nan     nan     nan     1.000
```

observations

some junctions have 0 and nan, some are mostly nan



questions:

compared to 8-sample process, how many junctions are there? what fractions of nan are observed? of 0?

####  see if any major chromosomes are missing

```
f=/mnt/${new_dir}/analysis/_intron_retention.tsv
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"
missing=$(comm -23 \
    <(echo "$expected" | tr ' ' '\n' | sort) \
    <(tail -n +2 $f | cut -f1 | grep -o '^chr[^:]*' | sort -u))
[[ -n "$missing" ]] && echo "MISSING: $missing" || echo "OK"

```

to confirm that this works, re-run it with :

```
expected="chrblahblahblah"
```

expected output with "bad" test case:

```
MISSING: chrblahblahblah

```

#### sort intron_retention results

```
cd /mnt/${new_dir}/analysis/
cat _intron_retention.tsv  | head -1 > _intron_retention.sorted.tsv
cat _intron_retention.tsv | grep -v ^Junction | sort --field-separator=":" -k1,1V -k2,2n >> _intron_retention.sorted.tsv

```



## Attempt 9 - run refactored updated ir_table on a few samples - swamped by mxcluster

parallelize getFilteredJunctions and use pandas

#### server ubuntu@hbeale-clin-validation

define run-specific variables

```
echo 'export new_dir=splicedice_ir_example
export old_dir=splicedice_ir_example_from_hbeale_mesa' > /mnt/scratch/env.sh
```



run this in each new gnu screen window used for the analysis

```
source /mnt/scratch/env.sh
```



### Download repo



```
mkdir -p /mnt/${new_dir}/git_code /mnt/${new_dir}/analysis
cd /mnt/${new_dir}/git_code
git clone https://github.com/hbeale/splicedice_analysis.git
git switch 
```



### Build docker

```
cd /mnt/${new_dir}/git_code/splicedice_analysis/code
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f Dockerfile_ir_table_for_high_sample_number .
bash ~/alert_msg.sh "docker build complete"
```

completed without error



copy_data_from hbeale-mesa

```
scp ubuntu@10.50.100.135://mnt/splicedice_ir_example /mnt/splicedice_ir_example_from_hbeale_mesa
scp ubuntu@10.50.100.135://mnt/ref/gencode.v47.primary_assembly.annotation.gtf /mnt/ref/

```



```

cp -r /mnt/${old_dir}/analysis/* /mnt/${new_dir}/analysis/
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
# find a few files to copy over
ls /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* | wc -l
sudo cp /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l

```

std out

```
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example/analysis/coverage_output$ ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
495
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example/analysis/coverage_output$ sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example/analysis/coverage_output$ ls /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* | wc -l
8
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example/analysis/coverage_output$ sudo cp /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
8

```

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

### run ir_table in new dir 

```
source /mnt/scratch/env.sh
base_dir=/mnt/${new_dir}/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time python -u $(which splicedice) ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-n 8 \
-o ${base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"

```

```
/mnt/splicedice_ir_example/analysis/run_ir_table_with_edit.2026.06.11_22.19.13.log
Thu Jun 11 22:21:21 UTC 2026
Starting ir_table with 8 samples
Loading annotation...
Annotation loaded: 673463 annotated junctions. 53.1s
Gathering inclusion counts and clusters...
```

old log for comparison:

```
Starting ir_table with 8 samples
Gathering inclusion counts and clusters...
Loaded 495 samples and 800411 clusters. 573.6s
Annotation loaded: 673463 annotated junctions. 631.1s
Collecting junctions across all samples...
Junction collection and RSD filtering complete: 58609 junctions retained. 745.9s
Writing IR table...
IR calculated for 8/8 samples
IR table written. 804.7s
Done. Total runtime: 804.7s
```

i got swamped by mxCluster errors; changed print("mxCluster", sample, cluster, mxCluster) to pass. next attempt:

the log exploded with entries like this:



```
mxCluster TCGA-05-4382-01A chr1:159032692-159051678:+ chr1:159045451-159049586:+
mxCluster TCGA-05-4382-01A chr1:159032692-159051678:+ chr1:159045465-159047568:+
mxCluster TCGA-05-4382-01A chr1:159032692-159051678:+ chr1:159045465-159049307:+
mxCluster TCGA-05-4382-01A chr1:159032692-159051678:+ chr1:159045465-159054820:+

```



I silences mxCluster reports by changing 

  print("mxCluster", sample, cluster, mxCluster)

to 

​                            pass 

on line 169 of splicedice/ir_table.py

When the matrices are built from many samples and I'm running a test using only intron_coverage from a few samples, the number of clusters not present becomes very high. In the past, each cluster is reported separately, which overwhelms the output (log, gnu screen windows, whatever). This may only be a problem for people doing testing. What should we do going forward?



### Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

cp -R /mnt/${new_dir}/ $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.06.12_20.05.38/







## Attempt 10 - run refactored updated ir_table on a few samples - success

parallelize getFilteredJunctions and use pandas

#### server ubuntu@hbeale-clin-validation

define run-specific variables

```
echo 'export new_dir=splicedice_ir_example_vA10
export old_dir=splicedice_ir_example_from_hbeale_mesa' > /mnt/scratch/env.sh
```



run this in each new gnu screen window used for the analysis

```
source /mnt/scratch/env.sh
```



### Download repo


```
mkdir -p /mnt/${new_dir}/git_code /mnt/${new_dir}/analysis
cd /mnt/${new_dir}/git_code
git clone https://github.com/hbeale/splicedice_analysis.git

```



### Build docker

```
cd /mnt/${new_dir}/git_code/splicedice_analysis/code
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f Dockerfile_ir_table_for_high_sample_number .
bash ~/alert_msg.sh "docker build complete"
```

completed without error

```
cp -r /mnt/${old_dir}/analysis/* /mnt/${new_dir}/analysis/
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
# find a few files to copy over
ls /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* | wc -l
sudo cp /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l

```

std out

```
ubuntu@hbeale-clin-validation:~$ cp -r /mnt/${old_dir}/analysis/* /mnt/${new_dir}/analysis/
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
495
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_vA10/analysis/coverage_output$ sudo rm -fr /mnt/${new_dir}/analysis/coverage_output/*
# find a few files to copy over
ls /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* | wc -l
sudo cp /mnt/${old_dir}/analysis/coverage_output/TCGA-05-43[89]* /mnt/${new_dir}/analysis/coverage_output/ 
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
8
8
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_vA10/analysis/coverage_output$ 

```

### start docker interactively

```
this_docker=splicedice_analysis:latest
docker run --rm -it \
-v /mnt/:/mnt/ \
--entrypoint=/bin/bash \
$this_docker
```

### run ir_table in new dir 

```
source /mnt/scratch/env.sh
base_dir=/mnt/${new_dir}/analysis
genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf
log_file=${base_dir}/run_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file

date
time python -u $(which splicedice) ir_table \
--annotation $genes \
-i ${base_dir}/_inclusionCounts.tsv \
-c ${base_dir}/_allClusters.tsv \
-d ${base_dir}/coverage_output \
-n 8 \
-o ${base_dir}/ 2>&1 | tee $log_file
date
/mnt/bin/alert_msg.sh "ir_table complete"

```

```
/mnt/splicedice_ir_example_vA10/analysis/run_ir_table_with_edit.2026.06.11_22.44.00.log
Thu Jun 11 22:44:15 UTC 2026
Starting ir_table with 8 samples
Loading annotation...
Annotation loaded: 673463 annotated junctions. 53.5s
Gathering inclusion counts and clusters...
Loaded 495 samples and 800411 clusters. 296.0s
Collecting junctions across all samples...
getJunctions complete: 165179 junctions. 10.9s
RSD filtering complete: 58609 junctions retained. 28.7s
Junction collection and RSD filtering complete: 58609 junctions retained. 324.8s
Writing IR table...
IR calculated for 8/8 samples
IR table written. 386.5s
Done. Total runtime: 386.5s
real    6m39.078s
user    7m23.378s
sys     1m9.073s
Thu Jun 11 22:50:54 UTC 2026
```

old log for comparison:

```
Starting ir_table with 8 samples
Gathering inclusion counts and clusters...
Loaded 495 samples and 800411 clusters. 573.6s
Annotation loaded: 673463 annotated junctions. 631.1s
Collecting junctions across all samples...
Junction collection and RSD filtering complete: 58609 junctions retained. 745.9s
Writing IR table...
IR calculated for 8/8 samples
IR table written. 804.7s
Done. Total runtime: 804.7s
```

#### keep an eye on memory 

```
source /mnt/scratch/env.sh
base_dir=/mnt/${new_dir}/analysis
mem_log_file=${base_dir}/mem_log_for_ir_table_with_edit.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $mem_log_file

echo "time pid vsz_GB rss_GB %mem etime" >> $mem_log_file
while true; do
    ps -o pid,vsz,rss,%mem,etime -p $(pgrep python) | tail -1 | \
    awk -v ts="$(date '+%H:%M:%S')" '{printf "%s %s %6.1fG %6.1fG %s %s\n", ts, $1, $2/1024/1024, $3/1024/1024, $4, $5}' >> $mem_log_file
    sleep 30
done
```

```
tail -f /mnt/splicedice_ir_example_vA10/analysis/mem_log_for_ir_table_with_edit.2026.06.11_22.49.32.log

```

```
time pid vsz_GB rss_GB %mem etime
22:49:43 57830   11.6G   10.6G 16.8 05:28
22:50:13 57830   11.6G   10.6G 16.8 05:58
22:50:43 57830   11.6G   10.6G 16.8 06:28

```



### check output

```
ls /mnt/${new_dir}/analysis
```

```
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_vA10/analysis$ head /mnt/${new_dir}/analysis/_intron_retention.tsv | cut -f1-5 
Junction        TCGA-05-4382-01A        TCGA-05-4384-01A        TCGA-05-4389-01A        TCGA-05-4390-01A
chr10:1000869-1000947:+ 0.000   0.000   0.000   0.000
chr10:100190165-100190298:+     1.000   1.000   1.000   1.000
chr10:100233444-100233952:+     1.000   1.000   1.000   nan
chr10:100348347-100352365:+     0.000   0.000   0.000   0.000
chr10:100352497-100354426:+     0.005   0.000   0.000   0.000
chr10:100356765-100360733:+     0.002   0.003   0.000   0.000
chr10:100373230-100381215:+     0.017   0.000   0.000   0.000
chr10:100374013-100380894:+     0.031   0.042   0.050   0.000
chr10:100374013-100380982:+     0.031   0.042   0.050   0.125
ubuntu@hbeale-clin-validation:/mnt/splicedice_ir_example_vA10/analysis$ 

```



####  see if any major chromosomes are missing

```
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"
missing=$(comm -23 \
    <(echo "$expected" | tr ' ' '\n' | sort) \
    <(tail -n +2 /mnt/${new_dir}/analysis/_intron_retention.tsv | cut -f1 | grep -o '^chr[^:]*' | sort -u))
[[ -n "$missing" ]] && echo "MISSING: $missing" || echo "OK"

```

to confirm that this works, re-run it with :

```
expected="chrblahblahblah"
```

expected output with "bad" test case:

```
MISSING: chrblahblahblah

```





### Cleanup and archive



```
cd /mnt
this_archive_folder=/mnt/splicedice_ir_example_archives/`date "+%Y.%m.%d_%H.%M.%S"`/
echo $this_archive_folder

echo cp -R /mnt/${new_dir}/ $this_archive_folder
cp -R /mnt/${new_dir}/ $this_archive_folder
```

/mnt/splicedice_ir_example_archives/2026.06.12_20.07.53/





## Attempt 11 - run refactored updated ir_table on 495 samples 

parallelize getFilteredJunctions and use pandas

#### server ubuntu@hbeale-clin-validation

define run-specific variables

```
echo 'export new_dir=splicedice_ir_example_A11
export old_dir=splicedice_ir_example5' > /mnt/scratch/env.sh
```



run this in each new gnu screen window used for the analysis

```
source /mnt/scratch/env.sh
```



create parallel dir; keep all coverage files

```
cp -r /mnt/${old_dir} /mnt/${new_dir}
cd /mnt/${new_dir}/analysis/coverage_output
ls /mnt/${new_dir}/analysis/coverage_output/* | wc -l
rm /mnt/${new_dir}/analysis/_intron_retention.tsv
rm /mnt/${new_dir}/analysis/_intron_retention.sorted.tsv

```



### Download repo


```
cd /mnt/${new_dir}/git_code/splicedice_analysis
git pull

```



### Build docker

```
cd /mnt/${new_dir}/git_code/splicedice_analysis/code
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f Dockerfile_ir_table_for_high_sample_number .
bash ~/alert_msg.sh "docker build complete"

```

completed without error

### run ir_table

```
source /mnt/scratch/env.sh
base_dir=/mnt/${new_dir}/analysis
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



```
/mnt/splicedice_ir_example_A11/analysis/run_ir_table_with_edit.2026.06.15_21.55.46.log
```

```
Mon Jun 15 21:56:57 UTC 2026
Starting ir_table with 495 samples
Loading annotation...
Annotation loaded: 673463 annotated junctions. 58.2s
Gathering inclusion counts and clusters...
Loaded 495 samples and 800411 clusters. 268.3s
Collecting junctions across all samples...
getJunctions complete: 165179 junctions. 566.9s
RSD filtering complete: 126568 junctions retained. 1426.6s
Junction collection and RSD filtering complete: 126568 junctions retained. 1695.6s
Writing IR table...
IR calculated for 50/495 samples
IR calculated for 100/495 samples
IR calculated for 150/495 samples
IR calculated for 200/495 samples
IR calculated for 250/495 samples
IR calculated for 300/495 samples
IR calculated for 350/495 samples
IR calculated for 400/495 samples
IR calculated for 450/495 samples
IR calculated for 495/495 samples
IR table written. 7591.0s
Done. Total runtime: 7591.0s

real    126m47.625s
user    0m0.598s
sys     0m0.125s
Tue Jun 16 00:03:45 UTC 2026
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
```



## Characterize completeness of data

data from attempt 8; 495 samples 

```
/mnt/splicedice_ir_example5/analysis/_intron_retention.tsv
base_dir=/mnt/splicedice_ir_example/analysis

R 
library(tidyverse)
ir_raw <- read_tsv("/mnt/splicedice_ir_example5/analysis/_intron_retention.sorted.tsv",
n_max = 10000)
ir_raw[1:6,1:6]
ir_raw_long <- pivot_longer(ir_raw, -Junction)
head(ir_raw_long)

per_jnx_vals <- ir_raw_long %>%
group_by(Junction) %>%
summarize(n_Nan = sum(is.na(value)),
n_0 = sum(value == 0, na.rm = TRUE),
n_1 = sum(value == 1, na.rm = TRUE))

summary(per_jnx_vals$n_Nan)
summary(per_jnx_vals$n_0)
summary(per_jnx_vals$n_1)

```



# Test set 

```
TCGA-05-4382-01A
TCGA-05-4384-01A
TCGA-05-4389-01A
TCGA-05-4390-01A
TCGA-05-4395-01A
TCGA-05-4396-01A
TCGA-05-4397-01A
TCGA-05-4398-01A
```



get example data 

# CLAUDE

```

```

in the intron_retention code in https://public.gi.ucsc.edu/~hcbeale/splicedice/, will the final results be affected if I run it on all bam files at once versus one bam file at a time?

10:08 AM

## Claude responded: No, the final results will be identical either way.

Searched the web

No, the final results will be identical either way. Looking at `ir_table.py`, the IR calculation is entirely **per-sample and per-junction** — each sample's IR value is computed independently as:

```
IR = median_intron_coverage / (median_intron_coverage + junction_count)
```

The only cross-sample step is `filtered_junctions`, which determines which junctions appear in the output table — a junction is kept if **any** sample passes the RSD threshold. This means:

- Running all BAMs at once → junctions present in any sample are retained
- Running one BAM at a time → each run only sees that one sample's junctions

So if you run one BAM at a time, you could get **different junction sets** in each output (junctions unique to one sample might be dropped), but the IR **values** for any junction that does appear will be numerically identical.

The practical implication: you want to run all samples together in `ir_table.py` so the junction filtering is done across the full cohort. The upstream per-sample steps (generating the coverage files and inclusion counts) are fine to run one BAM at a time.

## You said: what are the output names of the introncoverage process?

what are the output names of the intron_coverage process? for the ir_table processs?

10:10 AM

## Claude responded: Looking at the code already fetched:

Looking at the code already fetched:

**`intron_coverage.py`** — let me check that one:

Fetched: https://public.gi.ucsc.edu/~hcbeale/splicedice/splicedice/intron_coverage.py

**`intron_coverage`** outputs one file per sample into `--outputDir`:

```
{outputDir}/{sample_name}_intron_coverage.txt
```

Where `sample_name` comes from column 1 of the BAM manifest.

------

**`ir_table`** outputs up to two files based on `--outputPrefix`:

```
{outputPrefix}_intron_retention.tsv       # always
{outputPrefix}_intron_retention_RSD.tsv   # only if --makeRSDtable is passed
```

------

Also worth noting: `ir_table` discovers its samples by scanning the `--coverageDirectory` for files ending in `_intron_coverage.txt`, so the sample names it uses are derived directly from those filenames (stripping the suffix). The two steps are tightly coupled by that naming convention.

## You said: are the {outputDir}/{samplename}intron_coverage.

are the {outputDir}/{sample_name}_intron_coverage.txt results the same if I run it on all bam files at once versus one bam file at a time?

10:11 AM

## Claude responded: Yes, identical.

Yes, identical. Looking at `getCoverage()` in `intron_coverage.py`, each sample is processed completely independently — it opens its own BAM file, computes its own counts, and writes its own `{sample}_intron_coverage.txt`. There is no state shared between samples.

The multiprocessing in `getCoveragePool()` uses `imap_unordered` across samples, but each worker gets its own copy of the percentiles dict (`percentiles = self.percentiles.copy()`) and writes to its own output file. Nothing is accumulated across samples.

So you can safely run one BAM at a time and the output files will be byte-for-byte identical to running all at once.

## You said: say more about what getCoveragePool does and whether it's part of irtable or introncoverage

say more about what getCoveragePool does and whether it's part of ir_table or intron_coverage

10:12 AM

## Claude responded: getCoveragePool is part of introncoverage.

`getCoveragePool` is part of **`intron_coverage.py`** only — `ir_table.py` has no parallelism.

What it does: it's just a thin wrapper around Python's `multiprocessing.Pool` that calls `getCoverage(sample)` in parallel across samples:

python

```python
def getCoveragePool(self):
    samples = list(self.bams.keys())
    with Pool(self.numThreads) as pool:
        for run in pool.imap_unordered(self.getCoverage, samples):
            pass
```

- `Pool(self.numThreads)` — spawns N worker processes, controlled by `--numThreads`
- `imap_unordered` — distributes the sample list across workers; results come back in whatever order they finish (hence "unordered") — but since each worker just writes its own file and returns nothing meaningful, the order doesn't matter
- The `for run in ...: pass` loop is just there to consume the iterator and block until all workers finish

So `getCoveragePool` is purely a parallelization convenience — run with `--numThreads 1` (the default) and it processes samples serially, same as if you ran them one at a time manually. The outputs are identical either way.

