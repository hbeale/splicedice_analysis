# 2025-12-16 splicedice TCGA LUAD u2af1 runthrough with data
descriptions
Holly Beale
2025-12-16

# Set up splicedice

Note: this code runs on a computer that has had the following set up.
The “set up” commands are not run as part of the notebook

## Reset from any previous runs

Confirm example directory space is empty

    ls -alth /mnt/splicedice_example/

delete if it’s not

    rm -r /mnt/splicedice_example/

Exit python environments if one is active

    deactivate

## Check reference files

    ls /mnt/ref/GRCh38.primary_assembly.genome.fa
    ls /mnt/ref/gencode.v47.primary_assembly.annotation.gtf

if they are not present, obtain them as described in
https://github.com/hbeale/splicedice_analysis/blob/main/misc/reference_file_sources.md

## Download repo

this uses the latest splicedice code as of this run; I reset to this
commit for reproducibility

uses commit da045c4 from 9/16/2025

url:
https://github.com/BrooksLabUCSC/splicedice/commit/da045c486e314e6f7db253998d886a163172295b

SHA1=da045c486e314e6f7db253998d886a163172295b

    mkdir -p /mnt/splicedice_example/git_code /mnt/splicedice_example/analysis
    cd /mnt/splicedice_example/git_code
    git clone https://github.com/BrooksLabUCSC/splicedice.git 

    SHA1=da045c486e314e6f7db253998d886a163172295b
    cd /mnt/splicedice_ir_example/git_code/splicedice
    git reset --hard $SHA1

## Create environment

    cd /mnt/splicedice_example/git_code/splicedice/
    python3 -m venv splicedice_env
    splicedice_env/bin/pip install .
    source /mnt/splicedice_example/git_code/splicedice/splicedice_env/bin/activate
    pip install pysam
    splicedice

## Get manifest

    wget https://raw.githubusercontent.com/hbeale/splicedice_analysis/refs/heads/main/2025-12_tcga_luad_reproducible_example/bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv -P  /mnt/splicedice_example/analysis/

# Run splicedice

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

``` r
base_dir <- "/mnt/splicedice_example/analysis"
```

# Bam manifest

``` r
bam_manifest <- read_tsv(file.path(base_dir, "bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv"),
                         col_names = c("sample_id", "bam_with_path", "feature1", "feature2"))
```

    Rows: 46 Columns: 4
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (4): sample_id, bam_with_path, feature1, feature2

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
dim(bam_manifest)
```

    [1] 46  4

``` r
bam_manifest %>%
  head()
