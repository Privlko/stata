[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2dta
**description**
 a command to convert *.bim files (plink-format marker files) to *.dta

**syntax**
```bim2dta, bim(-filename-) ```
 
 * ```-filename-``` does not require the .bim filetype to be included - this is assumed

**notes**
* the program uses [```recodegenotype```](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md) to create the single letter IUPAC genotype code from the observed alleles. this information is stored in thevariable ```gt```. the program created a new \*.dta file ```<bimname>_bim.dta```. 
* an additional variable has been included ```loc_name``` to aid in merging (```loc_name``` = ```chr<chr>#:<position>#-<gt>```). the ````gt``` included in the ```loc_name``` is converted to ```R``` if ```Y``` and ```M``` if ```K```. 

**installation**
```net install bim2dta, from(https://raw.github.com/ricanney/stata/master/code/b/) replace```


