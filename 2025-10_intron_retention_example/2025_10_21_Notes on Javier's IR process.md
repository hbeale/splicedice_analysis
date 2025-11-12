Notes on Javier's IR process





```
hcbeale@mustard:/scratch/erj_public/Jurica_SSA$ ls scripts/
fastq.samples.txt  query2.sh       Sig_manifest.test.tsv  SSA100_mesa_IRcoverage.sh  SSA100_star.sh
fit_beta.sh        query3.sh       Sig_Manifest.tsv       SSA100_mesa_IRtable.sh     Test_Sig_Manifest.tsv
Manifest_file.txt  query.sh        ssa100_iread.sh        SSA100_mesa_quant.sh
mesa_pairwise.sh   sig_compare.sh  SSA100_manifest.sh     SSA100_mesa.sh

```





## misc notes Ideas

fastq.samples.txt is the list of samples

Manifest_file.txt was created by SSA100_manifest.sh

SSA100_star.sh

### SSA100_star.sh

what was input? starts with "while read file; do"

```
while read file; do
path="/data/scratch/javi/Jurica_SSA/data/fastq/"
output="/data/scratch/javi/Jurica_SSA/output/STAR/"
STAR --runThreadN 8 \
     --genomeDir /data/scratch/javi/reference/GRCh38_STAR_Indicies \
     --readFilesIn ${path}${file}_R1.filtered.fastq.gz ${path}${file}_R2.filtered.fastq.gz \
     --outFileNamePrefix ${output}${file}.filtered \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes Standard \
     --quantMode GeneCounts \
     --twopassMode Basic \
     --readFilesCommand zcat

done < fastq.samples.txt
hcbeale@mustard:/scratch/erj_public/Jurica_SSA/scripts$ 


```



### SSA100_mesa.sh

```
output="/data/scratch/javi/Jurica_SSA/output/mesa/bamtobed/SSA"
gtf="/data/scratch/javi/reference/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
genome="/data/scratch/javi/reference/GRCh38.primary_assembly.genome.fa"
mesa bam_to_junc_bed -m Manifest_file.txt --output_prefix ${output} \
--annotation ${gtf} --genome ${genome}
```

### SSA100_mesa_quant.sh

```
BDMF="/data/scratch/javi/Jurica_SSA/output/mesa/bamtobed/SSA_manifest.txt"
gtf="/data/scratch/javi/reference/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf"
genome="/data/scratch/javi/reference/GRCh38.primary_assembly.genome.fa"
out="/data/scratch/javi/Jurica_SSA/output/mesa/quant/SSA_Jurica"
mesa quant -m ${BDMF} -o ${out}

```

### SSA100_mesa_IRcoverage.sh

```
output="/data/scratch/javi/Jurica_SSA/output/mesa/IR_coverage/"
project="/data/scratch/javi/Jurica_SSA/output/mesa/quant/"
mesa intron_coverage -b Manifest_file.txt -m ${project}SSA_Jurica_allPS.tsv -j ${project}SSA_Jurica_junctions.bed -o ${output}SSA_Jurica
```

### SSA100_mesa_IRtable.sh

```
output="/data/scratch/javi/Jurica_SSA/output/mesa/IR_table/"
project="/data/scratch/javi/Jurica_SSA/output/mesa/quant/"
mesa ir_table -i ${project}SSA_Jurica_inclusionCounts.tsv \
 -c ${project}SSA_Jurica_allClusters.tsv \
 -d /data/scratch/javi/Jurica_SSA/output/mesa/IR_coverage/SSA_Jurica \
 -o ${output}SSA_Jurica \
 -a /data/scratch/javi/reference/gencode.v45.chr_patch_hapl_scaff.basic.annotation.gtf \
 -r

```

