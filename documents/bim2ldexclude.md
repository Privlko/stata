[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2ldexclude
**description** - create a list of snps that do include those within regions of known extended ld. regions were published in 
[Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes Price, Mike Weale et al., The American Journal of Human Genetics 83, 127 - 147, July 2008](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2443852/pdf/main.pdf)

the program creates a single file; 
 - long-range-ld.exclude


**remarks**  - you can specify the number of SNPs to include in the extract file, the default is 50000

**examples**
```
bim2ldexclude , bim(temp) 
```

**installation**
```
net install bim2ldexclude, from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

**dependencies**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)





