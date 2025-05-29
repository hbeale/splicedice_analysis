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
batches_1_and_2_bed_manifest_with_gt_distinct
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
| TCGA-91-6836-01A_09c0af14-a98f-4939-a132-9efcb4c2bc57 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/186b7ed8-cc25-45b6-bf7d-25d7a3a2154a.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 186b7ed8-cc25-45b6-bf7d-25d7a3a2154a | u2af1-wt |
| TCGA-44-3398-01A_347924ac-b049-4a8b-a298-ba3a246f58e9 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/1890feb6-9f7f-4437-9828-198ff43e16b0.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 1890feb6-9f7f-4437-9828-198ff43e16b0 | u2af1-wt |
| TCGA-67-3770-01A_f6284fb5-ab14-41a5-8d4f-63bde0394bfc | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/1da64d9f-f5dd-4017-bf82-d1a61512b56b.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 1da64d9f-f5dd-4017-bf82-d1a61512b56b | u2af1-wt |
| TCGA-62-8397-01A_b7dfe7a7-b569-4532-bc55-02665f4979e1 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/21a80f43-21be-4549-901b-c99083021c30.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 21a80f43-21be-4549-901b-c99083021c30 | u2af1-wt |
| TCGA-55-7576-01A_190ab37d-58fc-4f14-b02c-3eaac5a89260 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/25a6fe1b-0472-489f-a721-f596395badb1.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 25a6fe1b-0472-489f-a721-f596395badb1 | u2af1-wt |
| TCGA-50-6592-01A_2528b21b-8145-4c2c-b946-dae173928f7c | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/27266d85-3f2c-489f-9e5d-663d94ae9f55.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 27266d85-3f2c-489f-9e5d-663d94ae9f55 | u2af1-wt |
| TCGA-97-8547-01A_9f9b1a22-8bf8-4a2b-8d5d-dcc84271519d | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/2beab6d3-563d-421f-bf4a-7e1f843ec637.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 2beab6d3-563d-421f-bf4a-7e1f843ec637 | u2af1-wt |
| TCGA-86-6851-01A_788ecc45-ea2c-4197-9537-02016cfe14d3 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/32248a54-89ad-43a3-aa20-1c1897cb0054.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 32248a54-89ad-43a3-aa20-1c1897cb0054 | u2af1-wt |
| TCGA-44-2659-01A_704d42ab-3e11-4c3b-a74c-b1e6a30e27c5 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/325c7d6b-292d-46e5-85d1-785ae8a48c33.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 325c7d6b-292d-46e5-85d1-785ae8a48c33 | u2af1-wt |
| TCGA-44-A47G-01A_7c8cde36-afef-49e3-a389-6aa07fdf0d88 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/32675d71-6f79-4b8f-ab7c-e2350b15875c.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 32675d71-6f79-4b8f-ab7c-e2350b15875c | u2af1-wt |
| TCGA-49-4505-01A_0ebf5cc5-f242-45ef-821a-939b51dc95a2 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/330845b9-1d53-47af-8cb7-30ce5d30625d.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 330845b9-1d53-47af-8cb7-30ce5d30625d | u2af1-s34f |
| TCGA-MP-A4T4-01A_9eeae6b9-2031-47fa-80db-e04d53f0bfbd | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/39807893-979e-44c6-ada9-444c68b863c3.rna_seq.genomic.gdc_realn.junc.bed | oct | solid_tissue | 39807893-979e-44c6-ada9-444c68b863c3 | u2af1-s34f |
| TCGA-05-4395-01A_4d85514e-171d-46e4-b6db-43b4f8ff2eb0 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/3f7a9aee-2d10-4426-855b-de9a48b278ce.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 3f7a9aee-2d10-4426-855b-de9a48b278ce | u2af1-wt |
| TCGA-55-6543-01A_5fa0513c-3de7-4d3b-9df0-83f2df36b947 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/4102816c-2ab8-4ecb-83b0-4f78c052bcd8.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 4102816c-2ab8-4ecb-83b0-4f78c052bcd8 | u2af1-wt |
| TCGA-64-5781-01A_61005b7e-d7ad-4573-af9b-d9f33ce3c300 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/484f0a13-a636-484b-9880-5066955dee6e.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 484f0a13-a636-484b-9880-5066955dee6e | u2af1-wt |
| TCGA-97-8177-01A_39360ea0-c687-4856-bd05-bcde98012898 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/4b6c958a-7e20-4b88-b30a-2406b123c8c1.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 4b6c958a-7e20-4b88-b30a-2406b123c8c1 | u2af1-wt |
| TCGA-64-5815-01A_5fc71d41-3824-4649-9179-386bb566533c | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/4f721842-9460-4376-b577-59c3731f34a6.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 4f721842-9460-4376-b577-59c3731f34a6 | u2af1-wt |
| TCGA-86-8075-01A_0c633b9e-3303-4625-b59d-02102d8bf981 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/5158a031-b856-4423-9418-031b3107e88f.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 5158a031-b856-4423-9418-031b3107e88f | u2af1-wt |
| TCGA-05-4405-01A_35b18dab-9047-431b-b01b-1888d995d5dd | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/52b34ef3-a814-4aa9-a395-6beea6a71f11.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 52b34ef3-a814-4aa9-a395-6beea6a71f11 | u2af1-wt |
| TCGA-97-7941-01A_d816341b-dd8f-458a-b945-fd716c11c8c0 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/56c858be-3637-4ba0-81be-208a3edac992.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 56c858be-3637-4ba0-81be-208a3edac992 | u2af1-wt |
| TCGA-05-4396-01A_d1945e55-eaa9-41f3-8017-380ccd112dfc | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/59a0b90e-8b8b-41b8-95f0-d51961a94be5.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 59a0b90e-8b8b-41b8-95f0-d51961a94be5 | u2af1-wt |
| TCGA-55-7727-01A_86c05b02-68d0-473d-8aea-ab501cb40d29 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/59e8b7b7-5183-4655-aa5e-e4b5ba73eded.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 59e8b7b7-5183-4655-aa5e-e4b5ba73eded | u2af1-s34f |
| TCGA-78-8648-01A_9988cad6-0f42-4112-975c-814bfc3e91c3 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/5d843590-36a7-4568-88a4-2bc09e14927f.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 5d843590-36a7-4568-88a4-2bc09e14927f | u2af1-wt |
| TCGA-95-7948-01A_3498e816-9bf1-41ab-a662-206a78a32e2b | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/5eef868d-7c7f-42e8-aabf-ce3f75405c7a.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 5eef868d-7c7f-42e8-aabf-ce3f75405c7a | u2af1-wt |
| TCGA-05-5420-01A_216b822e-0d33-476f-ba03-18ff818f8a78 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/5fd9d2a8-3a95-440c-a0de-8ad5fd86e156.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 5fd9d2a8-3a95-440c-a0de-8ad5fd86e156 | u2af1-wt |
| TCGA-49-6744-01A_33c16d35-96da-4400-9f48-1fc7567e30a4 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/6efebff1-f165-415e-9001-45a782638785.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 6efebff1-f165-415e-9001-45a782638785 | u2af1-s34f |
| TCGA-64-5779-01A_46acba46-d33c-458b-b3cf-a9ba60ea32fb | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/73559b1e-ad93-432f-a7bb-c3946d4120d4.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 73559b1e-ad93-432f-a7bb-c3946d4120d4 | u2af1-wt |
| TCGA-67-3773-01A_a7834ece-39e1-4d47-a316-ae285a473c86 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/75eaaf2c-7cd9-416d-88c0-7c5502db9ab5.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 75eaaf2c-7cd9-416d-88c0-7c5502db9ab5 | u2af1-wt |
| TCGA-67-6215-01A_0a26152a-462f-4895-8fe8-15fcdcc56e16 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 7a7440bf-1ca1-4c6b-80f8-7151a38e5d18 | u2af1-wt |
| TCGA-50-5941-01A_aa7245fd-7073-4ff9-88cc-648a2c9f1f60 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/7b07706f-a1b4-4f18-a276-0822b578cc40.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 7b07706f-a1b4-4f18-a276-0822b578cc40 | u2af1-s34f |
| TCGA-L9-A444-01A_b14f167e-72ec-432e-a374-6d9472eca448 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/841e54a1-9d65-4256-b70e-eb64659b40a4.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 841e54a1-9d65-4256-b70e-eb64659b40a4 | u2af1-wt |
| TCGA-05-4402-01A_2a73ab35-41bc-48ca-910c-b562f830aeb3 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/882d1be3-1f82-41e7-8538-1ef513efef32.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 882d1be3-1f82-41e7-8538-1ef513efef32 | u2af1-wt |
| TCGA-64-1680-01A_16b44441-90d4-4289-8248-d31251f49f2b | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/8b3aec43-4c75-4598-bf0a-168f7ffb9f3b.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 8b3aec43-4c75-4598-bf0a-168f7ffb9f3b | u2af1-s34f |
| TCGA-97-8176-01A_8031c488-856a-4e1e-93f1-57e672e34d8d | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/8fa3359f-1e40-448a-aae8-a955c1ca3323.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 8fa3359f-1e40-448a-aae8-a955c1ca3323 | u2af1-wt |
| TCGA-38-4625-01A_a35d80d8-8b94-4f66-b408-bbe19f3edd54 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/9301f86d-9d6f-4aa6-a640-a543b5aea5db.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 9301f86d-9d6f-4aa6-a640-a543b5aea5db | u2af1-wt |
| TCGA-78-7149-01A_593cca0d-6f1f-447e-be54-24c4a6ad73c0 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/93f32fe3-cb5b-4910-bf06-e20c876cd8a5.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 93f32fe3-cb5b-4910-bf06-e20c876cd8a5 | u2af1-wt |
| TCGA-78-7155-01A_d0d763a9-856c-452b-9989-a72894b32326 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/962d56c6-0e10-4b55-9c4d-dbb89c983d74.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 962d56c6-0e10-4b55-9c4d-dbb89c983d74 | u2af1-wt |
| TCGA-75-5147-01A_4fc71e83-8aab-449f-807a-db5d6eb21ab9 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/99c5c1c4-851a-42a4-b5a2-dd9da2959343.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 99c5c1c4-851a-42a4-b5a2-dd9da2959343 | u2af1-wt |
| TCGA-86-8280-01A_4699cd8b-a11f-4151-a2ed-0618a476800b | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/9aa5eb7d-1d54-47f6-aeeb-59be4880f004.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 9aa5eb7d-1d54-47f6-aeeb-59be4880f004 | u2af1-wt |
| TCGA-55-5899-01A_d289975b-8b9c-43be-91ec-10ebd401937f | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/9ba0ff4b-4276-45ee-a543-a2e837777923.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 9ba0ff4b-4276-45ee-a543-a2e837777923 | u2af1-wt |
| TCGA-38-4626-01A_6c30992d-b469-4e80-965e-d7643b176f81 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/9bfd464b-419a-43c0-929a-c1d219713a6f.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 9bfd464b-419a-43c0-929a-c1d219713a6f | u2af1-wt |
| TCGA-38-4629-01A_45600709-c917-42ef-bc2f-229e6f3c71af | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/9ebc079c-069f-4468-8b9e-680e39a3c4ad.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | 9ebc079c-069f-4468-8b9e-680e39a3c4ad | u2af1-wt |
| TCGA-91-7771-01A_8459ed46-071c-42f6-ab9d-1a16424c8921 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/9f4c2cc8-8675-43be-98bb-004c45ba5a51.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 9f4c2cc8-8675-43be-98bb-004c45ba5a51 | u2af1-wt |
| TCGA-55-8207-01A_9e841128-e372-44dc-ada0-72be76782a2c | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/9f938aa7-9fc1-4893-aee4-15ab668b9260.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | 9f938aa7-9fc1-4893-aee4-15ab668b9260 | u2af1-wt |
| TCGA-44-7659-01A_20592e25-4b12-4cd3-b1b1-b8e8d6352960 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/a0c9ebdf-951b-4d8d-aa79-3ff1c82342cd.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | a0c9ebdf-951b-4d8d-aa79-3ff1c82342cd | u2af1-wt |
| TCGA-55-8512-01A_f148c5ad-0710-4a88-9303-f83f6b07d5da | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/a4f3f3fa-b161-402b-bc1a-1dddd6be8097.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | a4f3f3fa-b161-402b-bc1a-1dddd6be8097 | u2af1-wt |
| TCGA-75-6212-01A_5b319617-99a9-4bde-b962-93cc3cac6b77 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/a787801a-cb3f-4a1f-b14c-ed8f2bfd6028.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | a787801a-cb3f-4a1f-b14c-ed8f2bfd6028 | u2af1-wt |
| TCGA-97-7552-01A_810ef019-2069-46ec-903a-a47a2a8211ad | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/a7c58df0-fffc-4a80-85c4-2dab24b2edc2.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | a7c58df0-fffc-4a80-85c4-2dab24b2edc2 | u2af1-wt |
| TCGA-55-A490-01A_62a350a6-9cb3-474b-8eb2-6eec9f6e2904 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/aa764c7d-2e26-4e8c-94d3-870772bad93f.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | aa764c7d-2e26-4e8c-94d3-870772bad93f | u2af1-wt |
| TCGA-44-2657-01A_35a81dbe-bf1e-478c-8a95-d227b4195f34 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/ab589a7b-7cc9-4257-8fd7-241d2e3658da.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | ab589a7b-7cc9-4257-8fd7-241d2e3658da | u2af1-wt |
| TCGA-73-4670-01A_e8f2cdea-1430-43ad-8359-ead8b4c5fd6e | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/aea4fa60-a890-453e-8ba6-6f4f3d5ed084.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | aea4fa60-a890-453e-8ba6-6f4f3d5ed084 | u2af1-wt |
| TCGA-55-8206-01A_e87e6c78-12aa-4bda-8c7e-0c9c7b2cb774 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/aec36454-d9a1-4d51-90c6-561f219b6aee.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | aec36454-d9a1-4d51-90c6-561f219b6aee | u2af1-wt |
| TCGA-38-A44F-01A_dd1d7a21-1235-4934-b0b2-d4d3a5bf35f8 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/aeea81c2-afda-410d-a0bb-955e7cddda09.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | aeea81c2-afda-410d-a0bb-955e7cddda09 | u2af1-wt |
| TCGA-55-6968-01A_40708d9c-1c51-4e7c-9ce2-185ea1480eb2 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/af407c3f-2dad-4fb9-850e-4a79b361589b.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | af407c3f-2dad-4fb9-850e-4a79b361589b | u2af1-wt |
| TCGA-64-5775-01A_039e9a74-2e83-4962-ae9b-23f11d5c5fba | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/b5909b96-7ef6-497a-802e-11805dc7ded7.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | b5909b96-7ef6-497a-802e-11805dc7ded7 | u2af1-wt |
| TCGA-55-8621-01A_2b987ab5-2a04-4046-bd60-cb219c9e74b5 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/b603c2a6-4366-415a-871e-5949a2a8a4b6.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | b603c2a6-4366-415a-871e-5949a2a8a4b6 | u2af1-wt |
| TCGA-55-7903-01A_99c213ba-55b9-42b6-9546-62b8d3f6c284 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/b71b334c-768e-46f6-bc7e-c95a11f44f03.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | b71b334c-768e-46f6-bc7e-c95a11f44f03 | u2af1-s34f |
| TCGA-86-8054-01A_8bd1c6e6-6810-479c-a46f-f3a902296601 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/b8ae4b22-83b8-4cbf-9d3c-49092b7e0903.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | b8ae4b22-83b8-4cbf-9d3c-49092b7e0903 | u2af1-wt |
| TCGA-78-8655-01A_6f343aec-65e1-44ad-b4db-339d4ed62373 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/bc8b6dee-0f79-492f-85e1-c1a09d6f9680.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | bc8b6dee-0f79-492f-85e1-c1a09d6f9680 | u2af1-s34f |
| TCGA-75-5125-01A_2619993d-6b8b-4380-addd-0be8446e299a | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/bcb20e91-2931-4694-8268-686aee414fe7.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | bcb20e91-2931-4694-8268-686aee414fe7 | u2af1-wt |
| TCGA-44-7670-01A_6e90fa77-c338-4e9a-a43b-fa702386db08 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/be547f27-5157-4947-ad2a-c9d006dedabd.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | be547f27-5157-4947-ad2a-c9d006dedabd | u2af1-wt |
| TCGA-44-5643-01A_a26c9cfc-b7cf-4157-8d75-d668602ed4ff | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/c29e5bb3-860d-4f1f-b27d-ae5b9d8c4208.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | c29e5bb3-860d-4f1f-b27d-ae5b9d8c4208 | u2af1-wt |
| TCGA-75-5122-01A_6d2d8cc2-4e19-4e74-97dc-45e6eeec5e1c | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/c649e0cf-b787-4d0c-bab6-d81f7e491b15.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | c649e0cf-b787-4d0c-bab6-d81f7e491b15 | u2af1-wt |
| TCGA-55-8615-01A_b6d50fd3-1810-48d6-aab1-c97f9c29d194 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/c6bf25d8-abea-411f-bb80-6e6fefb82757.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | c6bf25d8-abea-411f-bb80-6e6fefb82757 | u2af1-wt |
| TCGA-69-7763-01A_4b9a61f4-5a9a-462a-ba94-7bc718abac56 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/c8e5ea6c-c6b1-4807-8d9f-b2e96154a1eb.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | c8e5ea6c-c6b1-4807-8d9f-b2e96154a1eb | u2af1-wt |
| TCGA-50-5051-01A_2239f076-6a9e-4aa3-b716-adabbc55d3de | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/cbf298e2-94bb-48c9-ae07-408081055497.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | cbf298e2-94bb-48c9-ae07-408081055497 | u2af1-wt |
| TCGA-91-6829-01A_f3968b44-8997-4be0-ad22-4bd460e5b9d1 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/d21d91e9-6e19-4c5f-aa2e-cdd41d98e542.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | d21d91e9-6e19-4c5f-aa2e-cdd41d98e542 | u2af1-wt |
| TCGA-05-4410-01A_243e1ddf-9b74-42c0-b357-13b302b039f9 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/d3c861af-cfe9-4d9f-bc76-a8a45b72df43.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | d3c861af-cfe9-4d9f-bc76-a8a45b72df43 | u2af1-wt |
| TCGA-80-5611-01A_c116d279-6f22-40c9-9521-d5e36af646e5 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/d5388d2a-976f-4f08-80c2-14bbf4ccc753.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | d5388d2a-976f-4f08-80c2-14bbf4ccc753 | u2af1-wt |
| TCGA-50-8460-01A_3dbc67a1-c49d-407c-867b-dc453f3aebc0 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/d94a4acc-1345-4cdb-b1e0-0b9c1afc593c.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | d94a4acc-1345-4cdb-b1e0-0b9c1afc593c | u2af1-s34f |
| TCGA-55-A48Z-01A_f9a5ba92-d9d1-409b-91ba-2bfb209c295d | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/da046621-2982-42dc-b54d-6c875ecb5368.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | da046621-2982-42dc-b54d-6c875ecb5368 | u2af1-wt |
| TCGA-95-7947-01A_d596b2b1-0915-41c2-b35c-b343f59b8923 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/da3718fb-d874-4469-a3fe-6ba6fa89676b.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | da3718fb-d874-4469-a3fe-6ba6fa89676b | u2af1-wt |
| TCGA-78-7145-01A_eae099b8-7486-42dc-9565-c875662eb729 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/db3c11b8-53c7-48f8-a16c-b86c1c7534b0.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | db3c11b8-53c7-48f8-a16c-b86c1c7534b0 | u2af1-s34f |
| TCGA-55-6985-01A_2a600a38-215c-4b2b-9b9d-ab5d3b9a0bbc | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/dc3ac0d3-d862-4761-ac12-60bb4d6758c1.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | dc3ac0d3-d862-4761-ac12-60bb4d6758c1 | u2af1-wt |
| TCGA-99-8033-01A_dad25a07-fb2a-42d0-95b6-b072afbdaa7c | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/e0dabde8-1dd8-4aa6-9f23-51dc22fc2cae.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | e0dabde8-1dd8-4aa6-9f23-51dc22fc2cae | u2af1-wt |
| TCGA-L4-A4E6-01A_1eafc7d3-4753-45e1-82c3-d819f9571404 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/e4fe566f-bf64-408e-a422-fef7b855391f.rna_seq.genomic.gdc_realn.junc.bed | oct | unknown | e4fe566f-bf64-408e-a422-fef7b855391f | u2af1-wt |
| TCGA-44-5644-01A_0a34988b-4886-4852-9b03-7915c44a0647 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/e89ecf81-4892-48c8-be13-926f92d5ec97.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | e89ecf81-4892-48c8-be13-926f92d5ec97 | u2af1-wt |
| TCGA-95-7039-01A_7c1bff62-84a9-446d-b5dc-bf92cfe6c58e | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/e9efd91b-8824-456b-b650-1d0287efbbe8.rna_seq.genomic.gdc_realn.junc.bed | unknown | unknown | e9efd91b-8824-456b-b650-1d0287efbbe8 | u2af1-wt |
| TCGA-64-1677-01A_b1182c5c-410c-41c3-b454-0dfa28bcaa6a | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/ed30ab10-5d65-4aeb-ba72-ec3e9b768cd3.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | ed30ab10-5d65-4aeb-ba72-ec3e9b768cd3 | u2af1-wt |
| TCGA-75-5146-01A_a8393e91-f334-4d1f-b13b-8008cf163fd0 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/ed4e21ee-1471-479e-af75-72c91986787a.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | ed4e21ee-1471-479e-af75-72c91986787a | u2af1-wt |
| TCGA-62-A46P-01A_fda585d3-a881-4831-8dd4-e391fc9d6e7c | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/ef19e097-8ae9-4362-b77a-76d8f5399760.rna_seq.genomic.gdc_realn.junc.bed | oct | unknown | ef19e097-8ae9-4362-b77a-76d8f5399760 | u2af1-wt |
| TCGA-55-8203-01A_7edd3c0d-516d-4b81-bdc1-8ca8997a8bff | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/f07f72e3-8bd8-4a16-91b4-e4444c2745d9.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | f07f72e3-8bd8-4a16-91b4-e4444c2745d9 | u2af1-wt |
| TCGA-55-7725-01A_44a3eb8c-135f-44f4-82bd-86fb6104a4e8 | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/f3d482bb-14e8-4569-bee4-22d7d2a027ea.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | f3d482bb-14e8-4569-bee4-22d7d2a027ea | u2af1-wt |
| TCGA-55-1595-01A_63da5a36-0ec0-4d89-be9d-7319f0eae8ed | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/f8cc4515-2576-4a72-9cf1-28dfe774eda9.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | f8cc4515-2576-4a72-9cf1-28dfe774eda9 | u2af1-s34f |
| TCGA-50-6590-01A_105ad832-c4e7-4622-8469-c558f5911bbf | /mnt/output/splicedice_2025.05.28_16.35.55/\_junction_beds/fbb4d953-39c3-4e94-a99c-a8927421709e.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | fbb4d953-39c3-4e94-a99c-a8927421709e | u2af1-wt |
| TCGA-50-5932-01A_98754b25-9c39-4830-b260-2d92b28f2e7a | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/fe3a5a49-7744-4336-a4b6-0e88f23e21d8.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | fe3a5a49-7744-4336-a4b6-0e88f23e21d8 | u2af1-wt |
| TCGA-55-7573-01A_9b179934-f54d-4256-84bd-3e516685a119 | /mnt/output/splicedice_2025.05.29_17.33.38/\_junction_beds/ff298d6f-071c-417a-acbe-a9ff38494f87.rna_seq.genomic.gdc_realn.junc.bed | unknown | solid_tissue | ff298d6f-071c-417a-acbe-a9ff38494f87 | u2af1-wt |

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

