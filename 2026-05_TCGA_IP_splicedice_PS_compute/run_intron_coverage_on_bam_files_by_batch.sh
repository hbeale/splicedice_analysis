#!/usr/bin/env bash
set -euo pipefail

# ── usage ─────────────────────────────────────────────────────────────────────
usage() {
    echo "Usage: $(basename "$0") <batch_size>"
    echo "  batch_size  Number of samples to process per batch (e.g. 16)"
    exit 1
}

if [[ $# -ne 1 || ! "$1" =~ ^[0-9]+$ ]]; then
    usage
fi

BATCH_SIZE="$1"

# ── paths ────────────────────────────────────────────────────────────────────
repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
analysis_base=/mnt/splicedice_ir_example/analysis/
bam_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bam_manifest_2026.06.03_15.06.58.tsv

coverage_dir=${analysis_base}/coverage_output
tmp_dir=/mnt/scratch/tmp

mkdir -p "$coverage_dir" "$tmp_dir"

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

    # ── step 1: build a combined bam manifest for this batch ─────────────
    batch_manifest="${tmp_dir}/batch_${batch_num}_bam_manifest.tsv"
    > "$batch_manifest"

    missing_bams=()
    for idx in "${!batch_ids[@]}"; do
        id="${batch_ids[$idx]}"
        bam_file="${batch_bam_files[$idx]}"
        if [[ -f "$bam_file" ]]; then
            grep -w "$id" "$bam_manifest" >> "$batch_manifest"
        else
            echo "WARNING: BAM for $id not found, skipping"
            missing_bams+=("$id")
        fi
    done

    if [[ ! -s "$batch_manifest" ]]; then
        echo "No BAMs available for batch ${batch_num}, skipping intron_coverage"
        continue
    fi

    # ── step 2: run intron_coverage once for the whole batch ─────────────
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

    # ── step 3: delete BAMs for samples with successful output ───────────
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