```

| sample_id | bam_with_path | feature1 | feature2 |
|:---|:---|:---|:---|
| TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16 | /mnt/data/tcga/0a26152a-462f-4895-8fe8-15fcdcc56e16/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam | u2af1-wt | u2af1-wt |
| TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981 | /mnt/data/tcga/0c633b9e-3303-4625-b59d-02102d8bf981/5158a031-b856-4423-9418-031b3107e88f.rna_seq.genomic.gdc_realn.bam | u2af1-wt | u2af1-wt |
| TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2 | /mnt/data/tcga/0ebf5cc5-f242-45ef-821a-939b51dc95a2/330845b9-1d53-47af-8cb7-30ce5d30625d.rna_seq.genomic.gdc_realn.bam | u2af1-s34f | u2af1-s34f |
| TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b | /mnt/data/tcga/16b44441-90d4-4289-8248-d31251f49f2b/8b3aec43-4c75-4598-bf0a-168f7ffb9f3b.rna_seq.genomic.gdc_realn.bam | u2af1-s34f | u2af1-s34f |
| TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960 | /mnt/data/tcga/20592e25-4b12-4cd3-b1b1-b8e8d6352960/a0c9ebdf-951b-4d8d-aa79-3ff1c82342cd.rna_seq.genomic.gdc_realn.bam | u2af1-wt | u2af1-wt |
| TCGA-55-6985-01A2a600a38-215c-4b2b-9b9d-ab5d3b9a0bbc | /mnt/data/tcga/2a600a38-215c-4b2b-9b9d-ab5d3b9a0bbc/dc3ac0d3-d862-4761-ac12-60bb4d6758c1.rna_seq.genomic.gdc_realn.bam | u2af1-wt | u2af1-wt |

``` r
tabyl(bam_manifest, feature1)
```

| feature1   |   n |   percent |
|:-----------|----:|----------:|
| u2af1-s34f |  11 | 0.2391304 |
| u2af1-wt   |  35 | 0.7608696 |

# bam_to_junc_bed

message: “sh: 1: source: not found”

maybe the source statement isn’t required, because it seems to proceed
without it

interwebs say: “The error message source: not found means that the
source command was evaluated properly, but the file it should have read
does not exist.”

## temporarily skip this step (already complete)

``` r
# bam_to_junc_bed_command <- 
#   paste("cd", base_dir, ";",
#         "source /mnt/splicedice_example/git_code/splicedice/splicedice_env/bin/activate;",
#         "genome=/mnt/ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa;",
#         "genes=/mnt/ref/gencode.v47.primary_assembly.annotation.gtf;",
#         "here=/mnt/splicedice_example/analysis/;",
#         "bam_manifest=bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv;",
#         "/mnt/splicedice_example/git_code/splicedice/splicedice_env/bin/splicedice bam_to_junc_bed",
#         "-m $bam_manifest",
#         "-o $here",
#         "--genome $genome",
#         "--annotation $genes",
#         "--number_threads 4;",
#         "~/alert_msg.sh 'bam_to_junc_bed complete'"
#   )
# 
# bam_to_junc_bed_command
# 
# bam_to_junc_bed_command_output <- system(bam_to_junc_bed_command, 
#        intern = TRUE)
# 
# head(bam_to_junc_bed_command_output)
```

## show files after bam_to_junc_bed

``` r
list.files(base_dir,
           recursive = FALSE)
```

    [1] "_allClusters.tsv"                                   
    [2] "_allPS.tsv"                                         
    [3] "_inclusionCounts.tsv"                               
    [4] "_junction_beds"                                     
    [5] "_junctions.bed"                                     
    [6] "_manifest.txt"                                      
    [7] "bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv"
    [8] "sig_manifest.txt"                                   

``` r
list.files(base_dir,
           recursive = TRUE) %>%
  head()
```

    [1] "_allClusters.tsv"                                                                      
    [2] "_allPS.tsv"                                                                            
    [3] "_inclusionCounts.tsv"                                                                  
    [4] "_junction_beds/06770623-6a10-4874-9eea-1497077f18ac.rna_seq.genomic.gdc_realn.junc.bed"
    [5] "_junction_beds/1890feb6-9f7f-4437-9828-198ff43e16b0.rna_seq.genomic.gdc_realn.junc.bed"
    [6] "_junction_beds/21a80f43-21be-4549-901b-c99083021c30.rna_seq.genomic.gdc_realn.junc.bed"

## show bam_to_junc_bed file contents

Score ranges from 1 to high (e.g. 41k)

Junctions are reported on both strands; should we have a strandedness
argument to account for unstranded data?

``` r
example_bed_file <- read_tsv(file.path(
  base_dir,
  "_junction_beds/06770623-6a10-4874-9eea-1497077f18ac.rna_seq.genomic.gdc_realn.junc.bed"),
  col_names = c("chr", "start", "end", "name", "score", "strand"))
```

    Rows: 376181 Columns: 6
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (3): chr, name, strand
    dbl (3): start, end, score

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
dim(example_bed_file)
```

    [1] 376181      6

``` r
head(example_bed_file)
```

| chr  | start |   end | name                         | score | strand |
|:-----|------:|------:|:-----------------------------|------:|:-------|
| chr1 | 14737 | 14969 | e:0.00:0.00;o:1;m:NN_NN;a:?  |     4 | \+     |
| chr1 | 14737 | 14969 | e:0.64:0.64;o:12;m:NN_NN;a:? |     3 | \-     |
| chr1 | 14829 | 15020 | e:2.02:2.02;o:20;m:NN_NN;a:? |    12 | \+     |
| chr1 | 14829 | 15020 | e:1.11:1.11;o:18;m:NN_NN;a:? |    21 | \-     |
| chr1 | 14829 | 15795 | e:0.00:0.00;o:6;m:NN_NN;a:?  |     2 | \+     |
| chr1 | 14829 | 15795 | e:1.18:1.04;o:17;m:NN_NN;a:? |    22 | \-     |

