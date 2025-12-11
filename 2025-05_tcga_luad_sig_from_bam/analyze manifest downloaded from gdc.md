# analyze-manifest-downloaded-from-gdc.rmarkdown
Holly Beale
2025-06-04

``` r
library(tidyverse)
```

    Warning: package 'tidyr' was built under R version 4.2.3

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
library(here)
```

    here() starts at /Users/hbeale/Documents/Dropbox/ucsc/projects/gitCode/splicedice_analysis

``` r
library(janitor)
```


    Attaching package: 'janitor'

    The following objects are masked from 'package:stats':

        chisq.test, fisher.test

``` r
gdc_sample_sheet <- read_tsv(here("2025-05_tcga_luad_sig_from_bam/gdc_sample_sheet.2025-05-22.tsv"))
```

    Rows: 541 Columns: 11
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (11): File ID, File Name, Data Category, Data Type, Project ID, Case ID,...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
gdc_manifest <- read_tsv(here("2025-05_tcga_luad_sig_from_bam/gdc_manifest.2025-05-22.132704.txt"))
```

    Rows: 541 Columns: 5
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (4): id, filename, md5, state
    dbl (1): size

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# Compare manifest and sample sheet contents

``` r
identical(gdc_sample_sheet$`File ID`, gdc_manifest$id)
```

    [1] TRUE

They are the same

# review sample features

``` r
n_unique <- function(x) length(unique(x))

unique_sample_vals <- gdc_sample_sheet %>%
  summarize(across(everything(),  n_unique)) %>%
  pivot_longer(everything())

unique_sample_vals
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| name                | value |
|:--------------------|------:|
| File ID             |   541 |
| File Name           |   541 |
| Data Category       |     1 |
| Data Type           |     1 |
| Project ID          |     1 |
| Case ID             |   516 |
| Sample ID           |   530 |
| Tissue Type         |     1 |
| Tumor Descriptor    |     2 |
| Specimen Type       |     2 |
| Preservation Method |     3 |

## What are multi-value columns?

Notes: anything with “1” or 541 is uninteresting

``` r
table(gdc_sample_sheet$`Tumor Descriptor`)
```


       Primary Recurrence 
           539          2 

``` r
table(gdc_sample_sheet$`Specimen Type`)
```


    Solid Tissue      Unknown 
             389          152 

``` r
table(gdc_sample_sheet$`Preservation Method`)
```


       FFPE     OCT Unknown 
         12      83     446 

# fix column names

``` r
lc_no_space <- function(x) str_replace_all(x, " ", "_") %>% tolower()
  

gdc_sample_sheet_renamed <- gdc_sample_sheet %>% rename_with(lc_no_space)
```

# review duplicate sample IDs

``` r
dupe_sample_ids <- gdc_sample_sheet_renamed$sample_id[duplicated(gdc_sample_sheet_renamed$sample_id)]


gdc_sample_sheet_renamed %>%
  filter(sample_id %in% dupe_sample_ids)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| file_id | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| aab35043-7ce8-4237-a732-45df7920a9a4 | 9aba4243-1817-4f5f-8e9d-66da98229246.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown |
