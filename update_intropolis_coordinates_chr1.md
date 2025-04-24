# update intropolis coordinates chr1.rmarkdown
Holly Beale
2025-04-24

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

# change settings for test run

``` r
# base_dir <- "/mnt/data/"
base_dir <- "/mnt/data/intropolis_chr1/"
# base_dir <- "/mnt/tiny_data/"

send_alerts <- TRUE
```

# setup for /mnt/tiny_data/

(previously run; do not re-run)

    mkdir /mnt/tiny_data/
    zcat /mnt/data/2020.11.16.intropolis_PS.tsv.gz | head -1000 | gzip > /mnt/tiny_data/2020.11.16.intropolis_PS.tsv.gz
    mkdir -p /mnt/tiny_data/dennisrm/tcga/luad
    zcat /mnt/data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz | head -1000 | gzip > /mnt/tiny_data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz
    chmod 777 -R /mnt/tiny_data/

# setup for chr1-only inputs

(previously run; do not re-run)

    base_dir=/mnt/data/intropolis_chr1/
    mkdir -p ${base_dir}/dennisrm/tcga/luad/

    zcat /mnt/data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz | grep -E '(^cluster|^chr1:)' | pigz > ${base_dir}/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz; ~/alertme.sh

    zcat /mnt/data/2020.11.16.intropolis_PS.tsv.gz  | grep -E '(^cluster|^chr1:)' | pigz > ${base_dir}/2020.11.16.intropolis_PS.tsv.gz; ~/alertme.sh

define files name variables in R

``` r
# inputs
original_intropolis_PS_file <- paste0(base_dir, "2020.11.16.intropolis_PS.tsv.gz")
luad_PS_file <- paste0(base_dir, "dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz")

# outputs
original_intropolis_cluster_ids_file <- paste0(base_dir, "2020.11.16.intropolis_PS.cluster_id_only.awk.tsv.gz")
luad_and_corresponding_intropolis_cluster_ids_file <- paste0(base_dir, "luad_and_corresponding_intropolis_cluster_ids.tsv.gz")
luad_cluster_ids_in_intropolis_format_file <- paste0(base_dir, "luad_cluster_ids_in_intropolis_format.tsv.gz")

intropolis_PS_present_in_luad_file <- paste0(base_dir, "2020.11.16.intropolis_PS.in_luad.tsv.gz")

intropolis_cluster_ids_present_in_luad_file <- paste0(base_dir, "intropolis_cluster_ids_present_in_luad.gz")
new_intropolis_cluster_ids_in_order_file <- paste0(base_dir, "new_intropolis_cluster_ids_in_order.tsv.gz")

intropolis_no_cluster_id_file <- paste0(base_dir, "2020.11.16.intropolis_PS.in_luad.no_cluster_id.tsv.gz")
intropolis_PS_updated_cluster_ids_file  <- paste0(base_dir, "2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz")
```

set variables in the bash environment

``` r
Sys.setenv(original_intropolis_PS_file = original_intropolis_PS_file)
Sys.setenv(luad_PS_file = luad_PS_file)

Sys.setenv(original_intropolis_cluster_ids_file = original_intropolis_cluster_ids_file)
Sys.setenv(luad_and_corresponding_intropolis_cluster_ids_file = luad_and_corresponding_intropolis_cluster_ids_file)
Sys.setenv(luad_cluster_ids_in_intropolis_format_file = luad_cluster_ids_in_intropolis_format_file)
Sys.setenv(intropolis_PS_present_in_luad_file = intropolis_PS_present_in_luad_file)

Sys.setenv(intropolis_cluster_ids_present_in_luad_file = intropolis_cluster_ids_present_in_luad_file)
Sys.setenv(new_intropolis_cluster_ids_in_order_file = new_intropolis_cluster_ids_in_order_file)
Sys.setenv(intropolis_no_cluster_id_file = intropolis_no_cluster_id_file)

Sys.setenv(intropolis_PS_updated_cluster_ids_file = intropolis_PS_updated_cluster_ids_file)
```

confirm input variables in the bash environment

``` bash

echo $original_intropolis_PS_file
echo $luad_PS_file
```

    /mnt/data/intropolis_chr1/2020.11.16.intropolis_PS.tsv.gz
    /mnt/data/intropolis_chr1/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz

# characterize input files

