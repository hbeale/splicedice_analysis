intron coverage output explainer



from Claude



The output is a BED-like tab-separated file with 8 columns:

| Col  | Value             | Description                                                  |
| ---- | ----------------- | ------------------------------------------------------------ |
| 1    | `chromosome`      | Chromosome name                                              |
| 2    | `left`            | Intron start (0-based)                                       |
| 3    | `right`           | Intron end (0-based half-open)                               |
| 4    | `.`               | Name — unused, always `.`                                    |
| 5    | `median`          | **Median read coverage** across the 5 percentile positions (the key IR signal) |
| 6    | `strand`          | Strand (`+` or `-`)                                          |
| 7    | `juncPercentiles` | Comma-separated **genomic positions** of the 5 sampled points along the intron |
| 8    | `juncCounts`      | Comma-separated **read counts** at each of those 5 positions |

The 5 percentile positions (column 7) are computed in `getIntronPercentiles()` as the 1st, 25th, 50th, 75th, and 99th percentile positions along the intron:



Column 8 gives the coverage at each of those 5 positions, and column 5 is the median of those 5 counts — which is the summary statistic used downstream as the intron retention coverage estimate.