[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2frq  
**description** - create allele frequency file from plink binaries. the command is primarily a wrapper for [```plink```](https://www.cog-genomics.org/plink/1.9/) - this program should be accessable by the ${plink} command (see setting up ```profile.do``` in [getting_started](https://github.com/ricanney/stata/blob/master/documents/getting_started.md)). the program creates the variable ```gt``` and ```maf``` which are preserved in memory (therefore any stored data is cleared from memory), and also saved a new file ```<bimname>_frq.dta```. 

**remarks** 

**examples**
```
bim2frq , bim(temp) 
```
**installation**
```
net install bim2frq,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

**dependencies**

[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)   

[```checktabbed```](https://github.com/ricanney/stata/blob/master/documents/checktabbed.md)

[```recodegenotype```](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md)   



