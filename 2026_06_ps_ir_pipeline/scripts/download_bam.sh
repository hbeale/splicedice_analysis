#!/usr/bin/env bash
set -euo pipefail
# set -x # uncomment for troubleshooting
# trap 'echo "ERROR: script failed at line $LINENO with exit code $?" >&2' ERR # uncomment for troubleshooting

if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename $0) <gdc_identifier> <bam_base_dir>" >&2
    echo "      gdc_identifier:           identifier for the sample, e.g. 567c5d5f-2b27-4070-86c3-3905d06ed02b" >&2
    echo " bam_base_dir:           2x-parent directory for bam" >&2
    exit 1
fi

gdc_identifier=$1
bam_base_dir=$2

token_file=$(ls -t ~/gdc-user-token* 2>/dev/null | head -1)
if [[ -z "$token_file" ]]; then
    echo "ERROR: no gdc-user-token file found in home directory" >&2
    exit 1
fi
echo "using token: $token_file"

# mkdir -p ${bam_base}/$tcga_id
mkdir -p $bam_base_dir
gdc-client download \
    --dir $bam_base_dir \
    --token-file $token_file \
    $gdc_identifier