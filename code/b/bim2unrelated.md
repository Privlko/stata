[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2unrelated

**description** 
* a command to use plink-format genotype files and to select a subset of unrelated individuals

**syntax**

 ```bim2unrelated , bim(-filename-) [threshold(-threshold-)]```
 
 * ```-filename-```   does not require the .bim filetype to be included - this is assumed
 * ```-threshold-```  kinship threshold for unrelated default = 0.0221

**notes**
* the program uses a greedy algorithm via the --king-cutoff flag in ``` plink2``` - this means that in trios it is often the child who is removed due to their relatedness to >1 individual. the following graphs are created alongside a set of plink binaries (see below)

![](../images/bim2unrelated-ibs-by-kin.png)
![](../images/bim2unrelated-kinship-histogram.png)

* created files include;
 * ```input.king.cutoff.in```
 * ```input.king.cutoff.out```
 * ```input-unrelated.bed```
 * ```input-unrelated.bim```
 * ```input-unrelated.fam```
 * ```input-unrelated.log```

* you can define a threshold for "relatedness", this number is based on the KING algorithm; where 0.354 = duplicates; 0.1770 = first degree relationships; 0.0884 = second degree relationships; 0.0442 = third degree relatinships etc) The default for this program is .0221
 
**installation**

```net install bim2unrelated ,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```




