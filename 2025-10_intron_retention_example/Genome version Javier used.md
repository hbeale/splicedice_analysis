# Genome version Javier used



To keep using Javier's data while working on intron retention, I will need to either keep using the genome and gene definitions versions that he's using or re-align the data if we want to use different reference files.

## Goal: use a primary build from gencode

e.g. 

https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.primary_assembly.genome.fa.gz

(primary because "all" includes haplotypes which are contain duplicate sequence)
(gencode since we use their gene models)



## gencode v49 vs Javier's

To determine what genome version he's using, I downloaded our desired version and compared it to the version Javier shared with me

Javier's that I copied to mesa

```
md5sum /mnt/ref/GRCh38.primary_assembly.genome.fa
```

output

```
49bdb80d21a64dcb16acfc941843356e /mnt/ref/GRCh38.primary_assembly.genome.fa
```



Download gencode v49

on hbeale-mesa:

```
cd /mnt/ref/gencode_49
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.primary_assembly.genome.fa.gz
gzip -d GRCh38.primary_assembly.genome.fa.gz
md5sum GRCh38.primary_assembly.genome.fa

```

output

```
49bdb80d21a64dcb16acfc941843356e  GRCh38.primary_assembly.genome.fa
```



### Conclusion: Javier's is the same as gencode v 49



## brooks lab vs javier's

As an aside, I checked the version he shared with me with the version in the brooks lab folder. 



on mustard

```
cd /private/groups/brookslab
md5sum ./reference_sequence/GRCh38.primary_assembly.genome.fa

```

output

```
49bdb80d21a64dcb16acfc941843356e  ./reference_sequence/GRCh38.primary_assembly.genome.fa
```



also identical!



Note: since Javier was using v45 gene model, that may be the v45 genome, and it didn't change. I haven't checked. 
