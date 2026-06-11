# 2026-05-05_PS_table_addition_to_intron_retention_walkthrough



See https://github.com/hbeale/splicedice_analysis/blob/d8e5a3bf7a775dfc72a96c1f27919b85f1bf3e0a/SUGP1/2026-05-05_intron_retention_walkthrough.md

for previous steps (code setup, dockers, intron-prospector, quant)





# Server

hbeale-mesa

ssh ubuntu@10.50.100.135



## Recreate docker so it contains scripts

update dockerfile to keep stuff

```
cd /mnt/splicedice_ir_example/git_code/splicedice_analysis/code
sudo docker build -t splicedice_analysis:latest .
```





## Signature analysis


### Prepare signature manifest

```
TS=2026-05-05_20-28-22
bed_manifest=/mnt/splicedice_ir_example/git_code/splicedice_analysis/SUGP1/bed_manifest_${TS}.tsv
sig_manifest=/mnt/splicedice_ir_example/analysis/sig_manifest.txt

cd /mnt/splicedice_ir_example/analysis/
cat $bed_manifest | cut -f1,3 > $sig_manifest
```

### Compare two conditions

```
sudo docker run -it --rm \
-v /mnt:/mnt \
splicedice_analysis:latest /bin/bash

sig_manifest=/mnt/splicedice_ir_example/analysis/sig_manifest.txt
here=/mnt/splicedice_ir_example/analysis/

python3 /opt/splicedice/scripts/signature.py compare \
  -p ${here}/_allPS.tsv \
  -m $sig_manifest \
  -o $here
  
```

output

```
.sig.tsv
```

std out

```
Testing for differential splicing...
Groups: control (3), SUGP1_kd (3)
Writing...

```



no results, only one line in .sig.tsv



allPS <- read_tsv("/mnt/splicedice_example/analysis/_allPS.tsv")

```
setwd("/mnt/splicedice_ir_example/analysis/")
allPS <- read_tsv("_allPS.tsv")
phenotypes <- read_tsv("/mnt/splicedice_ir_example/analysis/sig_manifest.txt", 
col_names = c("sample", "phenotype"))

```



```
allPS_no_NA <- allPS %>%
filter(!if_any(everything(), is.na))

allPS_no_NA_long <- allPS_no_NA %>%
pivot_longer(-cluster, names_to = "sample", values_to = "PS") %>%
left_join(phenotypes)

allPS_no_NA_long_variable <- allPS_no_NA_long %>%
group_by(cluster) %>%
mutate(sd_PS = sd(PS)) %>%
filter(sd_PS > 0.01) # i iterated to see what t.test could tolerate

fail_clusters <- c("chr18:80048194-80069797:+", "chr5:177883880-177921061:+", "chr6:122481957-122482146:+")

allPS_no_NA_long_variable_t_test <- allPS_no_NA_long_variable %>%
filter(! cluster %in% fail_clusters) %>%
group_by(cluster) %>%
mutate(p_value = t.test(PS[phenotype=="control"], PS[phenotype == "SUGP1_kd"])$p.value)


```



t.test couldn't handle this, even though it's kind of the optimal result, but I don't think it's a splice junction, more like a fusion if anything

```
> allPS_no_NA_long_variable %>% filter(cluster == "chr18:80048194-80069797:+")
# A tibble: 6 × 5
# Groups:   cluster [1]
  cluster                   sample         PS phenotype sd_PS
  <chr>                     <chr>       <dbl> <chr>     <dbl>
1 chr18:80048194-80069797:+ SRR12801019     1 control   0.548
2 chr18:80048194-80069797:+ SRR12801020     0 SUGP1_kd  0.548
3 chr18:80048194-80069797:+ SRR12801023     1 control   0.548
4 chr18:80048194-80069797:+ SRR12801024     0 SUGP1_kd  0.548
5 chr18:80048194-80069797:+ SRR12801027     1 control   0.548
6 chr18:80048194-80069797:+ SRR12801028     0 SUGP1_kd  0.548
> 

```

ditto chr5:177883880-177921061



```
> summary(allPS_no_NA_long_variable_t_test$p_value)
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
0.0000034 0.2243538 0.4226497 0.4227428 0.5563978 1.0000000 

```



```
allPS_sig <- allPS_no_NA_long_variable_t_test %>%
filter(p_value < 0.05)
allPS_sig_chr <- allPS_sig %>%
filter(str_detect(cluster, "^chr"))
```

