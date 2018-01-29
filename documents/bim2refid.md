[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2refid
**description** - converts hg19 mapped snps to reference nomenclature via ```loc_name```. ```loc_name``` is a snp name concatenated from chromosome, location and UIPAC genotype code (e.g ```chr22:16050654-ID``` ```chr22:16050840-S``` ```chr22:16051249-R``` or ```chr22:16051453-M```). The reference file must contain the variables ```snp``` and ```loc_name```. e.g. ```eur-1000g-phase3-chrall-mac5_bim.dta```.

**remarks** - to create ```eur-1000g-phase3-chrall-mac5_bim.dta``` see [```create_1000genomes```](https://github.com/ricanney/stata/blob/master/documents/create_1000genomes.md) and apply the routine [```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)

**syntax**
```bim2refid , bim(string asis) ref(string asis)```
**example**
```bim2refid, bim(bipolar-disorder-wtccc1) ref(eur-1000g-phase3-chrall-mac5_bim.dta)```
**installation**
```net install bim2refid , from(https://raw.github.com/ricanney/stata/master/code/b/) replace```
**auxiliary files**
```eur-1000g-phase3-chrall-mac5_bim.dta``` or any hg19 genotype reference containing the variables ```snp``` and ```loc_name```
**dependencies**
[```bim2count```](https://github.com/ricanney/stata/blob/master/documents/bim2count.md) [```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md) [```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)