``` r
example_bed_file[1:6,1:6]
```

| chr  | start |   end | name                         | score | strand |
|:-----|------:|------:|:-----------------------------|------:|:-------|
| chr1 | 14737 | 14969 | e:0.00:0.00;o:1;m:NN_NN;a:?  |     4 | \+     |
| chr1 | 14737 | 14969 | e:0.64:0.64;o:12;m:NN_NN;a:? |     3 | \-     |
| chr1 | 14829 | 15020 | e:2.02:2.02;o:20;m:NN_NN;a:? |    12 | \+     |
| chr1 | 14829 | 15020 | e:1.11:1.11;o:18;m:NN_NN;a:? |    21 | \-     |
| chr1 | 14829 | 15795 | e:0.00:0.00;o:6;m:NN_NN;a:?  |     2 | \+     |
| chr1 | 14829 | 15795 | e:1.18:1.04;o:17;m:NN_NN;a:? |    22 | \-     |

``` r
# Score is not reported (e.g.is always 0).
summary(example_bed_file$score)
```

        Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
        1.00     2.00     7.00    47.57    29.00 41175.00 

``` r
# Strand is reported.
table(example_bed_file$strand)
```


         -      + 
    145819 230362 

``` r
example_bed_file %>%
  get_dupes(chr, start, end) %>%
  head()
```

| chr  | start |   end | dupe_count | name                         | score | strand |
|:-----|------:|------:|-----------:|:-----------------------------|------:|:-------|
| chr1 | 14737 | 14969 |          2 | e:0.00:0.00;o:1;m:NN_NN;a:?  |     4 | \+     |
| chr1 | 14737 | 14969 |          2 | e:0.64:0.64;o:12;m:NN_NN;a:? |     3 | \-     |
| chr1 | 14829 | 15020 |          2 | e:2.02:2.02;o:20;m:NN_NN;a:? |    12 | \+     |
| chr1 | 14829 | 15020 |          2 | e:1.11:1.11;o:18;m:NN_NN;a:? |    21 | \-     |
| chr1 | 14829 | 15795 |          2 | e:0.00:0.00;o:6;m:NN_NN;a:?  |     2 | \+     |
| chr1 | 14829 | 15795 |          2 | e:1.18:1.04;o:17;m:NN_NN;a:? |    22 | \-     |

# Quantify splice junction usage

``` r
# quant_command <- 
#   paste("cd", base_dir, ";",
#         "here=/mnt/splicedice_example/analysis/;",
#         "/mnt/splicedice_example/git_code/splicedice/splicedice_env/bin/splicedice quant",
#         "-m _manifest.txt",
#         "-o $here"
#   )
# 
# quant_command
# 
# quant_command_output <- system(quant_command, 
#        intern = TRUE)
# 
# head(quant_command_output)
```

# after splicedice quant

``` r
list.files(base_dir)
```

    [1] "_allClusters.tsv"                                   
    [2] "_allPS.tsv"                                         
    [3] "_inclusionCounts.tsv"                               
    [4] "_junction_beds"                                     
    [5] "_junctions.bed"                                     
    [6] "_manifest.txt"                                      
    [7] "bam_manifest_of_46_TCGA_LUAD_with_11_U2AF1_S34F.tsv"
    [8] "sig_manifest.txt"                                   

## show output

``` r
allPS <- read_tsv(file.path(base_dir, "_allPS.tsv"))
```

    Rows: 524247 Columns: 47
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr  (1): cluster
    dbl (46): TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16, TCGA-86-8075...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
inclusionCounts <- read_tsv(file.path(base_dir, "_inclusionCounts.tsv"))
```

    Rows: 524247 Columns: 47
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr  (1): cluster
    dbl (46): TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16, TCGA-86-8075...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
junctions <- read_tsv(file.path(base_dir, "_junctions.bed"), 
                      col_names = c("chr", "start", "end", "name", "score", "strand"))
```

    Rows: 524247 Columns: 6
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (3): chr, name, strand
    dbl (3): start, end, score

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
allClusters <- read_tsv(file.path(base_dir, "_allClusters.tsv"), 
                        col_names = c("cluster_id", "maybe_subclusters"))
