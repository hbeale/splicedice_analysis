# 2026 05 28-analyze-manifest-from-soulette 2023.rmarkdown
Holly Beale
2026-05-28

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
LUAD_soulette <- read_tsv("LUAD_601_RNA_summary_Final495SamplesForAnalysis.tsv")  %>%
  mutate(sample_id_key = str_extract(barcode, "^TCGA-\\w+-\\w+-\\w+"))
```

    Rows: 495 Columns: 27
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (23): study, barcode, disease, disease_name, sample_type, analyte_type, ...
    dbl  (2): sample_type_name, files_size
    lgl  (2): sample_accession, reason

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
head(LUAD_soulette)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| study | barcode | disease | disease_name | sample_type | sample_type_name | analyte_type | library_type | center | center_name | platform | platform_name | assembly | filename | files_size | checksum | analysis_id | aliquot_id | participant_id | sample_id | tss_id | sample_accession | published | uploaded | modified | state | reason | sample_id_key |
|:---|:---|:---|:---|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| TCGA | TCGA-05-4244-01A-01R-1107-07 | LUAD | Lung adenocarcinoma | TP | 1 | RNA | RNA-Seq | UNC-LCCC | UNC-LCCC | ILLUMINA | Illumina | HG19 | UNCID_1209060.e6a101b9-61f9-4ed1-a59f-d9db3fdb4555.sorted_genome_alignments.bam | 9339790525 | bd02f629519c5a611a14b1d21b1dc5a5 | 931374db-a463-4c8e-9373-98cafa77f1bf | e6a101b9-61f9-4ed1-a59f-d9db3fdb4555 | 34040b83-7e8a-4264-a551-b16621843e28 | bac0b02d-ac3b-4784-b8bf-180eadd548a3 | 5 | NA | 7/18/2012 | 7/18/2012 | 5/16/2013 | Live | NA | TCGA-05-4244-01A |
| TCGA | TCGA-05-4249-01A-01R-1107-07 | LUAD | Lung adenocarcinoma | TP | 1 | RNA | RNA-Seq | UNC-LCCC | UNC-LCCC | ILLUMINA | Illumina | HG19 | UNCID_1209022.d1a8d88d-1708-4959-9695-6f2e67853bd5.sorted_genome_alignments.bam | 8829979512 | f3d6efae06ee6953168a12d6ecf4ab73 | 8864cd77-9d71-4f1b-b5fd-16e9821d9c6f | d1a8d88d-1708-4959-9695-6f2e67853bd5 | 4addf05f-3668-4b3f-a17f-c0227329ca52 | 80f196fe-1eaf-40cb-ab58-c84795acc5c7 | 5 | NA | 7/18/2012 | 7/18/2012 | 5/16/2013 | Live | NA | TCGA-05-4249-01A |
| TCGA | TCGA-05-4250-01A-01R-1107-07 | LUAD | Lung adenocarcinoma | TP | 1 | RNA | RNA-Seq | UNC-LCCC | UNC-LCCC | ILLUMINA | Illumina | HG19 | UNCID_1207973.bba9333a-09f7-4585-b22e-e4ae4049f7da.sorted_genome_alignments.bam | 8292363790 | 77bb2bd9863722911923a00905e7d035 | cd12922f-084c-4dfe-b4a5-96e9bee50de3 | bba9333a-09f7-4585-b22e-e4ae4049f7da | f98ecd8a-b878-4f53-b911-20cd8e17281c | 8f274178-7a8e-46b6-8d2c-900338bbb946 | 5 | NA | 7/18/2012 | 7/18/2012 | 5/16/2013 | Live | NA | TCGA-05-4250-01A |
| TCGA | TCGA-05-4382-01A-01R-1206-07 | LUAD | Lung adenocarcinoma | TP | 1 | RNA | RNA-Seq | UNC-LCCC | UNC-LCCC | ILLUMINA | Illumina | HG19 | UNCID_1468373.e4177b01-6898-4bb7-b38d-0c09f85c5668.sorted_genome_alignments.bam | 11548665999 | fafa3e56770ccb97585e5ab5c868eed8 | 39b72260-9126-4439-b619-b62a18e3230b | e4177b01-6898-4bb7-b38d-0c09f85c5668 | 3434b91a-c05f-460f-a078-7b1bb6e7085d | cce6d71f-369e-467f-bd7e-03d20e97b7f3 | 5 | NA | 8/16/2012 | 8/16/2012 | 5/16/2013 | Live | NA | TCGA-05-4382-01A |
| TCGA | TCGA-05-4384-01A-01R-1755-07 | LUAD | Lung adenocarcinoma | TP | 1 | RNA | RNA-Seq | UNC-LCCC | UNC-LCCC | ILLUMINA | Illumina | HG19 | UNCID_1466313.7d6cf896-b04a-431a-a192-aaf540eeaf77.sorted_genome_alignments.bam | 3722996099 | d778a30d3f60b4ed06bdbac9e98a6c44 | 10530826-f797-4c9f-9b2f-285456caddff | 7d6cf896-b04a-431a-a192-aaf540eeaf77 | 9a50e7e4-831d-489f-87d2-979e987561cc | e4416303-50b0-4316-bfee-030c7b29fac6 | 5 | NA | 8/16/2012 | 8/16/2012 | 5/16/2013 | Live | NA | TCGA-05-4384-01A |
| TCGA | TCGA-05-4389-01A-01R-1206-07 | LUAD | Lung adenocarcinoma | TP | 1 | RNA | RNA-Seq | UNC-LCCC | UNC-LCCC | ILLUMINA | Illumina | HG19 | UNCID_1466857.a588764f-f972-4d3a-b8f8-d0209fc7d2a1.sorted_genome_alignments.bam | 6834724678 | cafd3a3259929d1b5add775fd786a6c7 | 5b65f819-573f-4efe-afb8-5fbbb8a4ec3a | a588764f-f972-4d3a-b8f8-d0209fc7d2a1 | a3de401d-91fe-49a2-bb07-81c1a06506e6 | ed61ac6a-f21f-4b88-928a-029340d4aebd | 5 | NA | 8/16/2012 | 8/16/2012 | 5/16/2013 | Live | NA | TCGA-05-4389-01A |

``` r
nrow(LUAD_soulette)
```

    [1] 495

``` r
gdc_sample_sheet <- read_tsv("gdc_sample_sheet.2026-05-28.tsv")
```

    Rows: 542 Columns: 11
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (11): File ID, File Name, Data Category, Data Type, Project ID, Case ID,...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
gdc_manifest <- read_tsv("gdc_manifest.2026-05-28.131615.txt")
```

    Rows: 542 Columns: 5
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (4): id, filename, md5, state
    dbl (1): size

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
nrow(gdc_sample_sheet)
```

    [1] 542

``` r
nrow(gdc_manifest)
```

    [1] 542

``` r
gdc_sample_sheet_renamed <- gdc_sample_sheet %>% clean_names() 
```

# Compare manifest and sample sheet contents

``` r
identical(gdc_sample_sheet_renamed$file_id, gdc_manifest$id)
```

    [1] TRUE

``` r
n_distinct(gdc_sample_sheet_renamed$file_id)
```

    [1] 542

They are the same

# review sample features

``` r
n_unique <- function(x) length(unique(x))

