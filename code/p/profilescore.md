[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## profilescore

**description** 
  command to generate polygenic profile scores 

**syntax**

```profilescore , param(-param-) [premerge(-premerge-) draw_manhattan(-manhattan-)]```

* ```-param-``` 	name of parameter file
* ```-premerge-``` 	type yes if you want to include premerging via bim2merge
* ```-manhattan-``` type yes if you want the intercept manhattan (for the processed gwas) to be drawn

**notes**
* calculate polygenic risk scores over multiple thresholds for multiple genotype files against a single GWAS input.
* the program acts as a wrapper for ```plink``` to run through a pipeline of checks and balances, merges and clumping routines to generate \*.profile scores at a range of P-value thresholds from 0.5 to 1e-8. 
* these profile scores are merged into a single analysis \*.dta for each genotype and a summary \*.meta-log describing key metrics from the process.

**remarks** 
* prior to running ```profilescore``` a numbe of prep steps are required;
 - preparing the input GWAS data - see [```summary2gwas```](https://github.com/ricanney/stata/blob/master/documents/summary2gwas.md) 
 - preparing the test genotypes - see [```genotypeqc```](https://github.com/ricanney/stata/blob/master/documents/genotypeqc.md)
 - pre-merging the input genotypes - see [```bim2merge```](https://github.com/ricanney/stata/blob/master/documents/bim2merge.md) 
 - create parameter file containing information about the analysis (not ${plink} ${tabbed} and a range of unix replocas should be loaded from the ```profile.do``` file as standard)

* ```project_folder``` set the location of project folder (set as current using \`c(pwd)')
* ```project_name```   set the project name to project1
* ```kg_ref ```        set location/filename of the hg19 1000-genomes phase 3 reference genotypes
* ```Ndata ```         set number of genotypes files to be examined
* ```data1```          set location/filename for dataset1
* ```data2```          set location/filename for dataset2
* ```data3```          set location/filename for dataset3
* ```gwas_short```     set a short-name for gwas input for output files
* ```gwas_prePRS```    set location/filename for prePRS.tsv or *tsv.gz file 

**example**

```
global ref    E:\data\genotypes\ref\1000-genomes\phase3\data\ftp.1000genomes.ebi.ac.uk\eur-1000g-phase3-chrall-mac5
global bim3   E:\data\genotypes\dep\jules-thorn\data\julesthorn-cases-qc-v7\julesthorn-cases-qc-v7
global bim4   E:\data\genotypes\dep\jules-thorn\data\julesthorn-controls-qc-v7\julesthorn-controls-qc-v7

cd D:\github\software\stata\sandbox\data
!mkdir profilescore
cd profilescore
discard 
net install profilescore, from(https://raw.github.com/ricanney/stata/master/code/p/) replace
clear
set obs 1
outsheet using ${project_name}.parameters, non noq replace
	
global project_folder   D:\github\software\stata\sandbox\data\profilescore
global kg_ref           ${ref}
global data_name        test
global data1            ${bim3}
global data2            ${bim4}
global Ndata            2
qui { // anney-ripke-antilla-autism-2017
	global gwas_short		  anney-ripke-antilla-autism-2017
	global gwas_prePRS  	  D:\github\methods\polygenic_risk_scoring\data\prePRS\anney-ripke-antilla-2017-prePRS.tsv
	global project_name		  ${gwas_short}-${data_name}
	noi profilescore , param(${project_name}.parameters) draw_manhattan(yes) 
	}
qui { // anney-ripke-antilla-autism-2017 (premerge)
	cd D:\github\software\stata\sandbox\data
	cd profilescore
	discard 
    global kg_ref           ${ref}
	global data_name        test
	global data1            ${bim3}
	global data2            ${bim4}
	global project_name		${gwas_short}-${data_name}
    noi bim2merge , bim(${data1}, ${data2}) ref_bim(${kg_ref}) project(${project_name})
    global kg_ref           D:\github\software\stata\sandbox\data\profilescore\eur-1000g-phase3-chrall-mac5-intersect
	global data1            D:\github\software\stata\sandbox\data\profilescore\julesthorn-cases-qc-v7-intersect
	global data2            D:\github\software\stata\sandbox\data\profilescore\julesthorn-controls-qc-v7-intersect
	noi profilescore , param(${project_name}.parameters) draw_manhattan(yes) premerge(yes)
	}
```

**installation**

```net install profilescore,         from(https://raw.github.com/ricanney/stata/master/code/p/) replace```



