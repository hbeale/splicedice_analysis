I tried to run update_intropolis_coordinates.qmd on full data from Rstudio server, but it pooped out at some point when my computer went to sleep

Morning of 2025-04-24, i converted it to bash with claude, see update_intropolis_coords.sh.

Moved previous output of update_intropolis_coordinates.qmd on toy data from /mnt/tiny_data to /mnt/tiny_data_v1. 
Created a "just-data" setup in /mnt/tiny_data_template 

```
hbeale@hbeale-mesa:/mnt$ ls -R /mnt/tiny_data_template
/mnt/tiny_data_template:
2020.11.16.intropolis_PS.tsv.gz  dennisrm

/mnt/tiny_data_template/dennisrm:
tcga

/mnt/tiny_data_template/dennisrm/tcga:
luad

/mnt/tiny_data_template/dennisrm/tcga/luad:
2022.07.06.luad_allPS.tsv.gz
hbeale@hbeale-mesa:/mnt$ 
```

copied the template to /mnt/tiny_data

Ran update_intropolis_coords.sh with base_dir="/mnt/tiny_data/" (I lated renamed update_intropolis_coords.sh update_intropolis_coords_v1.sh)

Compare outputs in /mnt/tiny_data_v1 and /mnt/tiny_data

```
hbeale@hbeale-mesa:/mnt$ f1=/mnt/tiny_data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
hbeale@hbeale-mesa:/mnt$ zcat $f1 | head | cut -f1-6
cluster	0	1	2	4	5
	nan	nan	nan	nan	0.500
	nan	nan	0.000	nan	0.333
	nan	nan	1.000	nan	0.500
	nan	0.000	0.000	nan	nan
	nan	0.800	0.944	nan	nan
	nan	0.200	0.056	nan	nan
	nan	nan	nan	nan	nan
	nan	nan	nan	nan	nan
	nan	nan	nan	nan	nan
hbeale@hbeale-mesa:/mnt$ f1=/mnt/tiny_data_v1/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
hbeale@hbeale-mesa:/mnt$ zcat $f1 | head | cut -f1-6
cluster	0	1	2	4	5
chr1:14829-14969:-	nan	nan	nan	nan	0.500
chr1:14829-15795:-	nan	nan	0.000	nan	0.333
chr1:15038-15795:-	nan	nan	1.000	nan	0.500
chr1:15942-16606:-	nan	0.000	0.000	nan	nan
chr1:15947-16606:-	nan	0.800	0.944	nan	nan
chr1:16310-16606:-	nan	0.200	0.056	nan	nan
chr1:17055-17232:-	nan	nan	nan	nan	nan
chr1:17055-29320:-	0.000	nan	0.000	nan	0.000
chr1:17368-17525:-	nan	nan	nan	nan	nan
hbeale@hbeale-mesa:/mnt$ 
```

cluster IDs are missing in the new output. 

I went back to Claude and said "that code didn't work. The output didn't contain any text in the cluster column". 

# round 2
using the new output from Claude, now named update_intropolis_coords_v2.sh

(Oops, in hindsight I realized i ran the original script again)

refresh data
```
rm -fr /mnt/tiny_data/
cp -R /mnt/tiny_data_template /mnt/tiny_data
```

run script
```
bash /mnt/gitCode/splicedice_analysis/update_intropolis_coords.sh
```

visually compare output from last step
```
f1=/mnt/tiny_data_v1/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
echo expected output
zcat $f1 | head | cut -f1-6
f1=/mnt/tiny_data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
echo output from new bash script
zcat $f1 | head | cut -f1-6
```

same problem. i went back to claud and showed the output problem 

# round 3
using the new output from Claude, now named update_intropolis_coords_v3.sh


refresh data
```
rm -fr /mnt/tiny_data/
cp -R /mnt/tiny_data_template /mnt/tiny_data
```

run script
```
bash /mnt/gitCode/splicedice_analysis/update_intropolis_coords_v3.sh
```


visually compare output from last step
```

f1=/mnt/tiny_data_v1/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
echo expected output
zcat $f1 | head | cut -f1-6
f1=/mnt/tiny_data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
echo output from new bash script
zcat $f1 | head | cut -f1-6
```

the coordinates are different
```

f1=/mnt/tiny_data_v1/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
f2=/mnt/tiny_data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
paste <(zcat $f1 | head | cut -f1-2) <(zcat $f2 | head | cut -f1-2)
```
```
cluster 0       cluster 0
chr1:14829-14969:-      nan     chr1:14829-14969:-      nan
chr1:14829-15795:-      nan     chr1:14829-15795:-      nan
chr1:15038-15795:-      nan     chr1:15038-15795:-      nan
chr1:15942-16606:-      nan     chr1:15942-16606:-      nan
chr1:15947-16606:-      nan     chr1:15947-16606:-      nan
chr1:16310-16606:-      nan     chr1:16310-16606:-      nan
chr1:17055-17232:-      nan     chr1:16765-16857:+      nan
chr1:17055-29320:-      0.000   chr1:17055-17232:-      nan
chr1:17368-17525:-      nan     chr1:17055-17914:+      0.000
```

