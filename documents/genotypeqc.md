[back to opening page](https://github.com/ricanney/stata)
 
[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## genotypeqc
**description** - a program / pipeline to perform quality control genotype data from arrays or imputation. 

the program acts as a wrapper for ```plink``` and ```plink2``` to run through a pipeline of checks and balances, along with a applying a range of quality controls. the program creates a bundle of qc'd plink binaries along with a summary \*.meta-log and a quality control report in \*docx format containing numerous quality metrics. as part of the pipeline the program identified the genome-build of the array as well as most likely source of array. markers are renamed to rsid and procerssed according to excessive cryptic relatedness, missingess, heterozygosity, relatedess(duplicates, second and third degree relatives are removed), minor allele frequency and hardy weinberg equilibrium. ancestry are inferred and plotted against references and files generated to allow individuals to be removed in downstream applications.

**remarks** - to run ```genotypeqc``` you will first need to set a number of global parameters. these parameters need to be saved into a flat text file e.g. test.parameters
**parameter file** - the pipeline requires a number of dependencies and thresholds to be defined within a parameters file. The parameter file is basically a set of macros that ```stata``` stores in memory and applies during the qc program

> note that as of 16th November, the parameter file has become streamlined, removing annotation and becoming in essence a \*.do file

** example parameter file**
```
# > define the following globals in the parameter file
global array_ref // the location of the genotyping array folder 
global build_ref // location of the genotyping build file (rsid-hapmap-genome-location.dta)
global kg_ref_frq // location of the -frq.dta file providing reference allele frequency for the 1000genome european reference datasets
global hapmap_data // location of th hapmap3 (hg19+1) referenece genotype file + *.population file
global aims // location of list of ancestry informative markers (hapmap3-all-hg19-1-aims.snp-list)
global rounds // number of quality control rounds to cycle through (default = 4)
global hwep // min -log10 p-value tolerated for hardy-weinberg deviation (default = 10)
global hetsd // maximum standard deviations tolerated from mean heterozygosity (default = 4)
global mind // maximum missingness by individual tolerated (default = 0.02)
global geno1 // maximum missingness by marker tolerated - round 1 (default = 0.05)
global geno2 // maximum missingness by marker tolerated - final (default = 0.02)
global kin_d // kinship threshold for duplicates (default = 0.3540)
global kin_f // kinship threshold for first degree relatives (default = 0.1770)
global kin_s // kinship threshold for second degree relatives (default = 0.0884)
global kin_t // kinship threshold for third degree relatives (default = 0.0442)
```

**version history**
 - v4 - included a minor allele frequency threshold default = 0.01
 - v5 - alter maf to mac5 to retain additional "rarer" variation
 - v6 - convert script to include stand-alone subroutines; bug-fix: duplicate routine now retain one of the duplicated observations
 - xx - add known_array function - this skips array check for known arrays (e.g. post imputation) - assumes hg19+1 co-ordinates


**examples**
```
* non-imputed data
file open myfile using test.parameters, write replace
file write myfile "global array_ref genotype-array\data" _n
file write myfile "global build_ref build-ref\data\rsid-hapmap-genome-location.dta" _n
file write myfile "global kg_ref_frq 1000genomes\eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta" _n
file write myfile "global hapmap_data hapmap3\hapmap3-all-hg19-1" _n
file write myfile "global aims hapmap3\hapmap3-all-hg19-1-aims.snp-list" _n
file write myfile "global rounds 4" _n
file write myfile "global hwep 10" _n
file write myfile "global hetsd 4" _n
file write myfile "global maf 0.01" _n
file write myfile "global mind 0.02" _n
file write myfile "global geno1 0.05" _n
file write myfile "global geno2 0.02" _n
file write myfile "global kin_d 0.3540" _n
file write myfile "global kin_f 0.1770" _n
file write myfile "global kin_s 0.0884" _n
file write myfile "global kin_t 0.0442" _n
file close myfile
genotypeqc, param(test.parameters)

* imputed data (known_array)
genotypeqc, param(test.parameters) known_array(michigan-imputation-server-v1.0.3-hrc-r1.1-2016)
```

**installation**
```
net install genotypeqc, from(https://raw.github.com/ricanney/stata/master/code/g/) replace
```

**auxiliary files**
- [```rsid-hapmap-genome-location.dta```](<add-link>) 
- [```eur_1000g_phase3_chrall_impute_macgt5.bim```](<add-link>) 
- [```eur_1000g_phase3_chrall_impute_macgt5.bed```](<add-link>) 
- [```eur_1000g_phase3_chrall_impute_macgt5.fam```](<add-link>) 
- [```eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta```](<add-link>) 
- [```hapmap3-all-hg19-1.bim```](<add-link>) 
- [```hapmap3-all-hg19-1.bed```](<add-link>) 
- [```hapmap3-all-hg19-1.fam```](<add-link>) 
- [```hapmap3-all-hg19-1.population```](<add-link>) 
- [```hapmap3-all-hg19-1-aims.snp-list```](<add-link>) 
- [```genotype-array.tar.gz```](<add-link>)


**dependencies**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)
[```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)



