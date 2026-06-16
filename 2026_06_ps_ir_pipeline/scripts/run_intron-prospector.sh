#!/usr/bin/env bash
set -euo pipefail
set -x
trap 'echo "ERROR: script failed at line $LINENO with exit code $?" >&2' ERR

if [[ $# -lt 3 ]]; then
    echo "Usage: $(basename $0) <manifest> <genome> <disk_constraint>" >&2
    echo >&2
    echo "  manifest:         TSV with columns: dataset_id, bam_location, bed_location, phenotype, download_id" >&2
    echo "  genome:           path to reference genome FASTA" >&2
    echo "  disk_constraint:  delete BAM files after processing? [yes or no]" >&2
    exit 1
fi

manifest=$1
genome=$2
disk_constraint=$3

# cat $manifest | grep -v ^id | while read dataset_id bam_location bed_location phenotype download_id; do
while read dataset_id bam_location bed_location phenotype download_id; do
echo
echo processing $dataset_id

if [[ ! -f "$bed_location" && ! -f "$bam_location" ]]; then 
    echo "neither bed or bam file exists"
    echo "downloading bam file..."
    # replace this with whatever download is relevant to your data
    bam_upstream_base_dir=$(dirname $(dirname $bam_location))
    bash $(dirname $0)/download_bam.sh $download_id $bam_upstream_base_dir
fi

if [[ ! -f "$bed_location" && -f "$bam_location" ]]; then 
    echo "bam file exists but bed file does not"
    echo "running intron-prospector..."
    mkdir -p ${dirname $bed_location)
    docker run --rm \
    -v /mnt/:/mnt \
    splicedice_analysis:latest \
    intron-prospector \
    --genome-fasta=$genome \
    --intron-bed6=$bed_location \
    --skip-missing-targets \
    $bam_location
fi

if [[ $disk_constraint == "yes" && -f "$bam_location" && -f "$bed_location" ]]; then 
    echo "both bed and bam files now exist"
    echo "deleting bam file"
    rm $bam_location 
fi

# done
done < <(grep -v ^dataset_id $manifest)