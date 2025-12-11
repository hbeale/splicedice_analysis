# reference file sources


## Genome

Brooks lab uses genome builds from gencode since they also use gencode gene models. They use primary assembly instead of "All"  because "All" includes haplotypes which are contain duplicate sequence.

I downloaded https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.primary_assembly.genome.fa.gz and confirmed by md5sum that it was the same as the one they use (/private/groups/brookslab/reference_sequence/GRCh38.primary_assembly.genome.fa)

## Gene definitions



To be consistent with Javier's implementation, I'm using gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf

It can be downloaded from here:

https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.chr_patch_hapl_scaff.annotation.gtf.gz



## Reference recommendations from the star manual:

* include major chromosomes
* include un-placed/un-localized scaffolds
* patches and alternative haplotypes should not be included