``` bash

date
ls -lh $original_intropolis_PS_file
zcat $original_intropolis_PS_file | head | cut -f1-6 
zcat $original_intropolis_PS_file | wc -l
date

echo
ls -lh $luad_PS_file
zcat $luad_PS_file  | head | cut -f1-6
zcat $luad_PS_file | wc -l
date
```

    Thu Apr 24 21:54:45 UTC 2025
    -rwxrwxrwx 1 ubuntu ubuntu 2.7G Apr 24 19:07 /mnt/data/intropolis_chr1/2020.11.16.intropolis_PS.tsv.gz
    cluster 0   1   2   4   5
    chr1:14830-14969    nan nan nan nan 0.500
    chr1:14830-15795    nan nan 0.000   nan 0.333
    chr1:15039-15795    nan nan 1.000   nan 0.500
    chr1:15099-15795    nan nan 0.000   nan 0.000
    chr1:15562-15795    nan nan 0.000   nan 0.000
    chr1:15943-16606    nan 0.000   0.000   nan nan
    chr1:15948-16606    nan 0.800   0.944   nan nan
    chr1:16311-16606    nan 0.200   0.056   nan nan
    chr1:16766-16853    nan nan nan nan nan
    405119
    Thu Apr 24 22:01:23 UTC 2025

    -rwxrwxrwx 1 ubuntu ubuntu 19M Apr 24 17:47 /mnt/data/intropolis_chr1/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz
    cluster 00d461ae-a1d8-42f2-abd8-5e159363d857    00fabec9-d311-4994-a7e5-eb91178d14f2    01ebdef8-920f-4b71-8b44-512598962d6b    020a2284-03f3-4439-89bb-2292ebc3ecd2    02f6c9d4-8296-4e00-9e78-4f4d8c942340
    chr1:11211-12009:+  nan nan nan nan nan
    chr1:11844-12009:+  nan nan nan nan nan
    chr1:12227-12612:+  nan nan nan nan nan
    chr1:12721-13220:+  0.000   0.000   1.000   nan nan
    chr1:13052-13220:+  1.000   1.000   0.000   nan nan
    chr1:13374-13452:+  nan nan nan nan nan
    chr1:14784-14977:-  nan 0.000   0.000   0.000   0.000
    chr1:14829-14929:-  nan 1.000   0.000   0.000   0.000
    chr1:14829-14969:-  nan 0.000   0.000   0.000   0.000
    79845
    Thu Apr 24 22:01:24 UTC 2025

# convert luad cluster IDs to intropolis format

## load data

``` r
luad_PS <- read_tsv(luad_PS_file)
```

    Rows: 79844 Columns: 591
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr   (1): cluster
    dbl (590): 00d461ae-a1d8-42f2-abd8-5e159363d857, 00fabec9-d311-4994-a7e5-eb9...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

## make cluster IDs like the ones in intropolis

``` r
# break cluster IDs into parts
# warning message "Expected 4 pieces." is acceptable
luad_PS_cluster_ids <- luad_PS %>%
  select(cluster) %>%
  separate(cluster, 
           into = c("chr", "start", "stop", "strand"),
           convert = TRUE,
           remove = FALSE) %>%
  mutate(strand = str_sub(cluster, -1))

# exclude chromosomes with "random" and "chrUn" in the name"
luad_PS_cluster_ids_in_main_chr <- luad_PS_cluster_ids %>%
  filter(! stop == "random",
         ! chr == "chrUn") %>%
  mutate(stop_num = as.numeric(stop),
         start_num = as.numeric(start))

# add 1 in the start pos
luad_cluster_ids_with_intropolis_format <- luad_PS_cluster_ids_in_main_chr %>%
  rename(luad_cluster_id = cluster) %>%
  mutate(intropolis_start = start_num + 1,
        intropolis_cluster_id  = paste0(chr, ":", intropolis_start, "-", stop_num)) 

head (luad_cluster_ids_with_intropolis_format)
```

| luad_cluster_id | chr | start | stop | strand | stop_num | start_num | intropolis_start | intropolis_cluster_id |
|:---|:---|---:|---:|:---|---:|---:|---:|:---|
| chr1:11211-12009:+ | chr1 | 11211 | 12009 | \+ | 12009 | 11211 | 11212 | chr1:11212-12009 |
| chr1:11844-12009:+ | chr1 | 11844 | 12009 | \+ | 12009 | 11844 | 11845 | chr1:11845-12009 |
| chr1:12227-12612:+ | chr1 | 12227 | 12612 | \+ | 12612 | 12227 | 12228 | chr1:12228-12612 |
| chr1:12721-13220:+ | chr1 | 12721 | 13220 | \+ | 13220 | 12721 | 12722 | chr1:12722-13220 |
| chr1:13052-13220:+ | chr1 | 13052 | 13220 | \+ | 13220 | 13052 | 13053 | chr1:13053-13220 |
| chr1:13374-13452:+ | chr1 | 13374 | 13452 | \+ | 13452 | 13374 | 13375 | chr1:13375-13452 |

