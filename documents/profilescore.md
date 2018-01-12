[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## profilescore
**description** - calculate polygenic risk scores over multiple thresholds for multiple genotype files against a single GWAS input. 

the program acts as a wrapper for plink to run through a pipeline of checks and balances, merges and clumping routines to generate \*.profile scores at a range of P-value thresholds from 1 to 1e-8. these profile scores are merged into a single analysis \*.dta for each genotype and a summary \*.meta-log describing key metrics from the process.

**remarks** - prior to running ```profilescore``` a numbe of prep steps are required;
 - preparing the input GWAS data - see [```summary2gwas```](https://github.com/ricanney/stata/blob/master/documents/summary2gwas.md) 
 - preparing the test genotypes - see [```genotypeqc```](https://github.com/ricanney/stata/blob/master/documents/genotypeqc.md)
 - pre-merging the input genotypes - see [```bim2merge```](https://github.com/ricanney/stata/blob/master/documents/bim2merge.md) 
 - create parameter file containing information about the analysis (not ${plink} ${tabbed} and a range of unix replocas should be loaded from the ```profile.do``` file as standard)

| global parameter | Description
| -: | :-
| ```project_folder``` | set the location of project folder (set as current using `c(pwd)')
| ```project_name```   | set the project name to project1
| ```kg_ref ```        | set location/filename of the hg19 1000-genomes phase 3 reference genotypes
| ```Ndata ```         | set number of genotypes files to be examined
| ```data1```          |  set location/filename for dataset1
| ```data2```          |  set location/filename for dataset1
| ```data3```          |  set location/filename for dataset1
| ```gwas_short```     | set a short-name for gwas input for output files
| ```gwas_prePRS```    | set location/filename for prePRS.tsv or *tsv.gz file 

**example**
```
global project_folder  E:\sandbox\tmp\profilescore
global project_name    merge_all
global kg_ref          E:\sandbox\tmp\profilescore\eur_1000g_phase3_chrall_impute_macgt5
global dataset1        ${project_folder}\dataset1
global dataset2        ${project_folder}\dataset2
global dataset3        ${project_folder}\dataset3

* - merge 3 datasets: dataset1 dataset2 dataset3
cd ${project_folder}
noi bim2merge , bim(${dataset1}, ${dataset2}, ${dataset3}) ref_bim(${kg_ref}) project(${project_name})

* - create profilescore.parameter file
cd ${project_folder}
file open myfile using ${project_name}.parameters, write replace
file write myfile "global Ndata           3"                                _n
file write myfile "global data1           ${dataset1}-intersect"            _n
file write myfile "global data2           ${dataset2}-intersect"            _n
file write myfile "global data3           ${dataset3}-intersect"            _n 
file write myfile "global gwas_short      author-year-phenotype"            _n 
file write myfile "global gwas_prePRS     author-year-phenotype-prePRS.tsv" _n 
file close myfile

* - create run profilescore
profilescore, param( ${project_name}.parameters)
```

**installation**

```
net install profilescore,         from(https://raw.github.com/ricanney/stata/master/code/p/) replace
```
**additional files**

