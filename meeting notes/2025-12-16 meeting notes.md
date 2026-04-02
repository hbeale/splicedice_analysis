# 2025-12-16 meeting notes



Plan:

review walkthrough of splicedice, clarify results

https://github.com/hbeale/splicedice_analysis/blob/main/2025-12_tcga_luad_reproducible_example/2025-12-16_splicedice_TCGA_LUAD_u2af1_runthrough_with_data_descriptions.md



Which column in bam manifest is meaningful?



Junctions are reported on both strands; should we have a strandedness argument to account for unstranded data?



What are inclusion counts?



Some alpha and beta values are “None”; maybe we should change
those to NA.





update coordinates to 1-based intronic coords



erros in the align



# Summary

From Angela:

- Replace bam_to_juncbed with intronProspector which has the same function, but should have better options.
- Recommend use: start with BAM file, use intronProspector to get the BED file, BED file is used as input to SpliceDice.
- TBD: Maintain usage of STAR SJ.out.tab as input to SpliceDice? We need to double check if it has issues with having the same exact splice junction start and end coordinate but with reads on both strands. If this happens in real biology, this is likely extremely rare, so would prefer to filter out these types of junctions. Maybe print a warning that it occurs and ask the user to remove them or resolve?

From Holly:

Thanks Angela. This sounds great! Also on my follow-up list is making sure Piet gets a server account.