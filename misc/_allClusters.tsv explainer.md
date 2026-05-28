# _allClusters.tsv explainer



The following is based on Claude response to a prompt. I've reviewed it, and it seems right, but any concerns should be investigated further rather than assuming this is correct. 



prompt: using the code here https://public.gi.ucsc.edu/~hcbeale/splicedice/, write an explainer of the format of _allClusters.tsv



# Format of_allClusters.tsv

## Overview
This file is written by the writeClusters() method in SPLICEDICE.py. It records every splice junction and its **cluster membership** — that is, which other junctions share a splice site with it and are therefore in competition (mutually exclusive alternatives).
There is **no header line**. Each row describes one junction and lists the other junctions it overlaps.

## Terminology
- The first column contains the focal junction for the cluster being defined.
- The second contains a list of junctions in the cluster, excluding the focal one.

## Structure: two tab-separated columns per row


<junction>    <comma-separated list of overlapping junctions>
| **Column** |                         **Content**                          |
| :--------: | :----------------------------------------------------------: |
|     1      |      The focal junction, in chr:start-end:strand format      |
|     2      | Comma-separated list of junctions that overlap with it (its "cluster partners"), in the same format — **empty string if none** |

## Junction coordinate format
Each junction is represented as:


chr:start-end:strand
For example: chr1:10000-12500:+
* **chr** — chromosome name, taken directly from the input BED file
* **start** — 1-based left coordinate (the raw 0-based BED coordinate plus 1, per junctionString(..., one_based=True))
* **end** — right coordinate as-is from BED (0-based half-open right boundary, i.e. the last base of the intron)
* **strand** — + or -

⠀
## What "cluster" means
Two junctions are in the same cluster if they **overlap** — meaning one junction's right coordinate (end) is ≥ the other's left coordinate (start), on the same chromosome and strand. This captures the case where two introns share a splice donor or splice acceptor site, making them mutually exclusive alternatives.
The clustering is computed in getClusters(): junctions are sorted by (chrom, strand, start, end), and a sweep-line approach links any new junction to all prior junctions whose end hasn't passed its start yet.

## Row ordering
Rows are sorted by the junction's natural tuple order: (chrom, start, end, strand) — which is Python's default sort on the (chromosome, left, right, strand) tuples.

## Example
Suppose three junctions on chr1+ are found:
* J1: chr1:1000-2000:+
* J2: chr1:1500-3000:+ (overlaps J1, since 2000 ≥ 1500)
* J3: chr1:5000-6000:+ (does not overlap either)

⠀The file would look like:


chr1:1000-2000:+	chr1:1500-3000:+
chr1:1500-3000:+	chr1:1000-2000:+
chr1:5000-6000:+
J3's second column is an empty string (the tab is still present, but nothing follows it).

## Key points
* **No header.** The file starts immediately with data rows.
* **Every junction gets a row**, even if it has no cluster partners (column 2 is just empty).
* **Cluster membership is symmetric**: if J1 lists J2, then J2 also lists J1.
* **Coordinates are 1-based on the left, 0-based-half-open on the right** — a somewhat unusual mixed convention inherited from converting the BED input. The start is BED start + 1; the end is the BED end unchanged.
* **This file is the foundation** for _inclusionCounts.tsv and _allPS.tsv, which use the same junction string format as row identifiers.

# Questions

## Are reference junctions automatically included?

[note, this answer analyzed newer code that uses intron prospector]

You said: are members of clusters included if the cluster is in the gene model reference but no sample has any counts for the cluster?
are members of clusters included if the cluster is in the gene model reference but no sample has any counts for the cluster?

1:01 PM
Claude responded: Based on the code, no.
Based on the code, no. Junctions are built entirely bottom-up from the sample data.

In getAllJunctions(), the union of junctions is assembled by reading only the input BED files from the manifest — there's no reference annotation consulted at any point. getClusters() then builds clusters solely from that junction set. If no sample has any reads spanning a junction, it never enters self.junctions, never gets clustered, and never appears in _allClusters.tsv.

The gene model reference isn't used anywhere in SPLICEDICE.py at all — the tool is purely data-driven.

Holly note: I think this is correct. The GTF isn't used until the step that generates the inclusion count table (splicedice ir_table). 



## Are reference junctions automatically included when using bam_to_junc_bed?

The GTF is used only for two purposes:

1. **Annotation status labeling** — the `a:` field in the BED name column records whether a junction is known (gene name) or novel (`?`). This is purely metadata.
2. **Strand disambiguation** — in `inferCombine`/`inferOnly` mode, being in `self.annotated` helps decide which strand to assign when a junction appears on both strands with the same coordinates.

Critically, `getAnnotated()` builds a lookup dictionary from the GTF, but it is only ever *queried* against junctions already found in the reads — it is never iterated to *emit* junctions. A reference junction with no read support will never enter `counts{}`, never make it into `filteredJunctions`, and therefore never appear in the output BED. The GTF can only influence which read-supported junctions survive or how they're labeled, not add new ones.

So the answer remains: **no reference-only junctions will appear in `_allClusters.tsv`**.




## why are some membership lists so long?
Holly answer: we were talking about the cluster that contained many (100+) member junctions. i think I figured out why they're not reciprocal. it's a junction that spans many genes (chr1:15226-185746), so all junctions of all genes in it are members of its cluster, but they're not members of each other's clusters because the within-gene junctions don't overlap with junctions inside other genes. Because those PS values will have a denominator including so many junctions, the values are likely to be very low irrespective of intersample variability. 