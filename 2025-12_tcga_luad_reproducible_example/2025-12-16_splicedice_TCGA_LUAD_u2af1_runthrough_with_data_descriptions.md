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
p_vals_transposed <- pvals %>%
  pivot_longer(-query) %>%
  pivot_wider(names_from = query)
  
pvals %>%
  pivot_longer(-query) %>%
  pull(value) %>%
  range()
```

    [1] 0 1

``` r
apply(pvals[,-1], 2, summary)
```

            TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16
    Min.                                           4.245765e-247
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981
    Min.                                           2.433674e-274
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2
    Min.                                           1.413419e-161
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b
    Min.                                            5.56469e-172
    1st Qu.                                          2.50000e-01
    Median                                           5.00000e-01
    Mean                                             5.00000e-01
    3rd Qu.                                          7.50000e-01
    Max.                                             1.00000e+00
            TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960
    Min.                                           7.609813e-133
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-6985-01A2a600a38-215c-4b2b-9b9d-ab5d3b9a0bbc
    Min.                                           9.251405e-163
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-49-6744-01A33c16d35-96da-4400-9f48-1fc7567e30a4
    Min.                                           4.446051e-131
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-44-3398-01A347924ac-b049-4a8b-a298-ba3a246f58e9
    Min.                                           1.066583e-198
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-95-7948-01A3498e816-9bf1-41ab-a662-206a78a32e2b
    Min.                                           1.703151e-192
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-44-2657-01A35a81dbe-bf1e-478c-8a95-d227b4195f34
    Min.                                           7.451145e-186
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-50-8460-01A3dbc67a1-c49d-407c-867b-dc453f3aebc0
    Min.                                           5.621176e-129
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-6968-01A40708d9c-1c51-4e7c-9ce2-185ea1480eb2
    Min.                                           4.943328e-196
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-86-8280-01A4699cd8b-a11f-4151-a2ed-0618a476800b
    Min.                                                    0.00
    1st Qu.                                                 0.25
    Median                                                  0.50
    Mean                                                    0.50
    3rd Qu.                                                 0.75
    Max.                                                    1.00
            TCGA-55-A4DF-01A4a5e9e8a-8c48-48cf-8bf0-eb564611d382
    Min.                                           2.403095e-196
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-69-7763-01A4b9a61f4-5a9a-462a-ba94-7bc718abac56
    Min.                                           1.960278e-170
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-05-4395-01A4d85514e-171d-46e4-b6db-43b4f8ff2eb0
    Min.                                           1.986489e-189
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-75-5147-01A4fc71e83-8aab-449f-807a-db5d6eb21ab9
    Min.                                            3.88132e-196
    1st Qu.                                          2.50000e-01
    Median                                           5.00000e-01
    Mean                                             5.00000e-01
    3rd Qu.                                          7.50000e-01
    Max.                                             1.00000e+00
            TCGA-55-6543-01A5fa0513c-3de7-4d3b-9df0-83f2df36b947
    Min.                                           5.051257e-218
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-64-5815-01A5fc71d41-3824-4649-9179-386bb566533c
    Min.                                            1.921342e-95
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-64-5781-01A61005b7e-d7ad-4573-af9b-d9f33ce3c300
    Min.                                           4.956862e-129
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-A490-01A62a350a6-9cb3-474b-8eb2-6eec9f6e2904
    Min.                                             2.00455e-64
    1st Qu.                                          2.50000e-01
    Median                                           5.00000e-01
    Mean                                             5.00000e-01
    3rd Qu.                                          7.50000e-01
    Max.                                             1.00000e+00
            TCGA-55-1595-01A63da5a36-0ec0-4d89-be9d-7319f0eae8ed
    Min.                                           1.269016e-154
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-75-5122-01A6d2d8cc2-4e19-4e74-97dc-45e6eeec5e1c
    Min.                                           3.886319e-152
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-44-7670-01A6e90fa77-c338-4e9a-a43b-fa702386db08
    Min.                                           1.669896e-207
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-78-8655-01A6f343aec-65e1-44ad-b4db-339d4ed62373
    Min.                                           3.907122e-130
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-95-7039-01A7c1bff62-84a9-446d-b5dc-bf92cfe6c58e
    Min.                                           3.405443e-117
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-44-A47G-01A7c8cde36-afef-49e3-a389-6aa07fdf0d88
    Min.                                           3.105298e-145
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-97-8176-01A8031c488-856a-4e1e-93f1-57e672e34d8d
    Min.                                           3.798961e-144
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-7727-01A86c05b02-68d0-473d-8aea-ab501cb40d29
    Min.                                            9.262421e-37
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-50-5932-01A98754b25-9c39-4830-b260-2d92b28f2e7a
    Min.                                           4.227138e-158
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-78-8648-01A9988cad6-0f42-4112-975c-814bfc3e91c3
    Min.                                           4.342585e-144
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-7903-01A99c213ba-55b9-42b6-9546-62b8d3f6c284
    Min.                                           9.142564e-215
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-7573-01A9b179934-f54d-4256-84bd-3e516685a119
    Min.                                           5.719943e-188
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-MP-A4T4-01A9eeae6b9-2031-47fa-80db-e04d53f0bfbd
    Min.                                            2.043766e-76
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-97-8547-01A9f9b1a22-8bf8-4a2b-8d5d-dcc84271519d
    Min.                                           1.673323e-142
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-50-5941-01Aaa7245fd-7073-4ff9-88cc-648a2c9f1f60
    Min.                                            6.698828e-78
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-L9-A444-01Ab14f167e-72ec-432e-a374-6d9472eca448
    Min.                                           2.011587e-130
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-62-8397-01Ab7dfe7a7-b569-4532-bc55-02665f4979e1
    Min.                                           3.207215e-112
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-78-7155-01Ad0d763a9-856c-452b-9989-a72894b32326
    Min.                                           1.457001e-146
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-5899-01Ad289975b-8b9c-43be-91ec-10ebd401937f
    Min.                                           3.050145e-174
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-95-7947-01Ad596b2b1-0915-41c2-b35c-b343f59b8923
    Min.                                           4.131936e-292
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-97-7941-01Ad816341b-dd8f-458a-b945-fd716c11c8c0
    Min.                                                    0.00
    1st Qu.                                                 0.25
    Median                                                  0.50
    Mean                                                    0.50
    3rd Qu.                                                 0.75
    Max.                                                    1.00
            TCGA-99-8033-01Adad25a07-fb2a-42d0-95b6-b072afbdaa7c
    Min.                                           3.224993e-205
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-55-8206-01Ae87e6c78-12aa-4bda-8c7e-0c9c7b2cb774
    Min.                                           3.333194e-292
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-73-4670-01Ae8f2cdea-1430-43ad-8359-ead8b4c5fd6e
    Min.                                           2.368086e-249
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00
            TCGA-78-7145-01Aeae099b8-7486-42dc-9565-c875662eb729
    Min.                                           4.199659e-109
    1st Qu.                                         2.500000e-01
    Median                                          5.000000e-01
    Mean                                            5.000000e-01
    3rd Qu.                                         7.500000e-01
    Max.                                            1.000000e+00

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
