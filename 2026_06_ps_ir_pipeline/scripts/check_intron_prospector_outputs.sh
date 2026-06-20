#!/usr/bin/env bash
set -euo pipefail

# Usage: check_intron_prospector_outputs.sh --manifest PATH

# ── defaults ──────────────────────────────────────────────────────────────────
manifest=""

# ── argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --manifest) manifest="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$manifest" ]]; then
    echo "ERROR: --manifest is required" >&2
    echo "Usage: $(basename $0) --manifest PATH" >&2
    echo >&2
    echo "  --manifest:  TSV with columns: dataset_id, bam_location, bed_location, phenotype, download_id" >&2
    exit 1
fi

# ── chromosome check setup ────────────────────────────────────────────────────
expected="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"

# ── counters ──────────────────────────────────────────────────────────────────
total=0
n_bed_missing=0
n_chr_missing=0
n_ok=0

# ── check samples ─────────────────────────────────────────────────────────────
while read dataset_id bam_location bed_location phenotype download_id; do
    total=$((total + 1))

    if [[ ! -f "$bed_location" ]]; then
        echo "$dataset_id: MISSING BED ($bed_location)"
        n_bed_missing=$((n_bed_missing + 1))
        continue
    fi

    missing=$(comm -23 \
        <(echo "$expected" | tr ' ' '\n' | sort) \
        <(cut -f1 "$bed_location" | sort -u))

    if [[ -n "$missing" ]]; then
        missing_oneline=$(echo "$missing" | tr '\n' ' ' | sed 's/ $//')
        echo "$dataset_id: MISSING CHROMOSOMES: $missing_oneline"
        n_chr_missing=$((n_chr_missing + 1))
    else
        echo "$dataset_id: OK"
        n_ok=$((n_ok + 1))
    fi

done < <(grep -v ^dataset_id "$manifest")

# ── summary ───────────────────────────────────────────────────────────────────
echo
echo "SUMMARY: $total datasets | $n_ok OK | $n_bed_missing missing BED | $n_chr_missing missing chromosomes"