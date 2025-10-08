# 2025_10_07-addl_downloads_for_u2af1_s34f_sig_lab_notebook



### install gdc client

```
cd /mnt/scratch
wget https://gdc.cancer.gov/system/files/public/file/gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip
unzip gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip 
unzip gdc-client_2.3_Ubuntu_x64.zip
./gdc-client

```

### get gdc token (already done)

go to https://portal.gdc.cancer.gov/, login, in user menu (down arrow to the right of e.g. hbeale), select "download token"

copy to open stack server

secure

```
chmod 600 /mnt/gitCode/gdc_manifests/gdc-user-token.2025-10-07T23_47_32.543Z.txt
```



### make manifest

Note: Luad_samples_U2_wt.tsv came from Javier via slack 10/7/2025

```
cat /mnt/data/manifests/Luad_samples_U2_wt.tsv | grep -v Column | while read id ; do 
grep -h $id /mnt/gitCode/gdc_manifests/*
done > /mnt/data/manifests/gdc_bonus_samples_2025_10_07.tsv

```

### download files

```

this_manifest=/mnt/data/manifests/gdc_bonus_samples_2025_10_07.tsv
cat $this_manifest | grep -v filename | while read id filename other; do 

f=/mnt/data/tcga/$id/$filename

echo
echo $id $filename

# ls $f  

if ! [ -f   $f  ]; then
echo "File  $f  does not exist. Downloading"

/mnt/scratch/gdc-client download --dir  /mnt/data/tcga --token-file /mnt/gitCode/gdc_manifests/gdc-user-token.2025-10-07T23_47_32.543Z.txt $id

else
echo "File  $f is already present. Moving along"

fi

done


```





### copy to mustard



run this on mustard

```
scp ubuntu@10.50.100.135:/mnt/data/manifests/gdc_bonus_samples_2025_10_07.tsv /private/groups/brookslab/hbeale/manifests/

m=/private/groups/brookslab/hbeale/manifests/gdc_bonus_samples_2025_10_07.tsv 

cat $m | grep -v filename | while read id filename other; do 

echo
echo $id $filename

f=/mnt/data/tcga/$id/$filename

scp ubuntu@10.50.100.135:$f /private/groups/brookslab/hbeale/tcga_luad/$filename
done

```

