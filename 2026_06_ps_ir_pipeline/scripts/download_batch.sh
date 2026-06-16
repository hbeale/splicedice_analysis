#!/usr/bin/env bash
# download_batch.sh
# Downloads BAMs for all samples in a batch manifest that are not already on disk.
# All bam_location directories are created as needed.
#
# Usage: download_batch.sh --manifest PATH --token PATH [--gdc-client PATH] [--n-threads N]
set -euo pipefail

# ── defaults ──────────────────────────────────────────────────────────────────

bam_base_dir=""
n_threads=8
manifest=""

# ── argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --manifest)   manifest="$2";    shift 2 ;;
        --n-threads)  n_threads="$2";   shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$manifest" ]]; then
    echo "ERROR: --manifest and --token are required"
    echo "Usage: $0 --manifest PATH [--n-threads N]"
    exit 1
fi

token_file=$(ls -t ~/gdc-user-token* 2>/dev/null | head -1)
if [[ -z "$token_file" ]]; then
    echo "ERROR: no gdc-user-token file found in home directory" >&2
    exit 1
fi
echo "using token: $token_file"

bam_upstream_base_dir=$(tail -n +2 "$manifest" | head -1 | cut -f2 | xargs dirname | xargs dirname)
mkdir -p $bam_upstream_base_dir


# ── identify which BAMs need downloading ──────────────────────────────────────
# Primary manifest columns: dataset_id  bam_location  bed_location  phenotype  download_id
uuids_to_download=()

while IFS=$'\t' read -r id bam_location _bed _phenotype download_id; do
    if [[ -f "$bam_location" ]]; then
        echo "$id: BAM already present, skipping"
    else
        echo "$id: queuing $download_id for download"
        uuids_to_download+=("$download_id")
    fi
done < <(tail -n +2 "$manifest")

# ── download ──────────────────────────────────────────────────────────────────
if [[ ${#uuids_to_download[@]} -eq 0 ]]; then
    echo "All BAMs already present, nothing to download."
    exit 0
fi

echo "Downloading ${#uuids_to_download[@]} BAM(s)..."
date

gdc-client download \
    --dir "$bam_upstream_base_dir" \
    --token-file "$token_file" \
    -n "$n_threads" \
    "${uuids_to_download[@]}"

echo "Downloads complete."
date
