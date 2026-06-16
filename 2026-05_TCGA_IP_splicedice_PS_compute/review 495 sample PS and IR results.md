# review-495-sample-PS-and-IR-results
Holly Beale
2026-06-15

- [Import some data](#import-some-data)
- [Analyze ps values for 10k
  clusters](#analyze-ps-values-for-10k-clusters)
- [Analyze ps values for 10k
  junctions](#analyze-ps-values-for-10k-junctions)

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

# Import some data

``` r
ps_small <- read_tsv("~/downloads/TCGA_LUAD_allPS.tsv.gz", n_max = 10000)
```

    Rows: 10000 Columns: 496
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr   (1): cluster
    dbl (495): TCGA-86-8074-01A, TCGA-62-8402-01A, TCGA-86-8358-01A, TCGA-86-805...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
#ir <- read_tsv("~/downloads/TCGA_LUAD_intron_retention.tsv.gz")
ir_small <- read_tsv("~/downloads/TCGA_LUAD_intron_retention.tsv.gz", n_max = 10000)
```

    Rows: 10000 Columns: 496
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr   (1): Junction
    dbl (495): TCGA-78-7166-01A, TCGA-78-7167-01A, TCGA-78-7220-01A, TCGA-78-753...

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# Analyze ps values for 10k clusters

``` r
ps_small_long  <- pivot_longer(ps_small, -cluster)
head(ps_small_long)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| cluster            | name             | value |
|:-------------------|:-----------------|------:|
| chr1:10179-10282:- | TCGA-86-8074-01A |   NaN |
| chr1:10179-10282:- | TCGA-62-8402-01A |   NaN |
| chr1:10179-10282:- | TCGA-86-8358-01A |   NaN |
| chr1:10179-10282:- | TCGA-86-8056-01A |   NaN |
| chr1:10179-10282:- | TCGA-78-7158-01A |   NaN |
| chr1:10179-10282:- | TCGA-49-4507-01A |   NaN |

``` r
per_cluster_vals <- ps_small_long %>%
group_by(cluster) %>%
summarize(n_Nan = sum(is.na(value)),
n_0 = sum(value == 0, na.rm = TRUE),
n_1 = sum(value == 1, na.rm = TRUE))

summary(per_cluster_vals$n_Nan)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
        0.0     2.0    51.0   169.7   394.0   494.0 

``` r
summary(per_cluster_vals$n_0)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
        0.0     2.0   155.0   221.1   470.0   495.0 

``` r
summary(per_cluster_vals$n_1)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
       0.00    0.00    0.00   72.17   16.00  495.00 

``` r
ggplot(per_cluster_vals) +
  geom_histogram(aes(x=n_Nan))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-4-1.png)

``` r
ggplot(per_cluster_vals) +
  geom_histogram(aes(x=n_0))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-4-2.png)

``` r
ggplot(per_cluster_vals) +
  geom_histogram(aes(x=n_1))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-4-3.png)

``` r
per_cluster_vals %>%
  pivot_longer(-cluster) %>%
  filter(value != 0) %>%
  ggplot() +
  geom_histogram(aes(x = value,
                     fill = name)) +
  scale_fill_brewer(palette = "Set1") +
  facet_wrap(~name)
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-4-4.png)

``` r
per_cluster_vals %>%
  pivot_longer(-cluster) %>%
  filter(value != 0) %>%
  ggplot() +
  geom_density(aes(x = value,
                     fill = name)) +
  scale_fill_brewer(palette = "Set1") +
  facet_wrap(~name)
```

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-4-5.png)

``` r
ggplot(ps_small_long) +
  geom_histogram(aes(x=value))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

    Warning: Removed 1696843 rows containing non-finite values (`stat_bin()`).

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-5-1.png)

# Analyze ps values for 10k junctions

``` r
ir_small[1:6,1:6]
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| Junction | TCGA-78-7166-01A | TCGA-78-7167-01A | TCGA-78-7220-01A | TCGA-78-7535-01A | TCGA-78-7536-01A |
|:---|---:|---:|---:|---:|---:|
| chr10:1000869-1000947:+ | 0 | 0.008 | 0.006 | 0 | 0.007 |
| chr10:1001014-1005817:+ | 0 | 0.000 | 0.000 | 0 | 0.000 |
| chr10:100190165-100190298:+ | NaN | 1.000 | 1.000 | NaN | 1.000 |
| chr10:100229725-100231014:+ | NaN | NaN | NaN | NaN | NaN |
| chr10:100233444-100233952:+ | 1 | 1.000 | 1.000 | 1 | 1.000 |
| chr10:100347532-100348063:+ | 0 | 0.000 | 0.003 | 0 | 0.000 |

``` r
ir_small_long <- pivot_longer(ir_small, -Junction)
head(ir_small_long)
```

    Warning: 'xfun::attr()' is deprecated.
    Use 'xfun::attr2()' instead.
    See help("Deprecated")

| Junction                | name             | value |
|:------------------------|:-----------------|------:|
| chr10:1000869-1000947:+ | TCGA-78-7166-01A | 0.000 |
| chr10:1000869-1000947:+ | TCGA-78-7167-01A | 0.008 |
| chr10:1000869-1000947:+ | TCGA-78-7220-01A | 0.006 |
| chr10:1000869-1000947:+ | TCGA-78-7535-01A | 0.000 |
| chr10:1000869-1000947:+ | TCGA-78-7536-01A | 0.007 |
| chr10:1000869-1000947:+ | TCGA-78-7537-01A | 0.000 |

``` r
per_jnx_vals <- ir_small_long %>%
group_by(Junction) %>%
summarize(n_Nan = sum(is.na(value)),
n_0 = sum(value == 0, na.rm = TRUE),
n_1 = sum(value == 1, na.rm = TRUE))

summary(per_jnx_vals$n_Nan)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
        0.0     1.0    18.0   115.6   193.0   494.0 

``` r
summary(per_jnx_vals$n_0)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
        0.0   106.0   304.0   273.5   439.0   494.0 

``` r
summary(per_jnx_vals$n_1)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
       0.00    0.00    0.00   12.29    1.00  494.00 

``` r
ggplot(per_jnx_vals) +
  geom_histogram(aes(x=n_Nan))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-7-1.png)

``` r
ggplot(per_jnx_vals) +
  geom_histogram(aes(x=n_0))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-7-2.png)

``` r
ggplot(per_jnx_vals) +
  geom_histogram(aes(x=n_1))
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-7-3.png)

``` r
per_jnx_vals %>%
  pivot_longer(-Junction) %>%
  filter(value != 0) %>%
  ggplot() +
  geom_histogram(aes(x = value,
                     fill = name)) +
  scale_fill_brewer(palette = "Set1") +
  facet_wrap(~name)
```

    `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-7-4.png)

``` r
per_jnx_vals %>%
  pivot_longer(-Junction) %>%
  filter(value != 0) %>%
  ggplot() +
  geom_density(aes(x = value,
                     fill = name)) +
  scale_fill_brewer(palette = "Set1") +
  facet_wrap(~name)
```

![](review-495-sample-PS-and-IR-results_files/figure-commonmark/unnamed-chunk-7-5.png)
