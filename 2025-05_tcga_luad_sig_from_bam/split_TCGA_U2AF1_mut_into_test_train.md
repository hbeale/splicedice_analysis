# split TCGA U2AF1 mut into test train.rmarkdown
Holly Beale
2025-06-04

``` r
library(tidyverse)
```

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
    ✔ purrr     1.0.2     
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(janitor)
```


    Attaching package: 'janitor'

    The following objects are masked from 'package:stats':

        chisq.test, fisher.test

# Load previous manifest

``` r
all_93_samples_sig_manifest <- 
read_tsv("/mnt/data/manifests/batches_1_and_2_sig_manifest.with_genotypes.2025.05.29_22.26.44.tsv",
         col_names = c("id", "genotype"))
```

    Rows: 93 Columns: 2
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (2): id, genotype

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# Select train/test sets

``` r
tabyl(all_93_samples_sig_manifest,
      genotype)
```

| genotype   |   n |   percent |
|:-----------|----:|----------:|
| u2af1-s34f |  11 | 0.1182796 |
| u2af1-wt   |  82 | 0.8817204 |

``` r
# decision, train on 7 u2af1-s34f (64%, 7/11), test on 4
# correspondingly, train on 52 u2af1-wt  (63%, 52/82), test on 30


train_samples <- all_93_samples_sig_manifest  %>%
  group_by(genotype) %>%
  sample_frac(0.63)

tabyl(train_samples,
      genotype)
```

| genotype   |   n |   percent |
|:-----------|----:|----------:|
| u2af1-s34f |   7 | 0.1186441 |
| u2af1-wt   |  52 | 0.8813559 |

``` r
test_samples <- anti_join(all_93_samples_sig_manifest, 
                          train_samples, 
                          by = 'id')

tabyl(test_samples,
      genotype)
```

| genotype   |   n |   percent |
|:-----------|----:|----------:|
| u2af1-s34f |   4 | 0.1176471 |
| u2af1-wt   |  30 | 0.8823529 |

# Make train dataset

``` r
write_tsv(train_samples,
          "/mnt/data/manifests/batches_1_and_2_sig_manifest.59_test.samples_2025.05.29_22.26.44.tsv",
          col_names = FALSE)
```

# generate signature

``` r
system( command = "
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py; echo $sig_script
source_dir=/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/; echo $source_dir
allPS_file=${source_dir}/batches_1_and_2_bed_manifest.with_genotypes.2025.05.29_22.26.44_allPS.tsv 
out_dir=/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test/
sig_manfiest=/mnt/data/manifests/batches_1_and_2_sig_manifest.59_test.samples_2025.05.29_22.26.44.tsv
time python3 $sig_script compare -p $allPS_file -m $sig_manfiest -o $out_dir
~/alertme.sh",
intern = TRUE)
```

    [1] "/mnt/code/dennisrm_splicedice/splicedice/code/signature.py"
    [2] "/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/"   
    [3] ""                                                          
    [4] "Testing for differential splicing..."                      
    [5] "Groups: u2af1-wt (52), u2af1-s34f (7)"                     
    [6] "Writing..."                                                
    [7] "{\"status\":\"OK\",\"nsent\":2,\"apilimit\":\"6\\/1000\"}" 

# review sig

``` r
sig <- read_tsv("/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test/.sig.tsv")
```

    Warning: One or more parsing issues, call `problems()` on your data frame for details,
    e.g.:
      dat <- vroom(...)
      problems(dat)

    Rows: 4800 Columns: 9
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (1): splice_interval
    dbl (8): median_u2af1-wt, mean_u2af1-wt, delta_u2af1-wt, pval_u2af1-wt, medi...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
head(sig)
```

| splice_interval | median_u2af1-wt | mean_u2af1-wt | delta_u2af1-wt | pval_u2af1-wt | median_u2af1-s34f | mean_u2af1-s34f | delta_u2af1-s34f | pval_u2af1-s34f |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|
| chr1:17368-17605:+ | 0.6625 | 0.6646346 | -0.0045 | 0.5848980 | 0.782 | 0.8050000 | 0.115 | 0.0240652 |
| chr1:17368-17605:- | 0.7965 | 0.7929038 | -0.0065 | 0.6383720 | 0.935 | 0.8965714 | 0.132 | 0.0281425 |
| chr1:185350-185490:- | 0.9365 | 0.9360000 | 0.0015 | 0.9260954 | 1.000 | 0.9917143 | 0.065 | 0.0106709 |
| chr1:729955-735422:- | 0.1035 | 0.0907115 | 0.0045 | 0.7060118 | 0.000 | 0.0181429 | -0.099 | 0.0108796 |
| chr1:732207-732980:- | 0.2355 | 0.2630385 | -0.0055 | 0.6846868 | 0.325 | 0.3287143 | 0.084 | 0.0253634 |
| chr1:733364-735422:+ | 0.6470 | 0.6547500 | -0.0150 | 0.3244762 | 0.889 | 0.8451429 | 0.227 | 0.0368684 |

# Fit beta