``` r
luad_cluster_ids_with_intropolis_format_min <- luad_cluster_ids_with_intropolis_format %>%
  select(luad_cluster_id, intropolis_cluster_id)
```

# de-duplicate

in tiny data with 1000 samples, 276 entries had cluster ids that differ
only depending on whether the positive or negative strand

in all these cases, i excluded one; usually the negative strand cluster
id

``` r
dupes_just_1 <- luad_cluster_ids_with_intropolis_format_min %>%
    filter(duplicated(intropolis_cluster_id))


if (base_dir == "/mnt/tiny_data/"){ # show what the data looks like 
  
  dupes_both <- luad_cluster_ids_with_intropolis_format_min %>%
    filter(intropolis_cluster_id %in% dupes_just_1$intropolis_cluster_id)
  
  luad_PS %>%
    filter(str_detect(cluster, "chr1:16027-16606")) %>%
    mutate(mean_PS = rowSums(pick(where(is.numeric)), na.rm = TRUE)/(ncol(luad_PS)-1)) %>%
    select(cluster, mean_PS)
  
  luad_PS %>%
    filter(cluster %in%  dupes_both$luad_cluster_id) %>%
    arrange(cluster) %>%
    mutate(mean_PS = rowSums(pick(where(is.numeric)), na.rm = TRUE)/(ncol(luad_PS)-1)) %>%
    select(cluster, mean_PS) %>%
    head
}

luad_cluster_ids_with_intropolis_format_min_no_dupes <- luad_cluster_ids_with_intropolis_format_min %>%
  filter(! intropolis_cluster_id %in% dupes_just_1$intropolis_cluster_id)
```

## write output

``` r
write_tsv(luad_cluster_ids_with_intropolis_format_min_no_dupes, 
          luad_and_corresponding_intropolis_cluster_ids_file)


luad_cluster_ids_with_intropolis_format_min_no_dupes %>% 
            select(cluster = intropolis_cluster_id) %>%
            write_tsv(luad_cluster_ids_in_intropolis_format_file)
```

check output

``` bash
date
ls -lh $luad_and_corresponding_intropolis_cluster_ids_file
zcat $luad_and_corresponding_intropolis_cluster_ids_file | head 
zcat $luad_and_corresponding_intropolis_cluster_ids_file |  wc -l 
```

    Thu Apr 24 22:01:39 UTC 2025
    -rw-r--r-- 1 hbeale hbeale 506K Apr 24 22:01 /mnt/data/intropolis_chr1/luad_and_corresponding_intropolis_cluster_ids.tsv.gz
    luad_cluster_id intropolis_cluster_id
    chr1:11211-12009:+  chr1:11212-12009
    chr1:11844-12009:+  chr1:11845-12009
    chr1:12227-12612:+  chr1:12228-12612
    chr1:12721-13220:+  chr1:12722-13220
    chr1:13052-13220:+  chr1:13053-13220
    chr1:13374-13452:+  chr1:13375-13452
    chr1:14784-14977:-  chr1:14785-14977
    chr1:14829-14929:-  chr1:14830-14929
    chr1:14829-14969:-  chr1:14830-14969
    51597

# make subset intropolis data

``` bash
date
rm  ${luad_cluster_ids_in_intropolis_format_file/.gz}
gzip -d --keep $luad_cluster_ids_in_intropolis_format_file
zcat $original_intropolis_PS_file | grep -f ${luad_cluster_ids_in_intropolis_format_file/.gz} | pigz > $intropolis_PS_present_in_luad_file

date
```

    Thu Apr 24 22:01:39 UTC 2025
    rm: cannot remove '/mnt/data/intropolis_chr1/luad_cluster_ids_in_intropolis_format.tsv': No such file or directory
    Thu Apr 24 22:09:45 UTC 2025

``` r
if(send_alerts) system("~/alert_msg.sh 'limited intropolis data to luad'")
```

check output

``` bash
date
ls -lh $intropolis_PS_present_in_luad_file
zcat $intropolis_PS_present_in_luad_file | head | cut -f1-6
zcat $intropolis_PS_present_in_luad_file | wc -l 
```

    Thu Apr 24 22:09:46 UTC 2025
    -rw-r--r-- 1 hbeale hbeale 560M Apr 24 22:09 /mnt/data/intropolis_chr1/2020.11.16.intropolis_PS.in_luad.tsv.gz
    cluster 0   1   2   4   5
    chr1:14830-14969    nan nan nan nan 0.500
    chr1:14830-15795    nan nan 0.000   nan 0.333
    chr1:15039-15795    nan nan 1.000   nan 0.500
    chr1:15943-16606    nan 0.000   0.000   nan nan
    chr1:15948-16606    nan 0.800   0.944   nan nan
    chr1:16311-16606    nan 0.200   0.056   nan nan
    chr1:17056-17232    nan nan nan nan nan
    chr1:17056-29320    0.000   nan 0.000   nan 0.000
    chr1:17369-17525    nan nan nan nan nan
    38934

