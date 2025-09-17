2025_09_17 copy TCGA LUAD files to mustard



from mustard

```

cd /private/groups/brookslab/hbeale
mkdir manifests
scp ubuntu@10.50.100.135://mnt/data/manifests/batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv manifests/
mkdir tcga_luad
cat manifests/batch_2_bam_manifest.with_genotypes.2025.09.10_10.03.13.tsv | while read id path p1 p2; do 
echo $path
scp ubuntu@10.50.100.135:/$path tcga_luad/
done
```



message:

I copied 46 bam files to mustard. 11 have the U2AF1 S34F mutation. the samples are characterized here:



https://github.com/hbeale/splicedice_analysis/blob/main/2025-05_tcga_luad_download/2025.09.17_characterize_46_sample_cohort.md



