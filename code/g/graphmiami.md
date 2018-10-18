[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## graphmiami
**description** - plot a miami plot for two gwas datasets for a defined region. the plot also includes a geneplot. both input gwas require the variable rsid/p; co-ordinates are taken from a reference binary.

![](../images/miami-plot-chr9_85000000-88000000.png)

**remarks** - the geneplot requires gene/exon boundaries derived using the [```get-ensembl-gtf.do```](https://github.com/ricanney/stata/blob/master/code/g/get-ensembl-gtf.do) script. as well as reference geontypes (1000-genomes phase-3 hg19)

**examples**
```
graphmiami , gwas1(file1) gwas2(fil2) title1(disease1) title2(disease1) region(chr7:100000000-120000000) exons(E:\data\other\ftp-ensembl\data\Homo_sapiens.GRCh37.87.gtf_exon.dta) ref(E:\data\genotypes\ref\1000-genomes\phase3\data\hg19\eur_1000g_phase3_chrall_impute_macgt5)
```
**installation**
```
net install graphmiami,         from(https://raw.github.com/ricanney/stata/master/code/g/) replace
```
**dependencies**

[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)



