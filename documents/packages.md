![back to opening page](https://github.com/ricanney/stata)
## information on packages
[```bim2build```](#bim2build) [```bim2count```](#bim2count) [```bim2dta```](#bim2dta) [```bim2count```](#bim2eigenvec) [```bim2eigenvec```](#bim2count) [```bim2frq```](#bim2frq) [```bim2hapmap```](#bim2hapmap) [```bim2ld_subset```](#bim2ld_subset) [```bim2ldexclude```](#bim2ldexclude) [```checkfile```](#checkfile) [```checktabbed```](#checktabbed) [```create_temp_dir```](#create_temp_dir) [```datestamp```](#datestamp) [```ensembl2symbol```](#ensembl2symbol) [```fam2dta```](#fam2dta) [```genotypeqc```](#genotypeqc) [```get_stata_bundle```](#get_stata_bundle) [```graphmanhattan```](#graphmanhattan) [```graphmiami```](#graphmiami) [```graphqq```](#graphqq) [```graphplinkfrq```](#graphplinkfrq) [```graphplinkhet```](#graphplinkhet) [```graphplinkhwe```](#graphplinkhwe) [```graphplinkimiss```](#graphplinkimiss) [```graphplinkkin0```](#graphplinkkin0) [```graphplinklmiss```](#graphplinklmiss) [```graphgene```](#graphgene) [```gwas2prs```](#gwas2prs) [```kin0filter```](#kin0filter) [```loadUnixReplicas```](#loadUnixReplicas) [```profilescore```](#profilescore) [```recodegenotype```](#recodegenotype) [```recodestrand```](#recodestrand) [```symbol2ensembl```](#symbol2ensembl) 

## bim2build

**description** - a command to examine the genome build of a plink \*.bim file. the command utilises the programs ```checkfile```, ```bim2dta``` and requires a reference of snps with location on various builds ```rsid-hapmap-genome-location.dta```

**remarks** - to date this only examines hg17 +0/1- hg19 +0/1

**examples**

```
bim2build , bim(temp) build_ref(rsid-hapmap-genome-location.dta)

```
**installation**

```
net install bim2build,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**additional files**

[```rsid-hapmap-genome-location.dta```](<add-link>)


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

**description** - this program performs genotype quality control on plink binaries; the program acts as a wrapper for plink to run through a pipeline of checks and balances, along with a applying a range of quality controls. the program creates a bundle of qc'd plink binaries along with a summary \*.meta-log and a quality control report in \*docx format containing numerous quality metrics. as part of the pipeline the program identified the genome-build of the array as well as most likely source of array. markers are renamd to rsid and procerssed according to excessive cryptic relatedness, missingess, heterozygosity, relatedess(duplicates, second and third degree relatives are removed), minor allele frequency and hardy weinberg equilibrium. ancestry are inferred and plotted against references and files generated to allow individuals to be removed in downstream applications.   

**remarks** - to run ```genotypeqc``` you will first need to set a number of global parameters. these parameters need to be saved into a flat text file e.g. test.parameters

**examples**

```
/*
# > define the following globals in the parameter file
global array_ref                             // the location of the genotyping array folder 
global build_ref                             // location of the genotyping build file (rsid-hapmap-genome-location.dta)
global kg_ref_frq                            // location of the -frq.dta file providing reference allele frequency for the 1000genome european reference datasets (eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta)
global hapmap_data                           // location of th hapmap3 (hg19+1) referenece genotype file + *.population file
global aims                                  // location of list of ancestry informative markers (hapmap3-all-hg19-1-aims.snp-list)
global rounds                                // number of quality control rounds to cycle through (default = 4)
global hwep                                  // min -log10 p-value tolerated for hardy-weinberg deviation (default = 10)
global hetsd                                 // maximum standard deviations tolerated from mean heterozygosity (default = 4)
global mind                                  // maximum missingness by individual tolerated (default = 0.02)
global geno1                                 // maximum missingness by marker tolerated - round 1 (default = 0.05)
global geno2                                 // maximum missingness by marker tolerated - final (default = 0.02)
global kin_d                                 // kinship threshold for duplicates (default =  0.3540)
global kin_f                                 // kinship threshold for first degree relatives (default = 0.1770)
global kin_s                                 // kinship threshold for second degree relatives (default = 0.0884)
global kin_t                                 // kinship threshold for third degree relatives (default = 0.0442)
global data_folder	                         // location of the genotypes to be processed
global data_input		                         // name of genotype files (plink binaries) to be processed 
global tabbed                                // perl + the location of the perl script tabbed.pl (e.g. perl D:/perl/code/tabbed.pl)
global plink                                 // the location of the plink1.9.exe (e.g. D:/plink/bin/plink.exe)
global plink2                                // the location of the plink2.exe (e.g. D:/plink/bin/plink2.exe)

* plink plink2 and tabbed whould be set up via the profile.do along with loadunixreplicas (includes many other standard dependencies)
*/

file open myfile using test.parameters, write replace
file write myfile "global array_ref		genotype-array\data" _n
file write myfile "global build_ref		build-ref\data\rsid-hapmap-genome-location.dta" _n
file write myfile "global kg_ref_frq	1000genomes\eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta" _n
file write myfile "global hapmap_data	hapmap3\hapmap3-all-hg19-1" _n
file write myfile "global aims	      hapmap3\hapmap3-all-hg19-1-aims.snp-list" _n
file write myfile "global rounds      4" _n
file write myfile "global hwep        10" _n
file write myfile "global hetsd       4" _n
file write myfile "global maf         0.01" _n
file write myfile "global mind        0.02" _n
file write myfile "global geno1       0.05" _n
file write myfile "global geno2       0.02" _n
file write myfile "global kin_d       0.3540" _n
file write myfile "global kin_f       0.1770" _n
file write myfile "global kin_s       0.0884" _n
file write myfile "global kin_t       0.0442" _n
file write myfile "global data_folder	example\data" _n
file write myfile "global data_input	example" _n
file close myfile

genotypeqc, param(test.parameters)
```

**installation**

```
net install genotypeqc,         from(https://raw.github.com/ricanney/stata/master/code/g/) replace
```

**additional files**

[```rsid-hapmap-genome-location.dta```](<add-link>)
[```eur_1000g_phase3_chrall_impute_macgt5.bim```](<add-link>)
[```eur_1000g_phase3_chrall_impute_macgt5.bed```](<add-link>)
[```eur_1000g_phase3_chrall_impute_macgt5.fam```](<add-link>)
[```eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta```](<add-link>)
[```hapmap3-all-hg19-1.bim```](<add-link>)
[```hapmap3-all-hg19-1.bed```](<add-link>)
[```hapmap3-all-hg19-1.fam```](<add-link>)
[```hapmap3-all-hg19-1.population```](<add-link>)
[```hapmap3-all-hg19-1-aims.snp-list```](<add-link>)
[```genotype-array.tar.gz```](<add-link)

## get_stata_bundle
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

* plink and tabbed whould be set up via the profile.do along with loadunixreplicas (includes many other standard dependencies)

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
**additional files**

[```eur_1000g_phase3_chrall_impute_macgt5.bim```](<add-link>)
[```eur_1000g_phase3_chrall_impute_macgt5.bed```](<add-link>)
[```eur_1000g_phase3_chrall_impute_macgt5.fam```](<add-link>)

## recodegenotype
## recodestrand
## symbol2ensembl

