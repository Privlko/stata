[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)


## bim2array
**description** - imports plink \*.bim files into stata and maps to the most likely array from the reference database.

**remarks** 

**examples**
```
bim2array , bim(temp) dir(directory_containing_reference_panels) 
```
**installation**
```
net install bim2array, from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```
**dependencies**

[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md) - [```array-reference-panels```](link inactive)