unique_sample_vals <- LUAD_soulette %>%
  summarize(across(everything(),  n_unique)) %>%
  pivot_longer(everything())

unique_sample_vals %>%
  filter(! value == 1,
         ! value == nrow(LUAD_soulette))
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| name      | value |
|:----------|------:|
| tss_id    |    33 |
| published |    40 |
| uploaded  |    26 |
| modified  |    19 |

## What are multi-value columns?

Notes: anything with “1” or 541 is uninteresting

``` r
LUAD_soulette %>%
  select(unique_sample_vals %>% 
           filter(value > min(value),
                  value < max(value)) %>%
           pull(name)) %>%
  apply(2, table)
```

    $tss_id

    35 38 44 49 4B  5 50 53 55 62 64 67 69 71 73 75 78 80 83 86 91 93 95 97 99 J2 
     4 11 44 27  1 32 31  4 87 15 12  8 14  1 11 16 32  3  1 33 16  7 12 25  6  5 
    L4 L9 MN MP NJ O1 S2 
     1  6  3 16  9  1  1 

    $published

     1/18/2014 10/17/2012 11/10/2014 11/11/2014 11/12/2012 11/12/2014 11/13/2012 
            11         38         13          6         49          1          2 
     11/6/2013  11/7/2013  11/9/2012   2/1/2015  4/19/2013  4/20/2013   5/1/2012 
            19          1          2          3         14         22          3 
     5/23/2012  5/24/2012  5/25/2012   5/6/2012   5/7/2012   5/8/2012  6/18/2012 
             8          9          2          7         18         46          2 
     6/19/2013  6/21/2012  6/21/2013  6/22/2012  6/22/2013  6/23/2013  6/24/2013 
             2          1         19          1          3          7          6 
     6/25/2013  6/27/2013  6/28/2013   6/6/2012   6/8/2012   6/9/2012  7/18/2012 
             1          3          9          1         47         51         27 
     8/16/2012  8/30/2013  8/31/2013  9/25/2012   9/3/2013 
             8          6         11         13          3 

    $uploaded

     1/18/2014 10/17/2012 11/10/2014 11/11/2014 11/12/2012  11/6/2013  11/7/2013 
            11         38         13          7         49         19          1 
     11/9/2012   2/1/2015  4/19/2013  4/20/2013   5/1/2012   5/6/2012   5/7/2012 
             2          3         16         20          3          7         19 
      5/8/2012  6/18/2013  6/23/2013  6/27/2013  6/28/2013   6/8/2012   6/9/2012 
            67         25         17          3          5         50         50 
     7/18/2012  8/16/2012  8/30/2013  8/31/2013  9/25/2012 
            28          9          9         11         13 

    $modified

     1/18/2014 11/10/2014 11/11/2014 11/12/2014  11/6/2013  11/7/2013   2/1/2015 
            11         13          6          1         19          1          3 
     5/16/2013  6/19/2013  6/21/2013  6/22/2013  6/23/2013  6/24/2013  6/25/2013 
           371          2         19          3          7          6          1 
     6/27/2013  6/28/2013  8/30/2013  8/31/2013   9/3/2013 
             3          9          6         11          3 