| 06a7cb83-03c8-4ac4-b7c1-a037951c289c | f3bf4152-5e1d-42d2-920e-9dfbe2e0dbc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown |
| ecbd016f-74ce-4a7a-8553-4df9022c76a1 | fd713184-4bb4-4e1b-a3b8-636273ee6ccc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01A | Tumor | Primary | Solid Tissue | Unknown |
| db2e431a-6a7b-4d24-87cb-44d3f3d5accc | 7977a11b-246f-4c4c-a200-ee35d2d51fc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01A | Tumor | Primary | Solid Tissue | Unknown |
| ac8491bd-069c-406c-be34-a88858c5f206 | 3369898e-21d8-4ded-8bbc-a746b1a743ad.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01A | Tumor | Primary | Solid Tissue | Unknown |
| b2cf0b26-1f46-478d-b2e1-73115384ed57 | b307f8c5-d21f-42ae-9771-07126d58999e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01A | Tumor | Primary | Solid Tissue | Unknown |
| b5310007-7004-4306-8629-4c5a61219971 | b556d35a-4855-4e56-9e02-5fc939722169.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01A | Tumor | Primary | Solid Tissue | Unknown |
| 133d0758-2b29-47cf-89b9-97dc8c860271 | 735e3d15-4df3-4162-b819-1ebc1991bfce.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01A | Tumor | Primary | Solid Tissue | Unknown |
| 220f0f07-2691-4c14-af2d-0dfac14b3278 | d832db0a-348f-4e28-953a-741192fe0826.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01A | Tumor | Primary | Solid Tissue | Unknown |
| b66b7858-7464-47fd-8c42-0fe2917fb6a4 | 3f579bea-4481-42cd-b433-4f4ff65cf7b0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01A | Tumor | Primary | Unknown | Unknown |
| 8000ff4a-0b35-4b41-98af-bb616f2d3aa5 | 765dc4a5-ce4d-4437-9061-20c018bbbade.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01A | Tumor | Primary | Unknown | Unknown |
| 21daa1d2-8766-46ee-a0cb-b51b361a5a8d | 33e0a8b2-3e7e-46da-b5ef-76463308d3b9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01A | Tumor | Primary | Solid Tissue | Unknown |
| b614f97d-5004-4b5b-8125-0884404c702a | 883ef55a-e8c0-4774-a298-d2bfeaeeae4b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8863b8af-1ec2-4b06-ad68-b918a4c477c5 | 9a5e0fa6-a785-4d8e-bca5-43e02a3965bf.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01A | Tumor | Primary | Solid Tissue | Unknown |
| b002c35d-78d6-4330-b793-98aec1591e21 | 9a54be5e-6201-4beb-9689-289b9849756e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01A | Tumor | Primary | Solid Tissue | Unknown |
| a507729c-05f1-4d90-bba5-58ec4cdd67fc | d6e945f2-4a94-48ab-9ba0-d4f0ee2fb262.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7e6b813e-6bf9-4492-96c3-24f2dd780e53 | 9e504ab4-85a0-465d-be52-0c28ed83e5f8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01A | Tumor | Primary | Solid Tissue | Unknown |
| 187e65a9-5ac4-4251-9bc1-33a97123f5be | 655b5152-d150-4b2a-b7cc-ef70dc0b2256.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01A | Tumor | Primary | Solid Tissue | Unknown |
| 66fa5eaf-554c-4164-9502-660a5932bfe7 | 58e4f0e6-3b0f-4370-8abf-0b4d533672c5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01A | Tumor | Primary | Solid Tissue | Unknown |
| 15b605d3-cf71-406d-b704-6e0759faac8c | cc1646da-11b3-40c7-b35e-1206f4517b36.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01A | Tumor | Primary | Solid Tissue | Unknown |
| b59b480f-ac76-4ed2-9e63-a090036448e2 | 77b82c3f-e20c-4e3b-a55c-08af359bbb6e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown |
| 73c368dd-99db-4e34-a02f-fdff478a491c | af649713-fb41-496a-a94b-3691d202c1c8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown |

# review duplicate case IDs

