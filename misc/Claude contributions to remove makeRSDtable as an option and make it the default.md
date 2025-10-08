Claude contributions to remove makeRSDtable as an option and make it the default

implemented in branch "remove-makeRSDtable-option,-make-default"

In this code https://public.gi.ucsc.edu/~hbeale/splicedice/splicedice/ir_table.py,  how do i change makeRSDtable from an argument into a default?

I'll fetch that code to see the current implementation.

To change `makeRSDtable` from an argument into a default (so it always runs), you need to:

1. **Remove the argument definition** (lines 18-20)
2. **Remove the conditional check** that uses it (line 130)
3. **Always calculate RSD** (line 112)

Here are the specific changes:

**In the `add_parser` function**, remove these lines:

python

```python
parser.add_argument("-r","--makeRSDtable",
                    action="store_true",
                    help="Make a table of relative standard deviations in coverage across intron.")
```

**In the `calculateIR` function** (around line 112), change:

python

```python
if args.makeRSDtable:
    RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
```

to:

python

```python
RSD[sample][cluster] = np.std(covArray) / np.mean(covArray)
```

**In the `run_with` function** (around line 130), change:

python

```python
if args.makeRSDtable:
    writeRSDtable(samples, outputPrefix, junctions, RSD)
```

to:

python

```python
writeRSDtable(samples, outputPrefix, junctions, RSD)
```

This will make the RSD table generation always happen by default, without requiring the `-r` or `--makeRSDtable` flag.