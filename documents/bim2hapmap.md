[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2hapmap
**description** - create ancestry plots and similarity to hapmap3 classifiers from plink binaries. 

the program creates three files; 
 - ```bim2hapmap_<ancestry>.png``` - non-selected scatter plots
 - ```bim2hapmap_<ancestry>-like.png```  - ancestry-selected scatter plots
 - ```bim2hapmap_<ancestry>-like.keep``` - list of ```fid iid``` of individuals who are similar to the defined ancestry

![](../images/bim2hapmap_pca.png)
![](../images/bim2hapmap_pca-CEU_TSI-like.png)

**remarks** 

**examples**
```
bim2hapmap , bim(temp) like(CEU TSI) hapmap(hapmap3-all-hg19-1) aims(hapmap3-all-hg19-1-aims.snp-list)
```

**installation**
```
net install bim2hapmap, from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

[```hapmap3-all-hg19-1.bed```](https://www.dropbox.com/s/zldpw4r8xhr468b/hapmap3-all-hg19-1.bed)
[```hapmap3-all-hg19-1.bim```](https://www.dropbox.com/s/8p73iwui1nvciwn/hapmap3-all-hg19-1.bim)
[```hapmap3-all-hg19-1.fam```](https://www.dropbox.com/s/q7cirqxx053gfjn/hapmap3-all-hg19-1.fam)
[```hapmap3-all-hg19-1.population```](https://www.dropbox.com/s/y4x879x7lnw6crs/hapmap3-all-hg19-1.population)
[```hapmap3-all-hg19-1-aims.snp-list```](https://www.dropbox.com/s/6c9it6q7emwcbap/hapmap3-all-hg19-1-aims.snp-list)


**dependencies**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)
[```checktabbed```](https://github.com/ricanney/stata/blob/master/documents/checktabbed.md)
[```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)
[```bim2eigenvec```](https://github.com/ricanney/stata/blob/master/documents/bim2eigenvec.md)
[```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)