``` r
dupe_case_ids <- gdc_sample_sheet_renamed$case_id[duplicated(gdc_sample_sheet_renamed$case_id)]



gdc_sample_sheet_renamed %>%
  filter(case_id %in% dupe_case_ids,
         #! sample_id %in% dupe_sample_ids
         ) %>%
  arrange(case_id)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| file_id | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| fb091d8f-779f-452a-ab0c-ff59cd822483 | 9f97863a-5019-41de-a095-dd20c4d55e02.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01B | Tumor | Primary | Solid Tissue | FFPE |
| b2cf0b26-1f46-478d-b2e1-73115384ed57 | b307f8c5-d21f-42ae-9771-07126d58999e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01A | Tumor | Primary | Solid Tissue | Unknown |
| b5310007-7004-4306-8629-4c5a61219971 | b556d35a-4855-4e56-9e02-5fc939722169.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01A | Tumor | Primary | Solid Tissue | Unknown |
| 21daa1d2-8766-46ee-a0cb-b51b361a5a8d | 33e0a8b2-3e7e-46da-b5ef-76463308d3b9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01A | Tumor | Primary | Solid Tissue | Unknown |
| b614f97d-5004-4b5b-8125-0884404c702a | 883ef55a-e8c0-4774-a298-d2bfeaeeae4b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01A | Tumor | Primary | Solid Tissue | Unknown |
| 51645a28-9e36-462d-a069-bce88ef445e9 | 3d11905a-16eb-40b2-a36b-e37dca6359d3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01B | Tumor | Primary | Solid Tissue | FFPE |
| becae9e1-8886-4f2e-b20f-92c429158848 | f7beaa9b-98ae-40bd-aadc-e69688499170.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01B | Tumor | Primary | Solid Tissue | FFPE |
| b59b480f-ac76-4ed2-9e63-a090036448e2 | 77b82c3f-e20c-4e3b-a55c-08af359bbb6e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown |
| 73c368dd-99db-4e34-a02f-fdff478a491c | af649713-fb41-496a-a94b-3691d202c1c8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2c864712-71a7-4c29-a96b-38058d10f4a3 | 00d461ae-a1d8-42f2-abd8-5e159363d857.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01B | Tumor | Primary | Solid Tissue | FFPE |
| 187e65a9-5ac4-4251-9bc1-33a97123f5be | 655b5152-d150-4b2a-b7cc-ef70dc0b2256.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01A | Tumor | Primary | Solid Tissue | Unknown |
| 15b605d3-cf71-406d-b704-6e0759faac8c | cc1646da-11b3-40c7-b35e-1206f4517b36.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01A | Tumor | Primary | Solid Tissue | Unknown |
| b002c35d-78d6-4330-b793-98aec1591e21 | 9a54be5e-6201-4beb-9689-289b9849756e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01A | Tumor | Primary | Solid Tissue | Unknown |
| 66fa5eaf-554c-4164-9502-660a5932bfe7 | 58e4f0e6-3b0f-4370-8abf-0b4d533672c5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01A | Tumor | Primary | Solid Tissue | Unknown |
| 12c918f4-ac2b-4e6f-8497-cf5b4388b268 | 812033b2-3784-44bf-8913-56307b267ea9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01B | Tumor | Primary | Solid Tissue | FFPE |
| a124f52b-3a64-4642-ba61-9307ac5cb3bc | 146a69db-f304-4dd3-97e2-4d11b6512069.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3917 | TCGA-44-3917-01A | Tumor | Primary | Unknown | Unknown |
| 01e9e2f2-ac97-4eca-85df-3105bb82436c | 0b55cf48-41ca-4d54-a6c6-fa15c711370b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3917 | TCGA-44-3917-01B | Tumor | Primary | Unknown | FFPE |
| 1e197fa0-d91c-4faa-bc27-806a1500bafd | 758b1a4d-bd46-4611-b8c3-49c5f62a2dab.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01B | Tumor | Primary | Unknown | FFPE |
| b66b7858-7464-47fd-8c42-0fe2917fb6a4 | 3f579bea-4481-42cd-b433-4f4ff65cf7b0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01A | Tumor | Primary | Unknown | Unknown |
| 8000ff4a-0b35-4b41-98af-bb616f2d3aa5 | 765dc4a5-ce4d-4437-9061-20c018bbbade.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01A | Tumor | Primary | Unknown | Unknown |
| 2f7e20ee-2db9-4ec9-a39c-d4735654b857 | 1ca692e6-1dff-4d84-ace1-671bac7b9f61.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01B | Tumor | Primary | Unknown | FFPE |
| aab35043-7ce8-4237-a732-45df7920a9a4 | 9aba4243-1817-4f5f-8e9d-66da98229246.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown |
| 06a7cb83-03c8-4ac4-b7c1-a037951c289c | f3bf4152-5e1d-42d2-920e-9dfbe2e0dbc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown |
| a507729c-05f1-4d90-bba5-58ec4cdd67fc | d6e945f2-4a94-48ab-9ba0-d4f0ee2fb262.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7e6b813e-6bf9-4492-96c3-24f2dd780e53 | 9e504ab4-85a0-465d-be52-0c28ed83e5f8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01A | Tumor | Primary | Solid Tissue | Unknown |
| b1d79b0e-960a-41e1-855c-82993ba9467b | 26fdaa75-cea5-4355-b3b1-6b5c2c75e542.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01B | Tumor | Primary | Solid Tissue | FFPE |
| 133d0758-2b29-47cf-89b9-97dc8c860271 | 735e3d15-4df3-4162-b819-1ebc1991bfce.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3e4107e8-4937-4bed-9c90-65d42f084f49 | 6338619f-470c-4ae1-8b45-959b5f9ad3da.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01B | Tumor | Primary | Solid Tissue | FFPE |
| 220f0f07-2691-4c14-af2d-0dfac14b3278 | d832db0a-348f-4e28-953a-741192fe0826.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01A | Tumor | Primary | Solid Tissue | Unknown |
| ecbd016f-74ce-4a7a-8553-4df9022c76a1 | fd713184-4bb4-4e1b-a3b8-636273ee6ccc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8863b8af-1ec2-4b06-ad68-b918a4c477c5 | 9a5e0fa6-a785-4d8e-bca5-43e02a3965bf.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6f2a3937-7e81-49c1-a734-2be886114e03 | ee030015-242a-4dd1-b43c-2c97d5d365d9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01B | Tumor | Primary | Solid Tissue | FFPE |
| db2e431a-6a7b-4d24-87cb-44d3f3d5accc | 7977a11b-246f-4c4c-a200-ee35d2d51fc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01A | Tumor | Primary | Solid Tissue | Unknown |
| c5ea8088-b64f-4044-9842-fda42633f862 | a0ead79b-f99c-46d1-a092-4cb98291bdcc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01C | Tumor | Primary | Solid Tissue | FFPE |
| ac8491bd-069c-406c-be34-a88858c5f206 | 3369898e-21d8-4ded-8bbc-a746b1a743ad.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01A | Tumor | Primary | Solid Tissue | Unknown |
| bbb6f3d1-ee72-41fa-bd2a-48bb2818f68a | c6dd2eb6-2297-4dc0-8cae-c7a6b733a1c2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5066 | TCGA-50-5066-01A | Tumor | Primary | Solid Tissue | Unknown |
| f5105dfe-d0e4-4392-994e-c3f8ec3d66b5 | ad3180d3-8ae4-4446-9292-dd0c464b03c9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5066 | TCGA-50-5066-02A | Tumor | Recurrence | Solid Tissue | Unknown |
| a7af780d-280e-45e0-bc5f-f6d791adfa4f | 1f71e82c-0781-4d19-bc26-6c3c176827c5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5946 | TCGA-50-5946-02A | Tumor | Recurrence | Solid Tissue | Unknown |
| 832227fd-b159-475f-a787-bd5661406164 | c36d8349-6af1-4583-818d-cd3742ea97a7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5946 | TCGA-50-5946-01A | Tumor | Primary | Solid Tissue | Unknown |

Create bam manifest

``` r
gdc_sample_sheet_renamed_for_bam_manifest <- gdc_sample_sheet_renamed %>%
  mutate(tcga_id = paste(sample_id, file_id),
         file_location = paste0("/mnt/data/tcga/", file_id, "/", file_name),
         feature1 = lc_no_space(preservation_method),
         feature2 = lc_no_space(specimen_type))
  