```

    Rows: 524247 Columns: 2
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (2): cluster_id, maybe_subclusters

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

### allPS

allPS contains one splicing cluster per row (named in the cluster
column), and has a column for each analyzed RNA-Seq dataset
(e.g. “TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16”). The
dataset columns contain the percent spliced of that cluster. The values
can be NaN or 0-1

``` r
allPS[1:6,1:6]
```

| cluster | TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16 | TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981 | TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2 | TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b | TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960 |
|:---|---:|---:|---:|---:|---:|
| chr1:11844-12009:+ | NaN | NaN | NaN | NaN | NaN |
| chr1:12227-12612:+ | NaN | NaN | NaN | NaN | NaN |
| chr1:12697-13402:+ | NaN | 0.0 | NaN | NaN | 0.0 |
| chr1:12721-13220:+ | NaN | 0.5 | NaN | NaN | 0.5 |
| chr1:12721-13452:+ | NaN | 0.0 | NaN | NaN | 0.0 |
| chr1:12721-13482:+ | NaN | 0.0 | NaN | NaN | 0.0 |

``` r
long_allPS <- allPS %>%
  pivot_longer(-cluster) 

summary(long_allPS$value)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
          0       0       1       1       1       1 5038582 

``` r
long_allPS %>%
  filter(! is.na(value)) %>%
  nrow()
```

    [1] 19076780

``` r
dim(long_allPS)
```

    [1] 24115362        3

### inclusionCounts

inclusionCounts has the same format as allPS but contains … inclusion
counts? (To be confirmed) The values can be NaN or 0-1

``` r
dim(inclusionCounts)
```

    [1] 524247     47

``` r
inclusionCounts[1:6,1:6]
```

| cluster | TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16 | TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981 | TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2 | TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b | TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960 |
|:---|---:|---:|---:|---:|---:|
| chr1:11844-12009:+ | 0 | 0 | 0 | 0 | 0 |
| chr1:12227-12612:+ | 0 | 0 | 0 | 0 | 0 |
| chr1:12697-13402:+ | 0 | 0 | 0 | 0 | 0 |
| chr1:12721-13220:+ | 0 | 3 | 0 | 0 | 1 |
| chr1:12721-13452:+ | 0 | 0 | 0 | 0 | 0 |
| chr1:12721-13482:+ | 0 | 0 | 0 | 0 | 0 |

``` r
long_inclusionCounts <- inclusionCounts %>%
  pivot_longer(-cluster) 

summary(long_inclusionCounts$value)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
          0       0       1      42      14  368791 

``` r
dim(long_inclusionCounts)
```

    [1] 24115362        3

``` r
sum(is.na(long_inclusionCounts$value))
```

    [1] 0

### junctions.bed

a bed file describing reach identified junction. Score is not reported
(e.g.is always 0). Strand is reported. Some junctions are reported on
both the + and 1 strand

``` r
dim(junctions)
```

    [1] 524247      6

``` r
junctions[1:6,1:6]
```

| chr  | start |   end | name               | score | strand |
|:-----|------:|------:|:-------------------|------:|:-------|
| chr1 | 11844 | 12009 | chr1:11844-12009:+ |     0 | \+     |
| chr1 | 12227 | 12612 | chr1:12227-12612:+ |     0 | \+     |
| chr1 | 12697 | 13402 | chr1:12697-13402:+ |     0 | \+     |
| chr1 | 12721 | 13220 | chr1:12721-13220:+ |     0 | \+     |
| chr1 | 12721 | 13452 | chr1:12721-13452:+ |     0 | \+     |
| chr1 | 12721 | 13482 | chr1:12721-13482:+ |     0 | \+     |

``` r
# Score is not reported (e.g.is always 0).
summary(junctions$score)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
          0       0       0       0       0       0 

``` r
# Strand is reported.
table(junctions$strand)
```


         -      + 
    185426 338821 

``` r
junctions %>%
  get_dupes(chr, start, end) %>%
  head()
```