``` r
# head(LUAD_soulette$reason)
# head(LUAD_soulette$state)
```

``` r
# Count occurrences of each sample_id_key
LUAD_soulette %>%
  count(sample_id_key, name = "n_rows") %>%
  filter(n_rows > 1) %>%
  arrange(desc(n_rows))
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| sample_id_key | n_rows |
|:--------------|-------:|

``` r
joined_data <- left_join(LUAD_soulette, gdc_sample_sheet_renamed,
          by=c("sample_id_key"="sample_id")) 

# are any LUAD_soulette samples missing from the sample sheet?
# if no, there will be 0 rows in the following
joined_data %>% filter(is.na(file_id))
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| study | barcode | disease | disease_name | sample_type | sample_type_name | analyte_type | library_type | center | center_name | platform | platform_name | assembly | filename | files_size | checksum | analysis_id | aliquot_id | participant_id | sample_id | tss_id | sample_accession | published | uploaded | modified | state | reason | sample_id_key | file_id | file_name | data_category | data_type | project_id | case_id | tissue_type | tumor_descriptor | specimen_type | preservation_method |
|:---|:---|:---|:---|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|

``` r
dupe_ids <- joined_data %>%
  filter(duplicated(sample_id_key)) %>%
  pull(sample_id_key)

joined_data %>%
  filter(sample_id_key %in% dupe_ids ) %>%
  select(LUAD_soulette_barcode=barcode,
         gdc_sample_id = sample_id) %>%
 # distinct() %>%
  arrange(LUAD_soulette_barcode)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| LUAD_soulette_barcode        | gdc_sample_id                        |
|:-----------------------------|:-------------------------------------|
| TCGA-44-2656-01A-02R-A278-07 | 5593f581-3d45-4a4a-a525-bfae1f4753a0 |
| TCGA-44-2656-01A-02R-A278-07 | 5593f581-3d45-4a4a-a525-bfae1f4753a0 |
| TCGA-44-2662-01A-01R-A278-07 | d2198941-e96f-40bd-9fbe-82886217d5db |
| TCGA-44-2662-01A-01R-A278-07 | d2198941-e96f-40bd-9fbe-82886217d5db |
| TCGA-44-2665-01A-01R-A278-07 | a0863fa6-515c-44fa-825f-f9e243f945f1 |
| TCGA-44-2665-01A-01R-A278-07 | a0863fa6-515c-44fa-825f-f9e243f945f1 |
| TCGA-44-2666-01A-01R-A278-07 | 27a64f32-69c5-4c49-86b4-c8fc923cae08 |
| TCGA-44-2666-01A-01R-A278-07 | 27a64f32-69c5-4c49-86b4-c8fc923cae08 |
| TCGA-44-2668-01A-01R-A278-07 | dd9a6c68-b8b4-4168-9ff9-72a45f20c44f |
| TCGA-44-2668-01A-01R-A278-07 | dd9a6c68-b8b4-4168-9ff9-72a45f20c44f |
| TCGA-44-3918-01A-01R-A278-07 | 2ff8bafd-2ac5-4bfd-8c60-81519cd44166 |
| TCGA-44-3918-01A-01R-A278-07 | 2ff8bafd-2ac5-4bfd-8c60-81519cd44166 |
| TCGA-44-4112-01A-01R-A278-07 | 6c206676-e511-4281-91f5-bfe91b3279a4 |
| TCGA-44-4112-01A-01R-A278-07 | 6c206676-e511-4281-91f5-bfe91b3279a4 |
| TCGA-44-5645-01A-01R-A278-07 | 37a8d3a5-baa0-427c-ab43-48ae4b93633b |
| TCGA-44-5645-01A-01R-A278-07 | 37a8d3a5-baa0-427c-ab43-48ae4b93633b |
| TCGA-44-6146-01A-11R-A278-07 | ad66185f-983d-4416-b705-25d3d4d8b5a5 |
| TCGA-44-6146-01A-11R-A278-07 | ad66185f-983d-4416-b705-25d3d4d8b5a5 |
| TCGA-44-6147-01A-11R-A278-07 | 43f5270a-f2f2-4dd9-83b5-486b805e35b8 |
| TCGA-44-6147-01A-11R-A278-07 | 43f5270a-f2f2-4dd9-83b5-486b805e35b8 |
| TCGA-44-6775-01A-11R-A278-07 | 7c606f64-69a1-465c-9f4e-2eb1ebeda5d7 |
| TCGA-44-6775-01A-11R-A278-07 | 7c606f64-69a1-465c-9f4e-2eb1ebeda5d7 |

# format

colnames in manifest should be id filename md5 size state

Find differences in gdc data between samples with the same barcode

``` r
all_data_for_one_barcode <- joined_data %>%
  filter(barcode == "TCGA-44-2656-01A-02R-A278-07") %>%
  mutate(across(everything(), as.character)) %>%
  pivot_longer(-file_id) %>%
  pivot_wider (names_from = "file_id") 

