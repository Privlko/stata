[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2frq
**description**
* command to create _frq.dta (plink-format marker files) from plink binaries 

**syntax**

```bim2frq, bim(-filename-)``` 

* ```-filename-``` does not require the .bim filetype to be included - this is assumed

**notes** 
* create allele frequency file from plink binaries. the command is primarily a wrapper for [```plink```](https://www.cog-genomics.org/plink/1.9/) 
* this program should be accessable by the ${plink} command (see setting up ```profile.do``` in [getting_started](https://github.com/ricanney/stata/blob/master/documents/getting_started.md)). 
* the program creates the variable ```gt``` and ```maf``` which are preserved in memory (therefore any stored data is cleared from memory), and also saved a new file ```<bimname>_frq.dta```. 

**installation**

```net install bim2frq,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```