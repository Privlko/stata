[back to opening page](https://github.com/ricanney/stata)

# information on packages
|package | description|
| ------: | :------- |
|        [```bim2build```](https://github.com/ricanney/stata/blob/master/documents/bim2build.md)        | checks the genome build from a plink \*.bim file
|        [```bim2count```](https://github.com/ricanney/stata/blob/master/documents/bim2count.md)        | counts the number of markers and individuals plink \*.bim and \*.fam file
|          [```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)          | imports plink \*.bim files into stata 
|     [```bim2eigenvec```](https://github.com/ricanney/stata/blob/master/documents/bim2eigenvec.md)     | create eigenvector and eigenvalues from plink binaries
|          [```bim2frq```](https://github.com/ricanney/stata/blob/master/documents/bim2frq.md)          | create allele frequency file from plink binaries
|       [```bim2hapmap```](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md)       | create ancestry plots and similarity to hapmap3 classifiers from plink binaries
|    [```bim2ld_subset```](https://github.com/ricanney/stata/blob/master/documents/bim2ld_subset.md)    | create a list of N snps that are ld independent from from plink binaries
|    [```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)    | create a list of snps that do include those within regions of known extended ld
|        [```bim2merge```](https://github.com/ricanney/stata/blob/master/documents/bim2merge.md)        | merge multiple plink binary files (with quality control and limit to overlap)
|    [```bim2unrelated```](https://github.com/ricanney/stata/blob/master/documents/bim2unrelated.md)    | create a subset of unrelated individuals from plink binaries using the --king-cutoff flag in ``` plink2```
|        [```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)        | check the presence/absence of a file 
|      [```checktabbed```](https://github.com/ricanney/stata/blob/master/documents/checktabbed.md)      | check that ```tabbed.pl``` is working from the ```${tabbed}``` command and is that perl is working 
|  [```create_temp_dir```](https://github.com/ricanney/stata/blob/master/documents/create_temp_dir.md)  | create a temporary directory using the date/time as a random seed generator
|        [```datestamp```](https://github.com/ricanney/stata/blob/master/documents/datestamp.md)        | create a non space seperated date macro ${DATE} that can be used to tag files
|   [```ensembl2symbol```](https://github.com/ricanney/stata/blob/master/documents/ensembl2symbol.md)   | ![](../images/under-construction.png)
|          [```fam2dta```](https://github.com/ricanney/stata/blob/master/documents/fam2dta.md)          | imports plink \*.fam files into stata 
|       [```genotypeqc```](https://github.com/ricanney/stata/blob/master/documents/genotypeqc.md)       | ![](../images/under-construction.png)
| [```get_stata_bundle```](https://github.com/ricanney/stata/blob/master/documents/get_stata_bundle.md) | ![](../images/under-construction.png)
|        [```graphgene```](https://github.com/ricanney/stata/blob/master/documents/graphgene.md)        | ![](../images/under-construction.png)
|   [```graphmanhattan```](https://github.com/ricanney/stata/blob/master/documents/graphmanhattan.md)   | ![](../images/under-construction.png)
|       [```graphmiami```](https://github.com/ricanney/stata/blob/master/documents/graphmiami.md)       | plot a miami plot for two gwas datasets for a defined region
|    [```graphplinkfrq```](https://github.com/ricanney/stata/blob/master/documents/graphplinkfrq.md)    | ![](../images/under-construction.png)
|    [```graphplinkhet```](https://github.com/ricanney/stata/blob/master/documents/graphplinkhet.md)    | ![](../images/under-construction.png)
|    [```graphplinkhwe```](https://github.com/ricanney/stata/blob/master/documents/graphplinkhwe.md)    | ![](../images/under-construction.png)
|  [```graphplinkimiss```](https://github.com/ricanney/stata/blob/master/documents/graphplinkimiss.md)  | ![](../images/under-construction.png)
|   [```graphplinkkin0```](https://github.com/ricanney/stata/blob/master/documents/graphplinkkin0.md)   | ![](../images/under-construction.png)
|  [```graphplinklmiss```](https://github.com/ricanney/stata/blob/master/documents/graphplinklmiss.md)  | ![](../images/under-construction.png)
|          [```graphqq```](https://github.com/ricanney/stata/blob/master/documents/graphqq.md)          | ![](../images/under-construction.png)
|         [```gwas2prs```](https://github.com/ricanney/stata/blob/master/documents/gwas2prs.md)         | ![](../images/under-construction.png)
|       [```kin0filter```](https://github.com/ricanney/stata/blob/master/documents/kin0filter.md)       | ![](../images/under-construction.png)
| [```loadunixreplicas```](https://github.com/ricanney/stata/blob/master/documents/loadunixreplicas.md) | ![](../images/under-construction.png)
|     [```profilescore```](https://github.com/ricanney/stata/blob/master/documents/profilescore.md)     | ![](../images/under-construction.png)
|   [```recodegenotype```](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md)   | ![](../images/under-construction.png)
|     [```recodestrand```](https://github.com/ricanney/stata/blob/master/documents/recodestrand.md)     | ![](../images/under-construction.png)
|     [```summary2gwas```](https://github.com/ricanney/stata/blob/master/documents/summary2gwas.md)     | ![](../images/under-construction.png)
|   [```symbol2ensembl```](https://github.com/ricanney/stata/blob/master/documents/symbol2ensembl.md)   | ![](../images/under-construction.png)


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

[```eur_1000g_phase3_chrall_impute_macgt5.bim```](<add-link>) | [```eur_1000g_phase3_chrall_impute_macgt5.bed```](<add-link>) | [```eur_1000g_phase3_chrall_impute_macgt5.fam```](<add-link>)

## recodegenotype

**description** - this program creates the single letter IUPAC genotype code (see below) from the observed alleles and stores as the variable ```gt```. the bim data is preserved in memory (therefore any stored data is cleared from memory), and also saved a new file ```<bimname>_bim.dta```. 

| IUPAC nucleotide code	| Base | IUPAC nucleotide code	| Base
| :-- | -- | :-- | --|
| A	| **A**denine | C	| **C**ytosine |
| G	| **G**uanine | T | **T**hymine |
| U | **U**racil  | R	| pu**R**ine (A or G) |
| Y	| pyr**Y**midine (C or T) | S	| **S**trong (G or C) |
| W	| **W**eak (A or T) | K	| **K**etone (G or T) |
| M	| a**M**ine (A or C) | B	| not **A** (C or G or T) |
| D	| not **C** A or G or T | H | not **G** (A or C or T) |
| V	| not **T** (A or C or G) | N	| a**N**y |
| X	| reverse complement of a**N**y base | . | gap |
| - | gap ||

**remarks** - [```recodegenotype```](#recodegenotype) works with biallelic markers and indels; *indels* - allele codes of I = insert and D = deletion; longer indel allele codes are reduced to single letter with the longer of the 2 alleles being coded the insertion. the D allele code clashes with the IUPAC naming convention -  *if* we update the program to deal with triallelic markers, then the D code will be used for "not **C**" and we will update the ID coding for indels. the program requires allele1 and allele2 to be varnames to be defined. 

**examples**

```
recodegenotype, a1(a1) a2(a2) 

```

**installation**

```
net install recodegenotype,         from(https://raw.github.com/ricanney/stata/master/code/r/) replace
```

**additional files**

## recodestrand

**description** 

**remarks** 

**examples**

```
syntax

```
**installation**

```
net install -name-,         from(https://raw.github.com/ricanney/stata/master/code/-folder-/) replace
```

**additional files**

## summary2gwas 

**description**  - post-gwas analysis of gwas summary files requires a variety of formats, but often the same quality controls need to be applied, common builds need to be mapped and ambiguous or non-strand compatible genotypes need to be removed. this program performs standard quality control on pre-processed gwas summary files and saves as \*.dta format. these files can then be used to create input files for [```profilescore```](#profilescore), magma and ldscore regression as \*.prePRS.tsv.gz, \*.pval.gz and \*.sumstats files respectively. additional sub-routine files  [```_gwas2magma```](#_gwas2magma), [```_gwas2prePRS```](#_gwas2prePRS), and [```_gwas2sumstat```](#_gwas2sumstat) are required to convert to other formats.

**remarks** 

**examples**

```
syntax

```
**installation**

```
net install -name-,         from(https://raw.github.com/ricanney/stata/master/code/-folder-/) replace
```

**additional files**

