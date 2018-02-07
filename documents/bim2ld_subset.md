[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2ld_subset
**description**
* command to use *.bim files (plink-format marker files) to generate a subset of linkage disequilibrium independent snps (_subset#.extract)

**syntax**
```bim2ld_subset, bim(-filename-) [n(-n-)]```

 * ```-filename-``` does not require the .bim filetype to be included - this is assumed
 * ```-n-``` this refers to the number of SNPs retained in dataset (default - 50000)

**notes** 
* create a list of N snps that are ld independent from from plink binaries
* the list is reported to ```bim2ld_subset`n'.extract```
* you can specify the number of SNPs to include in the extract file, the default is 50000

**installation**
```net install bim2ld_subset, from(https://raw.github.com/ricanney/stata/master/code/b/) replace```