``` r
system( command = "
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py; echo $sig_script
source_dir=/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/; echo $source_dir
allPS_file=${source_dir}/batches_1_and_2_bed_manifest.with_genotypes.2025.05.29_22.26.44_allPS.tsv 
out_dir=/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test/
sig_manfiest=/mnt/data/manifests/batches_1_and_2_sig_manifest.59_test.samples_2025.05.29_22.26.44.tsv
time python3 $sig_script fit_beta -p $allPS_file -s ${out_dir}.sig.tsv -m $sig_manfiest -o $out_dir
~/alertme.sh",
intern = TRUE)
```

    [1] "/mnt/code/dennisrm_splicedice/splicedice/code/signature.py"
    [2] "/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/"   
    [3] ""                                                          
    [4] "Reading..."                                                
    [5] "Fitting beta distributions..."                             
    [6] "significant intervals: 4794"                               
    [7] "Writing files..."                                          
    [8] "{\"status\":\"OK\",\"nsent\":2,\"apilimit\":\"7\\/1000\"}" 

# review beta

``` r
beta_result <- read_tsv("/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test/.beta.tsv")
```

    Rows: 4794 Columns: 7
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (5): splice_interval, alpha_u2af1-wt, beta_u2af1-wt, alpha_u2af1-s34f, b...
    dbl (2): median_u2af1-wt, median_u2af1-s34f

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
head(beta_result)
```

| splice_interval | median_u2af1-wt | alpha_u2af1-wt | beta_u2af1-wt | median_u2af1-s34f | alpha_u2af1-s34f | beta_u2af1-s34f |
|:---|---:|:---|:---|---:|:---|:---|
| chr1:17368-17605:- | 0.7965 | 4.590352940340863 | 1.1462647071949095 | 0.935 | 6.585018760413659 | 0.7478905349120508 |
| chr1:17368-17605:+ | 0.6625 | 3.0280582395491717 | 1.3935642303772215 | 0.782 | 3.8144931343774404 | 0.8440088720178311 |
| chr1:185350-185490:- | 0.9365 | 8.2175166578095 | 0.5513854032162009 | 1.000 | 41.78102922464994 | 0.39511755138086596 |
| chr1:732207-732980:- | 0.2355 | 2.0787106363659222 | 5.637987638161149 | 0.325 | 30.508985245022096 | 62.21205072001571 |
| chr1:729955-735422:- | 0.1035 | 0.5750087297695552 | 6.015566374595269 | 0.000 | 0.3726780757233011 | 19.196092409047296 |
| chr1:733364-735422:+ | 0.6470 | 1.3057364994506764 | 0.6641101350726808 | 0.889 | 2.717216236612308 | 0.4566772548221096 |

# Create PS file with only test samples

note: set na = “nan” to be consistent with data generated by splicedice

``` r
allPS <- read_tsv("/mnt/output/splicedice/tcga_batches_1_and_2_2025.05.29/batches_1_and_2_bed_manifest.with_genotypes.2025.05.29_22.26.44_allPS.tsv")
```

    Rows: 642714 Columns: 94
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr  (1): cluster
    dbl (93): TCGA-55-A4DF-01A_4a5e9e8a-8c48-48cf-8bf0-eb564611d382, TCGA-78-763...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
test_ps <- allPS %>%
  select(cluster, test_samples$id)

write_tsv(test_ps, 
          "/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test/test_allPS.tsv",
          na = "nan")
```

# Query with test set

``` r
system( command = "
out_dir=/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test
sig_script=/mnt/code/dennisrm_splicedice/splicedice/code/signature.py; echo $sig_script
test_PS=${out_dir}/test_allPS.tsv
beta_file=${out_dir}/.beta.tsv
time python3 $sig_script query -p $test_PS -b $beta_file -o ${out_dir}/find_u2af1_s34f_sig_in_test_set
~/alertme.sh",
intern = TRUE)
```

    [1] "/mnt/code/dennisrm_splicedice/splicedice/code/signature.py"
    [2] ""                                                          
    [3] "Reading..."                                                
    [4] "Querying..."                                               
    [5] "Writing..."                                                
    [6] "{\"status\":\"OK\",\"nsent\":2,\"apilimit\":\"8\\/1000\"}" 

# review results

``` r
query_result <- read_tsv("/mnt/output/splicedice/tcga_batches_1_and_2_2025.06.04_train_test/find_u2af1_s34f_sig_in_test_set.pvals.tsv")
```

    Rows: 2 Columns: 35
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr  (1): query
    dbl (34): TCGA-55-A4DF-01A_4a5e9e8a-8c48-48cf-8bf0-eb564611d382, TCGA-97-817...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