gdc_sample_sheet_renamed_for_bam_manifest %>%
  select(tcga_id,
         file_location,
         feature1,
         feature2) %>%
  write_tsv(paste0("bam_manifest.tcga.", 
                   nrow(gdc_sample_sheet_renamed_for_bam_manifest), 
                   "_bam_files.tsv"),
            col_names = FALSE)
```

sync with luad_s34f_wt_manifest.tsv

``` r
luad_u2af1_s34f_wt_manifest <- read_tsv(here("2025-05_tcga_luad_sig_from_bam/luad_u2af1_s34f_wt_manifest.tsv"),
                                        col_names = c("id", "mutation"))
```

    Rows: 532 Columns: 2
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (2): id, mutation

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
gdc_sample_sheet_renamed_with_mutations <- 
  gdc_sample_sheet_renamed %>%
  mutate(mutation_match_code = str_remove(file_name, ".rna_seq.genomic.gdc_realn.bam")) %>%
  left_join(luad_u2af1_s34f_wt_manifest,
            by=c("mutation_match_code" = "id")) 

gdc_sample_sheet_renamed_with_mutations %>%
  tabyl(mutation)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| mutation   |   n |   percent | valid_percent |
|:-----------|----:|----------:|--------------:|
| u2af1-s34f |  12 | 0.0221811 |     0.0225989 |
| u2af1-wt   | 519 | 0.9593346 |     0.9774011 |
| NA         |  10 | 0.0184843 |            NA |

``` r
gdc_sample_sheet_renamed_with_mutations %>%
  filter(is.na(mutation))
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| file_id | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method | mutation_match_code | mutation |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| a3127d56-8b47-4fa7-954b-86929db5e982 | bd84bab3-4614-4806-bfd1-dab3fca9d6fa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8585 | TCGA-86-8585-01A | Tumor | Primary | Solid Tissue | Unknown | bd84bab3-4614-4806-bfd1-dab3fca9d6fa | NA |
| 8ebd4c54-1436-4756-a82e-4628b53586da | cbfa6fea-3a77-4d0f-ab15-12307d08055a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-7027 | TCGA-75-7027-01A | Tumor | Primary | Unknown | Unknown | cbfa6fea-3a77-4d0f-ab15-12307d08055a | NA |
| aab35043-7ce8-4237-a732-45df7920a9a4 | 9aba4243-1817-4f5f-8e9d-66da98229246.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown | 9aba4243-1817-4f5f-8e9d-66da98229246 | NA |
| b0157ada-d3cb-4cf3-aceb-40e6d4beb267 | d34f0d3c-a058-4569-a8c8-380ada182e76.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6978 | TCGA-55-6978-01A | Tumor | Primary | Unknown | Unknown | d34f0d3c-a058-4569-a8c8-380ada182e76 | NA |
| 09ebf058-809e-4ebf-91e5-78f1a99a6cbb | d6662ab3-af1a-4e7e-a907-111e4241713b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8092 | TCGA-55-8092-01A | Tumor | Primary | Solid Tissue | Unknown | d6662ab3-af1a-4e7e-a907-111e4241713b | NA |
| 4d6609e2-6ad0-43a1-9bda-fbc4710e1da0 | ebf8d429-0437-4987-9bca-89e62910f168.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7158 | TCGA-78-7158-01A | Tumor | Primary | Solid Tissue | Unknown | ebf8d429-0437-4987-9bca-89e62910f168 | NA |
| a6f82885-da83-49d5-ad43-966b9dff4ea5 | c6acc762-3909-4cc0-91c7-f66bc3f0e667.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4507 | TCGA-49-4507-01A | Tumor | Primary | Unknown | Unknown | c6acc762-3909-4cc0-91c7-f66bc3f0e667 | NA |
| e08d0c44-9834-43b8-b518-6882e36a1bb0 | 9f030a01-eef7-4885-8edc-316fe88860d7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7159 | TCGA-78-7159-01A | Tumor | Primary | Solid Tissue | Unknown | 9f030a01-eef7-4885-8edc-316fe88860d7 | NA |
| 217e75fb-00de-4fe4-9ecb-88cf17da83a6 | 25212f64-8017-4b93-b171-10a830558566.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8090 | TCGA-55-8090-01A | Tumor | Primary | Solid Tissue | Unknown | 25212f64-8017-4b93-b171-10a830558566 | NA |
| 73c368dd-99db-4e34-a02f-fdff478a491c | af649713-fb41-496a-a94b-3691d202c1c8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown | af649713-fb41-496a-a94b-3691d202c1c8 | NA |

