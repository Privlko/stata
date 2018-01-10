[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2count   
**description** - counts the number of markers and individuals plink \*.bim and \*.fam file and prints to screen.

**remarks** - requires the [```loadunixreplicas```](https://github.com/ricanney/stata/blob/master/documents/loadunixreplicas.md) to be loaded and working on your system, as it requires the ```wc.exe``` executable to be linked via ```${wc}```. 

**examples**
```
bim2count , bim(temp) 
```
**installation**
```
net install bim2count,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

**dependencies**


