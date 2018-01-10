[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2ld_subset
**description** - create a list of N snps that are ld independent from from plink binaries

the program creates a single file; 
 - _subset<N>.extract


**remarks**  - you can specify the number of SNPs to include in the extract file, the default is 50000

**examples**
```
bim2ld_subset , bim(temp) 
bim2ld_subset , bim(temp) n(real 1000)
```

**installation**
```
net install bim2ld_subset, from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

**dependencies**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)
[```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)