chr1:16765-16857:+ is in new output  but not old
all old output ends with -; check, ok, i think it's just chance

```
zcat $f1 | head -1000 | cut -f1 | sed 's/.*\(.\)$/\1/' | sort | uniq -c
ubuntu@hbeale-mesa:/mnt/data$ zcat $f1 | head -1000 | cut -f1 | sed 's/.*\(.\)$/\1/' | sort | uniq -c
     16 +
     93 -
      1 r
ubuntu@hbeale-mesa:/mnt/data$ 

```

look through original data and see if chr1:16765-16857:+ should be in the output

it's not in intropolis
```
 zcat /mnt/tiny_data_template/2020.11.16.intropolis_PS.tsv.gz | cut -f1-6 | grep "16765" | head
```

```
zcat /mnt/tiny_data_template/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz | cut -f1-6 | grep "16765" | head
```

observation: This code takes clusters in 2022.07.06.luad_allPS.tsv.gz and puts them in 2020.11.16.intropolis_PS.tsv.gz. only clusters originally in 2020.11.16.intropolis_PS.tsv.gz AND 2022.07.06.luad_allPS.tsv.gz should be used in the final output


# round 4
using the new output from Claude, now named update_intropolis_coords_v4.sh


refresh data
```
rm -fr /mnt/tiny_data/
cp -R /mnt/tiny_data_template /mnt/tiny_data
```

run script after setting base_dir="/mnt/tiny_data/" and send_alerts=false

```
bash /mnt/gitCode/splicedice_analysis/update_intropolis_coords_v4.sh
```


visually compare output from last step
```

f1=/mnt/tiny_data_v1/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
echo expected output
zcat $f1 | head | cut -f1-6
f1=/mnt/tiny_data/2020.11.16.intropolis_PS.in_luad.updated_cluster_id.tsv.gz
echo output from new bash script
zcat $f1 | head | cut -f1-6
```

chr1:16765-16857:+ is in the output but not input

ok, i ran out of free claude time

# change of strategy: run R markdown notebook on chr1

create chr1-only inputs

```
base_dir=/mnt/data/intropolis_chr1/
mkdir -p ${base_dir}/dennisrm/tcga/luad/

zcat /mnt/data/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz | grep -E '(^cluster|^chr1:)' | pigz > ${base_dir}/dennisrm/tcga/luad/2022.07.06.luad_allPS.tsv.gz; ~/alertme.sh

zcat /mnt/data/2020.11.16.intropolis_PS.tsv.gz  | grep -E '(^cluster|^chr1:)' | pigz > ${base_dir}/2020.11.16.intropolis_PS.tsv.gz; ~/alertme.sh

```

started a new branch: run_only_chr1

rendering update_intropolis_coordinates_chr1.qmd

error
```
  |.......................                            |  44% [unnamed-chunk-10]Error in `open.connection()`:
! cannot open the connection
Backtrace:
  1. global .main()
  2. execute(...)
  3. rmarkdown::render(...)
  4. knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
  5. knitr:::process_file(text, output)
     ...
 16. base::withRestarts(...)
 17. base (local) withRestartList(expr, restarts)
 18. base (local) withOneRestart(withRestartList(expr, restarts[-nr]), restarts[[nr]])
 19. base (local) docall(restart$handler, restartArgs)
 21. evaluate (local) fun(base::quote(`<smplErrr>`))



Quitting from lines 200-210 [unnamed-chunk-10] (update_intropolis_coordinates_chr1.qmd)
                                                                                                             
Execution halted
```


next, freshen /mnt/data_tiny and try it there.

also name chunks

# retry r script with tiny_data


refresh data
```
rm -fr /mnt/tiny_data/
cp -R /mnt/tiny_data_template /mnt/tiny_data
```

needed chmod -R 777 /mnt/tiny_data

# run original R markdown notebook on chr1 - v2 SUCCESS

```
chmod -R 777 /mnt/data/intropolis_chr1/
```

arguments in 
```
base_dir <- "/mnt/data/intropolis_chr1/"
# base_dir <- "/mnt/tiny_data/"

send_alerts <- TRUE
```

SUCCESS!

review numbers

the following are for chr1 alone
```
intropolis PS gz: 2.7G, 405,119 junctions
luad PS gz: 19M, 79,845 junctions

luad cluster IDs in intropolis gz 
506k, 51,597 junctions

intropolis PS in luad gz
560M 38,934 junctions

intropolis junctions in luad gz
234k, 38,934 junctions

intropolis_PS with updated_cluster_ids gz
560M, 38,934 junctions
```


