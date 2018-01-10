[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2eigenvec  
**description** - create eigenvector and eigenvalues from plink binaries. the command is essentially a wrapper for [```plink```](https://www.cog-genomics.org/plink/1.9/) and [```plink2```](https://www.cog-genomics.org/plink/2.0/) - both programs should be accessable by the ${plink} and ${plink2} commands (see setting up ```profile.do``` in [getting_started](https://github.com/ricanney/stata/blob/master/documents/getting_started.md)). the program creates two files ```<bimname>_eigenvec.dta``` and ```<bimname>_eigenval.dta```. these are stata versions of the plink2 --pca output file \*. eigenvec and \*.eigenval (see https://www.cog-genomics.org/plink/2.0/formats#eigenvec). 

**remarks** - [```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md) is based on build hg19 co-ordinates. exclusion co-ordinates will need updating for other builds. 

**remarks** - also consider [```bim2hapmap```](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md) to generate plots related to the hapmap3 reference panel genotypes. [```bim2hapmap```](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md) also uses the [```bim2eigenvec```](#bim2eigenvec) program and creates a "similarity" file that identifies samples that show similar ancestries to the definable hapmap3 populations 

**examples**
```
bim2eigenvec , bim(temp) 
```
**installation**
```
net install bim2eigenvec,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

**dependencies**

[```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)

[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)



