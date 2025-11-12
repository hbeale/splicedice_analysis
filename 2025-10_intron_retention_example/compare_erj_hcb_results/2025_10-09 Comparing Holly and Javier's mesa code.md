2025_10-09 Comparing Holly and Javier's mesa code



on mustard

```

cd /scratch/hbeale_public
git clone https://github.com/BrooksLabUCSC/splicedice.git 
cd splicedice/
git checkout 0f59716

```



HEAD is now at 0f59716 Updated simliarity score to not include nan values in denominator



```
diff -r . ../mesa/ --exclude ".git"
```



```
Only in ../mesa/: build
Only in ../mesa/mesa: __pycache__
Only in ../mesa/: mesa.egg-info

```



# q from erj:

Is it only the IR that’s is being called differently?

Does the PS table look identical?

```
ps_j=/mnt/splicedice_ir_example_archives/Javier/SSA_Jurica_allPS.tsv
ps_h=/mnt/splicedice_ir_example_archives/2025.10.08_21.47.01/analysis/_allPS.tsv
diff $ps_j $ps_h

```

The ps table was not the same.
