[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2hapmap
**description**
* command that uses plink-format genotype files to plot against hapmap ancestries.
* the script also defines individuals with ancestral similarities to a defined hapmap set

**syntax**

```bim2hapmap,  bim(-filename-) hapmap(string asis) aims(string asis) like(string asis)```
 
* ```-filename-``` does not require the .bim filetype to be included - this is assumed
* ```-aims-```     download bim2hapmap.aims from github.com/ricanney
* ```-hapmap-```   download hapmap3-all-hg19+1.bed; hapmap3-all-hg19+1.bim; hapmap3-all-hg19+1.fam; hapmap3-all-hg19+1.population from github.com/ricanney
* ```-like-```     this refers to population codes (```ASW LWK MKK YRI CEU TSI MEX GIH CHB CHD JPT```); more than one code can be specified (space seperated)

**notes** 
* the program creates three files; 
 * ```bim2hapmap_<ancestry>.png``` - non-selected scatter plots
 * ```bim2hapmap_<ancestry>-like.png```  - ancestry-selected scatter plots
 * ```bim2hapmap_<ancestry>-like.keep``` - list of ```fid iid``` of individuals who are similar to the defined ancestry

![](../images/bim2hapmap_pca.png)
![](../images/bim2hapmap_pca-CEU_TSI-like.png)

**installation**

```net install bim2hapmap, from(https://raw.github.com/ricanney/stata/master/code/b/) replace```