| chr  | start |   end | dupe_count | name               | score | strand |
|:-----|------:|------:|-----------:|:-------------------|------:|:-------|
| chr1 | 14829 | 14969 |          2 | chr1:14829-14969:+ |     0 | \+     |
| chr1 | 14829 | 14969 |          2 | chr1:14829-14969:- |     0 | \-     |
| chr1 | 14829 | 15020 |          2 | chr1:14829-15020:+ |     0 | \+     |
| chr1 | 14829 | 15020 |          2 | chr1:14829-15020:- |     0 | \-     |
| chr1 | 14829 | 15795 |          2 | chr1:14829-15795:+ |     0 | \+     |
| chr1 | 14829 | 15795 |          2 | chr1:14829-15795:- |     0 | \-     |

### allClusters

I’m not sure what this is. I assume it’s any splice junctions are
included in the cluster of splice junctions included in the cluster ID.

The cluster (first column) isn’t necessarily listed in part of the
second column. It isn’t necessarily the outermost span
(e.g. chr1:12697-13402:+ is exceeded at the higher end by
chr1:12721-13452:+)

``` r
allClusters[1:6, 1:2]
```

| cluster_id | maybe_subclusters |
|:---|:---|
| chr1:11844-12009:+ | NA |
| chr1:12227-12612:+ | NA |
| chr1:12697-13402:+ | chr1:12721-13220:+,chr1:12721-13452:+,chr1:12721-13482:+,chr1:13052-13220:+ |
| chr1:12721-13220:+ | chr1:12697-13402:+,chr1:12721-13452:+,chr1:12721-13482:+,chr1:13052-13220:+ |
| chr1:12721-13452:+ | chr1:12721-13220:+,chr1:12697-13402:+,chr1:12721-13482:+,chr1:13052-13220:+ |
| chr1:12721-13482:+ | chr1:12721-13452:+,chr1:12721-13220:+,chr1:12697-13402:+,chr1:13052-13220:+ |

# Signature analysis

## Prepare signature manifest

``` r
system(paste0("cat ", base_dir, "/_manifest.txt | cut -f1,3 > ", base_dir, "/sig_manifest.txt"), intern = TRUE)
```

    character(0)

## Compare two conditions

``` r
# command_to_compare_two_conditions <- paste("cd", base_dir, ";",
# "here=/mnt/splicedice_example/analysis/;",
# "python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py compare",
#   "-p _allPS.tsv ", 
#   "-m sig_manifest.txt ", 
#   "-o $here"
# )
# 
# command_to_compare_two_conditions
# 
# system(command_to_compare_two_conditions, 
#        intern = TRUE)
# command_to_compare_two_conditions
```

### sig

.sig.tsv contains one splicing cluster per row (here called
splice_intervals), and has four columns for each of the two conditions
defined in the sig manifest (here u2af1-wt and u2af1-s34f). The columns
contain summary statistics for samples in the condition (median, mean,
delta and pval). Median, mean, and pval range from 0-1, delta’s range is
-1 to 1.

``` r
sig <- read_tsv(file.path(base_dir, ".sig.tsv"))
```

    Rows: 2693 Columns: 9
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (1): splice_interval
    dbl (8): median_u2af1-wt, mean_u2af1-wt, delta_u2af1-wt, pval_u2af1-wt, medi...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
dim(sig)
```

    [1] 2693    9

``` r
sig[1:6,1:6]
```

| splice_interval | median_u2af1-wt | mean_u2af1-wt | delta_u2af1-wt | pval_u2af1-wt | median_u2af1-s34f |
|:---|---:|---:|---:|---:|---:|
| chr1:17368-17605:+ | 0.662 | 0.6615429 | -0.0400 | 0.3355855 | 0.782 |
| chr1:17368-17605:- | 0.788 | 0.7786857 | -0.0195 | 0.3031689 | 0.886 |
| chr1:498456-498683:- | 0.273 | 0.2971429 | 0.0200 | 0.3355855 | 0.175 |
| chr1:729955-735422:+ | 0.073 | 0.0629714 | 0.0125 | 0.3452430 | 0.000 |
| chr1:733364-735422:+ | 0.641 | 0.6454000 | -0.0235 | 0.3191078 | 0.857 |
| chr1:939412-941143:+ | 0.556 | 0.5320952 | -0.0440 | 0.3777181 | 1.000 |

``` r
long_allPS <- allPS %>%
  pivot_longer(-cluster) 

