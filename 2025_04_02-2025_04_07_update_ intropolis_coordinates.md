Adjust intronopolis junction definitions to make it compatible with later PS values, including TCGA luad values. 

Limitation: I only used junctions that were present in the LUAD dataset. 

### View contents of files
```
intronopolis_PS_file=/mnt/data/2020.11.16.intropolis_PS.tsv
luad_PS_file=/mnt/data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv
cat $intronopolis_PS_file | head | cut -f1-6
cat $luad_PS_file  | head | cut -f1-6
```

try awk instead
```
in=2020.11.16.intropolis_PS.tsv
out=2020.11.16.intropolis_PS.cluster_id_only.awk.tsv
time awk '{print $1}' $in  | grep -v cluster > $out

```

### make list of LUAD junctions in intronopolis format 

see [Rmd](https://github.com/hbeale/splicedice_analysis/blob/main/change_cluster_ids.rmd)

## Use grep to select intronopolis junctions present in LUAD
### step 1 test on small data
```
head -100 /mnt/data/2020.11.16.intropolis_PS.tsv > /mnt/data/2020.11.16.intropolis_PS.100.tsv

keep_list=/mnt/data/analysis/intronopolis_cluster_ids_present_in_luad.tsv
small_input=/mnt/data/2020.11.16.intropolis_PS.100.tsv
output=2020.11.16.intropolis_PS.in_luad.100.tsv
grep -f $keep_list $small_input > $output
```
success!
```
ubuntu@hbeale-mesa:/mnt/data$ wc -l $small_input 
100 /mnt/data/2020.11.16.intropolis_PS.100.tsv
ubuntu@hbeale-mesa:/mnt/data$ wc -l $output
27 2020.11.16.intropolis_PS.in_luad.100.tsv

```
### step 2 run on complete data
command
```
keep_list=/mnt/data/analysis/intronopolis_cluster_ids_present_in_luad.tsv
input=2020.11.16.intropolis_PS.tsv
output=2020.11.16.intropolis_PS.in_luad.tsv
grep -f $keep_list $input > $output
```

as submitted
```
ubuntu@hbeale-mesa:/mnt/data$ keep_list=/mnt/data/analysis/intronopolis_cluster_ids_present_in_luad.tsv
input=2020.11.16.intropolis_PS.tsv
output=2020.11.16.intropolis_PS.in_luad.tsv
ubuntu@hbeale-mesa:/mnt/data$ grep -f $keep_list $input > $output
```

preliminary output
```
ubuntu@hbeale-mesa:/mnt/data$ cat 2020.11.16.intropolis_PS.in_luad.tsv | cut -f1-6 | head
chr1:14830-14969        nan     nan     nan     nan     0.500
chr1:14830-15795        nan     nan     0.000   nan     0.333
chr1:15039-15795        nan     nan     1.000   nan     0.500
chr1:15943-16606        nan     0.000   0.000   nan     nan
chr1:15948-16606        nan     0.800   0.944   nan     nan
chr1:16311-16606        nan     0.200   0.056   nan     nan
chr1:16766-16857        nan     nan     nan     nan     nan
chr1:17056-17232        nan     nan     nan     nan     nan
chr1:17056-17914        0.000   nan     0.000   nan     0.000
chr1:17056-29320        0.000   nan     0.000   nan     0.000
```

check final output line count
```
ubuntu@hbeale-mesa:/mnt/data$ wc -l $output
526579 2020.11.16.intropolis_PS.in_luad.tsv
```

compresss
```
pigz 2020.11.16.intropolis_PS.in_luad.tsv
```

file size
```
ubuntu@hbeale-mesa:/mnt/data$ ls -alth 2020.11.16.intropolis_PS.in_luad.tsv.gz 
-rw-rw-r-- 1 ubuntu ubuntu 7.9G Apr  8 00:26 2020.11.16.intropolis_PS.in_luad.tsv.gz
```