\# select all u2af1-s34f samples

``` r
u2af1_s34f_sample_sheet <- gdc_sample_sheet_renamed_with_mutations %>%
  filter(! is.na(mutation)) %>%
  filter(mutation == "u2af1-s34f")

nrow(u2af1_s34f_sample_sheet)
```

    [1] 12

``` r
length(unique(u2af1_s34f_sample_sheet$case_id))
```

    [1] 12

``` r
cat (u2af1_s34f_sample_sheet$file_id)
```

    33c16d35-96da-4400-9f48-1fc7567e30a4 16b44441-90d4-4289-8248-d31251f49f2b 9eeae6b9-2031-47fa-80db-e04d53f0bfbd 3dbc67a1-c49d-407c-867b-dc453f3aebc0 99c213ba-55b9-42b6-9546-62b8d3f6c284 6f343aec-65e1-44ad-b4db-339d4ed62373 63da5a36-0ec0-4d89-be9d-7319f0eae8ed 0ebf5cc5-f242-45ef-821a-939b51dc95a2 eae099b8-7486-42dc-9565-c875662eb729 e161311b-eb34-42fd-b906-d0b4cfb7c15a aa7245fd-7073-4ff9-88cc-648a2c9f1f60 86c05b02-68d0-473d-8aea-ab501cb40d29

