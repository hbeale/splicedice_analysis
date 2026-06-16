#!/usr/bin/env bash
# run_intron_coverage_pipeline.sh
# Wrapper: reads primary manifest, finds pending samples, processes in batches.
# Calls download_batch.sh and run_intron_coverage.sh for each batch.
#
# Usage: run_intron_coverage_pipeline.sh [--manifest PATH] [--batch-size N]
set -euo pipefail

# ── defaults ─────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
analysis_base=/mnt/splicedice_ir_example/analysis
coverage_dir=${analysis_base}/coverage_output
tmp_dir=/mnt/scratch/tmp
token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt
primary_manifest=""
BATCH_SIZE=16

# ── argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --manifest)    primary_manifest="$2"; shift 2 ;;
        --batch-size)  BATCH_SIZE="$2";       shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$primary_manifest" ]]; then
    echo "ERROR: --manifest is required"
    echo "Usage: $0 --manifest PATH [--batch-size N]"
    exit 1
fi

mkdir -p "$coverage_dir" "$tmp_dir"

# ── collect pending samples ───────────────────────────────────────────────────
# Primary manifest columns: dataset_id  bam_location  bed_location  phenotype  download_id
mapfile -t all_samples < <(tail -n +2 "$primary_manifest")

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

# ── process in batches ────────────────────────────────────────────────────────
batch_num=0
i=0

while [[ $i -lt $total ]]; do

    batch_num=$(( batch_num + 1 ))
    batch=("${pending[@]:$i:$BATCH_SIZE}")
    i=$(( i + BATCH_SIZE ))

    echo "========================================================"
    echo "BATCH ${batch_num}: ${#batch[@]} samples"
    echo "========================================================"

    # Build a per-batch slice of the primary manifest (header + batch rows)
    batch_manifest="${tmp_dir}/batch_${batch_num}_manifest.tsv"
    head -n 1 "$primary_manifest" > "$batch_manifest"
    for row in "${batch[@]}"; do
        echo "$row" >> "$batch_manifest"
    done

    # ── step 1: download BAMs for this batch ──────────────────────────────
    echo ""
    echo "--- downloading BAMs for batch ${batch_num} ---"
    "${SCRIPT_DIR}/download_batch.sh" \
        --manifest  "$batch_manifest" \
        --token     "$token_file"

    # ── step 2: run intron_coverage for this batch ────────────────────────
    echo ""
    echo "--- running intron_coverage for batch ${batch_num} ---"
    "${SCRIPT_DIR}/run_intron_coverage.sh" \
        --manifest    "$batch_manifest" \
        --coverage-dir "$coverage_dir" \
        --analysis-base "$analysis_base"

    echo ""
    echo "batch ${batch_num} complete"
    echo ""

done

echo "========================================================"
echo "All batches complete."
echo "========================================================"
