![back to opening page](https://github.com/ricanney/stata)
## information on packages
[```bim2build```](#bim2build) [```bim2count```](#bim2count) [```bim2dta```](#bim2dta) [```bim2count```](#bim2eigenvec) [```bim2eigenvec```](#bim2count) [```bim2frq```](#bim2frq) [```bim2hapmap```](#bim2hapmap) [```bim2ld_subset```](#bim2ld_subset) [```bim2ldexclude```](#bim2ldexclude) [```checkfile```](#checkfile) [```checktabbed```](#checktabbed) [```create_temp_dir```](#create_temp_dir) [```datestamp```](#datestamp) [```ensembl2symbol```](#ensembl2symbol) [```fam2dta```](#fam2dta) [```genotypeqc```](#genotypeqc) [```get_stata_bundle```](#get_stata_bundle) [```graphmanhattan```](#graphmanhattan) [```graphmiami```](#graphmiami) [```graphqq```](#graphqq) [```graphplinkfrq```](#graphplinkfrq) [```graphplinkhet```](#graphplinkhet) [```graphplinkhwe```](#graphplinkhwe) [```graphplinkimiss```](#graphplinkimiss) [```graphplinkkin0```](#graphplinkkin0) [```graphplinklmiss```](#graphplinklmiss) [```graphgene```](#graphgene) [```gwas2prs```](#gwas2prs) [```kin0filter```](#kin0filter) [```loadUnixReplicas```](#loadUnixReplicas) [```profilescore```](#profilescore) [```recodegenotype```](#recodegenotype) [```recodestrand```](#recodestrand) [```symbol2ensembl```](#symbol2ensembl) 

## bim2build

**description** - a command to examine the genome build of a plink \*.bim file. the command utilises the programs ```checkfile```, ```bim2dta``` and requires a reference of snps with location on various builds ```rsid-hapmap-genome-location.dta```

**remarks** - to date this only examines hg17 +0/1- hg19 +0/1

**examples**

```
bim2build , bim(temp) build_ref(rsid-hapmap-genome-location.dta)

. bim2build, bim(temp) build_ref(rsid-hapmap-genome-location.dta)
# > checkfile ................................... located temp.bim
# > checkfile ................................... located rsid-hapmap-genome-location.dta
# > bim2dta ............................................. temp.bim
# > checkfile ................................... located temp.bim
# > bim2build  .......... build identified as hg18 +0 for temp.bim

```
**installation**

```
net install bim2build,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

```rsid-hapmap-genome-location.dta``` has been created and is available for download via dropbox at https://www.dropbox.com/s/zb7ehghhir2fjn3/rsid-hapmap-genome-location.dta?dl=0

## bim2count
## bim2dta    
## bim2eigenvec
## bim2frq
## bim2hapmap
## bim2ldexclude
## bim2ld_subset
## checkfile
## checktabbed
## create_temp_dir
## datestamp
## ensembl2symbol
## fam2dta
## genotypeqc
## get_stat_bundle
## graphgene
## graphmanhattan
## graphmiami
## graphplinkfrq
## graphplinkhet
## graphplinkhwe
## graphplinkimiss
## graphplinkkin0
## graphplinklmiss
## graphqq
## gwas2prs
## kin0filter
## loadUnixReplicas
## profilescore

**description** - this program performs polygenic risk score calculation at multiple thresholds for multiple genotype files against a single GWAS input. the GWAS input file need to be preprocessed to prePRS format (see [```gwas2psr```](#gwas2prs). using input prePRS and quality controlled genotypes (via [```genotypeqc```](#genotypeqc); the program acts as a wrapper for plink to run through a pipeline of checks and balances, merges and clumping routines to generate \*.profile scores at a range of P-value thresholds from 1 to 1e-8. these profile scores are merged into a single analysis \*.dta for each genotype and a summary \*.meta-log describing key metrics from the process.

**remarks** - to run ```profilescore``` you will first need to set a number of global parameters - linking to the prePRS file, the test genotypes and some reference files and software. these parameters need to be saved into a flat text file e.g. test.parameters

**examples**

```
/*
# > define the following globals in the parameter file
project_folder `c(pwd)'                      /// set current folder as the project folder
project_name   project1                      /// set the project name to project1
kg_ref eur_1000g_phase3_chrall_impute_macgt5 /// set location/filename of the 1000-genomes reference genotypes
Ndata 3                                      /// set number of genotypes files to be examined (n=3)
data1 dataset1                               /// set location/filename for dataset1
data2 dataset2                               /// set location/filename for dataset2
data3 dataset3                               /// set location/filename for dataset3
gwas_short author-year                       /// set a short-name for gwas input for output files
gwas_prePRS author-year-prePRS.tsv           /// set location/filename for prePRS.tsv file (note *.tsv often archived as *.tsv.gz - gz not needed)
global tabbed                                /// perl + the location of the perl script tabbed.pl (e.g. perl D:/perl/code/tabbed.pl)
global plink                                 /// the location of the plink1.9.exe (e.g. D:/plink/bin/plink.exe)
*/
file open myfile using test.parameters, write replace
file write myfile "global project_folder  `c(pwd)'"                              _n 
file write myfile "global project_name    project1"                              _n 
file write myfile "global kg_ref          kg_ref\eur_1000g_phase3_chrall_impute_macgt5" _n 
file write myfile "global Ndata           3"                                     _n
file write myfile "global data1           dataset1"                              _n
file write myfile "global data2           dataset2"                              _n
file write myfile "global data3           dataset3"                              _n 
file write myfile "global gwas_short      author-year"                           _n 
file write myfile "global gwas_prePRS     author-year-prePRS.tsv"                _n 
file close myfile

profilescore, param(test.parameters)
```

**installation**

```
net install profilescore,         from(https://raw.github.com/ricanney/stata/master/code/p/) replace
```

```kg_ref eur_1000g_phase3_chrall_impute_macgt5.bim```, ```kg_ref eur_1000g_phase3_chrall_impute_macgt5.bed```, ```kg_ref eur_1000g_phase3_chrall_impute_macgt5.fam``` are available in the archive ```kg_ref.tar.gz``` for download via dropbox at https://www.dropbox.com/s/xk6mk0v1bn777g7/kg_ref.tar.gz?dl=0



## recodegenotype
## recodestrand
## symbol2ensemble

