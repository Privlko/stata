[back to opening page](https://github.com/ricanney/stata)
[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)


## bim2dta   
**description** - imports plink \*.bim files into stata (and does some other useful stuff too). the program uses  [```recodegenotype```](#recodegenotype) to create the single letter IUPAC genotype code from the observed alleles. this information is stored in thevariable ```gt```. the program created a new \*.dta file ```<bimname>_bim.dta```. 

**remarks** 

**examples**
```
bim2dta , bim(temp) 
```
**installation**
```
net install bim2dta,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```
**additional files**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)[```recodegenotype```](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md)

