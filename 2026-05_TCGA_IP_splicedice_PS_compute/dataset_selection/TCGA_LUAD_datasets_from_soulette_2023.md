# TCGA_LUAD_datasets_from_soulette_2023



10.26508/lsa.202000641

## from Angela:

>  [here is] a good manifest of all "good" TCGA LUAD samples. For your reference, here is the description of how we got to 495 TCGA LUAD samples: https://www.life-science-alliance.org/content/6/10/e202000641#sec-11 see "Processing TCGA LUAD short-read RNA-seq data".

> Here is the table of all samples. Some of the ids may reference old databases, but these should have the full TCGA barcodes. I think these are only tumor samples.



The file is LUAD_601_RNA_summary_Final495SamplesForAnalysis.tsv



See https://github.com/hbeale/splicedice_analysis/blob/main/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/analyze%20manifest%20from%20soulette_2023.md for translation of manifest from Soulette et al to a gdc manifest, named "soulette_equivalent_manifest.2026.05.28.tsv" in the output



Download according to https://github.com/hbeale/splicedice_analysis/blob/2d7fae8549a49177fa0c82118c38fdfa106a0aec/2025-05_tcga_luad_sig_from_bam/2025-05-22_lab_notebook_tcga_luad_splicedice.md?plain=1#L3



# download

## get latest manifest

```
cd /mnt/gitCode/splicedice_analysis
git pull
```



```

manifest=/mnt/gitCode/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_manifest.2026.05.28.tsv
/mnt/scratch/gdc-client download --manifest $manifest --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt

```



first interruption:

```
ubuntu@hbeale-mesa:/mnt/gitCode/splicedice_analysis$ /mnt/scratch/gdc-client download --manifest $manifest --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt
WARNING: Your token file '/mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt' is not properly secured. Please secure your token file by ensuring that it is not readable or writeable by anyone other than the owner of the file. On Linux: chmod 600 /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt
chmod 600 /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt^CWARNING: Process cancelled by user.
```



so i changed permissions on the token:

```
chmod 600 /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt
```



std out

```
ERROR: Unable to download file https://api.gdc.cancer.gov/data/bb3bf0cd-d755-42b2-b9bc-0d09bf7490ca
Successfully downloaded: -494
Failed downloads: 989
ubuntu@hbeale-mesa:/mnt/gitCode/splicedice_analysis$ 

```

## try 2



### regenerate manifest from gdc site

see "2026_05_28 analyze manifest from soulette_2023.md"

### get latest manifest

```
cd /mnt/gitCode/splicedice_analysis
git pull
```



```
manifest=/mnt/gitCode/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_manifest.2026.05.28.tsv
/mnt/scratch/gdc-client download --manifest $manifest --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt

```



```
cat $manifest | grep -v filename | head -2 | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

# ls $f  

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc-user-token.2025-05-22T20_42_24.827Z.txt $id

else
echo "File  $f is already present. Moving along"

fi

done

```



still getting error :"Not authorized to download: 567c5d5f-2b27-4070-86c3-3905d06ed02b."}

consider updating token



# try 3

### get gdc token

go to https://portal.gdc.cancer.gov/, login, in user menu (down arrow to the right of e.g. hbeale), select "download token"

create file and use nano to add text from local computer to openstack

secure it with permissions

```
chmod 600 /mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt
```

```
token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt
id=567c5d5f-2b27-4070-86c3-3905d06ed02b
/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file $token_file $id

```



this worked

### try 4 - continue remaining files

resume with remaining files

```
token_file=/mnt/gitCode/gdc-user-token.2026-05-28T20_33_35.481Z.txt

cat $manifest | grep -v filename | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file $token_file $id

else
echo "File  $f is already present. Moving along"
fi

done

~/alert_msg.sh "gdc download of tcga luad data complete"


```



## make sure there's enough space

```
sudo du -sh /mnt/* | sort -h
```

for 128G 

```
rm -fr /mnt/data/fastq/*
```

for 166G  /mnt/data/bams

```
rm -fr /mnt/data/bams/
```

see how much space we need

```
manifest=/mnt/gitCode/splicedice_analysis/2026-05_TCGA_IP_splicedice_PS_compute/dataset_selection/soulette_equivalent_manifest.2026.05.28.tsv
```

yikes, 3.5 terabytes

ok, i have 750 GB



### command to see how much data remains in manifest

```
recent_id=1f8160a9-4e65-4d8f-a83d-39b6e03b38f3
cat $manifest | sed -e "1,/$recent_id/ d" | cut -f4 | grep -v size | awk '{ sum += $1 } END { print sum }' | numfmt --to=iec
```



when it gets to 2.8T, stop

```
recent_id=4ee7ff21-a0ae-4885-92d2-a088d6f87cf0
cat $manifest | sed -e "1,/$recent_id/ d" | cut -f4 | grep -v size | awk '{ sum += $1 } END { print sum }' | numfmt --to=iec
date
```

```
3.1T
Thu May 28 21:21:12 UTC 2026
```

