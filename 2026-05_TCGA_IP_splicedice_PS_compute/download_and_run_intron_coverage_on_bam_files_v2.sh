#!/usr/bin/env bash
set -euo pipefail

# ── paths ────────────────────────────────────────────────────────────────────
repo_base=/mnt/splicedice_ir_example/git_code/splicedice_analysis/
analysis_base=/mnt/splicedice_ir_example/analysis/
bam_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/splicedice_manifests/bam_manifest_2026.06.03_15.06.58.tsv
ip_manifest=${repo_base}/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_intron_prospector_manifest.2026.05.28.tsv
token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt

coverage_dir=${analysis_base}/coverage_output
tmp_dir=/mnt/scratch/tmp
BATCH_SIZE=8

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

    # ── step 1: download any missing BAMs in parallel ─────────────────────
    echo ""
    echo "--- downloading missing BAMs ---"
    download_pids=()

    for idx in "${!batch_ids[@]}"; do
        id="${batch_ids[$idx]}"
        bam_file="${batch_bam_files[$idx]}"

        if [[ -f "$bam_file" ]]; then
            echo "$id: BAM already present, skipping download"
        else
            ugly_id=$(grep "$id" "$ip_manifest" | cut -f1)
            echo "$id: downloading $ugly_id -> $bam_file"
            mkdir -p "$(dirname "$bam_file")"
            /mnt/scratch/gdc-client download \
                --dir /mnt/data/tcga \
                --token-file "$token_file" \
                "$ugly_id" &
            download_pids+=($!)
        fi
    done

    # wait for all downloads
    for pid in "${download_pids[@]}"; do
        wait "$pid"
    done
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
    echo ""
    echo "--- running intron_coverage on ${n_samples} samples (batch ${batch_num}) ---"
    date
    
    n_threads=$(( n_samples < 8 ? n_samples : 8 ))
    
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