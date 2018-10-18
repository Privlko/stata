[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

**description**
* command to create a publication quality graph-plots from range data

**syntax**

```graphgene,  chr(-chr-) from(-from-) to(-to-) generef(-generef-) ```
 
* ```-chr-```          chromosome to plot
* ```-from-```         base-position to plot from (hg19)
* ```-to-```           base-position to plot to (hg19)
* ```-generef-```      reference exon co-ordinates (hg19)
 
**notes**

* the ```generef``` dataset refers to the ```Homo_sapiens.GRCh37.87.gtf_exon.dta``` file that carries information on the intron/exon boundaries and transcript start and end  for protein-coding genes. my code to generate this file can be found under ```stata/code/g/get-ensembl-gtf.do```

![](../images/temp-graphgene.png)

**installation**

```net install graphgene, from(https://raw.github.com/ricanney/stata/master/code/g/) replace```

**dependencies**

```net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)```

