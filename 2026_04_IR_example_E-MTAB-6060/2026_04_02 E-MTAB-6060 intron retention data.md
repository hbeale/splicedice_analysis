# 2026_04_02 E-MTAB-6060 intron retention data



download filereport_read_run_ERP104850.tsv from https://www.ebi.ac.uk/ena/browser/view/ERP104850?show=reads



select relevant data

```

cd /mnt/gitCode/splicedice_analysis/
git pull
cd 2026_04_IR_example_E-MTAB-6060
cat filereport_read_run_ERP104850.tsv | grep -v BrU | grep "SSA\|DMSO" > ERP104850_SSA_or_DMSO_notBrU.tsv

ena_manifest=/mnt/gitCode/splicedice_analysis/2026_04_IR_example_E-MTAB-6060/ERP104850_SSA_or_DMSO_notBrU.tsv
cat $ena_manifest | cut -f1,7 | while read id files; do 
file1=${files/;*}
file2=${files/*;}
echo id $id
echo files $files
echo file 1 $file1
echo file 2 $file2
mkdir -p /mnt/data/fastq/$id
cd /mnt/data/fastq/$id
if [ -f `basename $file1` ]; then
    echo "`basename $file1` exists."
else
    echo "`basename $file1` does not exist."
    wget $file1
fi
if [ -f `basename $file2` ]; then
    echo "`basename $file1` exists."
else
    echo "`basename $file1` does not exist."
    wget $file2
fi
done
~/alert_msg.sh downloads_complete




```



check

```
ubuntu@hbeale-mesa:/mnt/data/fastq$ ls -Rlth E*
ERR2178355:
total 24G
-rw-rw-r-- 1 ubuntu ubuntu 12G Nov  1  2017 ERR2178355_1.fastq.gz
-rw-rw-r-- 1 ubuntu ubuntu 13G Nov  1  2017 ERR2178355_2.fastq.gz

ERR2178361:
total 26G
-rw-rw-r-- 1 ubuntu ubuntu 13G Nov  1  2017 ERR2178361_1.fastq.gz
-rw-rw-r-- 1 ubuntu ubuntu 13G Nov  1  2017 ERR2178361_2.fastq.gz

ERR2178356:
total 27G
-rw-rw-r-- 1 ubuntu ubuntu 13G Apr 18  2018 ERR2178356_1.fastq.gz
-rw-rw-r-- 1 ubuntu ubuntu 14G Apr 18  2018 ERR2178356_2.fastq.gz

ERR2178362:
total 29G
-rw-rw-r-- 1 ubuntu ubuntu 15G Nov  1  2017 ERR2178362_2.fastq.gz
-rw-rw-r-- 1 ubuntu ubuntu 15G Nov  1  2017 ERR2178362_1.fastq.gz
ubuntu@hbeale-mesa:/mnt/data/fastq$ 

```



```
/mnt/bin/STAR-2.7.11b/source/STAR
```

