[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2eigenvec  

**description**
* a command to generate ancestry informative eigenvectors from 
 plink-format files

**syntax**
```bim2eigenvec, bim(-filename-) [pc(real 10)]```
 
* ```-filename-``` does not require the .bim filetype to be included - this is assumed
* ```-pc-```  defines the number of principle components to calculate; the default number of pcs to calculate is 10

**notes** - 
* this program create eigenvector and eigenvalues from plink binaries. 
* the command is essentially a wrapper for [```plink```](https://www.cog-genomics.org/plink/1.9/) and [```plink2```](https://www.cog-genomics.org/plink/2.0/)
* both programs should be accessable by the ${plink} and ${plink2} commands (see setting up ```profile.do``` in [getting_started](https://github.com/ricanney/stata/blob/master/documents/getting_started.md)). 
* the program creates two files ```<bimname>_eigenvec.dta``` and ```<bimname>_eigenval.dta```. these are stata versions of the plink2 --pca output file \*. eigenvec and \*.eigenval (see https://www.cog-genomics.org/plink/2.0/formats#eigenvec). 
* the code uses [```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md) which  based on build hg19 co-ordinates. exclusion co-ordinates will need updating for other builds. 
* also consider [```bim2hapmap```](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md) to generate plots with reference to the hapmap3 reference panel genotypes. [```bim2hapmap```](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md) also uses the [```bim2eigenvec```](#bim2eigenvec) program and creates a "similarity" file that identifies samples that show similar ancestries to the definable hapmap3 populations 

**installation**
```net install bim2eigenvec,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```
