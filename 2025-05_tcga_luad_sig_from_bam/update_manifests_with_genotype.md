# update manifests with genotype.rmarkdown
Holly Beale
2025-05-29

``` r
library(tidyverse)
```

    Warning: package 'readr' was built under R version 4.2.3

    Warning: package 'dplyr' was built under R version 4.2.3

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ✔ ggplot2   3.4.4     ✔ tibble    3.2.1
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
library(here)
```

    here() starts at /Users/hbeale/Documents/Dropbox/ucsc/projects/gitCode/splicedice_analysis

``` r
batches_1_and_2_bed_manifest_without_gt <- read_tsv(here("2025-05_tcga_luad_download/batches_1_and_2_bed_manifest.2025.05.29_22.26.44.txt"),
                                                    col_names = c("sample_name",
                                                                  "bed_file_path",
                                                                  "id1",
                                                                  "id2")) %>%
  mutate(sample_name = str_replace_all(sample_name, " ", "_"))
```

    Rows: 95 Columns: 4
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (4): sample_name, bed_file_path, id1, id2

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
luad_u2af1_s34f_wt_manifest  <- read_tsv(here("2025-05_tcga_luad_download/luad_u2af1_s34f_wt_manifest.tsv"),
                                        col_names = c("id", "mutation"))
```

    Rows: 532 Columns: 2
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (2): id, mutation

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
batches_1_and_2_bed_manifest_with_gt <- batches_1_and_2_bed_manifest_without_gt %>%
  mutate(bam_file_uuid = str_remove(bed_file_path, "^.*beds/") %>% str_remove(".rna_seq.*$")) %>%
  left_join(luad_u2af1_s34f_wt_manifest, by=c("bam_file_uuid" = "id"))

set.seed(133455566)
batches_1_and_2_bed_manifest_with_gt_distinct <- batches_1_and_2_bed_manifest_with_gt %>%
  group_by(bam_file_uuid) %>%
  slice_sample(n = 1)



  

nrow(batches_1_and_2_bed_manifest_with_gt) 
```

    [1] 95

``` r
nrow(batches_1_and_2_bed_manifest_with_gt_distinct)
```

    [1] 93

``` r
head(batches_1_and_2_bed_manifest_with_gt_distinct)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| sample_name | bed_file_path | id1 | id2 | bam_file_uuid | mutation |
|:---|:---|:---|:---|:---|:---|
| TCGA-55-A4DF-01A_4a5e9e8a-8c48-48cf-8bf0-eb564611d382 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/06770623-6a10-4874-9eea-1497077f18ac.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 06770623-6a10-4874-9eea-1497077f18ac | u2af1-wt |
| TCGA-78-7633-01A_c916f887-6e77-4fc6-a692-30375d28650f | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/06c83065-5800-451a-84a7-7a7f352493ec.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 06c83065-5800-451a-84a7-7a7f352493ec | u2af1-wt |
| TCGA-62-A471-01A_ae528992-720c-4818-ac5e-8e1b0509f9d9 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/0a4e0b83-7afa-475b-8586-e9e79e31d6d2.rna_seq.genomic.gdc_realn.junc.bed | oct | unknown | 0a4e0b83-7afa-475b-8586-e9e79e31d6d2 | u2af1-wt |
| TCGA-38-6178-01A_a0755929-e85a-4ea8-a7bd-3413bd734c75 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/0e3e11b9-9f43-4a0d-8665-023fae9f8b00.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 0e3e11b9-9f43-4a0d-8665-023fae9f8b00 | u2af1-wt |
| TCGA-97-8172-01A_ba6057cc-61fd-4d2f-8599-ed0a6aaf80b6 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/145db6c5-f7ad-4e2f-88f1-d68bc457848a.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 145db6c5-f7ad-4e2f-88f1-d68bc457848a | u2af1-wt |
| TCGA-44-3917-01A_a124f52b-3a64-4642-ba61-9307ac5cb3bc | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/146a69db-f304-4dd3-97e2-4d11b6512069.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 146a69db-f304-4dd3-97e2-4d11b6512069 | u2af1-wt |

check features

``` r
gdc_sample_sheet <- read_tsv(here("2025-05_tcga_luad_download/gdc_sample_sheet.2025-05-22.tsv"))
```

    Rows: 541 Columns: 11
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (11): File ID, File Name, Data Category, Data Type, Project ID, Case ID,...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
lc_no_space <- function(x) str_replace_all(x, " ", "_") %>% tolower()
gdc_sample_sheet_renamed <- gdc_sample_sheet %>% rename_with(lc_no_space)

head(gdc_sample_sheet_renamed)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| file_id | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 704d42ab-3e11-4c3b-a74c-b1e6a30e27c5 | 325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2659 | TCGA-44-2659-01A | Tumor | Primary | Solid Tissue | Unknown |
| d1945e55-eaa9-41f3-8017-380ccd112dfc | 59a0b90e-8b8b-41b8-95f0-d51961a94be5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4396 | TCGA-05-4396-01A | Tumor | Primary | Solid Tissue | Unknown |
| 44a3eb8c-135f-44f4-82bd-86fb6104a4e8 | f3d482bb-14e8-4569-bee4-22d7d2a027ea.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7725 | TCGA-55-7725-01A | Tumor | Primary | Solid Tissue | Unknown |
| 216b822e-0d33-476f-ba03-18ff818f8a78 | 5fd9d2a8-3a95-440c-a0de-8ad5fd86e156.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-5420 | TCGA-05-5420-01A | Tumor | Primary | Solid Tissue | Unknown |
| ba6057cc-61fd-4d2f-8599-ed0a6aaf80b6 | 145db6c5-f7ad-4e2f-88f1-d68bc457848a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8172 | TCGA-97-8172-01A | Tumor | Primary | Solid Tissue | Unknown |
| 45600709-c917-42ef-bc2f-229e6f3c71af | 9ebc079c-069f-4468-8b9e-680e39a3c4ad.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4629 | TCGA-38-4629-01A | Tumor | Primary | Unknown | Unknown |

