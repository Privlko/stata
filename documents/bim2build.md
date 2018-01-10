[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2build   
**description** - checks the genome build from a plink \*.bim file. the command requires the marker identifiers to be rs# and uses a merge routine against a reference file of snps with location on various builds

**remarks** - to date this only examines hg17 +0/1- hg19 +0/1

**examples**
```
bim2build , bim(temp) build_ref(rsid-hapmap-genome-location.dta)
```
**installation**
```
net install bim2build,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

[```rsid-hapmap-genome-location.dta```](https://www.dropbox.com/s/uji8b7pe39pq7yp/rsid-hapmap-genome-location.dta)

**dependencies**

[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)

[```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)
