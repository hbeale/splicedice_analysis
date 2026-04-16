# 4-3-2026 - not following up with E-MTAB-6060



Based on conversation with Angela and Javier, I'll continue to use data from the SUGP1_KD experiment because it should phenocopy SF3B1 mutation signature and could be a nicer control for Javier's Euclidian distance-based query matching. We will make-do with only 2 reps





project id: ERP104850

# Conversation from Slack

Javier Quintana [11:11 AM]

here is a link to the SSA data
https://www.ebi.ac.uk/biostudies/ArrayExpress/studies/E-MTAB-6060/sdrf

ebi.ac.uk

[BioStudies < The European Bioinformatics Institute < EMBL-EBI](https://www.ebi.ac.uk/biostudies/ArrayExpress/studies/E-MTAB-6060/sdrf)

BioStudies – one package for all the data supporting a study

[11:16 AM]

There are a couple of splicing inhibitors used in the dataset, but you can just grab the SSA (5 nM) and DMSO samples. There are also BRU-labeled versions of those if you need them.

[11:16 AM]

here is the paper
https://pmc.ncbi.nlm.nih.gov/articles/PMC5727392/

PubMed Central (PMC)

[Molecular basis of differential 3′ splice site sensitivity to anti-tumor drugs targeting U2 snRNP](https://pmc.ncbi.nlm.nih.gov/articles/PMC5727392/)

Several splicing-modulating compounds, including Sudemycins and Spliceostatin A, display anti-tumor properties. Combining transcriptome, bioinformatic and mutagenesis analyses, we delineate sequence determinants of the differential sensitivity of 3′ ...

https://pmc.ncbi.nlm.nih.gov/articles/PMC5727392/



Angela [11:54 AM]

Please don't use the BRU-labeled. That is a different kind of experient.

hollybeale [12:01 PM]

It looks like I also used two pairs of wt/SUGP1_knockdown: https://pubmed.ncbi.nlm.nih.gov/33057152/ (e.g. [SRR12801019](https://www.ncbi.nlm.nih.gov/sra/?term=SRR12801019)). Do we have a preference for which data to use moving foward?

PubMed

[Genetic alterations of SUGP1 mimic mutant-SF3B1 splice pattern in lung adenocarcinoma and other cancers - PubMed](https://pubmed.ncbi.nlm.nih.gov/33057152/)

Genes involved in 3'-splice site recognition during mRNA splicing constitute an emerging class of oncogenes. SF3B1 is the most frequently mutated splicing factor in cancer, and SF3B1 mutants corrupt branchpoint recognition leading to usage of cryptic 3'-splice sites and subsequent aberrant junctions …

https://pubmed.ncbi.nlm.nih.gov/33057152/



Angela [12:15 PM]

If the SSA has three replicates per condition, I would prefer that one

hollybeale [2:02 PM]

The SSA has two replicates per condition.

Javier Quintana [3:45 PM]

there is this one
https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=293216
which has meOH and SSA cytoplasmic fractions
there are 3 reps for each

[3:46 PM]

https://pmc.ncbi.nlm.nih.gov/articles/PMC5159648/#YOSHIMOTORNA058065C10

PubMed Central (PMC)

[Global analysis of pre-mRNA subcellular localization following splicing inhibition by spliceostatin A](https://pmc.ncbi.nlm.nih.gov/articles/PMC5159648/#YOSHIMOTORNA058065C10)

Spliceostatin A (SSA) is a methyl ketal derivative of FR901464, a potent antitumor compound isolated from a culture broth of Pseudomonas sp. no. 2663. These compounds selectively bind to the essential spliceosome component SF3b, a subcomplex of the ...

https://pmc.ncbi.nlm.nih.gov/articles/PMC5159648/#YOSHIMOTORNA058065C10



Angela [3:52 PM]

Those aren't traditional RNA-seq libraries, so would rather not....

Technically, the SUGP1_KD data is nice because it should phenocopy SF3B1 mutation signature and could be a nicer control for Javier's Euclidian distance-based query matching. We might have to make-do with only 2 reps

hollybeale [10:02 AM]

OK, I'll move forward with the SUGP1_KD data. Thanks!