all_data_for_one_barcode
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| name | b2cf0b26-1f46-478d-b2e1-73115384ed57 | b5310007-7004-4306-8629-4c5a61219971 |
|:---|:---|:---|
| study | TCGA | TCGA |
| barcode | TCGA-44-2656-01A-02R-A278-07 | TCGA-44-2656-01A-02R-A278-07 |
| disease | LUAD | LUAD |
| disease_name | Lung adenocarcinoma | Lung adenocarcinoma |
| sample_type | TP | TP |
| sample_type_name | 1 | 1 |
| analyte_type | RNA | RNA |
| library_type | RNA-Seq | RNA-Seq |
| center | UNC-LCCC | UNC-LCCC |
| center_name | UNC-LCCC | UNC-LCCC |
| platform | ILLUMINA | ILLUMINA |
| platform_name | Illumina | Illumina |
| assembly | HG19 | HG19 |
| filename | UNCID_2275363.bdb0340d-da29-440a-8f4e-7d1fac2d59ac.sorted_genome_alignments.bam | UNCID_2275363.bdb0340d-da29-440a-8f4e-7d1fac2d59ac.sorted_genome_alignments.bam |
| files_size | 8454837626 | 8454837626 |
| checksum | d0397b7d0012b1e4cce1ca289bfadd68 | d0397b7d0012b1e4cce1ca289bfadd68 |
| analysis_id | 903a6ace-457c-47a9-9bde-d5deb82c531c | 903a6ace-457c-47a9-9bde-d5deb82c531c |
| aliquot_id | bdb0340d-da29-440a-8f4e-7d1fac2d59ac | bdb0340d-da29-440a-8f4e-7d1fac2d59ac |
| participant_id | 42ca54fc-c1ae-41cd-bca1-7fe9810db460 | 42ca54fc-c1ae-41cd-bca1-7fe9810db460 |
| sample_id | 5593f581-3d45-4a4a-a525-bfae1f4753a0 | 5593f581-3d45-4a4a-a525-bfae1f4753a0 |
| tss_id | 44 | 44 |
| sample_accession | NA | NA |
| published | 1/18/2014 | 1/18/2014 |
| uploaded | 1/18/2014 | 1/18/2014 |
| modified | 1/18/2014 | 1/18/2014 |
| state | Live | Live |
| reason | NA | NA |
| sample_id_key | TCGA-44-2656-01A | TCGA-44-2656-01A |
| file_name | b307f8c5-d21f-42ae-9771-07126d58999e.rna_seq.genomic.gdc_realn.bam | b556d35a-4855-4e56-9e02-5fc939722169.rna_seq.genomic.gdc_realn.bam |
| data_category | Sequencing Reads | Sequencing Reads |
| data_type | Aligned Reads | Aligned Reads |
| project_id | TCGA-LUAD | TCGA-LUAD |
| case_id | TCGA-44-2656 | TCGA-44-2656 |
| tissue_type | Tumor | Tumor |
| tumor_descriptor | Primary | Primary |
| specimen_type | Solid Tissue | Solid Tissue |
| preservation_method | Unknown | Unknown |

