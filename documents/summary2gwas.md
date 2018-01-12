[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## summary2gwas
**description** - process association data for post-gwas analysis. often gwas summary files requires conversion to a variety of formats, but the same quality controls need to be applied i.e. common builds need to be mapped and ambiguous or non-strand compatible genotypes need to be removed. ```summary2gwas``` creates a master \*-summary.dta file. the \*-summary.dta file contains the following variables; 

| varname | description
| -: | :-
|```chr```    | chromosome (hg19)
|```bp```     | base location (hg19 +1)
|```snp```    | rsid     (case-sensitive (lower))
|```a1```     | allele 1 (case-sensitive (upper))
|```a2```     | allele 2 (case-sensitive (upper))
|```a1_frq``` | allele frequency of allele 1 (either unaffected from original data or proxy from reference )
|```p```      | p-value from association
|``` n```     | sample size of gwas
|```z```      | standardised z-score (either original or derived from ``` z = beta/se```)
|```se```     | standard error (either original or derived from ```[se = sd/mean]``` where ```[sd = n * p]``` and  ```[mean = sqrt(n) * p * (1-p)]```
|```beta```   | beta (either original or derived from ``` beta = z * se```
|```or```     | odds ratio (either original or derived from ```or = exp(beta)```)
|```l95```    | lower 95% confidence interval (either original or derived from ```or = - (1.96 * se) ```)
|```u95```    | upper 95% confidence interval (either original or derived from ```or = + (1.96 * se) ```)

bespoke preprocesing is required to ensure the program has the appropriate variables to work. at a minimum the input file needs
```snp``` ```a1``` ```a2``` ```n``` ```b``` ```or``` ```se``` ```l95``` ```u95``` ```p``` ```z``` - note that ```chr``` and ```bp``` are taken from the reference bim files.

the program performs a number of sanity checks and standard quality controls - including duplicate removal and mapping strand / allele coding to reference and updating chromosome location to hg19 +1. some of the quality control is only applied if the following variables are present);

| varname | description
| -: | :-
|```info```         | imputation info score (limit to info > 0.8)
|```direction```    | direction of meta-analysis (remove snps where > 1 of the input studies are absent)

**remarks** - from the \*-summary.dta file we have included derived formats (see below); additional formats can be added over time (and upon request).

| formatted for | filename
| -: | :-
| [```profilescore```](https://github.com/ricanney/stata/blob/master/documents/profilescore.md) | \*.prePRS.tsv.gz file
| ```ld score regression``` | \*.sumstat.gz file
| ```magma``` | \*.pval.gz file


**examples**

```
* note that to work you should have python working on your computer and also be able to run ```munge_sumstats.py```. on a windows machine this may mean editing the py script to ignore the gzip command

global ref            eur_1000g_phase3_chrall_impute_macgt5
global munge_sumstats "C:\Users\Richard Anney\Anaconda2\Lib\ldsc\munge_sumstats.py"
global input          -original dataset-
global output         -new name- (author-year-pheno)  

* - example of bespoke pre-processing
cd original
!$zcat ${input} | ${head}        > tempfile-head.txt

* - check which headers you wish to extract
!$zcat ${input} | ${cut}  -f 1-7 > tempfile-input.txt

* - import extracted data
import delim using tempfile-input.txt, clear 
erase tempfile-input.txt

* - rename variables
rename (allele1 allele2 weight zscore) (a1 a2 n z)

* - derive missing variables
gen sd = sqrt(n) * p * (1-p)
gen mean = n * p
gen se = sd/mean
gen beta = z * se
gen or = exp(beta)
gen l95 = or - (1.96 * se)
gen u95 = or + (1.96 * se)

* - keep minimum variable set
keep snp a1 a2 n b or se l95 u95 p z direction 
for var a1 a2: replace X = strupper(X)

* - run processing
cd ..
!mkdir processed
cd processed
noi summary2gwas, in(${input}) out(${output}) reference(${ref}) munge(${munge_sumstats})

```
**installation**
```
net install summary2gwas,         from(https://raw.github.com/ricanney/stata/master/code/s/) replace
```

**additional files**


