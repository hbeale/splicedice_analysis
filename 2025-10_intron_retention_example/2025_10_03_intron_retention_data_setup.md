Got data from Javier



```
mv *.bam /private/groups/brookslab/hbeale/javier_erj_jurica_ssa
mv *.sh /private/groups/brookslab/hbeale/javier_erj_jurica_ssa
```



copy to hbeale-mesa open stack server

on mustard

```
server=ubuntu@10.50.100.135
scp /private/groups/brookslab/hbeale/javier_erj_jurica_ssa/*.bam ${server}:/mnt/data/bams/javier_erj_jurica_ssa/

```

organize on hbeale-mesa

```
cd /mnt/data/bams/javier_erj_jurica_ssa/
rm bam_manifest_scratch.txt
for i in *filteredAligned.sortedByCoord.out.bam; do
echo $i
sample=${i/.filteredAligned.sortedByCoord.out.bam}
#echo $sample
s_num=`echo $sample | tail -c 4`
#echo $s_num
combo=`echo $sample | sed 's/_.*//'`
condition=`echo $combo | sed 's/[0-9]*//g'`
condition_num=`echo $combo | sed 's/[A-Z]*//g'`
# echo $sample $s_num $condition $condition_num
new_sample_id=${s_num}_${condition}_${condition_num}
mkdir $new_sample_id
mv ${i} ${new_sample_id}/
done

```

make manifest

```

bam_manifest=javier_erj_jurica_ssa_bam_manifest.txt
cd /mnt/data/bams/javier_erj_jurica_ssa/

rm -f $bam_manifest

for ip in `find . -iname *.bam`
do
i=`basename $ip`
sample=${i/.filteredAligned.sortedByCoord.out.bam}
#echo $sample
s_num=`echo $sample | tail -c 4`
#echo $s_num
combo=`echo $sample | sed 's/_.*//'`
condition=`echo $combo | sed 's/[0-9]*//g'`
condition_num=`echo $combo | sed 's/[A-Z]*//g'`
new_sample_id=${s_num}_${condition}_${condition_num}
echo $new_sample_id $i NA $condition 
echo $new_sample_id /mnt/data/bams/javier_erj_jurica_ssa/$new_sample_id/$i NA $condition | tr " " "\t" >> $bam_manifest

done

```



these are the IDs Javier used

```
S65_DMSO
S66_DMSO
S75_DMSO
S76_DMSO
S73_HB10001
S74_HB10002
S83_HB10003
S84_HB10004
S71_HB1001
S72_HB1002
S81_HB1003
S82_HB1004
S69_SSA
S70_SSA
S79_SSA
S80_SSA
S67_SSA
S68_SSA
S77_SSA
S78_SSA

```



```
splicedice intron_coverage -b bam_manifest.tsv -m project_allPS.tsv -j project_junctions.bed -n 4 -o coverage_output_dir
splicedice ir_table -i project_inclusionCounts.tsv -c project_allClusters.tsv -d coverage_output_dir -o project_output_prefix
```