new manifest

\# Exclude samples without mutation info randomly select duplicates
include all u2af1-s34f samples check if u2af1 mutation status disagrees
in publication

``` r
set.seed(124343)
u2af1_wt_samples_one_per_case <- gdc_sample_sheet_renamed_with_mutations %>%
  filter(! is.na(mutation)) %>%
  filter(preservation_method == "Unknown",
         tumor_descriptor == "Primary",
         mutation != "u2af1-s34f") %>%
  group_by(case_id) %>%
   slice_sample(n=1)
```

``` r
gdc_manifest_50_samples <- read_tsv(here("2025-05_tcga_luad_sig_from_bam/gdc_manifest.50_samples.2025-05-22.132704.txt"))
```

    Rows: 49 Columns: 5
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (4): id, filename, md5, state
    dbl (1): size

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
new_u2af1_wt_samples_one_per_case <- u2af1_wt_samples_one_per_case %>%
  filter(! file_id %in% gdc_manifest_50_samples$id)

set.seed(124343)
u2af1_wt_samples_for_batch2 <- new_u2af1_wt_samples_one_per_case %>%
  ungroup %>%
  slice_sample(n=(50-12))
```

next 50

``` r
batch2_manifest <- gdc_manifest %>%
  filter(id %in% 
           c(u2af1_s34f_sample_sheet$file_id,
             u2af1_wt_samples_for_batch2$file_id))

batch2_manifest %>%
  write_tsv(here("2025-05_tcga_luad_sig_from_bam/gdc_manifest.50_samples.batch2.2025-05-28.txt"))
```

# show OCT samples

``` r
gdc_sample_sheet_renamed_with_mutations %>% 
  filter(preservation_method == "OCT", 
           file_id %in% batch2_manifest$id)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| file_id | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method | mutation_match_code | mutation |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 9eeae6b9-2031-47fa-80db-e04d53f0bfbd | 39807893-979e-44c6-ada9-444c68b863c3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T4 | TCGA-MP-A4T4-01A | Tumor | Primary | Solid Tissue | OCT | 39807893-979e-44c6-ada9-444c68b863c3 | u2af1-s34f |

``` r
# this is the sample that wasn't detected when i repeated the analysis with train/test datasets
# TCGA-55-7727-01A_86c05b02-68d0-473d-8aea-ab501cb40d29

gdc_sample_sheet_renamed_with_mutations %>%
  filter(str_detect(case_id, "TCGA-55-7727"))
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| file_id | file_name | data_category | data_type | project_id | case_id | sample_id | tissue_type | tumor_descriptor | specimen_type | preservation_method | mutation_match_code | mutation |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 86c05b02-68d0-473d-8aea-ab501cb40d29 | 59e8b7b7-5183-4655-aa5e-e4b5ba73eded.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7727 | TCGA-55-7727-01A | Tumor | Primary | Solid Tissue | Unknown | 59e8b7b7-5183-4655-aa5e-e4b5ba73eded | u2af1-s34f |