head(query_result)
```

| query | TCGA-55-A4DF-01A_4a5e9e8a-8c48-48cf-8bf0-eb564611d382 | TCGA-97-8172-01A_ba6057cc-61fd-4d2f-8599-ed0a6aaf80b6 | TCGA-91-6836-01A_09c0af14-a98f-4939-a132-9efcb4c2bc57 | TCGA-67-3770-01A_f6284fb5-ab14-41a5-8d4f-63bde0394bfc | TCGA-86-6851-01A_788ecc45-ea2c-4197-9537-02016cfe14d3 | TCGA-44-2659-01A_704d42ab-3e11-4c3b-a74c-b1e6a30e27c5 | TCGA-MP-A4T4-01A_9eeae6b9-2031-47fa-80db-e04d53f0bfbd | TCGA-05-4395-01A_4d85514e-171d-46e4-b6db-43b4f8ff2eb0 | TCGA-55-6543-01A_5fa0513c-3de7-4d3b-9df0-83f2df36b947 | TCGA-97-8177-01A_39360ea0-c687-4856-bd05-bcde98012898 | TCGA-86-8075-01A_0c633b9e-3303-4625-b59d-02102d8bf981 | TCGA-78-8648-01A_9988cad6-0f42-4112-975c-814bfc3e91c3 | TCGA-05-5420-01A_216b822e-0d33-476f-ba03-18ff818f8a78 | TCGA-49-6744-01A_33c16d35-96da-4400-9f48-1fc7567e30a4 | TCGA-L9-A444-01A_b14f167e-72ec-432e-a374-6d9472eca448 | TCGA-64-1680-01A_16b44441-90d4-4289-8248-d31251f49f2b | TCGA-78-7149-01A_593cca0d-6f1f-447e-be54-24c4a6ad73c0 | TCGA-55-5899-01A_d289975b-8b9c-43be-91ec-10ebd401937f | TCGA-91-7771-01A_8459ed46-071c-42f6-ab9d-1a16424c8921 | TCGA-55-8207-01A_9e841128-e372-44dc-ada0-72be76782a2c | TCGA-55-8512-01A_f148c5ad-0710-4a88-9303-f83f6b07d5da | TCGA-97-7552-01A_810ef019-2069-46ec-903a-a47a2a8211ad | TCGA-38-A44F-01A_dd1d7a21-1235-4934-b0b2-d4d3a5bf35f8 | TCGA-55-8621-01A_2b987ab5-2a04-4046-bd60-cb219c9e74b5 | TCGA-78-8655-01A_6f343aec-65e1-44ad-b4db-339d4ed62373 | TCGA-44-5643-01A_a26c9cfc-b7cf-4157-8d75-d668602ed4ff | TCGA-55-8615-01A_b6d50fd3-1810-48d6-aab1-c97f9c29d194 | TCGA-55-A48Z-01A_f9a5ba92-d9d1-409b-91ba-2bfb209c295d | TCGA-99-8033-01A_dad25a07-fb2a-42d0-95b6-b072afbdaa7c | TCGA-44-5644-01A_0a34988b-4886-4852-9b03-7915c44a0647 | TCGA-95-7039-01A_7c1bff62-84a9-446d-b5dc-bf92cfe6c58e | TCGA-75-5146-01A_a8393e91-f334-4d1f-b13b-8008cf163fd0 | TCGA-55-7725-01A_44a3eb8c-135f-44f4-82bd-86fb6104a4e8 | TCGA-50-6590-01A_105ad832-c4e7-4622-8469-c558f5911bbf |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| u2af1-wt_over_u2af1-s34f | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| u2af1-s34f_over_u2af1-wt | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |

``` r
query_result_longer <- query_result %>%
  pivot_longer(-query,
               names_to = "id",
               values_to = "pvalue") %>%
  mutate(pvalue_rounded = round(pvalue, 2))


query_result_longer_with_genotypes <- query_result_longer %>%
  filter(query == "u2af1-s34f_over_u2af1-wt") %>%
  rename(pvalue_for_u2af1_s34f_match = pvalue) %>%
  left_join(all_93_samples_sig_manifest,
            by = join_by(id))
```

# Did query results reflect genotypes?

``` r
ggplot(query_result_longer_with_genotypes) +
  geom_histogram(aes(x=pvalue_for_u2af1_s34f_match, fill = genotype),
                 bins = 20) +
  scale_fill_brewer(palette = "Set1")
```

![](split_TCGA_U2AF1_mut_into_test_train_files/figure-commonmark/unnamed-chunk-12-1.png)

``` r
query_result_longer_with_genotypes %>%
  filter(genotype == "u2af1-s34f",
         pvalue_rounded == 1)
```

| query | id | pvalue_for_u2af1_s34f_match | pvalue_rounded | genotype |
|:---|:---|---:|---:|:---|
| u2af1-s34f_over_u2af1-wt | TCGA-MP-A4T4-01A_9eeae6b9-2031-47fa-80db-e04d53f0bfbd | 1 | 1 | u2af1-s34f |
| u2af1-s34f_over_u2af1-wt | TCGA-49-6744-01A_33c16d35-96da-4400-9f48-1fc7567e30a4 | 1 | 1 | u2af1-s34f |
| u2af1-s34f_over_u2af1-wt | TCGA-64-1680-01A_16b44441-90d4-4289-8248-d31251f49f2b | 1 | 1 | u2af1-s34f |
| u2af1-s34f_over_u2af1-wt | TCGA-78-8655-01A_6f343aec-65e1-44ad-b4db-339d4ed62373 | 1 | 1 | u2af1-s34f |
