[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2build
**description** - checks the genome build from a plink \*.bim file. 

**remarks** - to date this only examines hg17 +0/1- hg19 +0/1

**examples**
```
bim2build , bim(temp) ref(bim2build.dta)
```
**installation**
```
net install bim2build, from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**
[```bim2build.dta```](link)

**dependencies**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md) [```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)
