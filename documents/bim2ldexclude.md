[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2ldexclude
**description**
* command to use *.bim files (plink-format marker files) to identify SNPs
 to exclude that are located in areas of extended linkage disequilibrium

**syntax**

```bim2ldexclude, bim(-filename-)```

* ```-filename-``` does not require the .bim filetype to be included - this is assumed

**notes**
* create a list of snps that are included  within regions of known extended linkage disequilibrium.
* these regions were published in [Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes Price, Mike Weale et al., The American Journal of Human Genetics 83, 127 - 147, July 2008](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2443852/pdf/main.pdf)
* the program creates a single file, ```bim2ldexclude.exclude``` that can be used with ```plink```

**installation**

```net install bim2ldexclude, from(https://raw.github.com/ricanney/stata/master/code/b/) replace```