# get list of IDs in reduced intropolis data

``` bash

date
zcat $intropolis_PS_present_in_luad_file | awk '{print $1}' | grep -v cluster | pigz > $intropolis_cluster_ids_present_in_luad_file
date
```

    Thu Apr 24 22:10:30 UTC 2025
    Thu Apr 24 22:11:15 UTC 2025

``` r
if(send_alerts) system("~/alert_msg.sh 'got list of IDs in reduced intropolis data'")
```

# reorder the luad cluster IDs

goal: they should be in the same order as intropolis cluster IDs from
the reduced intropolis data (exclude any luad cluster IDs not in
intropolis)

``` r
luad_and_corresponding_intropolis_cluster_ids <- read_tsv(luad_and_corresponding_intropolis_cluster_ids_file)
```

    Rows: 51596 Columns: 2
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (2): luad_cluster_id, intropolis_cluster_id

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
intropolis_cluster_ids <- read_tsv(intropolis_cluster_ids_present_in_luad_file,
                                   col_names = "original_intropolis_cluster_id")
```

    Rows: 38933 Columns: 1
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (1): original_intropolis_cluster_id

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
intropolis_cluster_ids_two_formats_raw <- left_join(intropolis_cluster_ids,
                                                    luad_and_corresponding_intropolis_cluster_ids,
                                                    by=c("original_intropolis_cluster_id"="intropolis_cluster_id") )

intropolis_cluster_ids_two_formats <- intropolis_cluster_ids_two_formats_raw %>%
  rename(updated_intropolis_cluster_id = luad_cluster_id)


intropolis_cluster_ids_two_formats %>% 
  select(cluster = updated_intropolis_cluster_id) %>%
  write_tsv(new_intropolis_cluster_ids_in_order_file)
```

check output

``` bash
date
ls -lh $new_intropolis_cluster_ids_in_order_file
zcat $new_intropolis_cluster_ids_in_order_file | head | cut -f1-6
zcat $new_intropolis_cluster_ids_in_order_file | wc -l 
```

    Thu Apr 24 22:11:16 UTC 2025
    -rw-r--r-- 1 hbeale hbeale 234K Apr 24 22:11 /mnt/data/intropolis_chr1/new_intropolis_cluster_ids_in_order.tsv.gz
    cluster
    chr1:14829-14969:-
    chr1:14829-15795:-
    chr1:15038-15795:-
    chr1:15942-16606:-
    chr1:15947-16606:-
    chr1:16310-16606:-
    chr1:17055-17232:-
    chr1:17055-29320:-
    chr1:17368-17525:-
    38934

## replace cluster ID in intropolis PS file

``` bash
date
# remove cluster ids from column 1 
zcat $intropolis_PS_present_in_luad_file | cut -f2- | pigz  > $intropolis_no_cluster_id_file 
date

# add new cluster ids in column 1
paste <(zcat $new_intropolis_cluster_ids_in_order_file) <(zcat $intropolis_no_cluster_id_file) | pigz > $intropolis_PS_updated_cluster_ids_file
date
```

    Thu Apr 24 22:11:16 UTC 2025
    Thu Apr 24 22:13:33 UTC 2025
    Thu Apr 24 22:14:55 UTC 2025

``` r
if(send_alerts) system("~/alert_msg.sh 'replaced cluster ID in intropolis PS file'")
```

check output

``` bash

date

ls -lh $intropolis_PS_updated_cluster_ids_file

zcat $intropolis_PS_updated_cluster_ids_file | head | cut -f1-6

zcat $intropolis_PS_updated_cluster_ids_file | wc -l 

date
```

    Thu Apr 24 22:14:55 UTC 2025
    -rw-r--r-- 1 hbeale hbeale 560M Apr 24 22:14 /mnt/data/intropolis_chr1/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
    cluster 0   1   2   4   5
    chr1:14829-14969:-  nan nan nan nan 0.500
    chr1:14829-15795:-  nan nan 0.000   nan 0.333
    chr1:15038-15795:-  nan nan 1.000   nan 0.500
    chr1:15942-16606:-  nan 0.000   0.000   nan nan
    chr1:15947-16606:-  nan 0.800   0.944   nan nan
    chr1:16310-16606:-  nan 0.200   0.056   nan nan
    chr1:17055-17232:-  nan nan nan nan nan
    chr1:17055-29320:-  0.000   nan 0.000   nan 0.000
    chr1:17368-17525:-  nan nan nan nan nan
    38934
    Thu Apr 24 22:15:40 UTC 2025
