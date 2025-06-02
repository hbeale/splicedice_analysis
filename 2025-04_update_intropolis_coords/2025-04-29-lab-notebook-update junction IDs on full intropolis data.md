# 2025-04-29 lab notebook

## run script to update junction IDs on full intropolis data
turn on alerts
edit line 13 to be **send_alerts=true**
save

started 10:42am 4/29

```
/mnt/gitCode/splicedice_analysis/scripts/process_cluster_ids.sh /mnt/data/

```
script code is (here)[scripts/process_cluster_ids.sh]

std out

```
ubuntu@hbeale-mesa:/mnt/gitCode/splicedice_analysis/scripts$ /mnt/gitCode/splicedice_analysis/scripts/process_cluster_ids.sh /mnt/data/
Starting process at Tue Apr 29 17:42:35 UTC 2025
Characterizing input files:
Original intropolis PS file: /mnt/data/2020.11.16.intropolis_PS.tsv.gz
-rwxrwxrwx 1 ubuntu ubuntu 29G Mar  6 22:20 /mnt/data/2020.11.16.intropolis_PS.tsv.gz
cluster 0       1       2       4       5
chr1:14830-14969        nan     nan     nan     nan     0.500
chr1:14830-15795        nan     nan     0.000   nan     0.333
chr1:15039-15795        nan     nan     1.000   nan     0.500
chr1:15099-15795        nan     nan     0.000   nan     0.000
chr1:15562-15795        nan     nan     0.000   nan     0.000
chr1:15943-16606        nan     0.000   0.000   nan     nan
chr1:15948-16606        nan     0.800   0.944   nan     nan
chr1:16311-16606        nan     0.200   0.056   nan     nan
chr1:16766-16853        nan     nan     nan     nan     nan
opLine count: 4498066
LUAD PS file: /mnt/data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz
-rwxrwxrwx 1 ubuntu ubuntu 190M Feb  5 20:53 /mnt/data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz
cluster 00d461ae-a1d8-42f2-abd8-5e159363d857    00fabec9-d311-4994-a7e5-eb91178d14f2    01ebdef8-920f-4b71-8b44-512598962d6b    020a2284-03f3-4439-89bb-2292ebc3ecd2   02f6c9d4-8296-4e00-9e78-4f4d8c942340
chr1:11211-12009:+      nan     nan     nan     nan     nan
chr1:11844-12009:+      nan     nan     nan     nan     nan
chr1:12227-12612:+      nan     nan     nan     nan     nan
chr1:12721-13220:+      0.000   0.000   1.000   nan     nan
chr1:13052-13220:+      1.000   1.000   0.000   nan     nan
chr1:13374-13452:+      nan     nan     nan     nan     nan
chr1:14784-14977:-      nan     0.000   0.000   0.000   0.000
chr1:14829-14929:-      nan     1.000   0.000   0.000   0.000
chr1:14829-14969:-      nan     0.000   0.000   0.000   0.000
Line count: 886248
Step 1: Converting LUAD cluster IDs to intropolis format
Running convert_luad_clusters.R script
── Attaching core tidyverse packages ─────────────────────────────────────────────────────────────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.5
✔ forcats   1.0.0     ✔ stringr   1.5.1
✔ ggplot2   3.5.1     ✔ tibble    3.2.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.1
✔ purrr     1.0.2     
── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
Rows: 886247 Columns: 591
── Column specification ───────────────────────────────────────────────────────────────────────────────────────────────────────────────
Delimiter: "\t"
chr   (1): cluster
dbl (590): 00d461ae-a1d8-42f2-abd8-5e159363d857, 00fabec9-d311-4994-a7e5-eb9...

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
Warning message:
Expected 4 pieces. Additional pieces discarded in 28653 rows [177719, 177720, 177721, 177722, 177723, 177724, 177725, 177726, 177727,
177728, 177729, 177730, 177731, 177732, 177733, 177734, 177735, 177736, 177737, 177738, ...]. 
# A tibble: 6 × 9
  luad_cluster_id   chr   start stop  strand stop_num start_num intropolis_start
  <chr>             <chr> <chr> <chr> <chr>     <dbl>     <dbl>            <dbl>
1 chr1:11211-12009… chr1  11211 12009 +         12009     11211            11212
2 chr1:11844-12009… chr1  11844 12009 +         12009     11844            11845
3 chr1:12227-12612… chr1  12227 12612 +         12612     12227            12228
4 chr1:12721-13220… chr1  12721 13220 +         13220     12721            12722
5 chr1:13052-13220… chr1  13052 13220 +         13220     13052            13053
6 chr1:13374-13452… chr1  13374 13452 +         13452     13374            13375
# ℹ 1 more variable: intropolis_cluster_id <chr>
Processing complete. Output files written:
1. /mnt/data/luad_and_corresponding_intropolis_cluster_ids.tsv.gz 
2. /mnt/data/luad_cluster_ids_in_intropolis_format.tsv.gz 
Checking output from Step 1:
-rwxrwxrwx 1 hbeale hbeale 5.5M Apr 29 18:59 /mnt/data/luad_and_corresponding_intropolis_cluster_ids.tsv.gz
luad_cluster_id intropolis_cluster_id
chr1:11211-12009:+      chr1:11212-12009
chr1:11844-12009:+      chr1:11845-12009
chr1:12227-12612:+      chr1:12228-12612
chr1:12721-13220:+      chr1:12722-13220
chr1:13052-13220:+      chr1:13053-13220
chr1:13374-13452:+      chr1:13375-13452
chr1:14784-14977:-      chr1:14785-14977
chr1:14829-14929:-      chr1:14830-14929
chr1:14829-14969:-      chr1:14830-14969
Line count: 576045

Step 2: Making subset of intropolis data
{"status":"OK","nsent":2,"apilimit":"0\/1000"}
Checking subset intropolis output:
-rwxrwxrwx 1 ubuntu ubuntu 5.4G Apr 29 20:28 /mnt/data/2020.11.16.intropolis_PS.in_luad.tsv.gz
cluster 0       1       2       4       5
chr1:14830-14969        nan     nan     nan     nan     0.500
chr1:14830-15795        nan     nan     0.000   nan     0.333
chr1:15039-15795        nan     nan     1.000   nan     0.500
chr1:15943-16606        nan     0.000   0.000   nan     nan
chr1:15948-16606        nan     0.800   0.944   nan     nan
chr1:16311-16606        nan     0.200   0.056   nan     nan
chr1:17056-17232        nan     nan     nan     nan     nan
chr1:17056-29320        0.000   nan     0.000   nan     0.000
chr1:17369-17525        nan     nan     nan     nan     nan
Line count: 394419

Step 3: Getting list of IDs in reduced intropolis data
{"status":"OK","nsent":2,"apilimit":"1\/1000"}

Step 4: Reordering LUAD cluster IDs
Running reorder_luad_clusters.R script
── Attaching core tidyverse packages ─────────────────────────────────────────────────────────────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.5
✔ forcats   1.0.0     ✔ stringr   1.5.1
✔ ggplot2   3.5.1     ✔ tibble    3.2.1
✔ lubridate 1.9.4     ✔ tidyr     1.3.1
✔ purrr     1.0.2     
── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
Rows: 576044 Columns: 2
── Column specification ───────────────────────────────────────────────────────────────────────────────────────────────────────────────
Delimiter: "\t"
chr (2): luad_cluster_id, intropolis_cluster_id

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
Rows: 394418 Columns: 1
── Column specification ───────────────────────────────────────────────────────────────────────────────────────────────────────────────
Delimiter: "\t"
chr (1): original_intropolis_cluster_id

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
Processing complete. Output file written:
/mnt/data/new_intropolis_cluster_ids_in_order.tsv.gz 
Checking reordered cluster IDs output:
-rw-rw-r-- 1 ubuntu ubuntu 2.4M Apr 29 20:43 /mnt/data/new_intropolis_cluster_ids_in_order.tsv.gz
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
Line count: 394419

Step 5: Replacing cluster ID in intropolis PS file
{"status":"OK","nsent":2,"apilimit":"2\/1000"}

Checking final output file:
-rwxrwxrwx 1 ubuntu ubuntu 5.4G Apr 29 21:21 /mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
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
Line count: 394419

Process completed at Tue Apr 29 21:29:25 UTC 2025

```

review counts

```
4,498,066 rows in original intropolis input (29G, gzipped)
886,248 rows in original luad input (190M, gzipped)
576,045 rows in luad after excluding chromosomes with "random" and "chrUn" in the name (0% of tiny data because of the way I selected it) and cluster ids that differ only depending on whether the positive or negative strand (25% of tiny data). This represents 65% of luad data.
394,419 rows in intropolis subset also in luad (5.4G, gzipped) (9% of original intropolis, 68% of post-exclusions luad)
394,419 rows in final intropolis output with revised cluster IDs (5.4G, gzipped)

```

check md5

```
ubuntu@hbeale-mesa:/mnt/gitCode/splicedice_analysis/scripts$ md5sum /mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
cd4371729785ed6e168c946ed7066527  /mnt/data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
ubuntu@hbeale-mesa:/mnt/gitCode/splicedice_analysis/scripts$ 
```
