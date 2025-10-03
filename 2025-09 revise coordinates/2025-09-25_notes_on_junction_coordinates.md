adjusting coordinates for splicedice



# file contents

## sample-specific junc.bed

```
head _junction_beds/7a7440bf-1ca1-4c6b-80f8-7151a38e5d18.rna_seq.genomic.gdc_realn.junc.bed
```

```
chr1    12697   13220   e:0.00:0.00;o:22;m:NN_NN;a:?    1       +
chr1    14737   14969   e:1.10:0.69;o:16;m:NN_NN;a:?    3       +
chr1    14737   14969   e:0.00:0.00;o:1;m:NN_NN;a:?     1       -
chr1    15012   25232   e:0.41:0.00;o:13;m:NN_NN;a:?    7       +
chr1    15012   25232   e:0.00:0.00;o:13;m:NN_NN;a:?    3       -
chr1    15038   15795   e:2.07:2.32;o:23;m:NN_NN;a:?    71      +
chr1    15038   15795   e:2.87:2.60;o:21;m:NN_NN;a:?    103     -
chr1    15947   16606   e:1.65:1.45;o:21;m:NN_NN;a:?    19      +
chr1    15947   16606   e:2.87:2.83;o:24;m:NN_NN;a:?    40      -
chr1    16765   16857   e:3.13:3.05;o:20;m:NN_NN;a:?    67      +
```

the fourth column is encoded this way:

```
name = f"e:
{leftEntropy[junction]:0.02f}:
{rightEntropy[junction]:0.02f};
o:
{overhangs[junction]};
m:{leftMotif[(chromosome,left)]}_{rightMotif[(chromosome,right)]};
a:{self.annotated.get(junction,'?')}"
```



## Shared junctions.bed

```
head _junctions.bed
```

```
chr1    11844   12009   chr1:11844-12009:+      0       +
chr1    12227   12612   chr1:12227-12612:+      0       +
chr1    12697   13402   chr1:12697-13402:+      0       +
chr1    12721   13220   chr1:12721-13220:+      0       +
chr1    12721   13452   chr1:12721-13452:+      0       +
chr1    12721   13482   chr1:12721-13482:+      0       +
chr1    13052   13220   chr1:13052-13220:+      0       +
chr1    14829   14969   chr1:14829-14969:+      0       +
chr1    14829   14969   chr1:14829-14969:-      0       -
chr1    14829   15020   chr1:14829-15020:+      0       +

```

## allPS

```
head _allPS.tsv | cut -f1-6
```



```
cluster TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16    TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981   TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2     TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b    TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960
chr1:11844-12009:+      nan     nan     nan     nan     nan
chr1:12227-12612:+      nan     nan     nan     nan     nan
chr1:12697-13402:+      nan     0.000   nan     nan     0.000
chr1:12721-13220:+      nan     0.500   nan     nan     0.500
chr1:12721-13452:+      nan     0.000   nan     nan     0.000

```



## inclusion counts

```
head _inclusionCounts.tsv | cut -f1-6
```



```
cluster TCGA-67-6215-01A0a26152a-462f-4895-8fe8-15fcdcc56e16    TCGA-86-8075-01A0c633b9e-3303-4625-b59d-02102d8bf981   TCGA-49-4505-01A0ebf5cc5-f242-45ef-821a-939b51dc95a2     TCGA-64-1680-01A16b44441-90d4-4289-8248-d31251f49f2b    TCGA-44-7659-01A20592e25-4b12-4cd3-b1b1-b8e8d6352960
chr1:11844-12009:+      0       0       0       0       0
chr1:12227-12612:+      0       0       0       0       0
chr1:12697-13402:+      0       0       0       0       0
chr1:12721-13220:+      0       3       0       0       1
chr1:12721-13452:+      0       0       0       0       0
chr1:12721-13482:+      0       0       0       0       0
chr1:13052-13220:+      0       3       0       0       1
chr1:14829-14969:+      0       0       0       0       0
chr1:14829-14969:-      0       0       0       0       0

```



# Relevant code



## line [126](https://github.com/BrooksLabUCSC/splicedice/blob/da045c486e314e6f7db253998d886a163172295b/splicedice/bam_to_junc_bed.py#L126) blocks = read.get_blocks():



### read.get_blocks

a list of start and end positions of aligned gapless blocks.

The start and end positions are in genomic coordinates.

Blocks are not normalized, i.e. two blocks might be directly adjacent. This happens if the two blocks are separated by an insertion in the read.

```python
read_start = blocks[0][0]
read_end = blocks[-1][1]
```



the junction is defined as the end of one block (`blocks[i][1]`) and the start of the next (`blocks[i+1][0]`)

```
junction = (read.reference_name,blocks[i][1],blocks[i+1][0],strand)
```



calculating overhang

left overhang = end of this block to beginning of this block (`blocks[i][1]-blocks[i][0]`)

right overhang = end of next block to beginning of next block (`blocks[i+1][1]-blocks[i+1][0]`)

```
leftOH = blocks[i][1]-blocks[i][0]
rightOH = blocks[i+1][1]-blocks[i+1][0]
overhang = min(leftOH,rightOH)
```



at what point should re revise the coordinates? at write? at process? if process, should I redefine blocks?



currently i lean toward revising them at the end, which would affect fewer parts of the code



# Example junctions

In both cases, we add one to the lower number

## test case 1:

currently

```
chr1:1477350-1478643
```



should be 

```
chr1:1477351-1478643
```



notes

### ATAD3B

ATAD3B, plus strand, exons 1 and 2

exon ENSE00003467707

coordinates in GTF chr1:1477274-1477350 

exon ENSE00003569130 

coordinates in GTF chr1:1478644 1478745

junction in splicedice output

chr1:1477350-1478643:+ 0.893  0.818  0.967  0.829  0.485

desired junction in splicedice output:

chr1:1477351-1478643:+ 0.893  0.818  0.967  0.829  0.485



look in splice junction out

```
cd /mnt/output/star_fusion_1.12.0_2024.09.30/SRR12801019
cat SJ.out.tab | grep chr1 | grep 1477351
```

```
chr1    1477351 1478643 1       1       1       17      58      49
```



now do it for a minus strand gene



## test case 2

currently in splicedice:

```
chr1:17055-17232:-
```



should be 

```
chr1:17056-17232:-
```



as seen in star output

```
f=/mnt/output/star_fusion_1.12.0_2024.09.30/SRR12801019/SJ.out.tab
chr1    17056   17232   2       2       1       24      173     49
chr1    17056   17605   2       2       0       3       10      49

```



https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=chr1%3A16877%2D17410&hgsid=3190340678_2MrEN0eAGh6Ta1cyDnn91N6tVtBz

gene: Wash 7p



# Claude

## Q 

In this code, I need to change the left or right coordinates by one depending on the value of the strand. How should I do that?

```
for junction in filteredJunctions:
                chromosome,left,right,strand = junction
```



suggestion

```
Looking at your code, you have a tuple unpacking where strand is the fourth element. To modify the left or right coordinates by one based on the strand value, you can add conditional logic after the unpacking.

for junction in filteredJunctions:
    chromosome, left, right, strand = junction
    
    if strand == '+':
        right += 1  # or left += 1, depending on your needs
    elif strand == '-':
        left += 1   # or right += 1, depending on your needs
```



