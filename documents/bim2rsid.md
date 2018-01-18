[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2rsid
**description** - covert non-rsid named markers to rs#. the script defines 4 classes of marker name; 
- class0 - unable to update (no rs#; no rs# in name; no chromosome location)
- class1 - rs# present
- class2 - rs# embedded in name (eg psy_rs1234)
- class3 - chromosome and bp (hg19) present - extract rsid from reference \*_bim.dta file

the resulting files include \*_rsid plink binaries

**remarks** 

**examples** 
```
bim2rsid , bim(string asis) ref(string asis)
```
**installation**
```
net install bim2rsid , from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```
**auxiliary files**

**dependencies**
[```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)