``` r
all_data_for_one_barcode %>%
  filter(`b2cf0b26-1f46-478d-b2e1-73115384ed57` != `b5310007-7004-4306-8629-4c5a61219971`)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| name | b2cf0b26-1f46-478d-b2e1-73115384ed57 | b5310007-7004-4306-8629-4c5a61219971 |
|:---|:---|:---|
| file_name | b307f8c5-d21f-42ae-9771-07126d58999e.rna_seq.genomic.gdc_realn.bam | b556d35a-4855-4e56-9e02-5fc939722169.rna_seq.genomic.gdc_realn.bam |

``` r
# 
# joined_data %>%
#   select(id, filename, md5, size, state)
# 
# joined_data %>%
#   filter(barcode == "TCGA-44-2656-01A-02R-A278-07") %>%
#   distinct()
```

there is no apparent difference besides file_id and file_name. the file
sizes are identical

decision: pick at random

# pick at random

``` r
set.seed(1)

data_for_new_manifest <- joined_data %>%
  group_by(barcode) %>%
  slice_sample(n=1)
  
nrow(data_for_new_manifest)
```

    [1] 495

propogate to manifest

``` r
soulette_equivalent_manifest <- gdc_manifest %>%
  filter(filename %in% data_for_new_manifest$file_name)
```

``` r
write_tsv(soulette_equivalent_manifest, "soulette_equivalent_manifest.2026.05.28.tsv")
```
