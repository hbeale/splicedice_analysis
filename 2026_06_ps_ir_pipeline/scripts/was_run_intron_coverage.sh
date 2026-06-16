#!/usr/bin/env bash
set -euo pipefail

# ── usage ─────────────────────────────────────────────────────────────────────
usage() {
    echo "Usage: $(basename "$0") <batch_size> <bam_manifest> <coverage_dir> <n_threads> <junctions_bed> <all_ps_tsv> <tmp_dir> <disk_constraint>" >&2
    echo >&2
    echo "  batch_size      number of samples to process per batch (e.g. 16)" >&2
    echo "  bam_manifest    path to the BAM manifest TSV file" >&2
    echo "  coverage_dir    directory for coverage output files" >&2
    echo "  n_threads       number of threads to use" >&2
    echo "  junctions_bed   path to output _junctions.bed file" >&2
    echo "  all_ps_tsv      path to output _allPS.tsv file" >&2
    echo "  tmp_dir         path to temporary working directory" >&2
    echo "  disk_constraint delete BAM files after processing? [yes or no]" >&2
    exit 1
}

if [[ $# -ne 8 || ! "$1" =~ ^[0-9]+$ ]]; then
    usage
fi

BATCH_SIZE="$1"
bam_manifest="$2"
coverage_dir="$3"
n_threads="$4"
junctions_bed="$5"
all_ps_tsv="$6"
tmp_dir="$7"
disk_constraint="$8"

if [[ ! -f "$bam_manifest" ]]; then
    echo "Error: bam_manifest not found: $bam_manifest" >&2
    exit 1
fi


# ── paths ────────────────────────────────────────────────────────────────────


mkdir -p "$coverage_dir" 

# ── collect samples that still need processing ───────────────────────────────
# Each element: "id\tbam_file\tgenotype"
mapfile -t all_samples < <(grep -v '^id' "$bam_manifest")

pending=()
for row in "${all_samples[@]}"; do
    id=$(echo "$row" | cut -f1)
    expected_output="${coverage_dir}/${id}_intron_coverage.txt"
    if [[ ! -f "$expected_output" ]]; then
        pending+=("$row")
    else
        echo "skipping $id (output already exists)"
    fi
done

total=${#pending[@]}
echo ""
echo "=== ${total} samples still need intron_coverage ==="
echo ""

if [[ $total -eq 0 ]]; then
    echo "Nothing to do."
    exit 0
fi

# ── process in batches ───────────────────────────────────────────────────────
batch_num=0
i=0

while [[ $i -lt $total ]]; do

    batch_num=$(( batch_num + 1 ))
    batch=("${pending[@]:$i:$BATCH_SIZE}")
    i=$(( i + BATCH_SIZE ))

    echo "========================================================"
    echo "BATCH ${batch_num}: ${#batch[@]} samples"
    echo "========================================================"

    # -- collect ids/paths for this batch --
    batch_ids=()
    batch_bam_files=()

    for row in "${batch[@]}"; do
        id=$(echo "$row"       | cut -f1)
        bam_file=$(echo "$row" | cut -f2)
        batch_ids+=("$id")
        batch_bam_files+=("$bam_file")
    done

    # ── step 1: download missing BAMs in one gdc-client call ─────────────
    echo ""
    echo "--- downloading missing BAMs ---"
    uuids_to_download=()

    for idx in "${!batch_ids[@]}"; do
        id="${batch_ids[$idx]}"
        bam_file="${batch_bam_files[$idx]}"
        if [[ -f "$bam_file" ]]; then
            echo "$id: BAM already present, skipping download"
        else
            ugly_id=$(grep "$id" "$ip_manifest" | cut -f1)
            echo "$id: queuing $ugly_id for download"
            mkdir -p "$(dirname "$bam_file")"
            uuids_to_download+=("$ugly_id")
        fi
    done
	if [[ ${#uuids_to_download[@]} -gt 0 ]]; then
		echo "downloading ${#uuids_to_download[@]} BAMs..."
		date
		for uuid in "${uuids_to_download[@]}"; do
			bash "$(dirname "$0")/download_bam.sh" "$uuid" /mnt/data/tcga
		done
	fi

    echo "all downloads complete for batch ${batch_num}"
    date

    # ── step 2: build a combined bam manifest for this batch ──────────────
    batch_manifest="${tmp_dir}/batch_${batch_num}_bam_manifest.tsv"
    > "$batch_manifest"

    missing_bams=()
    for idx in "${!batch_ids[@]}"; do
        id="${batch_ids[$idx]}"
        bam_file="${batch_bam_files[$idx]}"
        if [[ -f "$bam_file" ]]; then
            grep -w "$id" "$bam_manifest" >> "$batch_manifest"
        else
            echo "WARNING: BAM for $id not found after download attempt, skipping"
            missing_bams+=("$id")
        fi
    done

    if [[ ! -s "$batch_manifest" ]]; then
        echo "No BAMs available for batch ${batch_num}, skipping intron_coverage"
        continue
    fi

    # ── step 3: run intron_coverage once for the whole batch ─────────────
    n_samples=$(wc -l < "$batch_manifest")
    n_threads=$(( n_samples < 8 ? n_samples : 8 ))
    echo ""
    echo "--- running intron_coverage on ${n_samples} samples with ${n_threads} threads (batch ${batch_num}) ---"
    date

    time docker run --rm \
        -v /mnt/:/mnt \
        splicedice_analysis:latest \
        splicedice intron_coverage \
        -b "/mnt/scratch/tmp/batch_${batch_num}_bam_manifest.tsv" \
        -m "${analysis_base}/_allPS.tsv" \
        -j "${analysis_base}/_junctions.bed" \
        -n "${n_threads}" \
        -o "${coverage_dir}"

    date
    echo "intron_coverage done for batch ${batch_num}"

    # ── step 4: delete BAMs for samples with successful output ───────────
    echo ""
    echo "--- cleaning up BAMs ---"
    for idx in "${!batch_ids[@]}"; do
        id="${batch_ids[$idx]}"
        bam_file="${batch_bam_files[$idx]}"
        expected_output="${coverage_dir}/${id}_intron_coverage.txt"

        if [[ -f "$bam_file" && -f "$expected_output" ]]; then
            echo "$id: output confirmed, deleting BAM"
            rm "$bam_file"
        elif [[ -f "$bam_file" && ! -f "$expected_output" ]]; then
            echo "WARNING: $id: BAM present but no output found — keeping BAM for investigation"
        fi
    done

    echo ""
    echo "batch ${batch_num} complete"
    echo ""

done

echo "========================================================"
echo "All batches complete."
echo "========================================================"