apply(sig[,-1], 2, summary)
```

            median_u2af1-wt mean_u2af1-wt delta_u2af1-wt pval_u2af1-wt
    Min.          0.0000000     0.0036000  -0.7085000000    0.07231326
    1st Qu.       0.2000000     0.2219143  -0.0265000000    0.22053505
    Median        0.4710000     0.4677714   0.0000000000    0.27920896
    Mean          0.4821238     0.4832695   0.0005790939    0.26930007
    3rd Qu.       0.7700000     0.7516571   0.0270000000    0.32376078
    Max.          1.0000000     0.9982647   0.7270000000    0.56292754
            median_u2af1-s34f mean_u2af1-s34f delta_u2af1-s34f pval_u2af1-s34f
    Min.            0.0000000       0.0000000     -1.000000000    0.0001380437
    1st Qu.         0.1840000       0.2029091     -0.102500000    0.0099325116
    Median          0.4880000       0.4866364      0.053000000    0.0223148001
    Mean            0.4869861       0.4890272      0.005441329    0.0229892433
    3rd Qu.         0.7860000       0.7731818      0.107000000    0.0357494209
    Max.            1.0000000       1.0000000      1.000000000    0.0499815423

# Generate beta fit of signature

``` r
# command_to_generate_beta_fit_of_signature <- 
#   paste("cd", base_dir, ";",
#         "here=/mnt/splicedice_example/analysis/;",
#         "python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py fit_beta",
#         "-p _allPS.tsv ", 
#         "-s .sig.tsv",
#         "-m sig_manifest.txt ", 
#         "-o $here"
#   )
# command_to_generate_beta_fit_of_signature
# 
# system(command_to_generate_beta_fit_of_signature, 
#        intern = TRUE)
```

### beta

.beta.tsv contains one splicing cluster per row (here called
splice_intervals), and has three columns for each of the two conditions
defined in the sig manifest (here u2af1-wt and u2af1-s34f). The columns
contain summary statistics for samples in the condition (median, alpha
and beta). Some alpha and bet values are “None”; maybe we should change
those to NA.

``` r
beta <- read_tsv(file.path(base_dir, ".beta.tsv"))
```

    Rows: 2693 Columns: 7
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (5): splice_interval, alpha_u2af1-wt, beta_u2af1-wt, alpha_u2af1-s34f, b...
    dbl (2): median_u2af1-wt, median_u2af1-s34f

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
dim(beta)
```

    [1] 2693    7

``` r
beta[1:6,1:6]
```

| splice_interval | median_u2af1-wt | alpha_u2af1-wt | beta_u2af1-wt | median_u2af1-s34f | alpha_u2af1-s34f |
|:---|---:|:---|:---|---:|:---|
| chr1:17368-17605:+ | 0.662 | 4.4153076032213265 | 2.145204751213825 | 0.782 | 4.582948671062404 |
| chr1:498456-498683:- | 0.273 | 1.7249201047861975 | 4.252496281423634 | 0.175 | 1.2811951134415158 |
| chr1:17368-17605:- | 0.788 | 6.6384321455867 | 1.8651048854478238 | 0.886 | 7.902858931788376 |
| chr1:729955-735422:+ | 0.073 | 0.6788541197830424 | 10.293491277492125 | 0.000 | 0.3785182527053961 |
| chr1:733364-735422:+ | 0.641 | 1.793897792069864 | 0.8230651989876939 | 0.857 | 3.126678021845967 |
| chr1:939412-941143:+ | 0.556 | 0.5626535276230027 | 0.6514524895568761 | 1.000 | None |

``` r
colnames(beta)
```

    [1] "splice_interval"   "median_u2af1-wt"   "alpha_u2af1-wt"   
    [4] "beta_u2af1-wt"     "median_u2af1-s34f" "alpha_u2af1-s34f" 
    [7] "beta_u2af1-s34f"  

``` r
longer_beta <- beta %>%
  pivot_longer(-splice_interval,
               values_transform = list(value = as.character)) 

longer_beta %>%
  group_by(name) %>%
  filter(value == "None") %>%
  summarize(n_none = n())
```