``` r
batches_1_and_2_bed_manifest_with_gt_distinct_anno <- left_join(batches_1_and_2_bed_manifest_with_gt_distinct %>%
                                                                  mutate(gdc_file_uuid = str_remove(sample_name, "^.*_")),
          gdc_sample_sheet_renamed, by=c("gdc_file_uuid" = "file_id"))
```

# review sample features

``` r
n_unique <- function(x) length(unique(x))

unique_sample_vals <- batches_1_and_2_bed_manifest_with_gt_distinct_anno %>%
#   mutate(across(everything(), as.character)) %>%
  ungroup %>%
  summarize(across(everything(),  n_unique)) %>%
  pivot_longer(everything())

unique_sample_vals
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| name                | value |
|:--------------------|------:|
| sample_name         |    93 |
| bed_file_path       |    93 |
| id1                 |     2 |
| id2                 |     2 |
| bam_file_uuid       |    93 |
| mutation            |     2 |
| gdc_file_uuid       |    93 |
| file_name           |    93 |
| data_category       |     1 |
| data_type           |     1 |
| project_id          |     1 |
| case_id             |    93 |
| sample_id           |    93 |
| tissue_type         |     1 |
| tumor_descriptor    |     1 |
| specimen_type       |     2 |
| preservation_method |     2 |

``` r
tabyl(batches_1_and_2_bed_manifest_with_gt_distinct_anno,
      specimen_type)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| specimen_type |   n |   percent |
|:--------------|----:|----------:|
| Solid Tissue  |  70 | 0.7526882 |
| Unknown       |  23 | 0.2473118 |

``` r
tabyl(batches_1_and_2_bed_manifest_with_gt_distinct_anno,
      preservation_method)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| preservation_method |   n |   percent |
|:--------------------|----:|----------:|
| OCT                 |   4 | 0.0430108 |
| Unknown             |  89 | 0.9569892 |

consider removing OCT

``` r
batches_1_and_2_bed_manifest_with_gt_distinct_anno %>%
  filter(preservation_method == "OCT")
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| sample_name | bed_file_path | id1 | id2 | bam_file_uuid | mutation | gdc_file_uuid | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| TCGA-62-A471-01A_ae528992-720c-4818-ac5e-8e1b0509f9d9 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/0a4e0b83-7afa-475b-8586-e9e79e31d6d2.rna_seq.genomic.gdc_realn.junc.bed | oct | unknown | 0a4e0b83-7afa-475b-8586-e9e79e31d6d2 | u2af1-wt | ae528992-720c-4818-ac5e-8e1b0509f9d9 | 0a4e0b83-7afa-475b-8586-e9e79e31d6d2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A471 | TCGA-62-A471-01A | Tumor | Primary | Unknown | OCT |
| TCGA-MP-A4T4-01A_9eeae6b9-2031-47fa-80db-e04d53f0bfbd | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/39807893-979e-44c6-ada9-444c68b863c3.rna_seq.genomic.gdc_realn.junc.bed | oct | solid_tissue | 39807893-979e-44c6-ada9-444c68b863c3 | u2af1-s34f | 9eeae6b9-2031-47fa-80db-e04d53f0bfbd | 39807893-979e-44c6-ada9-444c68b863c3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T4 | TCGA-MP-A4T4-01A | Tumor | Primary | Solid Tissue | OCT |
| TCGA-L4-A4E6-01A_1eafc7d3-4753-45e1-82c3-d819f9571404 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/e4fe566f-bf64-408e-a422-fef7b855391f.rna_seq.genomic.gdc_realn.junc.bed | oct | unknown | e4fe566f-bf64-408e-a422-fef7b855391f | u2af1-wt | 1eafc7d3-4753-45e1-82c3-d819f9571404 | e4fe566f-bf64-408e-a422-fef7b855391f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L4-A4E6 | TCGA-L4-A4E6-01A | Tumor | Primary | Unknown | OCT |
| TCGA-62-A46P-01A_fda585d3-a881-4831-8dd4-e391fc9d6e7c | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/ef19e097-8ae9-4362-b77a-76d8f5399760.rna_seq.genomic.gdc_realn.junc.bed | oct | unknown | ef19e097-8ae9-4362-b77a-76d8f5399760 | u2af1-wt | fda585d3-a881-4831-8dd4-e391fc9d6e7c | ef19e097-8ae9-4362-b77a-76d8f5399760.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46P | TCGA-62-A46P-01A | Tumor | Primary | Unknown | OCT |

no, one is mutant, so i’ll keep all 4

# generate output

``` r
batches_1_and_2_bed_manifest_with_gt_distinct_anno %>%
  ungroup %>%
  mutate(id1 = mutation,
         id2 = mutation) %>% 
  select(1:4) %>%
write_tsv(here("2025-05_tcga_luad_download/batches_1_and_2_bed_manifest.with_genotypes.2025.05.29_22.26.44.tsv"),
            col_names = FALSE)
```
