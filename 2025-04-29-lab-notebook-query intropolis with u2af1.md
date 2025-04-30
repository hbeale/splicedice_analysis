# 2025-04-29-lab-notebook-query intropolis with u2af1





## Look for U2AF1 sig in intropolis


### decompress intropolis file
```
cd /mnt/data
gzip -d --keep /mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
```

### designate output
```
analysis_description=U2AF1_sig_in_intropolis
new_timestamp=`~/d`
echo $new_timestamp
splicedice_out=/mnt/output/splicedice_${analysis_description}_${new_timestamp}/ 
mkdir -p $splicedice_out
```
output: 2025.04.29_23.43.54


### define files

```
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py 
candidate_samples_PS_file=/mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv   
beta_file=/mnt/output/splicedice_2025.02.20_18.42.32/beta.tsv
cd $splicedice_out
```

### show file contents and md5sums
```
md5sum $sig_script
md5sum $candidate_samples_PS_file
md5sum $beta_file

echo $candidate_samples_PS_file 
head $candidate_samples_PS_file | cut -f1-6 
awk '{print NF}' $candidate_samples_PS_file | sort -nu | tail -n 1

echo $beta_file
head $beta_file  |cut -f1-6  

```

std out

```

9f93f56ca240c2b17f1cf8e8b7daab83  /mnt/code/dennisrm_splicedice/splicedice/code/signature.py
7ef65395acf16cc806568270845a7b33  /mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv
5b07f9dbde242571258ca7ead6f9ffd5  /mnt/output/splicedice_2025.02.20_18.42.32/beta.tsv
/mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv
cluster 0       1       2       4       5
chr1:14829-14969:-      nan     nan     nan     nan     0.500
chr1:14829-15795:-      nan     nan     0.000   nan     0.333
chr1:15038-15795:-      nan     nan     1.000   nan     0.500
chr1:15942-16606:-      nan     0.000   0.000   nan     nan
chr1:15947-16606:-      nan     0.800   0.944   nan     nan
chr1:16310-16606:-      nan     0.200   0.056   nan     nan
chr1:17055-17232:-      nan     nan     nan     nan     nan
chr1:17055-29320:-      0.000   nan     0.000   nan     0.000
chr1:17368-17525:-      nan     nan     nan     nan     nan
/mnt/output/splicedice_2025.02.20_18.42.32/beta.tsv
splice_interval median_u2af1-wt alpha_u2af1-wt  beta_u2af1-wt   median_u2af1-s34f       alpha_u2af1-s34f
chr1:17055-17232:-      0.8975  9.70337660578837        1.0754280583279827      0.9444999999999999      18.180628932406236
chr1:17368-17605:-      0.743   3.44778262627937        1.0590181327573678      0.844   6.473497482827203
chr1:143011-146385:+    0.0     0.13662625287979863     0.26512824062007495     1.0     None
chr1:146509-155766:-    0.6495  0.991625082939514       0.5444330433781498      0.889   0.5083931223568773
chr1:187890-188129:-    0.786   3.589618094875183       0.8646977788028919      0.865   4.835045639046378
chr1:505103-514358:+    0.0     0.14690740307323422     0.76989457030507        0.167   0.18380688269373402
chr1:498456-498683:-    0.224   1.4528759716121145      5.050594191590804       0.135   0.7681727375504569
chr1:729955-735422:-    0.088   0.7252886827472115      8.794568325347614       0.0     0.3435162787976333
chr1:847806-851926:+    0.286   0.6573462060268105      1.4933458218105389      0.451   0.6312550933096173
ubuntu@hbeale-mesa:/mnt/output/splicedice_U2AF1_sig_in_intropolis_2025.04.29_23.43.54$ 
[ hbeale-mesa ][help: <ESC> to copy/scroll][                 0-$ bash  (1*$bash)  2$ bash  3$ bash                 ][2025-04-30  0:07 ]
```




### Run query
```
date
python3 $sig_script query \
-p $candidate_samples_PS_file \
-b $beta_file \
-o $splicedice_out/${analysis_description}; ~/alertme.sh
date
```

output

```
python3 $sig_script query \
-p $candidate_samples_PS_file \
-b $beta_file \
-o $splicedice_out/${analysis_description}; ~/alertme.sh
date
Wed Apr 30 00:08:07 UTC 2025

Reading...
Querying...
Writing...
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
Wed Apr 30 07:00:37 UTC 2025

```

### results file info

commands

```
out=/mnt/output/splicedice_U2AF1_sig_in_intropolis_2025.04.29_23.43.54//U2AF1_sig_in_intropolis.pvals.tsv
ls -alth $out
md5sum $out
awk '{print NF}' $out | sort -nu | tail -n 1

```


```
-rw-rw-r-- 1 ubuntu ubuntu 1.7M Apr 30 07:00 /mnt/output/splicedice_U2AF1_sig_in_intropolis_2025.04.29_23.43.54//U2AF1_sig_in_intropolis.pvals.tsv
2db2cfd3b5eb25ddae25e5b3d8b0ebb0  /mnt/output/splicedice_U2AF1_sig_in_intropolis_2025.04.29_23.43.54//U2AF1_sig_in_intropolis.pvals.tsv
48838

```


peek inside results file

```


ubuntu@hbeale-mesa:/mnt/output/splicedice_U2AF1_sig_in_intropolis_2025.04.29_23.43.54$ cat $out | head | cut -f1-5
query   0       1       2       4
u2af1-wt_over_u2af1-s34f        2.671417427691679e-65   2.8189978768157696e-89  6.629180950002519e-89   2.619336414037497e-52
u2af1-s34f_over_u2af1-wt        1.0     1.0     1.0     1.0


```


## results analysis
see "review results of U2AF1_sig_in_intropolis 2025.04.29_23.43.54.md"

## Conclusion from results analysis

Here we find 10 significant matches to the u2af1 signature (assuming a p-value < 0.05 in the u2af1-s34f_over_u2af1-wt query means the same thing Dennis means when he says "significant matches to the U2AF1-S34F signature". 

If we want to pursue this, if we can find the key to connect intropolis IDs (e.g. 1-48000) to SRA IDs, we could check if we see what Dennis saw, the u2af1-s34f mutation in the SRA data.