| name             | n_none |
|:-----------------|-------:|
| alpha_u2af1-s34f |     25 |
| alpha_u2af1-wt   |      6 |
| beta_u2af1-s34f  |     25 |
| beta_u2af1-wt    |      6 |

``` r
longer_beta_numeric <- longer_beta %>%
  filter(value != "None") %>%
  type_convert()
```


    ── Column specification ────────────────────────────────────────────────────────
    cols(
      splice_interval = col_character(),
      name = col_character(),
      value = col_double()
    )

``` r
longer_beta_numeric %>% 
  group_by(name) %>%
  summarize(max = max(value),
            min = min(value))
```

| name              |          max |       min |
|:------------------|-------------:|----------:|
| alpha_u2af1-s34f  | 2.116169e+31 | 0.1289840 |
| alpha_u2af1-wt    | 3.835559e+02 | 0.1397506 |
| beta_u2af1-s34f   | 2.118285e+34 | 0.1289840 |
| beta_u2af1-wt     | 1.777889e+02 | 0.1337045 |
| median_u2af1-s34f | 1.000000e+00 | 0.0000000 |
| median_u2af1-wt   | 1.000000e+00 | 0.0000000 |

# Query to find other matching samples

``` r
# 
# command_to_find_matching_samples <- 
#   paste("cd", base_dir, ";",
#         "here=/mnt/splicedice_example/analysis/;",
#         "python3 /mnt/splicedice_example/git_code/splicedice/scripts/signature.py query",
#         "-p _allPS.tsv ", 
#         "-b .beta.tsv",
#         "-o $here"
#   )
# command_to_find_matching_samples
# 
# system(command_to_find_matching_samples, 
#        intern = TRUE)
```

### pvals

.pvals.tsv contains one condition per row and a column for each sample.
The values of sample columns are p-values indicating whether the samples
significantly matches the beta signature it was compared to.

``` r
pvals <- read_tsv(file.path(base_dir, ".pvals.tsv"))
```

    Rows: 2 Columns: 47
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr  (1): query
    dbl (46): TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16, TCGA-86-8075...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
dim(pvals)
```

    [1]  2 47

``` r
pvals[1:2,1:6]
```

| query | TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16 | TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981 | TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2 | TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b | TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960 |
|:---|---:|---:|---:|---:|---:|
| u2af1-wt_over_u2af1-s34f | 0 | 0 | 1 | 1 | 0 |
| u2af1-s34f_over_u2af1-wt | 1 | 1 | 0 | 0 | 1 |

``` r
pvals_longer <- pvals %>%
  pivot_longer(-query) 

p_vals_transposed <- pvals_longer %>%
  pivot_wider(names_from = query)
  
pvals_longer %>%
  pull(value) %>%
  range()
```

    [1] 0 1

``` r
summary(pvals_longer$value)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
        0.0     0.0     0.5     0.5     1.0     1.0 

#### pval results

expected result: the 11 u2af1-s34f samples will match the signature
results

``` r
sig_manifest <- read_tsv(file.path(base_dir, "sig_manifest.txt"),
                         col_names = c("library", "genotype"))
```

    Rows: 46 Columns: 2
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (2): library, genotype

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
tabyl(sig_manifest, genotype)
```

| genotype   |   n |   percent |
|:-----------|----:|----------:|
| u2af1-s34f |  11 | 0.2391304 |
| u2af1-wt   |  35 | 0.7608696 |

``` r
p_vals_transposed %>%
  mutate(significant = `u2af1-s34f_over_u2af1-wt` < 0.05) %>%
  tabyl(significant)
```

| significant |   n |   percent |
|:------------|----:|----------:|
| FALSE       |  35 | 0.7608696 |
| TRUE        |  11 | 0.2391304 |

# Move results

``` r
# timestamp <- format(Sys.time(), "%Y.%m.%d_%H.%M.%S")
# this_archive_folder <- file.path("/mnt/splicedice_example_archives/", paste0(timestamp, "_analysis"))
# 
# 
# command_to_move_results <- paste("mv /mnt/splicedice_example/analysis/", this_archive_folder)
# 
# command_to_move_results
# 
# system(command_to_move_results, 
#        intern = TRUE)
```

/mnt/splicedice_example_archives/2025.10.01_23.41.25/
