# helper for 2026-06-16 Simplified splicedice pipeline.md

## notes 

make manifests

primary manifest

sample_name	bam_location	bed_location	phenotype

splicedice: nice id, bed file, bam file, phenotype

gdc- nice id, ugly id



run ip

option to download and remove as we go

use helper script for downloading to keep download-specific data out





# test runs

## copy gdc file

```bash
cp /mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt ~
```





### define location

```
this_commit=4dd834b
this_description=streamlined
this_base_dir=/mnt/sd/ex_${this_description}_${this_commit}_`date "+%Y.%m.%d_%H.%M.%S"`/
mkdir -p $this_base_dir
echo $this_base_dir
```

```bash
this_base_dir=/mnt/sd/ex_streamlined_4dd834b_2026.06.16_21.04.07/
```



## clone repo

```bash
mkdir $this_base_dir/git_code
cd !$ 
git clone https://github.com/hbeale/splicedice_analysis.git
```

## build docker

```bash
cd ${this_base_dir}/git_code/splicedice_analysis/2026_06_ps_ir_pipeline
this_dockerfile=Dockerfile_4dd834b
docker build --build-arg CACHE_BUST=$(date +%s) -t splicedice_analysis:latest -f $this_dockerfile .
bash ~/alert_msg.sh "docker build complete"
```

## update manifest locations

```bash
manifest_dir=${this_base_dir}/git_code/splicedice_analysis/2026_06_ps_ir_pipeline/manifests
this_manifest=${manifest_dir}/primary_manifest.4dd834b_2026.06.16_21.04.07.txt
cat ${manifest_dir}/primary_manifest.txt  | sed "s|/mnt/data/tcga|${this_base_dir}/bams|" | \
sed "s|/mnt/data/intron_prospector_runs/common|${this_base_dir}/intron_beds|" > $this_manifest

```





## make mini manifest

```bash

head -3 $this_manifest > ${this_manifest/.txt}.2_samples.txt
```

```bash
```



## run ip

(see nice doc)

## check ip output

```bash
ls -rhl ${this_base_dir}/intron_beds
```



## make bed manifest

```bash
mini_manifest=${this_manifest/.txt}.2_samples.txt
quant_manifest=${mini_manifest/primary_manifest/quant_manifest}
cat ${mini_manifest} | grep -v dataset_id | cut -f1,3,4 > $quant_manifest
```

## run quant (see nice doc)

## run intron coverage

Calculate intron coverage

### define script

```
base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=download_and_run_intron_coverage_on_bam_files_v3.sh
script=${base_note_dir}${script_basename}
log_file=${base_note_dir}${script_basename/.sh}.`date "+%Y.%m.%d_%H.%M.%S"`.log
echo $log_file
```



```bash

base_note_dir=/mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/
script_basename=scripts/run_intron_coverage_pipeline.sh
mini_manifest=${this_manifest/.txt}.2_samples.txt
analysis_base=${base_note_dir}/analysis/
batch_size=2

${base_note_dir}/${script_basename} \
    --manifest $mini_manifest \
    --analysis-base $analysis_base \
    --batch-size $batch_size
 \
    --manifest /mnt/splicedice_ir_example/git_code/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/primary_manifest.txt \
    --analysis-base /mnt/splicedice_ir_example/analysis \
    --batch-size 16
```

## run ir_table (see nice doc)

## Cleanup and Archive

```
this_base_dir=/mnt/sd/ex_streamlined_4dd834b_2026.06.16_21.04.07/
sudo cp -R ${this_base_dir} /mnt/splicedice_ir_example_archives/
ls /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
echo /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
```

oops

```bash
cd /mnt/splicedice_ir_example_archives/`basename $this_base_dir`
mv _intron_retention* analysis/

```

