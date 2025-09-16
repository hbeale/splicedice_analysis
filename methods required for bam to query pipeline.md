# (prep for 2025-07-15 meeting)



## Methods required for bam to query pipeline:

Overview

```

├── original splicedice/mesa repo
    ├── Extract splice junctions (mostly bam_to_junc_bed.py)
    ├── Quantify junction usage (splicedice.py quant)
├── dennis splicedice repo
		├── Compare two (?) conditions (splicedice.py compare; write_sig generates signature)
		├── Identify the distribution characterizing significant intervals 
					(splicedice.py fit beta; write_beta generates beta distributions)
		├── Query: reports p-values to indicate how well each sample in the query matches the signature + distributions from the previous cohort. (splicedice.py query; write_pvals generates p-values)

```

## Step 1. Extract splice junctions (original splicedice/mesa repo)

In script bam_to_junc_bed.py, the function bamsToBeds generates one bed output for each bam file 

Example output format

```
1       12697   13220   e:0.00:0.00;o:43;m:GT_AG;a:?    2       +
1       14829   14969   e:3.42:3.35;o:50;m:CT_AC;a:?    406     -
```

## Step 2. Quantify junction usage (original splicedice/mesa repo)



In script splicedice.py, the function quant and getJunctionCounts and calculatePs

Example output

```
cluster A19     A20     A23     A24
1:14829-14969:- 1.000   1.000   1.000   1.000
1:15947-16606:- 1.000   0.739   0.889   0.792
1:16310-16606:- 0.000   0.261   0.111   0.208
```

## Step 3. Compare conditions (query splicedice repo)

From query-spicedice

```
├── compare (write_sig generates signature)
├── fit beta (write_beta generates beta distributions for each significant interval)
├── query (write_pvals generates p-values for each sample in the query that matches the beta)

```

# 

Questions:

Do we care about documenting what the info field means in the bed format? See example below. It looks like m reports the splice site motif and e reports entropy.

```
1       12697   13220   e:0.00:0.00;o:43;m:GT_AG;a:?    2       +
1       14829   14969   e:3.42:3.35;o:50;m:CT_AC;a:?    406     -
```

## Repos

"Original splicedice" https://github.com/BrooksLabUCSC/splicedice

### 

## raw material

`cat splicedice/bam_to_junc_bed.py | grep def | grep -v default`

```
   def __init__(self,args):
    def parseManifest(self):
    def getAnnotated(self):
    def getJunctionsFromBam(self,sample):
    def bamsToBeds(self,bams):
    def writeNewManifest(self,new_manifest):
def add_parser(parser):
def run_with(args):

```