gdc_sample_sheet_renamed
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
| f6284fb5-ab14-41a5-8d4f-63bde0394bfc | 1da64d9f-f5dd-4017-bf82-d1a61512b56b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-3770 | TCGA-67-3770-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8459ed46-071c-42f6-ab9d-1a16424c8921 | 9f4c2cc8-8675-43be-98bb-004c45ba5a51.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-7771 | TCGA-91-7771-01A | Tumor | Primary | Solid Tissue | Unknown |
| c916f887-6e77-4fc6-a692-30375d28650f | 06c83065-5800-451a-84a7-7a7f352493ec.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7633 | TCGA-78-7633-01A | Tumor | Primary | Solid Tissue | Unknown |
| 243e1ddf-9b74-42c0-b357-13b302b039f9 | d3c861af-cfe9-4d9f-bc76-a8a45b72df43.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4410 | TCGA-05-4410-01A | Tumor | Primary | Solid Tissue | Unknown |
| b1182c5c-410c-41c3-b454-0dfa28bcaa6a | ed30ab10-5d65-4aeb-ba72-ec3e9b768cd3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-1677 | TCGA-64-1677-01A | Tumor | Primary | Solid Tissue | Unknown |
| a0755929-e85a-4ea8-a7bd-3413bd734c75 | 0e3e11b9-9f43-4a0d-8665-023fae9f8b00.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-6178 | TCGA-38-6178-01A | Tumor | Primary | Solid Tissue | Unknown |
| 35b18dab-9047-431b-b01b-1888d995d5dd | 52b34ef3-a814-4aa9-a395-6beea6a71f11.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4405 | TCGA-05-4405-01A | Tumor | Primary | Solid Tissue | Unknown |
| 09c0af14-a98f-4939-a132-9efcb4c2bc57 | 186b7ed8-cc25-45b6-bf7d-25d7a3a2154a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6836 | TCGA-91-6836-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7edd3c0d-516d-4b81-bdc1-8ca8997a8bff | f07f72e3-8bd8-4a16-91b4-e4444c2745d9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8203 | TCGA-55-8203-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2b987ab5-2a04-4046-bd60-cb219c9e74b5 | b603c2a6-4366-415a-871e-5949a2a8a4b6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8621 | TCGA-55-8621-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9e841128-e372-44dc-ada0-72be76782a2c | 9f938aa7-9fc1-4893-aee4-15ab668b9260.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8207 | TCGA-55-8207-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2239f076-6a9e-4aa3-b716-adabbc55d3de | cbf298e2-94bb-48c9-ae07-408081055497.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5051 | TCGA-50-5051-01A | Tumor | Primary | Solid Tissue | Unknown |
| ae528992-720c-4818-ac5e-8e1b0509f9d9 | 0a4e0b83-7afa-475b-8586-e9e79e31d6d2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A471 | TCGA-62-A471-01A | Tumor | Primary | Unknown | OCT |
| 2a73ab35-41bc-48ca-910c-b562f830aeb3 | 882d1be3-1f82-41e7-8538-1ef513efef32.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4402 | TCGA-05-4402-01A | Tumor | Primary | Unknown | Unknown |
| a7834ece-39e1-4d47-a316-ae285a473c86 | 75eaaf2c-7cd9-416d-88c0-7c5502db9ab5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-3773 | TCGA-67-3773-01A | Tumor | Primary | Solid Tissue | Unknown |
| 788ecc45-ea2c-4197-9537-02016cfe14d3 | 32248a54-89ad-43a3-aa20-1c1897cb0054.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-6851 | TCGA-86-6851-01A | Tumor | Primary | Unknown | Unknown |
| a124f52b-3a64-4642-ba61-9307ac5cb3bc | 146a69db-f304-4dd3-97e2-4d11b6512069.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3917 | TCGA-44-3917-01A | Tumor | Primary | Unknown | Unknown |
| 039e9a74-2e83-4962-ae9b-23f11d5c5fba | b5909b96-7ef6-497a-802e-11805dc7ded7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-5775 | TCGA-64-5775-01A | Tumor | Primary | Solid Tissue | Unknown |
| 190ab37d-58fc-4f14-b02c-3eaac5a89260 | 25a6fe1b-0472-489f-a721-f596395badb1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7576 | TCGA-55-7576-01A | Tumor | Primary | Solid Tissue | Unknown |
| b6d50fd3-1810-48d6-aab1-c97f9c29d194 | c6bf25d8-abea-411f-bb80-6e6fefb82757.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8615 | TCGA-55-8615-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2528b21b-8145-4c2c-b946-dae173928f7c | 27266d85-3f2c-489f-9e5d-663d94ae9f55.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6592 | TCGA-50-6592-01A | Tumor | Primary | Solid Tissue | Unknown |
| 39360ea0-c687-4856-bd05-bcde98012898 | 4b6c958a-7e20-4b88-b30a-2406b123c8c1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8177 | TCGA-97-8177-01A | Tumor | Primary | Solid Tissue | Unknown |
| fda585d3-a881-4831-8dd4-e391fc9d6e7c | ef19e097-8ae9-4362-b77a-76d8f5399760.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46P | TCGA-62-A46P-01A | Tumor | Primary | Unknown | OCT |
| a35d80d8-8b94-4f66-b408-bbe19f3edd54 | 9301f86d-9d6f-4aa6-a640-a543b5aea5db.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4625 | TCGA-38-4625-01A | Tumor | Primary | Unknown | Unknown |
| 8bd1c6e6-6810-479c-a46f-f3a902296601 | b8ae4b22-83b8-4cbf-9d3c-49092b7e0903.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8054 | TCGA-86-8054-01A | Tumor | Primary | Solid Tissue | Unknown |
| 105ad832-c4e7-4622-8469-c558f5911bbf | fbb4d953-39c3-4e94-a99c-a8927421709e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6590 | TCGA-50-6590-01A | Tumor | Primary | Solid Tissue | Unknown |
| f3968b44-8997-4be0-ad22-4bd460e5b9d1 | d21d91e9-6e19-4c5f-aa2e-cdd41d98e542.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6829 | TCGA-91-6829-01A | Tumor | Primary | Solid Tissue | Unknown |
| 33c16d35-96da-4400-9f48-1fc7567e30a4 | 6efebff1-f165-415e-9001-45a782638785.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-6744 | TCGA-49-6744-01A | Tumor | Primary | Solid Tissue | Unknown |
| f9a5ba92-d9d1-409b-91ba-2bfb209c295d | da046621-2982-42dc-b54d-6c875ecb5368.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A48Z | TCGA-55-A48Z-01A | Tumor | Primary | Unknown | Unknown |
| c116d279-6f22-40c9-9521-d5e36af646e5 | d5388d2a-976f-4f08-80c2-14bbf4ccc753.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-80-5611 | TCGA-80-5611-01A | Tumor | Primary | Solid Tissue | Unknown |
| 46acba46-d33c-458b-b3cf-a9ba60ea32fb | 73559b1e-ad93-432f-a7bb-c3946d4120d4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-5779 | TCGA-64-5779-01A | Tumor | Primary | Solid Tissue | Unknown |
| 16b44441-90d4-4289-8248-d31251f49f2b | 8b3aec43-4c75-4598-bf0a-168f7ffb9f3b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-1680 | TCGA-64-1680-01A | Tumor | Primary | Solid Tissue | Unknown |
| 810ef019-2069-46ec-903a-a47a2a8211ad | a7c58df0-fffc-4a80-85c4-2dab24b2edc2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7552 | TCGA-97-7552-01A | Tumor | Primary | Solid Tissue | Unknown |
| a8393e91-f334-4d1f-b13b-8008cf163fd0 | ed4e21ee-1471-479e-af75-72c91986787a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-5146 | TCGA-75-5146-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0a34988b-4886-4852-9b03-7915c44a0647 | e89ecf81-4892-48c8-be13-926f92d5ec97.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5644 | TCGA-44-5644-01A | Tumor | Primary | Solid Tissue | Unknown |
| f148c5ad-0710-4a88-9303-f83f6b07d5da | a4f3f3fa-b161-402b-bc1a-1dddd6be8097.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8512 | TCGA-55-8512-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2619993d-6b8b-4380-addd-0be8446e299a | bcb20e91-2931-4694-8268-686aee414fe7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-5125 | TCGA-75-5125-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6c30992d-b469-4e80-965e-d7643b176f81 | 9bfd464b-419a-43c0-929a-c1d219713a6f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4626 | TCGA-38-4626-01A | Tumor | Primary | Unknown | Unknown |
| 5b319617-99a9-4bde-b962-93cc3cac6b77 | a787801a-cb3f-4a1f-b14c-ed8f2bfd6028.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6212 | TCGA-75-6212-01A | Tumor | Primary | Solid Tissue | Unknown |
| 1eafc7d3-4753-45e1-82c3-d819f9571404 | e4fe566f-bf64-408e-a422-fef7b855391f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L4-A4E6 | TCGA-L4-A4E6-01A | Tumor | Primary | Unknown | OCT |
| a26c9cfc-b7cf-4157-8d75-d668602ed4ff | c29e5bb3-860d-4f1f-b27d-ae5b9d8c4208.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5643 | TCGA-44-5643-01A | Tumor | Primary | Solid Tissue | Unknown |
| dd1d7a21-1235-4934-b0b2-d4d3a5bf35f8 | aeea81c2-afda-410d-a0bb-955e7cddda09.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-A44F | TCGA-38-A44F-01A | Tumor | Primary | Unknown | Unknown |
| 593cca0d-6f1f-447e-be54-24c4a6ad73c0 | 93f32fe3-cb5b-4910-bf06-e20c876cd8a5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7149 | TCGA-78-7149-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8f30956a-71d4-44ac-936d-2b74b6467f96 | 9207fbc6-99eb-4535-8c02-c8bba5875c1b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6211 | TCGA-75-6211-01A | Tumor | Primary | Solid Tissue | Unknown |
| b70b10f9-633c-48b7-b806-b349e8e9b5f0 | b57cc3e6-9017-48b7-9de9-74fe57d9bf6d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6987 | TCGA-55-6987-01A | Tumor | Primary | Unknown | Unknown |
| 8371c736-df69-4b1b-ba41-b578c902fae1 | 78e95f3e-1067-48a8-9429-dfdd6f587066.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6980 | TCGA-55-6980-01A | Tumor | Primary | Unknown | Unknown |
| 32d1c13c-f1eb-4351-94f4-a6b66ea66ff9 | 9343d3bd-0f60-49c3-8625-31a8a7a846c4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6835 | TCGA-91-6835-01A | Tumor | Primary | Solid Tissue | Unknown |
| a3127d56-8b47-4fa7-954b-86929db5e982 | bd84bab3-4614-4806-bfd1-dab3fca9d6fa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8585 | TCGA-86-8585-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9eeae6b9-2031-47fa-80db-e04d53f0bfbd | 39807893-979e-44c6-ada9-444c68b863c3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T4 | TCGA-MP-A4T4-01A | Tumor | Primary | Solid Tissue | OCT |
| ea802294-a5d3-40c2-8a15-fb9e038cb7db | 5d081953-cf3a-40cb-95bf-f418ed3879ac.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-S2-AA1A | TCGA-S2-AA1A-01A | Tumor | Primary | Solid Tissue | OCT |
| bbb6f3d1-ee72-41fa-bd2a-48bb2818f68a | c6dd2eb6-2297-4dc0-8cae-c7a6b733a1c2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5066 | TCGA-50-5066-01A | Tumor | Primary | Solid Tissue | Unknown |
| f5105dfe-d0e4-4392-994e-c3f8ec3d66b5 | ad3180d3-8ae4-4446-9292-dd0c464b03c9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5066 | TCGA-50-5066-02A | Tumor | Recurrence | Solid Tissue | Unknown |
| 035c43e6-c537-4d6e-b9e3-b263533afd5e | 14797b04-c56a-4ceb-bd0f-a4e785e90f75.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4398 | TCGA-05-4398-01A | Tumor | Primary | Unknown | Unknown |
| 4a92bf9e-4eee-4e3c-b022-db9355df8e23 | 143cbdd4-689e-4ba9-b0ad-069629dc7dfa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M6 | TCGA-97-A4M6-01A | Tumor | Primary | Unknown | OCT |
| 64fd558c-0446-4194-bf00-e30d0e944ccd | 73fc90cb-2b56-4a6b-8083-42f6647a2478.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6214 | TCGA-75-6214-01A | Tumor | Primary | Unknown | Unknown |
| 86fb2618-964b-426b-98d2-d8a54fca7a24 | fb3e2838-b073-40c9-824f-3216f940a2c5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L4-A4E5 | TCGA-L4-A4E5-01A | Tumor | Primary | Unknown | OCT |
| efd28d99-fead-4f7f-a6b4-1ee2e027aab4 | 897e33bc-3862-47bc-8277-a9b1b5371802.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A48X | TCGA-55-A48X-01A | Tumor | Primary | Unknown | Unknown |
| cc28cd2a-e26a-4a4d-b4a3-c063cf1d76c0 | 525e9185-ed15-403d-8987-93c50e4b89a1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6774 | TCGA-44-6774-01A | Tumor | Primary | Solid Tissue | Unknown |
| e760343a-5fc3-4a79-8ad1-3a82cb93acd2 | 3ddd596f-b02f-4b51-a837-3c684437600f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-5423 | TCGA-05-5423-01A | Tumor | Primary | Solid Tissue | Unknown |
| e6be56ed-7a45-471e-9904-758096073e9d | e0e055b6-6800-40e7-bde5-718823408f0c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4244 | TCGA-05-4244-01A | Tumor | Primary | Unknown | Unknown |
| afe6a6d1-000c-4f71-aabe-1bca0def2eae | 8da65700-04c7-444d-826e-ec2e692b257b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M2 | TCGA-97-A4M2-01A | Tumor | Primary | Unknown | OCT |
| 76c75af3-4a0c-47a3-822c-deb4b69ce539 | 0bb88c14-58c0-45d8-a8f3-f41840f62d37.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6777 | TCGA-44-6777-01A | Tumor | Primary | Solid Tissue | Unknown |
| de346e7e-e806-4cb9-89e1-e68315b55021 | 06deab65-ccea-473f-ad0e-7e3928df2e07.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4426 | TCGA-05-4426-01A | Tumor | Primary | Unknown | Unknown |
| 7239640f-ccc9-41f3-9fd9-e81c26125c0f | 5444c7d2-9c7e-4b9e-a8ee-7d64c375be17.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TD | TCGA-MP-A4TD-01A | Tumor | Primary | Solid Tissue | OCT |
| 5f3e279d-7f3b-4634-9d65-8e601f45f0f4 | c55c7a04-580b-43e3-b138-f83bd3003875.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7553 | TCGA-97-7553-01A | Tumor | Primary | Solid Tissue | Unknown |
| 60595998-f42a-43f4-be43-d8cb398eaf3c | a585711d-48a4-45bd-bb45-f9d2a7717af0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A492 | TCGA-55-A492-01A | Tumor | Primary | Unknown | Unknown |
| 6920f7d3-5755-41f5-8227-16327de30ca0 | aae80a97-730b-4180-93de-56ddbb262419.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4430 | TCGA-05-4430-01A | Tumor | Primary | Unknown | Unknown |
| fd97c225-cc46-47cf-9f5c-f92d14dc3fcf | 4ad05e6b-e3d8-4048-8f61-1e79e421de0b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7567 | TCGA-95-7567-01A | Tumor | Primary | Solid Tissue | Unknown |
| d1cbb649-f240-4429-b23d-726788bb425f | 48fdafbf-3f8b-46ba-8aa9-f081f0b54739.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A57B | TCGA-55-A57B-01A | Tumor | Primary | Solid Tissue | Unknown |
| 84c88ecd-cfcc-46c1-bbf5-ae30a3a2b86c | 1f7293ad-85b2-4d42-afcc-88cf1027cf5f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3396 | TCGA-44-3396-01A | Tumor | Primary | Unknown | Unknown |
| 407b7cef-a081-4af8-ac57-3de81d118a58 | 9c92bdc5-8b9b-4843-82a4-2fa6ee4d40a3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4420 | TCGA-05-4420-01A | Tumor | Primary | Unknown | Unknown |
| 6979c494-8d2b-4279-bcdc-125001241a1f | 1a0143ed-cd70-498f-b094-bc71b6921fb3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A4DG | TCGA-55-A4DG-01A | Tumor | Primary | Unknown | Unknown |
| 97f37f9f-c274-4274-8800-326bec538f76 | fc4f0b8e-ced1-4543-a21d-3cbb2d269eb0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-4679 | TCGA-67-4679-01B | Tumor | Primary | Solid Tissue | Unknown |
| f198b7e8-8927-4c8c-99cc-b4802b656324 | 23aeef43-0657-45f1-835e-52a829f0bea2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8506 | TCGA-55-8506-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2f9e6340-2c94-4ff4-a9ca-5bfdcec62dd6 | 9ce317be-70dc-4dd2-86b5-e6f79be6f10b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-O1-A52J | TCGA-O1-A52J-01A | Tumor | Primary | Solid Tissue | OCT |
| fb091d8f-779f-452a-ab0c-ff59cd822483 | 9f97863a-5019-41de-a095-dd20c4d55e02.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01B | Tumor | Primary | Solid Tissue | FFPE |
| b38575e2-47b8-41dc-851a-bb1726d2b9ce | 5f74c5cb-1127-4a5c-975e-58e5abc4db03.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7672 | TCGA-44-7672-01A | Tumor | Primary | Solid Tissue | Unknown |
| c4334889-91a2-421a-8e17-c834fc6f62de | 57048ebe-3153-4e65-bbca-eadb92b99d31.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A4YP | TCGA-NJ-A4YP-01A | Tumor | Primary | Solid Tissue | OCT |
| 9d211e37-9c7e-4773-b306-f08864bbc4d7 | 6545e778-687c-4b82-b6b6-b5d438879069.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7535 | TCGA-78-7535-01A | Tumor | Primary | Solid Tissue | Unknown |
| 567c5d5f-2b27-4070-86c3-3905d06ed02b | f6f15b7f-1af0-4da5-8ca5-a4b488d8f412.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8074 | TCGA-86-8074-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8ebd4c54-1436-4756-a82e-4628b53586da | cbfa6fea-3a77-4d0f-ab15-12307d08055a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-7027 | TCGA-75-7027-01A | Tumor | Primary | Unknown | Unknown |
| b61793ab-cf8a-496c-8306-76aa7d365be2 | 22d87348-bca7-4428-b8e2-2f161d77bcc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-8253 | TCGA-69-8253-01A | Tumor | Primary | Solid Tissue | Unknown |
| e5976aee-2a56-457c-80e5-00824254f6f8 | 461cd8f2-fe53-448d-b6a9-0a95792464c7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8358 | TCGA-86-8358-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6dee9448-b65a-498e-9490-7c282fb3b07d | 593623b6-0f7d-4089-8697-518c573c86c6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8056 | TCGA-86-8056-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2437e6c6-92ca-4bb9-ad5a-989aa17865ea | 7edd63ce-c5bb-4209-b8c8-98af0fae03ed.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AAR9 | TCGA-49-AAR9-01A | Tumor | Primary | Solid Tissue | OCT |
| a0318562-280f-4b8a-8ef9-39857547f3e4 | ff36264d-8485-46e6-8259-0b55f651ed8f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-8497 | TCGA-91-8497-01A | Tumor | Primary | Solid Tissue | Unknown |
| b3c414f8-454c-4a45-8d72-69ed5aafcc11 | 8536c3c1-1e75-4ebc-b792-30d7d228a117.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7669 | TCGA-44-7669-01A | Tumor | Primary | Solid Tissue | Unknown |
| 163fe4e0-202d-4ca9-aeb5-0043042e760f | 60cc41cd-a0af-4cad-a4be-253781e2f0b8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-6761 | TCGA-49-6761-01A | Tumor | Primary | Unknown | Unknown |
| 1f8160a9-4e65-4d8f-a83d-39b6e03b38f3 | f6108b9b-e02f-4608-bec3-bcc0112d05b4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AARO | TCGA-49-AARO-01A | Tumor | Primary | Solid Tissue | OCT |
| 073e7f71-5583-48fc-a037-4f799ec2d811 | 6200626d-556e-400d-81f4-e397ce49585f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-8499 | TCGA-91-8499-01A | Tumor | Primary | Solid Tissue | Unknown |
| c508b0d9-0d3c-4737-b19b-34752dfe3cbc | ef11ddff-02bb-44e2-ab77-fadde20acd87.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7227 | TCGA-55-7227-01A | Tumor | Primary | Solid Tissue | Unknown |
| 755e3d1a-38f8-4ae3-91b2-1da34dc5c404 | 256e320c-e4de-4918-b3bc-b71657bfd4cc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7953 | TCGA-86-7953-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6a2e92aa-b57f-4e1d-b61f-1162472fe62a | fdd9f9f1-8b02-4b83-a8f6-f28f968bdf54.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7816 | TCGA-55-7816-01A | Tumor | Primary | Solid Tissue | Unknown |
| af2f19ca-dc08-43b6-ae40-811cb952887a | b573a788-d117-48b0-9cab-c4ecbde82706.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6983 | TCGA-55-6983-01A | Tumor | Primary | Unknown | Unknown |
| 9aefd391-6b46-40aa-96a3-b81b96b68bd9 | aefc9460-27d4-4d7f-8167-baa2a80935b7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-7031 | TCGA-75-7031-01A | Tumor | Primary | Unknown | Unknown |
| 0fd61331-8363-402b-8d87-88bb39f467d0 | 534541e5-89a2-46bc-98d3-1fed57d6e4c1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46Y | TCGA-62-A46Y-01A | Tumor | Primary | Unknown | OCT |
| 0bd949c3-479b-4fec-a3e3-83a0e0f437a0 | 6804af50-1b4f-4872-83b8-bae24d398cb4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A7SV | TCGA-L9-A7SV-01A | Tumor | Primary | Solid Tissue | Unknown |
| 75fe49d9-5526-43dd-8e6b-9929d72bf761 | 57d89d75-a9bb-4bd3-af76-d29def9a9625.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8620 | TCGA-55-8620-01A | Tumor | Primary | Solid Tissue | Unknown |
| b3cb85eb-5102-4af1-9633-d16b75fd80ad | 0ba8665b-be52-4288-838a-8f5d189f809d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AAR3 | TCGA-49-AAR3-01A | Tumor | Primary | Solid Tissue | OCT |
| 5ef1801d-6587-4782-ba2e-5d13d23dca3a | ee14c1ac-fa18-4be1-b836-a1274abafe28.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6207 | TCGA-75-6207-01A | Tumor | Primary | Solid Tissue | Unknown |
| b5ec48f2-021b-439d-95f0-5b467727b469 | 3b286ed4-51bd-4a1e-9eab-b0ee9adf3b72.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-80-5608 | TCGA-80-5608-01A | Tumor | Primary | Unknown | Unknown |
| a5280c09-2f78-4fd5-9ec3-8888fac58178 | 07c5dadf-e801-4c1f-9109-7a2495407c75.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M5 | TCGA-97-A4M5-01A | Tumor | Primary | Unknown | OCT |
| a5b878f4-5fe7-4f53-a61f-d653d435b24c | a6a6b9c6-9db7-42b3-a09f-770b7e126fbb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-35-5375 | TCGA-35-5375-01A | Tumor | Primary | Solid Tissue | Unknown |
| 98491bfe-757d-4255-9d4e-3ab4473b92ef | 07c8891d-1917-45f8-bd1d-4c59d1baafaa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6830 | TCGA-91-6830-01A | Tumor | Primary | Unknown | Unknown |
| 93c69bd1-3426-4475-a59a-b5f6c25222b1 | 20cddb4c-1ad4-4f0e-bd5e-3071f573b2d0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7547 | TCGA-97-7547-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4ea72757-c15b-4c9d-9279-35fe484ad03d | 3e5fa22c-f02a-4da4-881c-6aa2869058c1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8281 | TCGA-86-8281-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6f00af19-888a-4b18-bafc-571ce343fae5 | df2ac75d-208d-4cc1-867b-aea3e36117c6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6145 | TCGA-44-6145-01A | Tumor | Primary | Solid Tissue | Unknown |
| 48a9f86c-daca-482e-9649-92969280844d | e0e9a0df-7052-4d42-b3fd-10ee23ceae62.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-A4P8 | TCGA-86-A4P8-01A | Tumor | Primary | Unknown | OCT |
| aa4ab9d9-dd7d-4667-9a97-cdbf33231c12 | 894424ab-29c3-4f41-88e7-f59d0df10c28.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4425 | TCGA-05-4425-01A | Tumor | Primary | Solid Tissue | Unknown |
| f6c015e7-77ce-4f83-bcaa-ae7e2446bb75 | b6ddcda9-dad4-4e70-b12a-db197a496713.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-7025 | TCGA-75-7025-01A | Tumor | Primary | Unknown | Unknown |
| e42d956e-d8fc-489f-adc7-de9dd6e069c3 | d0f1d923-1014-4a12-824b-9939fd75f9b1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-6767 | TCGA-49-6767-01A | Tumor | Primary | Solid Tissue | Unknown |
| 674b9bdd-c5e2-4539-802c-734f69b58097 | 49ab8f1a-6252-47b0-9f16-63e065f33efd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-3772 | TCGA-67-3772-01A | Tumor | Primary | Solid Tissue | Unknown |
| 5ac9189f-8764-4095-9313-e6a115b88720 | e9f19ff2-29c5-4578-9c23-9d58c192ff59.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-35-4123 | TCGA-35-4123-01A | Tumor | Primary | Unknown | Unknown |
| 2f7e20ee-2db9-4ec9-a39c-d4735654b857 | 1ca692e6-1dff-4d84-ace1-671bac7b9f61.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01B | Tumor | Primary | Unknown | FFPE |
| 384ffb41-7d1f-4125-8c6b-670e5163ff65 | ce68bb71-4052-499c-bf2e-81d9c0dafc9b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4397 | TCGA-05-4397-01A | Tumor | Primary | Unknown | Unknown |
| 1e197fa0-d91c-4faa-bc27-806a1500bafd | 758b1a4d-bd46-4611-b8c3-49c5f62a2dab.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01B | Tumor | Primary | Unknown | FFPE |
| aab35043-7ce8-4237-a732-45df7920a9a4 | 9aba4243-1817-4f5f-8e9d-66da98229246.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown |
| 995183b8-de28-4e1b-a06e-d5e0e448d851 | 3c6fdcc9-916b-4ec2-be58-1dd15e7d94a2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T9 | TCGA-MP-A4T9-01A | Tumor | Primary | Unknown | OCT |
| 06a7cb83-03c8-4ac4-b7c1-a037951c289c | f3bf4152-5e1d-42d2-920e-9dfbe2e0dbc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-4112 | TCGA-44-4112-01A | Tumor | Primary | Unknown | Unknown |
| 214071c5-0658-4106-9e95-0f16b29d4f9c | 6078603d-a4e2-4a1a-abca-01fb63106888.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MN-A4N1 | TCGA-MN-A4N1-01A | Tumor | Primary | Unknown | OCT |
| 61e0dde3-81f9-4c62-8dc3-a338e368678f | d7339ba2-0cc2-40b7-9dbe-f8f3366b20d9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4SV | TCGA-MP-A4SV-01A | Tumor | Primary | Unknown | OCT |
| 6d2d8cc2-4e19-4e74-97dc-45e6eeec5e1c | c649e0cf-b787-4d0c-bab6-d81f7e491b15.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-5122 | TCGA-75-5122-01A | Tumor | Primary | Solid Tissue | Unknown |
| 168678cb-22de-4ac3-8610-3d1a110c2c3a | f01d4b93-8aeb-4b87-a063-59d7b6057fba.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-8394 | TCGA-62-8394-01A | Tumor | Primary | Solid Tissue | Unknown |
| 14214c45-8108-41cd-b07d-e020e8436f7b | eaaacefc-a798-4b6e-8471-0fde96a80bb9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7761 | TCGA-69-7761-01A | Tumor | Primary | Solid Tissue | Unknown |
| b2926c07-53fd-43ca-a2e3-70c4d6f62bb0 | ecef82f6-3009-4345-a56d-d028535d78fd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-53-A4EZ | TCGA-53-A4EZ-01A | Tumor | Primary | Unknown | OCT |
| 9475f7c5-a6cb-4a6c-ba29-a7e6e118555b | d737cd97-619a-4fc3-9ae2-87e1f4b19beb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-A479 | TCGA-44-A479-01A | Tumor | Primary | Unknown | Unknown |
| c915194a-3127-4879-8605-8abfa260c1f9 | 01ebdef8-920f-4b71-8b44-512598962d6b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-99-8032 | TCGA-99-8032-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8ded18c5-1cc7-448d-9dbf-03af338540be | 828b6221-7b05-4e5f-aee0-0234f06fb81e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TF | TCGA-MP-A4TF-01A | Tumor | Primary | Solid Tissue | OCT |
| 2ae7be19-5b29-40e7-a29a-2628baabbbec | b99ff949-1922-4948-8d02-2ef2aa3dfb3b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-7109 | TCGA-50-7109-01A | Tumor | Primary | Solid Tissue | Unknown |
| 41c72749-b512-4930-9ad1-9fd59c8f90c5 | 35fc369e-6f16-415b-badb-380eedb2157b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7161 | TCGA-78-7161-01A | Tumor | Primary | Solid Tissue | Unknown |
| 98a3ce8c-390c-4b97-ad78-75df8ba027ad | db66be89-fb7c-41c3-9a0b-9beae75b7850.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-8120 | TCGA-44-8120-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0c633b9e-3303-4625-b59d-02102d8bf981 | 5158a031-b856-4423-9418-031b3107e88f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8075 | TCGA-86-8075-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6af364e8-9ee5-4df5-81b8-fd857fa3a8b8 | 72fe0e80-b3e6-4249-8345-fb9ff8d2ca9b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7760 | TCGA-69-7760-01A | Tumor | Primary | Solid Tissue | Unknown |
| 752e2830-5ed6-46de-81ba-37296ff1c5c8 | 41fde338-9254-4ad2-9806-d7864c2d038e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4SY | TCGA-MP-A4SY-01A | Tumor | Primary | Unknown | OCT |
| b7dfe7a7-b569-4532-bc55-02665f4979e1 | 21a80f43-21be-4549-901b-c99083021c30.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-8397 | TCGA-62-8397-01A | Tumor | Primary | Solid Tissue | Unknown |
| 73898db7-1015-4a90-a6b8-3fb68d9a9287 | e1b67311-dee7-4296-ac38-1ad47a80c257.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A8F4 | TCGA-L9-A8F4-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7b270022-0fac-48e2-a638-d5c688759508 | fe770b01-42c9-48c6-97f8-09f18a374350.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-A47B | TCGA-44-A47B-01A | Tumor | Primary | Unknown | Unknown |
| c305888e-9034-4185-8c8f-a96dade09e5f | 6460f151-7102-476d-b03b-fb4ea776b1ea.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AARN | TCGA-49-AARN-01A | Tumor | Primary | Solid Tissue | OCT |
| 7daf316a-d528-4b2d-a798-9cc0964e1efb | 5241ced4-4a72-40dc-9698-a647fb6d03a4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-99-8028 | TCGA-99-8028-01A | Tumor | Primary | Solid Tissue | Unknown |
| d08541a3-3815-48c5-b428-8e4423f3f531 | 905e32cb-a5bd-46a4-ac0f-32585e042695.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6847 | TCGA-91-6847-01A | Tumor | Primary | Unknown | Unknown |
| 30b73dff-6c83-45f4-935b-0f844ff9fdd7 | 6f6bf240-1ca4-47d0-9a77-17b0ce9b8ae7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-1592 | TCGA-55-1592-01A | Tumor | Primary | Solid Tissue | Unknown |
| 22efea62-586e-4e47-acf5-d5839a8ef7fc | 96f7dff7-660b-4700-88b3-6479ad02f20c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-1594 | TCGA-55-1594-01A | Tumor | Primary | Solid Tissue | Unknown |
| d8d37032-63f4-4522-8d6a-538bc28d7f83 | 34774d7b-1184-4b5f-b6a9-e16c428ca7ce.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8076 | TCGA-86-8076-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8df71bad-7348-472d-b40c-acc25c9b69cf | e5ff9d44-3193-4baa-bf04-c86563d3c9a9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8619 | TCGA-55-8619-01A | Tumor | Primary | Solid Tissue | Unknown |
| ecbd016f-74ce-4a7a-8553-4df9022c76a1 | fd713184-4bb4-4e1b-a3b8-636273ee6ccc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01A | Tumor | Primary | Solid Tissue | Unknown |
| 49c80597-6cd3-4d54-9115-5776d1c44c3a | 673621c0-f5d4-4eea-a0ae-469214a70e82.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7166 | TCGA-78-7166-01A | Tumor | Primary | Solid Tissue | Unknown |
| 29e5c4a5-3659-44c1-8609-82af113494e0 | f48a9d85-c3c7-40bc-9215-760ba3b8fa60.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4631 | TCGA-38-4631-01A | Tumor | Primary | Solid Tissue | Unknown |
| e07910d4-2c76-45e4-9792-d129cffb8ae4 | 555b77b9-d686-4f0e-a099-25bd5715a5e9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6597 | TCGA-50-6597-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3498e816-9bf1-41ab-a662-206a78a32e2b | 5eef868d-7c7f-42e8-aabf-ce3f75405c7a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7948 | TCGA-95-7948-01A | Tumor | Primary | Solid Tissue | Unknown |
| 09fae186-f274-486a-bb36-48c6dc310f90 | f602ef77-0db5-47af-b259-e551c77a4281.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7661 | TCGA-44-7661-01A | Tumor | Primary | Solid Tissue | Unknown |
| d596b2b1-0915-41c2-b35c-b343f59b8923 | da3718fb-d874-4469-a3fe-6ba6fa89676b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7947 | TCGA-95-7947-01A | Tumor | Primary | Solid Tissue | Unknown |
| 66a70381-99bc-4e27-a767-58a86923df1c | 73babed8-f934-42c7-9020-30f7c3e1766d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5935 | TCGA-50-5935-01A | Tumor | Primary | Solid Tissue | Unknown |
| 061e1a72-d225-46b3-ae7b-8233a4f3bb20 | fbd81adc-aa56-4cde-b1f2-e749e2cbf653.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A7XG | TCGA-NJ-A7XG-01A | Tumor | Primary | Solid Tissue | OCT |
| 01e9e2f2-ac97-4eca-85df-3105bb82436c | 0b55cf48-41ca-4d54-a6c6-fa15c711370b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3917 | TCGA-44-3917-01B | Tumor | Primary | Unknown | FFPE |
| b69fd32e-204e-4cd7-86a0-8ed9f718fdf7 | e38af20a-f4f2-40dc-82c0-69782f9192d7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4677 | TCGA-73-4677-01A | Tumor | Primary | Unknown | Unknown |
| 63d7c243-d996-46f8-84eb-865786c7e785 | 3d006e45-8ebf-4ba1-b003-13b711c0d0ee.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7540 | TCGA-78-7540-01A | Tumor | Primary | Solid Tissue | Unknown |
| 86ecbd9c-8ec7-4f1e-8b42-7877d740e45e | fe69fb9c-7215-478c-ae5c-44f5d0814b9d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-J2-A4AD | TCGA-J2-A4AD-01A | Tumor | Primary | Unknown | OCT |
| eaf48a69-792e-41e4-9b44-09e440e5d6d6 | d0966b4b-6c70-41f6-a220-4bf8be955366.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7954 | TCGA-86-7954-01A | Tumor | Primary | Solid Tissue | Unknown |
| f48cbb38-ea5f-4ba8-afa1-fadca5e5f29a | 96780e00-b519-4bec-a49b-c2cc2d19a744.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6981 | TCGA-55-6981-01A | Tumor | Primary | Unknown | Unknown |
| 16fa65aa-c53d-4b96-9c08-3c9bb47803a8 | 74aaf5e2-be23-49b1-b694-3a3dde306a5d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7284 | TCGA-55-7284-01B | Tumor | Primary | Solid Tissue | Unknown |
| ff8f8a84-4294-477d-9744-cfde221acf51 | c4115468-0566-49e2-a86f-9c7faf6388f5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7955 | TCGA-86-7955-01A | Tumor | Primary | Solid Tissue | Unknown |
| ebc9dad8-ac5c-42bd-8db0-5ef8fea67d41 | 40386f32-719d-480f-9ba7-57e1eea23b30.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-A4BD | TCGA-91-A4BD-01A | Tumor | Primary | Unknown | Unknown |
| 71bb6ca3-70cf-4d10-a19a-6464e4f890a3 | d53203c7-5070-455b-aec3-ce01f32186de.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-3771 | TCGA-67-3771-01A | Tumor | Primary | Solid Tissue | Unknown |
| 1336795f-b302-4d41-83f0-ce7a26a0d6c9 | 14aca23b-01ce-4532-8f2f-3b22b05a4757.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8089 | TCGA-55-8089-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9d190c84-7368-412f-a790-69b2afab246b | 4772e349-a753-4c41-9c48-ae3af0f58520.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A48Y | TCGA-55-A48Y-01A | Tumor | Primary | Unknown | Unknown |
| 8031c488-856a-4e1e-93f1-57e672e34d8d | 8fa3359f-1e40-448a-aae8-a955c1ca3323.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8176 | TCGA-97-8176-01A | Tumor | Primary | Solid Tissue | Unknown |
| af96ed22-dd83-44d7-8e4a-1c3f2a707af9 | 131c0149-e810-4004-97e0-6c8a4aa9049d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8179 | TCGA-97-8179-01A | Tumor | Primary | Solid Tissue | Unknown |
| eda8a001-f7cc-44c7-9c27-8f058609b7f2 | c9d8385a-9f73-48f9-bca4-1c0647881bfd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5931 | TCGA-50-5931-01A | Tumor | Primary | Solid Tissue | Unknown |
| 1c0c1b78-5622-4da2-a6ce-d00c37c51915 | 68f5d95d-e7ae-46d3-b836-e741fde98f23.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4662 | TCGA-73-4662-01A | Tumor | Primary | Unknown | Unknown |
| 3c2ce652-b88f-42d4-862b-ad4e610ae8eb | a9a12604-5100-4e45-b7f8-7e7c0d02a139.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7162 | TCGA-78-7162-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4ee7ff21-a0ae-4885-92d2-a088d6f87cf0 | 2f8abb88-ae9f-4315-bcad-4263862bd11b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-8660 | TCGA-78-8660-01A | Tumor | Primary | Solid Tissue | Unknown |
| f8f19de4-93cd-449d-9759-351783ef05c7 | 6531e137-3d23-44e7-af10-51e9cc517192.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-8662 | TCGA-78-8662-01A | Tumor | Primary | Solid Tissue | Unknown |
| c952cca9-ecf1-47fc-9739-dabe8a7fa08b | df3e51ff-63ad-45c2-ba71-676c5eb6b9e0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MN-A4N5 | TCGA-MN-A4N5-01A | Tumor | Primary | Unknown | OCT |
| b0157ada-d3cb-4cf3-aceb-40e6d4beb267 | d34f0d3c-a058-4569-a8c8-380ada182e76.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6978 | TCGA-55-6978-01A | Tumor | Primary | Unknown | Unknown |
| ff6bb07a-a6d7-4784-8472-db50c5646be4 | 12da2172-3304-4dad-bd80-3039e6d49de3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-J2-8192 | TCGA-J2-8192-01A | Tumor | Primary | Solid Tissue | Unknown |
| b04867b9-f339-45b0-a706-85e098baeca2 | 0326e97a-2ec7-4038-98f3-03d94962d869.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7546 | TCGA-97-7546-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4b9a61f4-5a9a-462a-ba94-7bc718abac56 | c8e5ea6c-c6b1-4807-8d9f-b2e96154a1eb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7763 | TCGA-69-7763-01A | Tumor | Primary | Solid Tissue | Unknown |
| a0eb61ec-37f7-4489-a119-7d30a8c8e498 | 73d96384-ebea-4467-8663-ada78336233c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7911 | TCGA-55-7911-01A | Tumor | Primary | Solid Tissue | Unknown |
| 36e024c8-4f22-44e5-9467-708583a3b4eb | 81a33f6c-0195-45c5-87e7-7748838d0a4e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7764 | TCGA-69-7764-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2e9d95a7-fdbd-4efb-8691-a34ede74c136 | 62b8c824-3e80-4341-bfee-78d04be904c9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-83-5908 | TCGA-83-5908-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3bdeddcd-846f-4807-b5a4-ed24e3a64eb3 | 53244201-6282-42ea-9da4-31524ca39bf8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8279 | TCGA-86-8279-01A | Tumor | Primary | Solid Tissue | Unknown |
| c1ff9d7a-6531-41da-881e-70f889cf7416 | 3289364c-0dc2-43e8-bfe2-57d25e8612e5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-A9RS | TCGA-73-A9RS-01A | Tumor | Primary | Solid Tissue | OCT |
| 5b32fe96-32c0-4d95-a75b-0fc454081ee7 | 22cd91fc-54c5-43e0-80ff-19a419298721.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A5IP | TCGA-L9-A5IP-01A | Tumor | Primary | Solid Tissue | Unknown |
| a833d8f8-4d90-436c-8548-16bc02361b88 | 30a6ea89-8eda-47cf-b336-e070fcd08740.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A4YI | TCGA-NJ-A4YI-01A | Tumor | Primary | Solid Tissue | OCT |
| e1d97633-39a2-4b63-aa06-fb3ffc941c3e | cbdf1edd-a8c9-4fc8-88ee-928f01abae34.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8299 | TCGA-55-8299-01A | Tumor | Primary | Solid Tissue | Unknown |
| e8e8d4db-555e-4a76-8299-e399fdbdd5fc | 918be5f7-a963-406f-8ce4-0a3e528998e5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-8398 | TCGA-62-8398-01A | Tumor | Primary | Solid Tissue | Unknown |
| cb267187-4eaa-4670-8a03-ec3c6c8c82b5 | b4a1a796-8bce-4b44-b4ed-fd7bf4c81b3b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-A4JP | TCGA-93-A4JP-01A | Tumor | Primary | Solid Tissue | OCT |
| 3e68cee6-03c4-4d8c-a5b7-bd849a24ad19 | efd3731a-0788-41e9-a985-0c3d400d7db3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8055 | TCGA-86-8055-01A | Tumor | Primary | Solid Tissue | Unknown |
| 116dabda-f4e2-40e0-a660-59333ef2e126 | 4966ebc7-b3d5-49d1-885d-f6ae4a8781e6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6982 | TCGA-55-6982-01A | Tumor | Primary | Unknown | Unknown |
| 4a5e9e8a-8c48-48cf-8bf0-eb564611d382 | 06770623-6a10-4874-9eea-1497077f18ac.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A4DF | TCGA-55-A4DF-01A | Tumor | Primary | Unknown | Unknown |
| 5c12b86d-f504-4e59-a8f8-9aea43cf1b8d | 77ca7978-5bc4-4264-8ca3-db132049c8a8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8096 | TCGA-55-8096-01A | Tumor | Primary | Solid Tissue | Unknown |
| e263001e-5afb-422f-91d4-849879ed6073 | 22c48da7-f220-43f4-a1b0-fd57358f7ae7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5930 | TCGA-50-5930-01A | Tumor | Primary | Solid Tissue | Unknown |
| ac5c764d-d1e5-4865-b7d0-35572959a973 | ca927d21-e459-469e-9655-c214b34447f7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-3774 | TCGA-67-3774-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6d01eab0-89e8-4b6e-a90f-c79f4ca814d2 | dd6e2735-7d83-4bc4-87b3-05a5d7f08caa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-71-8520 | TCGA-71-8520-01A | Tumor | Primary | Solid Tissue | Unknown |
| 768282c8-81db-432a-b41c-2b860479d4ca | 2b99d8d7-f329-4fe6-97b5-167953311755.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-A4VN | TCGA-95-A4VN-01A | Tumor | Primary | Solid Tissue | OCT |
| 3246816d-2008-4930-ad33-8f108ad011d1 | 98f4637a-4953-4f52-b90a-c768d005a3e7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8171 | TCGA-97-8171-01A | Tumor | Primary | Solid Tissue | Unknown |
| 708d0f0f-0595-4e68-88fb-951920affffa | da52147d-9bd6-449c-b5d9-b168822ddac0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A443 | TCGA-L9-A443-01A | Tumor | Primary | Unknown | Unknown |
| 39f0d00e-326c-49e3-a763-611619f6c50f | 57512aba-e397-4ab8-b1ed-de197e6f92fd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AAR0 | TCGA-49-AAR0-01A | Tumor | Primary | Solid Tissue | OCT |
| db2e431a-6a7b-4d24-87cb-44d3f3d5accc | 7977a11b-246f-4c4c-a200-ee35d2d51fc5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01A | Tumor | Primary | Solid Tissue | Unknown |
| c5ea8088-b64f-4044-9842-fda42633f862 | a0ead79b-f99c-46d1-a092-4cb98291bdcc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01C | Tumor | Primary | Solid Tissue | FFPE |
| ac8491bd-069c-406c-be34-a88858c5f206 | 3369898e-21d8-4ded-8bbc-a746b1a743ad.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6775 | TCGA-44-6775-01A | Tumor | Primary | Solid Tissue | Unknown |
| ab943d20-283c-4037-88f1-20fd9ef9443c | 4822db97-46d7-4302-bef9-63086b777e9c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-A4JO | TCGA-93-A4JO-01A | Tumor | Primary | Unknown | OCT |
| 35938c95-00cb-424b-a822-b3dadc8a033d | 8ce815e6-3c63-4cbf-8480-4f07867f18da.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7974 | TCGA-69-7974-01A | Tumor | Primary | Solid Tissue | Unknown |
| 07e4741a-bc01-409d-9bbb-6f6e19a534d6 | ef304a3b-e32b-450e-8c40-4173aa0a0366.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-5428 | TCGA-05-5428-01A | Tumor | Primary | Solid Tissue | Unknown |
| b2cf0b26-1f46-478d-b2e1-73115384ed57 | b307f8c5-d21f-42ae-9771-07126d58999e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01A | Tumor | Primary | Solid Tissue | Unknown |
| 61005b7e-d7ad-4573-af9b-d9f33ce3c300 | 484f0a13-a636-484b-9880-5066955dee6e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-5781 | TCGA-64-5781-01A | Tumor | Primary | Solid Tissue | Unknown |
| b5310007-7004-4306-8629-4c5a61219971 | b556d35a-4855-4e56-9e02-5fc939722169.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2656 | TCGA-44-2656-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6c10ffdb-f4a1-4e02-8f4e-7e09286308a7 | dad295e6-b4f8-4ad1-8439-acc3f903cfb0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-53-7813 | TCGA-53-7813-01A | Tumor | Primary | Solid Tissue | Unknown |
| cae0680e-f7bf-4742-aeca-8fac6d4f4934 | 2a48ffd2-9212-48f4-a836-7572eb2feffe.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-8402 | TCGA-62-8402-01A | Tumor | Primary | Solid Tissue | Unknown |
| 15ed0a75-7b07-4334-9f64-907d4a597123 | b3f38fc5-d1e6-4fd9-bd36-b413a3ac850e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4422 | TCGA-05-4422-01A | Tumor | Primary | Unknown | Unknown |
| 3dbc67a1-c49d-407c-867b-dc453f3aebc0 | d94a4acc-1345-4cdb-b1e0-0b9c1afc593c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-8460 | TCGA-50-8460-01A | Tumor | Primary | Solid Tissue | Unknown |
| b14f167e-72ec-432e-a374-6d9472eca448 | 841e54a1-9d65-4256-b70e-eb64659b40a4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A444 | TCGA-L9-A444-01A | Tumor | Primary | Unknown | Unknown |
| 80fbde52-30a2-478b-a3e6-b5cc2a295d28 | 1c66cca9-ad78-44e5-ab54-be31d4a66437.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T7 | TCGA-MP-A4T7-01A | Tumor | Primary | Unknown | OCT |
| f4ed8b5d-a5c3-46c0-aaa6-a29003cc750d | d7c787e0-6416-4724-8954-85467906f90d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6642 | TCGA-55-6642-01A | Tumor | Primary | Solid Tissue | Unknown |
| 048cb462-0a42-480a-80da-e5f2035e6abf | 094bd5ef-b1ca-46c6-b717-2519e5a6151b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-71-6725 | TCGA-71-6725-01A | Tumor | Primary | Solid Tissue | Unknown |
| 72bb7f41-e2fe-4dd0-bf97-d3b652911e52 | 258b0b5e-2b09-4378-9606-83955ca19d7c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4249 | TCGA-05-4249-01A | Tumor | Primary | Unknown | Unknown |
| 09ebf058-809e-4ebf-91e5-78f1a99a6cbb | d6662ab3-af1a-4e7e-a907-111e4241713b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8092 | TCGA-55-8092-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4d6609e2-6ad0-43a1-9bda-fbc4710e1da0 | ebf8d429-0437-4987-9bca-89e62910f168.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7158 | TCGA-78-7158-01A | Tumor | Primary | Solid Tissue | Unknown |
| a6f82885-da83-49d5-ad43-966b9dff4ea5 | c6acc762-3909-4cc0-91c7-f66bc3f0e667.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4507 | TCGA-49-4507-01A | Tumor | Primary | Unknown | Unknown |
| e08d0c44-9834-43b8-b518-6882e36a1bb0 | 9f030a01-eef7-4885-8edc-316fe88860d7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7159 | TCGA-78-7159-01A | Tumor | Primary | Solid Tissue | Unknown |
| 13f112e3-2c08-441d-979f-2367e775fef6 | c812eb06-bd41-4919-8f6d-9ade00654a4c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-A4D0 | TCGA-86-A4D0-01A | Tumor | Primary | Unknown | OCT |
| 9c10aab6-e991-4d55-852b-e136d2469d1d | b7f29b8c-08a8-4781-ba33-5a7b6b02ad23.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A4YQ | TCGA-NJ-A4YQ-01A | Tumor | Primary | Solid Tissue | OCT |
| 888e7914-72dc-46ab-b34f-84e30cf4ede8 | ec99ae0d-704e-481d-bc90-7b553075a845.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-53-7624 | TCGA-53-7624-01A | Tumor | Primary | Solid Tissue | Unknown |
| 32d57c36-8bf3-4134-8dd4-4cd17bc8ae7f | 868157f2-85e5-462c-9994-1e50791ad2c0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5068 | TCGA-50-5068-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3ab155d8-7f47-473e-a2f3-721169590879 | 3a284d39-2913-4d8c-b46a-9b1e991cfd0b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A4YF | TCGA-NJ-A4YF-01A | Tumor | Primary | Solid Tissue | OCT |
| 7bd81e9a-6853-4c8e-ba87-849957a8f015 | fec056a5-e860-4b68-8fa0-39cb7ad78a62.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-8395 | TCGA-62-8395-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0bc34939-5be8-4e8c-87ae-3af7933af31a | facd5609-e5f0-4993-bd84-049447d60d32.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6778 | TCGA-44-6778-01A | Tumor | Primary | Solid Tissue | Unknown |
| 07fc11a1-2413-4894-bea0-65ed5f4b4981 | 0832f2ee-ad00-42c7-8cc3-9c63a7b5cea9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7163 | TCGA-78-7163-01A | Tumor | Primary | Solid Tissue | Unknown |
| 18741ab4-90ba-4d43-aa69-8a86840399af | e48cabb8-73cd-4d42-81b0-f9ab7bebecc1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8085 | TCGA-55-8085-01A | Tumor | Primary | Solid Tissue | Unknown |
| bd243552-7513-412b-b236-545b402b200c | acbeca74-24ec-4e54-98e6-d3f59475dde9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7281 | TCGA-55-7281-01A | Tumor | Primary | Solid Tissue | Unknown |
| 99fbeafe-88d9-4c88-8df1-e7acef0696b3 | 929a50ee-02a9-44f5-8078-e4020a89263f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7994 | TCGA-55-7994-01A | Tumor | Primary | Solid Tissue | Unknown |
| 03007464-6f43-4863-80e0-83726921d841 | 4564496a-31da-4537-abe0-5b3f2455ed13.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-5429 | TCGA-05-5429-01A | Tumor | Primary | Solid Tissue | Unknown |
| 74695b53-d593-4a38-aa41-3334ded3c847 | 2aef96ea-5379-4066-8df1-66218ab77425.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-8117 | TCGA-44-8117-01A | Tumor | Primary | Solid Tissue | Unknown |
| d1969524-4d30-4a50-ba38-3ce50303b6e3 | b70dcd97-e1e4-417c-a05f-b37acdde6684.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-8494 | TCGA-95-8494-01A | Tumor | Primary | Solid Tissue | Unknown |
| 83e3257c-bc18-488a-8a49-867c9c939cec | ab0a7727-00ee-40fa-b5f5-a69234473e4a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5942 | TCGA-50-5942-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4d85514e-171d-46e4-b6db-43b4f8ff2eb0 | 3f7a9aee-2d10-4426-855b-de9a48b278ce.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4395 | TCGA-05-4395-01A | Tumor | Primary | Unknown | Unknown |
| ad648348-65df-4bca-934f-766d69132241 | 71809317-f775-4faa-b1c6-40bae85c69aa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-A4JQ | TCGA-93-A4JQ-01A | Tumor | Primary | Unknown | OCT |
| ef132c02-88be-48c4-acda-0544662379de | 3a8b14d9-c521-48d4-9400-074d752afe1b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T8 | TCGA-MP-A4T8-01A | Tumor | Primary | Unknown | OCT |
| 741e0a4b-b92d-4ca7-8335-3bf245c30cfd | fcb42a31-a716-430f-a0a1-001766fc62b5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5933 | TCGA-50-5933-01A | Tumor | Primary | Solid Tissue | Unknown |
| 99c213ba-55b9-42b6-9546-62b8d3f6c284 | b71b334c-768e-46f6-bc7e-c95a11f44f03.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7903 | TCGA-55-7903-01A | Tumor | Primary | Solid Tissue | Unknown |
| 58602df8-a37a-4fe4-9c80-7b79ac0c3e18 | c45c7b03-a317-4dac-ba0f-19989348cae3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8208 | TCGA-55-8208-01A | Tumor | Primary | Solid Tissue | Unknown |
| dcde3fba-f8c6-4c0b-8540-5abd036db6c8 | 4f8b284e-7e42-45c5-b7cc-57cc678ec3df.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-A47A | TCGA-44-A47A-01A | Tumor | Primary | Unknown | Unknown |
| 40708d9c-1c51-4e7c-9ce2-185ea1480eb2 | af407c3f-2dad-4fb9-850e-4a79b361589b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6968 | TCGA-55-6968-01A | Tumor | Primary | Unknown | Unknown |
| 209d979f-fc32-4fe6-bc09-181bdc36943d | 84595c09-6f85-4a1d-98fa-7d9bc9dc2c28.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-8039 | TCGA-95-8039-01A | Tumor | Primary | Solid Tissue | Unknown |
| eb07b0f0-40dd-49d2-88ad-c87fbb843ffb | 58681163-9f9d-4f74-a1bb-3a4bcb4856d6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AARR | TCGA-49-AARR-01A | Tumor | Primary | Solid Tissue | OCT |
| 1762cec9-b8f3-4fac-ad7a-d80c171637ef | 1aa0401e-b389-4852-87ef-e1ae357b76dc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-8459 | TCGA-50-8459-01A | Tumor | Primary | Solid Tissue | Unknown |
| cae43e2f-9cfa-4438-8061-1c0aa2727404 | aa2d6144-50d3-4096-9ecf-3cc0ceac7f41.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5045 | TCGA-50-5045-01A | Tumor | Primary | Solid Tissue | Unknown |
| 890f9eb9-79f1-4d34-a9c7-4381107138b3 | 068ba2ae-288c-446d-8d17-72445ce4f788.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-A4JN | TCGA-93-A4JN-01A | Tumor | Primary | Unknown | OCT |
| 2386dafe-f396-4fb9-a45f-c2981974be26 | 14e05372-1acb-4479-904b-ce8acef028eb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7150 | TCGA-78-7150-01A | Tumor | Primary | Solid Tissue | Unknown |
| cacdc356-2f4f-4ff5-a508-4666c8081291 | f3df8eaf-1fd2-4e08-ad48-ce5aa1d64e19.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-A4VP | TCGA-95-A4VP-01A | Tumor | Primary | Solid Tissue | OCT |
| 52103d63-0f85-49cf-8463-de2caaa4df4d | ed0926c8-6642-4741-9de6-e04014ba0364.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A491 | TCGA-55-A491-01A | Tumor | Primary | Unknown | Unknown |
| 63aad27b-4497-4c1d-818d-849ba8d83c0e | f30ea4c5-0110-403e-b171-2ea1e35c1ea0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4417 | TCGA-05-4417-01A | Tumor | Primary | Solid Tissue | Unknown |
| 165140ff-bcc4-411a-bc99-b54b814bafb3 | 35a9d225-0988-4e31-9a39-d54f3a63bea8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A743 | TCGA-L9-A743-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4cf282a6-9b40-4483-a826-275abc4b7155 | 8d438e20-04cb-4b39-b3a9-96a3a35de104.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8513 | TCGA-55-8513-01A | Tumor | Primary | Solid Tissue | Unknown |
| d6140094-7640-48e5-8d0b-1622593cbbd8 | 4933c476-e3f3-45b0-b158-dcbe0539644e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7660 | TCGA-44-7660-01A | Tumor | Primary | Solid Tissue | Unknown |
| ac1e305e-e387-4010-9169-026a7faa05bf | 56ba7921-5bee-4a1e-9fba-a78a034547a6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8614 | TCGA-55-8614-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6f343aec-65e1-44ad-b4db-339d4ed62373 | bc8b6dee-0f79-492f-85e1-c1a09d6f9680.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-8655 | TCGA-78-8655-01A | Tumor | Primary | Solid Tissue | Unknown |
| b0cc5938-c1e4-4a18-98fc-135ac89ef729 | 78bf9571-4145-4c0d-a61a-58a878351097.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-L9-A50W | TCGA-L9-A50W-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0630a12c-428e-4dac-bb7c-d7bdff288d30 | 764d71c7-f003-4cf6-851e-1587f12b4a69.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4668 | TCGA-73-4668-01A | Tumor | Primary | Unknown | Unknown |
| d506d948-b35a-478e-b21c-23d35ab5f72e | 5a1b3a79-375e-47a7-8a30-b37fbfd8162d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4390 | TCGA-05-4390-01A | Tumor | Primary | Solid Tissue | Unknown |
| ddede262-9d2b-40b9-ae70-bb4f6c61d2ea | a8d269f5-ebc9-4b2a-9cd9-7019204a246f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-8067 | TCGA-93-8067-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4cd04ea0-f23b-4f10-8018-e5e090e84388 | e860f314-beb1-4dfd-adb8-e188f13ca1c8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4418 | TCGA-05-4418-01A | Tumor | Primary | Unknown | Unknown |
| 63da5a36-0ec0-4d89-be9d-7319f0eae8ed | f8cc4515-2576-4a72-9cf1-28dfe774eda9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-1595 | TCGA-55-1595-01A | Tumor | Primary | Solid Tissue | Unknown |
| ab62a7c8-6ed3-4996-836f-580c0b4dc71f | 7f9b4506-b00b-4b6f-8469-d0e4a73df1d4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-6745 | TCGA-49-6745-01A | Tumor | Primary | Solid Tissue | Unknown |
| f79d2215-8cdb-4765-9edc-1d9a2691f87e | 32dd8db9-1e43-497e-a35a-664d7d15ed60.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8091 | TCGA-55-8091-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9dc4d7c4-610f-4f64-a04b-85d95bafa25a | bc037eb7-5afa-4730-b896-23bf21a31641.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4630 | TCGA-38-4630-01A | Tumor | Primary | Unknown | Unknown |
| f581a769-6ef2-4d00-985c-3f0d140132aa | 2f00871b-1c4a-4fe9-94f6-42493fd95841.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-80-5607 | TCGA-80-5607-01A | Tumor | Primary | Unknown | Unknown |
| 2048318d-3a7c-45a7-a7a7-680076d76b6f | 819e9776-131f-4c00-b93c-9936cbcc55b8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4384 | TCGA-05-4384-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0e1446f0-8bd5-4839-8f89-e332a0d1a02f | d1b10396-1656-4963-8fd0-7d7368c24dd2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-7498 | TCGA-73-7498-01A | Tumor | Primary | Solid Tissue | Unknown |
| 133d0758-2b29-47cf-89b9-97dc8c860271 | 735e3d15-4df3-4162-b819-1ebc1991bfce.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01A | Tumor | Primary | Solid Tissue | Unknown |
| bc6ebfd0-e972-46e1-9627-6b16a420a5ee | 32e5ef2b-4387-4d2c-8e62-d18b5106414f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4676 | TCGA-73-4676-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3e4107e8-4937-4bed-9c90-65d42f084f49 | 6338619f-470c-4ae1-8b45-959b5f9ad3da.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01B | Tumor | Primary | Solid Tissue | FFPE |
| 220f0f07-2691-4c14-af2d-0dfac14b3278 | d832db0a-348f-4e28-953a-741192fe0826.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6146 | TCGA-44-6146-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9b179934-f54d-4256-84bd-3e516685a119 | ff298d6f-071c-417a-acbe-a9ff38494f87.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7573 | TCGA-55-7573-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4735a470-cd74-4f16-9f06-31f4aeba6add | 45310b76-8ea1-4d13-9d9f-1f1d874e0285.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-8119 | TCGA-44-8119-01A | Tumor | Primary | Solid Tissue | Unknown |
| e51d5093-8639-43e3-9866-1480083f4232 | 72726dc4-fa08-4e34-9539-29ddb19dd782.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4501 | TCGA-49-4501-01A | Tumor | Primary | Unknown | Unknown |
| f95eb346-3e9a-4467-b097-10e98b1924d2 | 9a0910ce-634b-47b6-a63c-caaf219e0b55.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-J2-8194 | TCGA-J2-8194-01A | Tumor | Primary | Solid Tissue | Unknown |
| dfa64001-556a-47a9-9306-85bb2cd3a6d7 | 2fde57cd-97d2-492d-b37d-a4e2d43239cf.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6986 | TCGA-55-6986-01A | Tumor | Primary | Unknown | Unknown |
| 0ebf5cc5-f242-45ef-821a-939b51dc95a2 | 330845b9-1d53-47af-8cb7-30ce5d30625d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4505 | TCGA-49-4505-01A | Tumor | Primary | Unknown | Unknown |
| 839d3114-ec0d-47b7-8cb2-76642b0660d6 | 7ecd6087-9663-4d9d-828d-d9e9b5241c3c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8674 | TCGA-86-8674-01A | Tumor | Primary | Solid Tissue | Unknown |
| fea8014a-be97-4a25-b588-d5e39e007c30 | 25ef25f6-9982-41ad-9823-62763c6c29eb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4SW | TCGA-MP-A4SW-01A | Tumor | Primary | Unknown | OCT |
| a3c065c5-3267-424d-8d22-6985365d8a36 | 3b5d9bee-5e4f-4afc-b297-2f072ef18a93.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7671 | TCGA-44-7671-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0a50c26b-ee2c-4953-aacc-668589736fa6 | da145aec-4391-4fce-b5d0-bf91065b765e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-8640 | TCGA-78-8640-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2fa16f27-77e7-4f08-8263-eef90f96483d | 772dcecf-b53d-42e2-8161-f48030150aa0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5944 | TCGA-50-5944-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3f503411-5805-4889-a879-7f9b57fa77bf | f21b5258-2e93-4fe0-bd98-9eb1216e824b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-35-4122 | TCGA-35-4122-01A | Tumor | Primary | Unknown | Unknown |
| a3d162a0-925c-461d-b9d7-54d8798660c4 | 743f08af-5537-4454-a219-18639e5127c6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4666 | TCGA-73-4666-01A | Tumor | Primary | Unknown | Unknown |
| 489d6328-0678-4c85-9837-4f476c9afee9 | afccc865-1d58-475d-b85c-0d7eca330b0e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7714 | TCGA-86-7714-01A | Tumor | Primary | Solid Tissue | Unknown |
| eae099b8-7486-42dc-9565-c875662eb729 | db3c11b8-53c7-48f8-a16c-b86c1c7534b0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7145 | TCGA-78-7145-01A | Tumor | Primary | Solid Tissue | Unknown |
| 27078ed6-5e6c-4d44-a9cb-f68decdd5b12 | fb870a60-4b6d-4e83-b366-bdaaca72f205.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7143 | TCGA-78-7143-01A | Tumor | Primary | Solid Tissue | Unknown |
| ef45b46e-0902-4641-9d21-1a98c401f6ba | fddbde25-7d5c-496f-8f62-985dbda7e0fe.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M3 | TCGA-97-A4M3-01A | Tumor | Primary | Unknown | OCT |
| a35d36a1-fcba-4f4a-9c6d-a9af1d881026 | e40ae18a-9f57-4069-b99f-260c93b52e9f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-8255 | TCGA-69-8255-01A | Tumor | Primary | Solid Tissue | Unknown |
| b3d9124b-689b-475d-aa48-0c8428f51c77 | 39af4940-aeba-4d26-96fc-68da8663bc81.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4486 | TCGA-49-4486-01A | Tumor | Primary | Unknown | Unknown |
| 9988cad6-0f42-4112-975c-814bfc3e91c3 | 5d843590-36a7-4568-88a4-2bc09e14927f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-8648 | TCGA-78-8648-01A | Tumor | Primary | Solid Tissue | Unknown |
| 83d2711f-fb21-449f-9d96-352db089e643 | d20f5121-5e33-4b35-8cdf-df2eb51a099d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4424 | TCGA-05-4424-01A | Tumor | Primary | Solid Tissue | Unknown |
| abb26459-9ffa-4343-beae-c6e329b416aa | 00fabec9-d311-4994-a7e5-eb91178d14f2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-A59K | TCGA-69-A59K-01A | Tumor | Primary | Solid Tissue | OCT |
| b66b7858-7464-47fd-8c42-0fe2917fb6a4 | 3f579bea-4481-42cd-b433-4f4ff65cf7b0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01A | Tumor | Primary | Unknown | Unknown |
| 8000ff4a-0b35-4b41-98af-bb616f2d3aa5 | 765dc4a5-ce4d-4437-9061-20c018bbbade.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3918 | TCGA-44-3918-01A | Tumor | Primary | Unknown | Unknown |
| 149c7f86-d383-4a93-9666-1a6b78250b89 | f1eb1ef7-fe25-4dd8-abed-9d9c298d72fb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AAR4 | TCGA-49-AAR4-01A | Tumor | Primary | Solid Tissue | OCT |
| 56ce812f-00dc-462f-9a1e-ea6ca3e6f2e5 | 59578e5d-b76f-46eb-b5d9-7c90b8a9dbe4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7539 | TCGA-78-7539-01A | Tumor | Primary | Solid Tissue | Unknown |
| c0d51597-3fdd-48b9-a1db-0a247c1ca843 | 21eea21d-7db3-4f85-a9e4-72cbb562b5ed.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46U | TCGA-62-A46U-01A | Tumor | Primary | Unknown | OCT |
| c9a5da35-0249-4422-aafa-65f8264c37d2 | 2a53d9f7-430a-45c5-9171-8ee65dc560dd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7667 | TCGA-44-7667-01A | Tumor | Primary | Solid Tissue | Unknown |
| 84da8889-9467-4e84-83d2-6083fe380c72 | c6b74844-5140-4c2e-b13d-fc50c2f2e9f1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A4YG | TCGA-NJ-A4YG-01A | Tumor | Primary | Solid Tissue | OCT |
| a897e18d-5dd8-4881-b887-da06dbd632fc | 6b48d62b-0932-48df-9448-ae6dcb8853b2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8302 | TCGA-55-8302-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6b1b3509-92ad-4c5c-8d47-45c0261772b8 | 52beaa60-92f3-48cf-a695-78bb66ccd4f6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6970 | TCGA-55-6970-01A | Tumor | Primary | Unknown | Unknown |
| 75798ad4-64b3-420e-a08b-9ea3a3422bae | c6fcbf56-bc49-43eb-981a-ef032465a7ce.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8359 | TCGA-86-8359-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8be401e7-1fa3-4ae3-9f18-660941824671 | 29000c50-6667-4281-a97a-5f02cb24a8f4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6595 | TCGA-50-6595-01A | Tumor | Primary | Solid Tissue | Unknown |
| 55acf78f-4a64-44c0-a276-510c279cf861 | 6f53a60f-3be2-48df-a15a-4675e99efba1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4632 | TCGA-38-4632-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2301334d-e0fb-4d39-b742-fb29943767b1 | 233b6aa7-9d3f-4db0-a900-03f7cf4d0ac4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A55O | TCGA-NJ-A55O-01A | Tumor | Primary | Solid Tissue | OCT |
| ef081522-83fe-4588-8060-4d096f839ab7 | 36f81494-52c4-49db-9dba-26a0c2de2e8e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-99-8025 | TCGA-99-8025-01A | Tumor | Primary | Solid Tissue | Unknown |
| 05b548c6-9761-4f5f-8600-2ead980ec8dc | d38959c4-8069-4963-8eca-0c66699df9a7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8174 | TCGA-97-8174-01A | Tumor | Primary | Solid Tissue | Unknown |
| a626ad4b-579d-4f16-960e-588f780e809f | 91e79d93-01a8-4908-805a-12678d68a543.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-A456 | TCGA-86-A456-01A | Tumor | Primary | Unknown | OCT |
| c01b08f7-3a6d-48ea-a482-796220e5f56b | 6c438dcf-6ec0-4bf7-8122-875490967b70.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A5C7 | TCGA-MP-A5C7-01A | Tumor | Primary | Solid Tissue | OCT |
| 2389e098-4fc6-4368-953d-2dda462fa41d | c8bfb715-4c7a-4e3e-baa2-bc842d80654b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8552 | TCGA-97-8552-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4af96951-004a-41a0-a2c1-293fce0c8342 | 52e52b5d-4112-4616-8ddd-2a4524a91778.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6591 | TCGA-50-6591-01A | Tumor | Primary | Solid Tissue | Unknown |
| 088e8c85-c0dd-4bdb-b405-3406ce8b5602 | f57240f6-a5e4-4a9f-81d7-b59616d865dd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-A4P7 | TCGA-86-A4P7-01A | Tumor | Primary | Unknown | OCT |
| 5cc58fb9-dd2f-4b91-88b5-f659d6793eb8 | 085fd4df-27f7-4680-a0b5-8726f9eab370.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4512 | TCGA-49-4512-01A | Tumor | Primary | Solid Tissue | Unknown |
| d45b8f78-48e9-49ec-aa1f-df6d8eeda367 | e127acf3-0757-4f24-aff7-0fbe7283b9ed.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-6743 | TCGA-49-6743-01A | Tumor | Primary | Solid Tissue | Unknown |
| e87e6c78-12aa-4bda-8c7e-0c9c7b2cb774 | aec36454-d9a1-4d51-90c6-561f219b6aee.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8206 | TCGA-55-8206-01A | Tumor | Primary | Solid Tissue | Unknown |
| 976ac032-e4ca-4a9a-918b-722d0de6ecd7 | f3b31315-692c-4040-9f89-1a9988ed2fbc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4389 | TCGA-05-4389-01A | Tumor | Primary | Unknown | Unknown |
| 0c8f7bc3-8eea-4db8-9b8f-aa4785f73819 | e25887be-64fe-4e7c-983b-4fbdec52c4b7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7979 | TCGA-69-7979-01A | Tumor | Primary | Solid Tissue | Unknown |
| 475f1bf3-b892-4534-827c-d48382b0700f | a4a57e8f-cf4f-4322-b7fe-2336a58cd50f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7701 | TCGA-86-7701-01A | Tumor | Primary | Solid Tissue | Unknown |
| 5fc71d41-3824-4649-9179-386bb566533c | 4f721842-9460-4376-b577-59c3731f34a6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-5815 | TCGA-64-5815-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3604ecfe-9649-43c8-a36c-a29b32f7b7d7 | 5541c1a3-e0e5-4ded-ae0a-687e87a7d708.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6203 | TCGA-75-6203-01A | Tumor | Primary | Solid Tissue | Unknown |
| 31809095-b3ff-4ffb-9641-9fb561e08101 | 482e60ad-222e-4ead-8a3c-a3b44e54aa5e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A494 | TCGA-55-A494-01A | Tumor | Primary | Unknown | Unknown |
| 885b29e1-c858-41c6-8282-0b4d0c6fbe6b | 8a6d64cc-3f03-4a5d-b6ce-83fa9c7f7d07.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7995 | TCGA-55-7995-01A | Tumor | Primary | Solid Tissue | Unknown |
| d816341b-dd8f-458a-b945-fd716c11c8c0 | 56c858be-3637-4ba0-81be-208a3edac992.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7941 | TCGA-97-7941-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7c1bff62-84a9-446d-b5dc-bf92cfe6c58e | e9efd91b-8824-456b-b650-1d0287efbbe8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7039 | TCGA-95-7039-01A | Tumor | Primary | Unknown | Unknown |
| dda15125-b920-4567-9648-51a7bef1a383 | a6caa89b-29fc-46cf-8d6b-a6c0241be6d7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8301 | TCGA-55-8301-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4c97e518-bfed-4b8a-8793-a78481c33e15 | 76413057-e8a8-42b7-b545-897e3b32580d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7152 | TCGA-78-7152-01A | Tumor | Primary | Solid Tissue | Unknown |
| c712e999-5bd8-4841-96e4-a99e3381f6d8 | 42ecec5f-f097-4d86-a9d9-cf0507b08c42.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8097 | TCGA-55-8097-01A | Tumor | Primary | Solid Tissue | Unknown |
| 62a350a6-9cb3-474b-8eb2-6eec9f6e2904 | aa764c7d-2e26-4e8c-94d3-870772bad93f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A490 | TCGA-55-A490-01A | Tumor | Primary | Unknown | Unknown |
| a7af780d-280e-45e0-bc5f-f6d791adfa4f | 1f71e82c-0781-4d19-bc26-6c3c176827c5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5946 | TCGA-50-5946-02A | Tumor | Recurrence | Solid Tissue | Unknown |
| 832227fd-b159-475f-a787-bd5661406164 | c36d8349-6af1-4583-818d-cd3742ea97a7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5946 | TCGA-50-5946-01A | Tumor | Primary | Solid Tissue | Unknown |
| 89b233d6-33e0-4699-acf4-159609ccd872 | 7d9c7c34-76e0-4622-b5f7-60e12f6d4e07.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7913 | TCGA-55-7913-01B | Tumor | Primary | Solid Tissue | Unknown |
| f471e8d7-9e62-45ad-a03e-412bc69a932c | c63de407-f025-4939-9633-6550724be88c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6779 | TCGA-44-6779-01A | Tumor | Primary | Solid Tissue | Unknown |
| c7e11339-6f22-4e72-a7ab-6d0acd68a0ab | 2301103f-5cbe-4cb6-b5da-0b83b39e4616.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5055 | TCGA-50-5055-01A | Tumor | Primary | Solid Tissue | Unknown |
| 14c60245-7d47-406b-b459-40042fc89a2c | 322ff57d-60a1-45d6-a103-c953d11924f1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4628 | TCGA-38-4628-01A | Tumor | Primary | Unknown | Unknown |
| 12edfe44-c7bf-4ffb-8270-8f23bddcc42a | 55071ef3-bf09-43a2-a54c-a9ec61a84615.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7713 | TCGA-86-7713-01A | Tumor | Primary | Solid Tissue | Unknown |
| 21daa1d2-8766-46ee-a0cb-b51b361a5a8d | 33e0a8b2-3e7e-46da-b5ef-76463308d3b9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01A | Tumor | Primary | Solid Tissue | Unknown |
| b614f97d-5004-4b5b-8125-0884404c702a | 883ef55a-e8c0-4774-a298-d2bfeaeeae4b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01A | Tumor | Primary | Solid Tissue | Unknown |
| d4c759b8-c9a0-4931-8a17-425c20fff142 | c208cf0f-3922-4159-a7dd-76dccf9ff396.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-6216 | TCGA-67-6216-01A | Tumor | Primary | Solid Tissue | Unknown |
| c421afac-04ec-4285-ae1b-2187c4eb6a67 | 98a4b8cc-fd54-454c-adcd-6fe9ae159a3b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7283 | TCGA-55-7283-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3c083f52-f548-4f1b-b08e-2275eeb31218 | d4422306-b68c-4687-9131-02a60a2d4c42.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4659 | TCGA-73-4659-01A | Tumor | Primary | Unknown | Unknown |
| da1c76bb-76e2-4b80-ac1d-5cd7b5e23dc5 | 087c2c93-d071-41e1-a2e8-a1961ba54a86.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8073 | TCGA-86-8073-01A | Tumor | Primary | Solid Tissue | Unknown |
| 20742577-479a-4d1a-a3b0-16f5094aa667 | 50c308c9-922a-4083-ae09-e5e4d8c437af.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AARE | TCGA-49-AARE-01A | Tumor | Primary | Solid Tissue | OCT |
| 29e3cf8c-a07e-47a4-82f0-d824636ccb96 | 1f7938f1-e04e-4ed0-8189-3d701c6fef72.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4403 | TCGA-05-4403-01A | Tumor | Primary | Unknown | Unknown |
| abac4b21-6420-4324-95be-869ffaadc4d9 | 8c55ee80-c8c3-4196-9b67-81732fffe9f4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6840 | TCGA-91-6840-01A | Tumor | Primary | Unknown | Unknown |
| 252105c8-298b-40ff-869b-c3390fd67fab | 79e12f4d-94d7-45f8-b251-6b0fcbb6b885.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8673 | TCGA-86-8673-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8b3d6cd4-1aef-41ea-939a-af3a2dc8d955 | 56d7d6b5-33c0-4551-967c-afce1f970395.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6831 | TCGA-91-6831-01A | Tumor | Primary | Solid Tissue | Unknown |
| 36ef2609-d721-4db5-a9d5-8928c7a67ac6 | 597af330-73d5-4905-803e-56d744ab723d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7728 | TCGA-55-7728-01A | Tumor | Primary | Solid Tissue | Unknown |
| ffe6c4a6-f9c9-4dd1-abbb-7aa11336dc15 | 3b21349a-ee41-45bf-87de-19b6cda494d5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7973 | TCGA-69-7973-01A | Tumor | Primary | Solid Tissue | Unknown |
| f776cc87-6731-4e7a-9b7b-01f6461cd50f | c41a2347-8277-494e-90c6-f1918223388b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-6562 | TCGA-86-6562-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8767cb0f-42f8-460e-b545-6ed0638b88a5 | 2172f060-6402-44dc-a918-2f9c15c21fa4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7815 | TCGA-55-7815-01A | Tumor | Primary | Solid Tissue | Unknown |
| 15a295ec-c4fa-4cda-8d74-4bc5fc6eb05d | 20ecdb2d-16ad-437b-ac0e-b84339c769a6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M0 | TCGA-97-A4M0-01A | Tumor | Primary | Unknown | OCT |
| 2c864712-71a7-4c29-a96b-38058d10f4a3 | 00d461ae-a1d8-42f2-abd8-5e159363d857.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01B | Tumor | Primary | Solid Tissue | FFPE |
| dca26258-6f29-4c20-8139-6d029680a377 | 8a44c8a0-142b-48bb-9809-69914811bacc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6593 | TCGA-50-6593-01A | Tumor | Primary | Solid Tissue | Unknown |
| 49862d40-908a-40fa-b9e4-5a285db3dcbf | c18d9cb5-17ca-4c49-bd72-4b4c6184fba3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A472 | TCGA-62-A472-01A | Tumor | Primary | Unknown | OCT |
| 32932ffb-7413-42ec-aa3e-78221b5b55bf | 36db1d28-8a10-46cc-91ef-d5036aaba9c3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4432 | TCGA-05-4432-01A | Tumor | Primary | Unknown | Unknown |
| 39845a3f-f8c7-4a00-bcf7-e63016981df9 | c16f63fb-a468-48e8-b679-6e26b8457530.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7938 | TCGA-97-7938-01A | Tumor | Primary | Solid Tissue | Unknown |
| 38c15c9b-c28a-47df-b0ad-acb597b88fcd | 7eab2708-6708-4f8e-b238-e06007754e7e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4510 | TCGA-49-4510-01A | Tumor | Primary | Unknown | Unknown |
| 6967be90-16eb-4aad-9d47-425cd48ce1fb | 6aa56177-0576-454d-81e8-28aa9ce76406.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TI | TCGA-MP-A4TI-01A | Tumor | Primary | Unknown | OCT |
| 4fd0542b-30da-4820-bc4b-7344629f7859 | b1d9364c-d703-4884-b96d-20d8084040a8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-1678 | TCGA-64-1678-01A | Tumor | Primary | Solid Tissue | Unknown |
| 83ea371a-c68a-4afc-9b33-8d8fc53f7173 | b95a1889-2ef5-4da3-b5e9-14b678c4d71a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5936 | TCGA-50-5936-01A | Tumor | Primary | Solid Tissue | Unknown |
| 35a81dbe-bf1e-478c-8a95-d227b4195f34 | ab589a7b-7cc9-4257-8fd7-241d2e3658da.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2657 | TCGA-44-2657-01A | Tumor | Primary | Unknown | Unknown |
| b9f17e59-2249-4e4d-b2e8-0f7d77a413b3 | 4a967e6f-d39a-4fe5-864b-a43e8184a852.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AAR2 | TCGA-49-AAR2-01A | Tumor | Primary | Solid Tissue | OCT |
| becae9e1-8886-4f2e-b20f-92c429158848 | f7beaa9b-98ae-40bd-aadc-e69688499170.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01B | Tumor | Primary | Solid Tissue | FFPE |
| d0d763a9-856c-452b-9989-a72894b32326 | 962d56c6-0e10-4b55-9c4d-dbb89c983d74.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7155 | TCGA-78-7155-01A | Tumor | Primary | Solid Tissue | Unknown |
| ef6b6bf0-de01-405a-94b5-15157825b105 | f0395da6-5f12-4a35-8aa6-0b1b47a2acba.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4250 | TCGA-05-4250-01A | Tumor | Primary | Unknown | Unknown |
| c7868d2c-fc90-49f7-a748-187af5735d3b | d1eba37d-0b00-47f4-a7c8-d2e80ec3e27b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7937 | TCGA-97-7937-01A | Tumor | Primary | Solid Tissue | Unknown |
| f1ec9467-2b01-46d5-8457-4b2c15cc9e8d | cd271741-c470-4f57-9873-635fef14f902.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-1676 | TCGA-64-1676-01A | Tumor | Primary | Solid Tissue | Unknown |
| 033ec523-89f1-42db-ae8c-ea2608302d19 | 5a335f07-9b07-46cf-8902-503b24f89bfa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-5774 | TCGA-64-5774-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7877006b-79db-4b9b-a77b-19925630a921 | 044b4834-bb51-40c8-8027-e5d752fa8787.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8616 | TCGA-55-8616-01A | Tumor | Primary | Solid Tissue | Unknown |
| a7d80776-4d9a-4a9e-98da-1470623559fa | 9d2f9191-338e-49ea-a887-a808cdf2703f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7153 | TCGA-78-7153-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9b01b68a-51ca-4896-a22c-05882785826b | d4db8bd3-6f2f-4c34-a4a7-1e23342e62b5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46R | TCGA-62-A46R-01A | Tumor | Primary | Unknown | OCT |
| 10fcbc8f-ca09-4175-abe3-64276a78e492 | 7643fc1a-086e-4ea5-9766-3dde13cc00b4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6206 | TCGA-75-6206-01A | Tumor | Primary | Solid Tissue | Unknown |
| cb98f5ad-ce14-47f6-ab41-7fc704e4320c | 80416b83-9ea2-4d33-8ba4-1fe9330d51f2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8671 | TCGA-86-8671-01A | Tumor | Primary | Solid Tissue | Unknown |
| f591cea3-f2ba-42b1-8372-74bcd834fbef | 5418228b-cfd0-4580-87c6-3ebf6282ad73.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6972 | TCGA-55-6972-01A | Tumor | Primary | Unknown | Unknown |
| 8f82532e-91ca-469b-a1a5-9bca66844679 | 04c4affd-ca5d-4ea4-95d1-a6502e80d1af.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-1681 | TCGA-64-1681-01A | Tumor | Primary | Solid Tissue | Unknown |
| 535b7200-1785-4740-9410-e3597ea0e9bd | 131b98d5-aaf4-4a6c-bb96-c33895cd814a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M7 | TCGA-97-A4M7-01A | Tumor | Primary | Unknown | OCT |
| b814b1c8-0539-4247-91c4-cfc5916eedbb | e2f47d3a-0e1a-47cb-a53f-697e2a3cb89b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4494 | TCGA-49-4494-01A | Tumor | Primary | Unknown | Unknown |
| a03b2192-229f-4ead-8030-639617cb10cb | e121b871-b177-47ef-a4f1-de73cb338519.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7765 | TCGA-69-7765-01A | Tumor | Primary | Solid Tissue | Unknown |
| 19692110-bda4-44e4-9cfd-402ea0e0f495 | eecb4e6b-6916-4673-815b-9a5366fe3a86.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4487 | TCGA-49-4487-01A | Tumor | Primary | Solid Tissue | Unknown |
| 74184b07-5b46-4cf3-9c1a-305e656e8773 | aab7b2a0-4181-4556-b1a8-28d31f98a43c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TE | TCGA-MP-A4TE-01A | Tumor | Primary | Solid Tissue | OCT |
| a7f06826-8282-4538-80a3-489557f6af02 | 1d7be20b-b4ca-47bb-9552-689f2e3ff0f7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-A4SU | TCGA-44-A4SU-01A | Tumor | Primary | Unknown | Unknown |
| ec343407-2a9c-42fc-800f-26f9e0d94c7c | 1efac920-fb46-4ac8-b8b1-d1f2743edefe.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7907 | TCGA-55-7907-01A | Tumor | Primary | Solid Tissue | Unknown |
| e3ace32f-865a-47d5-b397-b9a96bc83519 | 05ca3ffd-a4d9-4667-80e2-d15125e88f7c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4M1 | TCGA-97-A4M1-01A | Tumor | Primary | Unknown | OCT |
| 95a7b088-bb5e-4eb7-a09d-2be656b761ef | fcfff41c-378f-49e8-b416-ccd1b9d8b4b4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8672 | TCGA-86-8672-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8cadcbf6-1b87-4147-8c6c-989a4493b5e8 | f99ac82f-4fe6-4a9a-9d49-67c42cf66208.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7160 | TCGA-78-7160-01A | Tumor | Primary | Solid Tissue | Unknown |
| 20592e25-4b12-4cd3-b1b1-b8e8d6352960 | a0c9ebdf-951b-4d8d-aa79-3ff1c82342cd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7659 | TCGA-44-7659-01A | Tumor | Primary | Solid Tissue | Unknown |
| 21e081b7-7d9c-4450-9c5f-37d7c6fd3b8a | 2f03d42e-9735-4edb-87d9-ec443b7801a5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4514 | TCGA-49-4514-01A | Tumor | Primary | Solid Tissue | Unknown |
| 27731400-551e-4b9d-9ad3-eee2c209b3b2 | 1e3d606d-e374-460c-a046-b6c98aa8256b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-6217 | TCGA-67-6217-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8398f037-19ad-41f5-9d8c-afb9580fdd88 | 367864dd-ccd2-473e-9661-6ff4342a4e64.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4658 | TCGA-73-4658-01A | Tumor | Primary | Solid Tissue | Unknown |
| b71478d5-00d8-4a78-93f6-c3db55299251 | 98d020b1-0467-4131-a3cc-64d288d0e9e7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-7271 | TCGA-38-7271-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7528d4c5-25d1-4200-90b8-177e3874f2c4 | 22002e84-1d7a-4f93-9934-9d74f45195c0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7914 | TCGA-55-7914-01A | Tumor | Primary | Solid Tissue | Unknown |
| 192318a1-c93d-4669-bb23-ca2e8aceb7da | 6906b453-44ef-404a-9fe6-2b4d5fa65110.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2661 | TCGA-44-2661-01A | Tumor | Primary | Unknown | Unknown |
| 98754b25-9c39-4830-b260-2d92b28f2e7a | fe3a5a49-7744-4336-a4b6-0e88f23e21d8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5932 | TCGA-50-5932-01A | Tumor | Primary | Solid Tissue | Unknown |
| 52cffdce-261c-4c82-9b64-5f9e84a8c5ab | b8e8f06f-a5a9-4d16-b39f-585dcee31087.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2655 | TCGA-44-2655-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8863b8af-1ec2-4b06-ad68-b918a4c477c5 | 9a5e0fa6-a785-4d8e-bca5-43e02a3965bf.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01A | Tumor | Primary | Solid Tissue | Unknown |
| 569cdcb4-9c4e-4dfb-8c24-506290f31ac5 | 3ce23908-d2b9-42b0-a409-5fbd767496c2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-6742 | TCGA-49-6742-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2ae21172-d280-47c0-99c4-e859d3094ddb | 020a2284-03f3-4439-89bb-2292ebc3ecd2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7562 | TCGA-95-7562-01A | Tumor | Primary | Solid Tissue | Unknown |
| 217e75fb-00de-4fe4-9ecb-88cf17da83a6 | 25212f64-8017-4b93-b171-10a830558566.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8090 | TCGA-55-8090-01A | Tumor | Primary | Solid Tissue | Unknown |
| fe6ef453-e5bb-4929-838e-bb0cd2670211 | 55e5447a-96d1-4d95-91ad-b5790392bbfa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5072 | TCGA-50-5072-01A | Tumor | Primary | Solid Tissue | Unknown |
| 73580d43-b951-449f-9bf9-49c276374f25 | 9d305ba3-6558-42ed-959c-4182de1c8ebb.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-7499 | TCGA-73-7499-01A | Tumor | Primary | Solid Tissue | Unknown |
| 11edcc88-7bd2-4974-87e8-2c66d4037b0e | 57ae0185-984b-40a7-8d95-1a6a2cc0b03a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A55R | TCGA-NJ-A55R-01A | Tumor | Primary | Solid Tissue | OCT |
| 519ed340-50d9-4077-a069-90d21bd1c4e2 | 681308e4-1122-4343-9d6b-63df6a39d302.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TH | TCGA-MP-A4TH-01A | Tumor | Primary | Solid Tissue | OCT |
| 5105f8b3-f462-411a-8908-520c896dee9f | 3e08ac76-9fba-40cf-8743-e2e1fb14f067.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6594 | TCGA-50-6594-01A | Tumor | Primary | Solid Tissue | Unknown |
| 54839351-9668-45b4-baf5-6497550f35a1 | 059b5dc1-45f7-4d7c-b07a-878b6db6d881.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7156 | TCGA-78-7156-01A | Tumor | Primary | Solid Tissue | Unknown |
| a7041b7e-b570-4530-870b-dad544233e6f | 7d46888b-282b-4f43-a09a-ff44bd1af110.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-1679 | TCGA-64-1679-01A | Tumor | Primary | Solid Tissue | Unknown |
| 80783fc2-e479-4889-9e55-69b4dc45541e | eda17fff-892d-440a-af83-b353ea60c478.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8669 | TCGA-86-8669-01A | Tumor | Primary | Solid Tissue | Unknown |
| c570f09a-bc8f-4919-bc59-491ab3501bdf | 4b6faa2b-5b8d-4ee5-ac5d-aafa6d95327f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-64-5778 | TCGA-64-5778-01A | Tumor | Primary | Solid Tissue | Unknown |
| f65e11a3-1c3c-4ecc-83ad-318d0c195656 | 3f79d678-e5d5-443e-a7df-187c2acd2b2c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6148 | TCGA-44-6148-01A | Tumor | Primary | Solid Tissue | Unknown |
| 02ad5c84-dbd7-4b21-bcae-2a0ad84edf66 | 89bcf4e2-f855-4035-bf0d-fe4917248223.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6971 | TCGA-55-6971-01A | Tumor | Primary | Unknown | Unknown |
| dad25a07-fb2a-42d0-95b6-b072afbdaa7c | e0dabde8-1dd8-4aa6-9f23-51dc22fc2cae.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-99-8033 | TCGA-99-8033-01A | Tumor | Primary | Solid Tissue | Unknown |
| 17d076ca-6d38-4ba4-9b69-63bc02297268 | 98f9eaa2-866f-4223-ad25-f93020214b4e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8205 | TCGA-55-8205-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8569cac6-a521-4353-bc94-36b922dfab44 | 4a1a0323-0cfb-4f33-ba44-0039283f9334.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-5126 | TCGA-75-5126-01A | Tumor | Primary | Solid Tissue | Unknown |
| 65e3ebf4-fd52-4b03-8c00-6b4ff514f135 | 156a175b-b419-4089-8541-7318e3dee78a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TJ | TCGA-MP-A4TJ-01A | Tumor | Primary | Solid Tissue | OCT |
| 3960a3cc-6466-449c-b3fe-1b7899396e01 | 56d2e7e0-7686-417f-a698-393a1385d87e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8510 | TCGA-55-8510-01A | Tumor | Primary | Solid Tissue | Unknown |
| b66c410a-03c1-463a-997a-16d08a339a2f | 64a2d5cb-2892-4d2a-aa7a-cc1a6dec1c46.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TA | TCGA-MP-A4TA-01A | Tumor | Primary | Unknown | OCT |
| 1d32c49b-04ce-4e59-b66e-db5d3b21f8b2 | 129a4f1c-81ee-4ebb-8c97-0a60fcc114d6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-99-7458 | TCGA-99-7458-01A | Tumor | Primary | Solid Tissue | Unknown |
| d5ce0725-ad99-4ce2-b57e-1953e5f73caa | 0a5dab01-33ff-41d1-8842-7b7f18a6efe0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6828 | TCGA-91-6828-01A | Tumor | Primary | Solid Tissue | Unknown |
| 4736a74a-6e21-423f-878f-a2b149cb6f60 | 38fbb0e8-cd18-425d-becf-791c8e8a8911.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AAQV | TCGA-49-AAQV-01A | Tumor | Primary | Solid Tissue | OCT |
| 98da3398-7003-4d3c-b715-2df3715cdfc3 | 56afb18f-7fdd-4672-be59-4d3a03b806de.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5049 | TCGA-50-5049-01A | Tumor | Primary | Solid Tissue | Unknown |
| f5b61758-7ddc-4ec1-a503-c6d7c0f05b34 | 34d64c67-b35b-418e-a7b2-759804876762.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6849 | TCGA-91-6849-01A | Tumor | Primary | Unknown | Unknown |
| 642f7c18-70c1-42e8-8d61-d0f22ecc8fe0 | 09728f38-787f-4868-b28d-8cf6afa3c71b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-5425 | TCGA-05-5425-01A | Tumor | Primary | Solid Tissue | Unknown |
| c31a33bb-f36f-44a5-ab8f-e951f6729247 | 65a2c4cf-7c84-4ca8-a37e-8deecb6ef026.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-7711 | TCGA-86-7711-01A | Tumor | Primary | Solid Tissue | Unknown |
| d289975b-8b9c-43be-91ec-10ebd401937f | 9ba0ff4b-4276-45ee-a543-a2e837777923.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-5899 | TCGA-55-5899-01A | Tumor | Primary | Solid Tissue | Unknown |
| 96894d18-665d-46f9-bb50-4289df746688 | e0819bee-5642-4297-b6bb-70e41d54ee8c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TC | TCGA-MP-A4TC-01A | Tumor | Primary | Unknown | OCT |
| f5d661f9-d7dd-43db-be6b-82abd42360fa | 03c7ece7-500d-4c38-a600-bd6863562bfd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-AARQ | TCGA-49-AARQ-01A | Tumor | Primary | Solid Tissue | OCT |
| 32faaebd-7733-4c3f-91ea-fd3c333480e9 | 8929ea12-e12a-4660-ac19-72b4e7bd2e9a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-6205 | TCGA-75-6205-01A | Tumor | Primary | Solid Tissue | Unknown |
| b2cc131e-837a-4e20-bcd5-aefaa1b36580 | 564e41d6-f9a4-4a6b-bb97-f8e5423b84bd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-8453 | TCGA-69-8453-01A | Tumor | Primary | Solid Tissue | Unknown |
| c646dd49-a4b1-4cea-8a0d-6cb3d1ba1ccc | f05d253b-7b64-4ecc-8249-55392326a91d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6975 | TCGA-55-6975-01A | Tumor | Primary | Unknown | Unknown |
| 587373d5-453d-46d9-91c9-134c31c2724d | e270dd9d-4a6b-40b3-823f-a46dd9493585.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7574 | TCGA-55-7574-01A | Tumor | Primary | Solid Tissue | Unknown |
| f15b9320-6a1c-4207-99ce-c68d579582a9 | 925a2268-1a0a-402b-8bb1-e6fa32521afe.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8278 | TCGA-86-8278-01A | Tumor | Primary | Solid Tissue | Unknown |
| 36726bf4-51b0-4c53-8f48-b91ad91d68d7 | aa305f5b-4c1d-4bc7-81d5-b2b999b327af.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-7554 | TCGA-97-7554-01A | Tumor | Primary | Solid Tissue | Unknown |
| a73cd583-7bfc-4abd-8ae4-da22875d621a | 2e86db3a-ac57-49d2-8378-5d5e7412eff7.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-6673 | TCGA-50-6673-01A | Tumor | Primary | Unknown | Unknown |
| 781ed88b-41a0-441f-8ab4-ed24928e0189 | dd20e202-a63c-4281-85c7-f16096212a91.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7662 | TCGA-44-7662-01A | Tumor | Primary | Solid Tissue | Unknown |
| f8566008-695a-4da1-aa9c-39d4f82f5ab4 | 56081bb7-480c-446f-9e21-41627df3b569.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7944 | TCGA-95-7944-01A | Tumor | Primary | Solid Tissue | Unknown |
| 9f9b1a22-8bf8-4a2b-8d5d-dcc84271519d | 2beab6d3-563d-421f-bf4a-7e1f843ec637.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8547 | TCGA-97-8547-01A | Tumor | Primary | Solid Tissue | Unknown |
| 257fde63-4725-42e6-ba36-ee5d0cb83d60 | c9494f0c-d6df-4dc9-a174-dfd53f121ee8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4675 | TCGA-73-4675-01A | Tumor | Primary | Unknown | Unknown |
| be2e8ac7-ff13-47aa-8eea-0a25af9628ce | f8a3b631-5140-45d0-8732-cb556d5f83b2.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7910 | TCGA-55-7910-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2eb79be5-f3db-4fd4-b6be-28989d87e4da | a6a841ae-f63f-45ab-9a17-2288e12a9577.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4433 | TCGA-05-4433-01A | Tumor | Primary | Solid Tissue | Unknown |
| b1bf2c29-5c13-4ca0-a755-1fdb8ccc835b | 77322072-2a7f-49e6-a9d1-c521c25acd70.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7980 | TCGA-69-7980-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7ff58d7a-dc47-44fc-9559-2afd969de542 | 7ec16b5a-7a86-4a22-9f1c-74d42ab1f43d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4506 | TCGA-49-4506-01A | Tumor | Primary | Unknown | Unknown |
| ea4712c3-719a-49d1-9985-1a0f955beec4 | 731c955b-e1e8-462a-9c94-64310f2d7eae.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MN-A4N4 | TCGA-MN-A4N4-01A | Tumor | Primary | Unknown | OCT |
| 4fc71e83-8aab-449f-807a-db5d6eb21ab9 | 99c5c1c4-851a-42a4-b5a2-dd9da2959343.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-5147 | TCGA-75-5147-01A | Tumor | Primary | Solid Tissue | Unknown |
| e3a7f754-fc76-4f6a-a4e2-8dd0f7592efc | f77f77e1-073c-4f6a-bc48-1ba165ecc024.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7154 | TCGA-78-7154-01A | Tumor | Primary | Solid Tissue | Unknown |
| 008889e9-6aab-4a0a-9204-e19c159f7c22 | 2306a9ab-37ae-4dfd-b992-4f62022c3d4c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-A4VK | TCGA-95-A4VK-01A | Tumor | Primary | Solid Tissue | OCT |
| e8f9fa2e-76cc-464c-8f74-adf5d4a8cd8f | aac03db2-1e90-4c0e-9094-4df06abeb84d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8508 | TCGA-55-8508-01A | Tumor | Primary | Solid Tissue | Unknown |
| a22b6af7-1f80-4937-8513-77835b9af610 | 9b4a912b-c42b-4a3a-8723-58b4dcb85949.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-53-7626 | TCGA-53-7626-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7063636e-1c79-4f3f-bd91-7470b03f36d3 | 1205cc6a-c42f-44c8-bf1c-84ef49eaaee4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-8457 | TCGA-50-8457-01A | Tumor | Primary | Solid Tissue | Unknown |
| b002c35d-78d6-4330-b793-98aec1591e21 | 9a54be5e-6201-4beb-9689-289b9849756e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01A | Tumor | Primary | Solid Tissue | Unknown |
| e161311b-eb34-42fd-b906-d0b4cfb7c15a | bae79640-8273-42a2-913e-3d29e00ccc4f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4488 | TCGA-49-4488-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7c8cde36-afef-49e3-a389-6aa07fdf0d88 | 32675d71-6f79-4b8f-ab7c-e2350b15875c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-A47G | TCGA-44-A47G-01A | Tumor | Primary | Unknown | Unknown |
| 69129378-91dc-45ce-80ed-f8c2480f954b | 3dde8e24-6a2b-49ab-b4df-c058f18a3851.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7536 | TCGA-78-7536-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0a26152a-462f-4895-8fe8-15fcdcc56e16 | 7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-67-6215 | TCGA-67-6215-01A | Tumor | Primary | Solid Tissue | Unknown |
| a507729c-05f1-4d90-bba5-58ec4cdd67fc | d6e945f2-4a94-48ab-9ba0-d4f0ee2fb262.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01A | Tumor | Primary | Solid Tissue | Unknown |
| 7e6b813e-6bf9-4492-96c3-24f2dd780e53 | 9e504ab4-85a0-465d-be52-0c28ed83e5f8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01A | Tumor | Primary | Solid Tissue | Unknown |
| b1d79b0e-960a-41e1-855c-82993ba9467b | 26fdaa75-cea5-4355-b3b1-6b5c2c75e542.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-5645 | TCGA-44-5645-01B | Tumor | Primary | Solid Tissue | FFPE |
| 187e65a9-5ac4-4251-9bc1-33a97123f5be | 655b5152-d150-4b2a-b7cc-ef70dc0b2256.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01A | Tumor | Primary | Solid Tissue | Unknown |
| bc44af8e-7a99-48f2-9dc1-a600c5f0622b | 12beb3ab-f6e1-42b0-af74-1a8cbb3416c0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-J2-A4AG | TCGA-J2-A4AG-01A | Tumor | Primary | Unknown | OCT |
| da56e0a9-c8d9-4a8b-b383-a51ae898eb09 | 2a05b2c0-f94d-4c07-889a-def7131895bd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-A4JF | TCGA-86-A4JF-01A | Tumor | Primary | Unknown | OCT |
| 35d8c3ca-0bff-457e-a6a3-4bd1ada93338 | f74d61fe-042f-4cfc-a32b-380389629951.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-A493 | TCGA-55-A493-01A | Tumor | Primary | Unknown | Unknown |
| 87dcc4ae-40bb-4a1b-b04b-265e8ebff3f4 | 0f6c0159-7342-4519-83f5-52c2d457c4f8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7147 | TCGA-78-7147-01A | Tumor | Primary | Solid Tissue | Unknown |
| a43a2403-a20e-4034-b8a8-b4fd63a72438 | ec3a68ca-1006-4f2f-95b5-74d506ceda86.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7148 | TCGA-78-7148-01A | Tumor | Primary | Solid Tissue | Unknown |
| 39d167f8-3e54-462e-ba6a-f1ca798390bf | 91181a9c-3113-47b6-8d1c-8173f9eac675.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6712 | TCGA-55-6712-01A | Tumor | Primary | Solid Tissue | Unknown |
| c62f1c03-7843-42a6-bab6-847719d83162 | 28e5e6cc-60b0-4324-b05e-d05af474da90.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-7978 | TCGA-69-7978-01A | Tumor | Primary | Solid Tissue | Unknown |
| 82cff7f3-b017-4c73-a990-87b16b0a997e | 3041806b-5855-4930-aeb8-a30472658d54.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-4B-A93V | TCGA-4B-A93V-01A | Tumor | Primary | Solid Tissue | OCT |
| e3a70d2b-e1da-4641-a7c7-9380d4b5be6a | 6b51d2ce-51ed-4b34-890d-9f83d363118c.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-7347 | TCGA-93-7347-01A | Tumor | Primary | Solid Tissue | Unknown |
| aa7245fd-7073-4ff9-88cc-648a2c9f1f60 | 7b07706f-a1b4-4f18-a276-0822b578cc40.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5941 | TCGA-50-5941-01A | Tumor | Primary | Solid Tissue | Unknown |
| d24316e2-23a5-4a25-8563-9539a76dffe2 | 9fde5e1d-5b86-411d-b194-3eb3c6305ebd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4TK | TCGA-MP-A4TK-01A | Tumor | Primary | Unknown | OCT |
| 010a8fbf-0d4f-4c48-b405-63fe2e272d34 | 0a11e8dc-5d34-4fcb-b2dc-aa57b4e90fc9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7146 | TCGA-78-7146-01A | Tumor | Primary | Solid Tissue | Unknown |
| 75764f6a-cd79-47f5-acd0-e280cd56f551 | 61807b4d-bbab-4ea8-a904-35c562ec6c29.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-A4SS | TCGA-44-A4SS-01A | Tumor | Primary | Unknown | Unknown |
| 347924ac-b049-4a8b-a298-ba3a246f58e9 | 1890feb6-9f7f-4437-9828-198ff43e16b0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3398 | TCGA-44-3398-01A | Tumor | Primary | Unknown | Unknown |
| 51645a28-9e36-462d-a069-bce88ef445e9 | 3d11905a-16eb-40b2-a36b-e37dca6359d3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2662 | TCGA-44-2662-01B | Tumor | Primary | Solid Tissue | FFPE |
| ba3d2868-fdcf-4c29-9fc6-5c2284ab27eb | 981bfd73-1d4c-47c0-870a-b9a6300858dc.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4415 | TCGA-05-4415-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6e5d3cd8-236c-490c-a567-db41dbe1ca3c | 67fc0674-3f48-41ec-a650-7efaa41607fa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-NJ-A55A | TCGA-NJ-A55A-01A | Tumor | Primary | Solid Tissue | OCT |
| 86c05b02-68d0-473d-8aea-ab501cb40d29 | 59e8b7b7-5183-4655-aa5e-e4b5ba73eded.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7727 | TCGA-55-7727-01A | Tumor | Primary | Solid Tissue | Unknown |
| 66fa5eaf-554c-4164-9502-660a5932bfe7 | 58e4f0e6-3b0f-4370-8abf-0b4d533672c5.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01A | Tumor | Primary | Solid Tissue | Unknown |
| e2c57b01-796f-4e28-9ad4-a8aa8239944a | 8bd7c2cf-7960-46ca-9373-1c19557dd0aa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-99-AA5R | TCGA-99-AA5R-01A | Tumor | Primary | Solid Tissue | OCT |
| 12c918f4-ac2b-4e6f-8497-cf5b4388b268 | 812033b2-3784-44bf-8913-56307b267ea9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2668 | TCGA-44-2668-01B | Tumor | Primary | Solid Tissue | FFPE |
| e175b52a-4ae7-4f33-ac4b-1e328d6f531a | fec7a02d-1d67-412d-9d69-df7124864e7a.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8507 | TCGA-55-8507-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3424991a-dbbf-4a86-839a-c714f1b51371 | 6e2e3178-73ad-4590-a56b-bb7fd9984acd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6969 | TCGA-55-6969-01A | Tumor | Primary | Unknown | Unknown |
| 9454ef92-c151-42c4-9b09-e50ed418483c | 978fb63c-dae9-4037-81c9-598e87341931.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-38-4627 | TCGA-38-4627-01A | Tumor | Primary | Unknown | Unknown |
| 482d4898-2791-46e0-8a59-ec8ebcd10103 | d3ebb2ea-10db-4c29-8e7c-7c13b23b5b15.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46O | TCGA-62-A46O-01A | Tumor | Primary | Unknown | OCT |
| 4699cd8b-a11f-4151-a2ed-0618a476800b | 9aa5eb7d-1d54-47f6-aeeb-59be4880f004.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8280 | TCGA-86-8280-01A | Tumor | Primary | Solid Tissue | Unknown |
| d5a80216-48b2-4ac1-b1a0-c733a55df37c | e6992421-f34c-4a68-a218-d53f56d0f562.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-75-7030 | TCGA-75-7030-01A | Tumor | Primary | Unknown | Unknown |
| 15b605d3-cf71-406d-b704-6e0759faac8c | cc1646da-11b3-40c7-b35e-1206f4517b36.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2666 | TCGA-44-2666-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0d6aff01-c03e-44cd-9c79-47a265e41af9 | 160dd8d4-3262-4789-bd92-d5470bc7d41b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46S | TCGA-62-A46S-01A | Tumor | Primary | Unknown | OCT |
| bfb30c6d-458c-4081-82ce-671322d43361 | 9446312e-b87c-411c-b9a3-a19603eff965.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-5715 | TCGA-05-5715-01A | Tumor | Primary | Solid Tissue | Unknown |
| dc5e59df-ba18-4b5a-a9b5-a951faeb6311 | 404aadcc-cb30-4dba-b2b3-efd573cd9ffe.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8087 | TCGA-55-8087-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2a600a38-215c-4b2b-9b9d-ab5d3b9a0bbc | dc3ac0d3-d862-4761-ac12-60bb4d6758c1.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6985 | TCGA-55-6985-01A | Tumor | Primary | Unknown | Unknown |
| 214bfc0e-7c53-40a4-8944-ca4373165693 | 2276a330-e86b-46e1-be45-ae41d217ef66.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-A4LX | TCGA-97-A4LX-01A | Tumor | Primary | Unknown | OCT |
| 1f12b7cb-c38e-4337-9c72-a0f7797b8aa4 | b5cadc0c-3088-4f81-9561-902c8ca44c2d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-J2-A4AE | TCGA-J2-A4AE-01A | Tumor | Primary | Unknown | OCT |
| 0a92e2c6-0646-42ae-b873-509bc9c3ca5b | ebc79b86-12cb-4a5b-b0e4-4d1017ef22f4.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A470 | TCGA-62-A470-01A | Tumor | Primary | Unknown | OCT |
| b3ebc890-4e31-4d50-a51b-1d8d13555d24 | 6667948a-1834-4572-a1b3-3bc9096650e8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7542 | TCGA-78-7542-01A | Tumor | Primary | Solid Tissue | Unknown |
| 61366adb-bf35-4f12-a12b-b69736994e74 | b7f9da49-2a09-4f32-af6c-980ccf75250b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-93-7348 | TCGA-93-7348-01A | Tumor | Primary | Solid Tissue | Unknown |
| 5fa0513c-3de7-4d3b-9df0-83f2df36b947 | 4102816c-2ab8-4ecb-83b0-4f78c052bcd8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6543 | TCGA-55-6543-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6c067003-63d2-49e8-ade8-b5271dcfbd56 | 49932944-ad54-4c6c-affc-08a4b76de933.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6984 | TCGA-55-6984-01A | Tumor | Primary | Unknown | Unknown |
| eb7d37ec-dba8-40fc-ae8c-719b59b5883b | aa0b2722-97db-4b5a-9a56-213f63255097.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-69-8254 | TCGA-69-8254-01A | Tumor | Primary | Solid Tissue | Unknown |
| fe75bde2-884e-43b3-a0db-2cacfbde1abe | a5f6ddd7-f795-4920-b714-ed86942953e3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-97-8175 | TCGA-97-8175-01A | Tumor | Primary | Solid Tissue | Unknown |
| ce3af9d8-a66b-48ea-bb32-c3cd31341ced | a308a190-de5d-401c-a030-e089cb6d39db.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-35-3615 | TCGA-35-3615-01A | Tumor | Primary | Solid Tissue | Unknown |
| d24a81e6-fad6-46db-aee7-c84f39d01fd3 | 268f14f5-e6f7-413a-90a6-20a205012246.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8505 | TCGA-55-8505-01A | Tumor | Primary | Unknown | Unknown |
| 66e98d41-1773-46f6-89bb-c4934808828d | e8ea2e59-65dc-49c9-b6f3-b9335185390d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-A4BC | TCGA-91-A4BC-01A | Tumor | Primary | Unknown | Unknown |
| 53af895c-0ab2-46f6-ab0e-5157d357c1a3 | 8e1fcc77-bf23-42e4-949f-d429f7211dd6.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-86-8668 | TCGA-86-8668-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2084ae71-c36c-4247-ad79-64a4f9be50b9 | 1084d48c-88e8-4d67-9049-d0e4cd7f9535.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-A46V | TCGA-62-A46V-01A | Tumor | Primary | Unknown | OCT |
| cc47fcb4-905b-48b6-b89b-eecbac7f7f8f | 49acc5ad-6a61-41e1-9acb-4260e932a184.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7570 | TCGA-55-7570-01A | Tumor | Primary | Solid Tissue | Unknown |
| b59b480f-ac76-4ed2-9e63-a090036448e2 | 77b82c3f-e20c-4e3b-a55c-08af359bbb6e.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown |
| ffcd16af-be94-41bf-acd7-f571ec7e2d16 | e789fc5c-1218-4f07-ba95-b54d8fb93e7b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5044 | TCGA-50-5044-01A | Tumor | Primary | Solid Tissue | Unknown |
| 2028c5cc-3285-4683-ade5-79a7c768678e | 19853c82-c205-4af9-badd-82946eec14ad.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7220 | TCGA-78-7220-01A | Tumor | Primary | Solid Tissue | Unknown |
| 73c368dd-99db-4e34-a02f-fdff478a491c | af649713-fb41-496a-a94b-3691d202c1c8.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-2665 | TCGA-44-2665-01A | Tumor | Primary | Solid Tissue | Unknown |
| 063096ed-9c17-4609-9246-eb3e5fa550a6 | bd1e3dcd-31c4-4f7f-8e99-9ad0d1050294.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7167 | TCGA-78-7167-01A | Tumor | Primary | Solid Tissue | Unknown |
| 80188ed0-954f-44d9-a212-fe88b8927b62 | 921aa14f-d674-4ecf-b4fd-ca846acc9fa3.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-1596 | TCGA-55-1596-01A | Tumor | Primary | Solid Tissue | Unknown |
| bb3bf0cd-d755-42b2-b9bc-0d09bf7490ca | d067f93b-7182-4a34-ba8e-be73589b7420.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-95-7043 | TCGA-95-7043-01A | Tumor | Primary | Unknown | Unknown |
| 20769457-c733-425b-b8bd-45c044f4ebe6 | 27e24fc6-af40-4152-8424-a9d365c717d9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8511 | TCGA-55-8511-01A | Tumor | Primary | Solid Tissue | Unknown |
| 47d9b806-84c4-4b60-8b5a-10453f11c4fc | 7623e22f-3401-47b3-be94-23f5da20ee0d.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6776 | TCGA-44-6776-01A | Tumor | Primary | Solid Tissue | Unknown |
| e8f2cdea-1430-43ad-8359-ead8b4c5fd6e | aea4fa60-a890-453e-8ba6-6f4f3d5ed084.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-73-4670 | TCGA-73-4670-01A | Tumor | Primary | Unknown | Unknown |
| 6f2a3937-7e81-49c1-a734-2be886114e03 | ee030015-242a-4dd1-b43c-2c97d5d365d9.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-6147 | TCGA-44-6147-01B | Tumor | Primary | Solid Tissue | FFPE |
| 6390912d-9333-4be5-bbf8-bb875ce1f539 | 74ab82a4-a55b-4e4c-b3f5-1f9317860914.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7726 | TCGA-55-7726-01A | Tumor | Primary | Solid Tissue | Unknown |
| 01a38c32-c2e3-46c9-a108-e15456503b32 | af276b15-2dc4-4724-bbf5-1be8224b7f73.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-7724 | TCGA-55-7724-01A | Tumor | Primary | Solid Tissue | Unknown |
| a94f8de8-2203-4fe0-b007-6437973f1aaf | fa7777c7-e04a-41db-9ade-0c875c62411f.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-6979 | TCGA-55-6979-01A | Tumor | Primary | Unknown | Unknown |
| ce46ac67-6a51-4a71-9b5c-3412c8576c8c | 430458f1-86d8-4ec8-a8fe-6a58ac832bdd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4382 | TCGA-05-4382-01A | Tumor | Primary | Unknown | Unknown |
| 33c82dff-9f2f-47ec-9b6e-0dfd7e3c7a00 | 4a39a182-e583-4ff0-a8f0-f73b0f5c4f20.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-50-5939 | TCGA-50-5939-01A | Tumor | Primary | Solid Tissue | Unknown |
| 6c52a80e-6d42-47d2-8002-f29d22f2ad33 | e62d96e9-3e79-4eef-9e5e-568a48dd737b.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4434 | TCGA-05-4434-01A | Tumor | Primary | Unknown | Unknown |
| 6e90fa77-c338-4e9a-a43b-fa702386db08 | be547f27-5157-4947-ad2a-c9d006dedabd.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-7670 | TCGA-44-7670-01A | Tumor | Primary | Solid Tissue | Unknown |
| 0ff32a41-532d-4fe0-bccb-020787041956 | 02f6c9d4-8296-4e00-9e78-4f4d8c942340.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-6848 | TCGA-91-6848-01A | Tumor | Primary | Unknown | Unknown |
| 5b88cd1f-f27b-4b67-9c96-40ce8b4b5fcb | d2bf5f92-08f4-492e-96c2-399262f96828.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-05-4427 | TCGA-05-4427-01A | Tumor | Primary | Solid Tissue | Unknown |
| 3746aa6c-d1bf-47da-9f41-503be7406c24 | 04ce9fac-b5f3-4830-935e-9d6ea74ee915.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-MP-A4T6 | TCGA-MP-A4T6-01A | Tumor | Primary | Solid Tissue | OCT |
| 18f16ad8-57a8-42be-bf7d-335a8b5e5026 | 2f966635-6a77-4205-9bab-df5940a973aa.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-91-8496 | TCGA-91-8496-01A | Tumor | Primary | Solid Tissue | Unknown |
| 8c6e36e9-04a8-4fc2-b91b-7d145ff18fc2 | c2c5b3f8-abe2-4112-9ddd-70056f268137.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-62-8399 | TCGA-62-8399-01A | Tumor | Primary | Solid Tissue | Unknown |
| a1da795d-51ef-43db-a947-7331f81c16e5 | 7276835e-ce0e-4fc6-a329-27d936c136ba.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8094 | TCGA-55-8094-01A | Tumor | Primary | Solid Tissue | Unknown |
| 1d93cae2-d8e3-4e9d-a097-240d3c06e6a1 | 81e85e60-a0b6-4898-8cb0-02ac1a70f157.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-44-3919 | TCGA-44-3919-01A | Tumor | Primary | Unknown | Unknown |
| 9702a272-3cf7-41ad-b43b-acb7c75b476d | b0747254-d7fd-4ec9-96b1-d132540c4b46.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8514 | TCGA-55-8514-01A | Tumor | Primary | Solid Tissue | Unknown |
| 55f3d950-45c3-432b-97bf-2d5be83902d4 | 8dc8ccd2-a842-4a48-a8db-007855733fc0.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-49-4490 | TCGA-49-4490-01A | Tumor | Primary | Solid Tissue | Unknown |
| f0499aec-b57d-4818-a691-656b1bfac0cf | b6e9752c-ad52-457d-a37c-78ffb7ddc520.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-78-7537 | TCGA-78-7537-01A | Tumor | Primary | Solid Tissue | Unknown |
| aebbfe45-f4ba-4e22-a642-dc24dff06bf2 | 7086e8ce-d1e5-4901-ac33-31c299f46356.rna_seq.genomic.gdc_realn.bam | Sequencing Reads | Aligned Reads | TCGA-LUAD | TCGA-55-8204 | TCGA-55-8204-01A | Tumor | Primary | Solid Tissue | Unknown |

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
