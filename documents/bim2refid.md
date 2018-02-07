[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2refid
**description**
* a command to convert the marker names to a common (reference) name via the snp location and genotype code

**syntax**

```bim2refid , bim(-filename-) ref(-reference-)```

* ```-filename-```    this is the test dataset - does not require the .bim filetype to be included - this is assumed
* ```-reference-```   this is the reference dataset - does not require the .bim filetype to be included - this is assumed

**notes** 
* converts hg19 mapped snps to reference nomenclature via ```loc_name```.
* ```loc_name``` is a snp name concatenated from chromosome, location and UIPAC genotype code (e.g ```chr22:16050654-ID``` ```chr22:16050840-S``` ```chr22:16051249-R``` or ```chr22:16051453-M```). 
* The reference file must contain the variables ```snp``` and ```loc_name```. e.g. ```eur-1000g-phase3-chrall-mac5_bim.dta```.
* to create ```eur-1000g-phase3-chrall-mac5_bim.dta``` see [```create_1000genomes```](https://github.com/ricanney/stata/blob/master/documents/create_1000genomes.md) and apply the routine [```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)

**installation**

```net install bim2refid , from(https://raw.github.com/ricanney/stata/master/code/b/) replace```




