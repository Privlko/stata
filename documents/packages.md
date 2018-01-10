[back to opening page](https://github.com/ricanney/stata)

# information on packages
# information on packages
|package | description|
| ------: | :------- |
|        [```bim2build```](https://github.com/ricanney/stata/blob/master/documents/bim2build.md)        | checks the genome build from a plink \*.bim file
|        [```bim2count```](https://github.com/ricanney/stata/blob/master/documents/bim2count.md)        | counts the number of markers and individuals plink \*.bim and \*.fam file
|          [```bim2dta```](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md)          | imports plink \*.bim files into stata 
|     [```bim2eigenvec```](https://github.com/ricanney/stata/blob/master/documents/bim2eigenvec.md)     | create eigenvector and eigenvalues from plink binaries
|          [```bim2frq```](https://github.com/ricanney/stata/blob/master/documents/bim2frq.md)          | create allele frequency file from plink binaries
|       [```bim2hapmap```](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md)       | create ancestry plots and similarity to hapmap3 classifiers from plink binaries
|    [```bim2ld_subset```](https://github.com/ricanney/stata/blob/master/documents/bim2ld_subset.md)    | xxxxx
|    [```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)    | xxxxx
|        [```bim2merge```](https://github.com/ricanney/stata/blob/master/documents/bim2merge.md)        | merge multiple plink binary files (with quality control and limit to overlap)
|    [```bim2unrelated```](https://github.com/ricanney/stata/blob/master/documents/bim2unrelated.md)    | xxxxx
|        [```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)        | xxxxx
|      [```checktabbed```](https://github.com/ricanney/stata/blob/master/documents/checktabbed.md)      | xxxxx
|  [```create_temp_dir```](https://github.com/ricanney/stata/blob/master/documents/create_temp_dir.md)  | xxxxx
|        [```datestamp```](https://github.com/ricanney/stata/blob/master/documents/datestamp.md)        | xxxxx
|   [```ensembl2symbol```](https://github.com/ricanney/stata/blob/master/documents/ensembl2symbol.md)   | xxxxx
|          [```fam2dta```](https://github.com/ricanney/stata/blob/master/documents/fam2dta.md)          | xxxxx
|       [```genotypeqc```](https://github.com/ricanney/stata/blob/master/documents/genotypeqc.md)       | xxxxx
| [```get_stata_bundle```](https://github.com/ricanney/stata/blob/master/documents/get_stata_bundle.md) | xxxxx
|        [```graphgene```](https://github.com/ricanney/stata/blob/master/documents/graphgene.md)        | xxxxx
|   [```graphmanhattan```](https://github.com/ricanney/stata/blob/master/documents/graphmanhattan.md)   | xxxxx
|       [```graphmiami```](https://github.com/ricanney/stata/blob/master/documents/graphmiami.md)       | xxxxx
|    [```graphplinkfrq```](https://github.com/ricanney/stata/blob/master/documents/graphplinkfrq.md)    | xxxxx
|    [```graphplinkhet```](https://github.com/ricanney/stata/blob/master/documents/graphplinkhet.md)    | xxxxx
|    [```graphplinkhwe```](https://github.com/ricanney/stata/blob/master/documents/graphplinkhwe.md)    | xxxxx
|  [```graphplinkimiss```](https://github.com/ricanney/stata/blob/master/documents/graphplinkimiss.md)  | xxxxx
|   [```graphplinkkin0```](https://github.com/ricanney/stata/blob/master/documents/graphplinkkin0.md)   | xxxxx
|  [```graphplinklmiss```](https://github.com/ricanney/stata/blob/master/documents/graphplinklmiss.md)  | xxxxx
|          [```graphqq```](https://github.com/ricanney/stata/blob/master/documents/graphqq.md)          | xxxxx
|         [```gwas2prs```](https://github.com/ricanney/stata/blob/master/documents/gwas2prs.md)         | xxxxx
|       [```kin0filter```](https://github.com/ricanney/stata/blob/master/documents/kin0filter.md)       | xxxxx
| [```loadunixreplicas```](https://github.com/ricanney/stata/blob/master/documents/loadunixreplicas.md) | xxxxx
|     [```profilescore```](https://github.com/ricanney/stata/blob/master/documents/profilescore.md)     | xxxxx
|   [```recodegenotype```](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md)   | xxxxx
|     [```recodestrand```](https://github.com/ricanney/stata/blob/master/documents/recodestrand.md)     | xxxxx
|     [```summary2gwas```](https://github.com/ricanney/stata/blob/master/documents/summary2gwas.md)     | xxxxx
|   [```symbol2ensembl```](https://github.com/ricanney/stata/blob/master/documents/symbol2ensembl.md)   | xxxxx

## bim2hapmap

**description** - a command to generate eigenvector and eigenvalues from plink binaries  \*.bim \*.bed and \*.fam file. this program also utilises reference genotypes from the hapmap3 collection to plot and creates a "similarity" file that identifies samples that show similar ancestries to the definable hapmap3 populations. 

the command is primarily a wrapper for [```plink```](https://www.cog-genomics.org/plink/1.9/) and [```plink2```](https://www.cog-genomics.org/plink/2.0/) - both programs should be accessable by the ${plink} and ${plink2} commands (see setting up ```profile.do``` in ![1-getting_started](https://github.com/ricanney/stata/blob/master/documents/getting_started.md)). 


this program also utilises the programs [```checkfile```](#checkfile), [```bim2ldexclude```](#bim2ldexclude). The program creates two files ```<bimname>_eigenvec.dta``` and ```<bimname>_eigenval.dta```. these are stata versions of the plink2 --pca output file \*. eigenvec and \*.eigenval (see https://www.cog-genomics.org/plink/2.0/formats#eigenvec). 

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

## bim2ldexclude

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

## bim2ld_subset

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

## bim2merge 

**description** - a command to create mergable plink binaries. the process includes; limit to autosome; remove ambiguous markers (W/S); remove incompatible markers; strand flip and limit to intercept over all markers and reference. the resultant binaries are created and named with the tag ```-intercept```.

**remarks** 

**examples** - list comma-seperate binaries in bim(). add the reference binary to ref_bim() - this binary will be used to define strand. add a project-name in project() - the log file will be named using this name. if the join(yes) flag is included - the files in the bim() command will be merged into a the project.bim 'bed .fam

```
bim2merge , bim(file1,file2,file3) ref_bim(file4) project(project_name) [join(yes)]

```
**installation**

```
net install bim2merge ,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**additional files**

## bim2unrelated 

**description** - a command to create a subset froma genotype dataset on "unrelated" individuals. the program is a wrapper for plink2 - where it extracts a subset of 50000 ld-independent markers via [```bim2ld_subset```](#bim2ld_subset) and applies the ```--king-cutoff``` command. the program creates the unrelated dataset and uses [```graphplinkkin0```](#graphplinkkin0) to plot the kinship from the ```--make-king-table```.

**remarks** - you can define a threshold for "relatedness", this number is based on the KING algorithm; where 0.354 = duplicates; 0.1770 = first degree relationships; 0.0884 = second degree relationships; 0.0442 = third degree relatinships etc) The default for this program is .0221
 
**examples** 
```
bim2unrelated , bim(file1) threshold(0.0442)
bim2unrelated , bim(file1) 
```
**installation**

```
net install bim2unrelated ,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**additional files**


## checkfile

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

## checktabbed

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

## create_temp_dir

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

## datestamp

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

## ensembl2symbol

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

## fam2dta

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

## genotypeqc

**description** - this program performs genotype quality control on plink binaries; the program acts as a wrapper for plink to run through a pipeline of checks and balances, along with a applying a range of quality controls. the program creates a bundle of qc'd plink binaries along with a summary \*.meta-log and a quality control report in \*docx format containing numerous quality metrics. as part of the pipeline the program identified the genome-build of the array as well as most likely source of array. markers are renamd to rsid and procerssed according to excessive cryptic relatedness, missingess, heterozygosity, relatedess(duplicates, second and third degree relatives are removed), minor allele frequency and hardy weinberg equilibrium. ancestry are inferred and plotted against references and files generated to allow individuals to be removed in downstream applications.   

**remarks** - to run ```genotypeqc``` you will first need to set a number of global parameters. these parameters need to be saved into a flat text file e.g. test.parameters

**version history**
  - v4 - included a minor allele frequency threshold default = 0.01
  - v5 - alter maf to mac5 to retain additional "rarer" variation
  - v6 - convert script to include stand-alone subroutines; bug-fix: duplicate routine now retain one of the duplicated observations
  - xx - add known_array function - this skips array check for known arrays (e.g. post imputation) - assumes hg19+1 co-ordinates

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
global data_folder                           // location of the genotypes to be processed
global data_input                            // name of genotype files (plink binaries) to be processed 
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
genotypeqc, param(test.parameters) known_array(michigan-imputation-server-v1.0.3-hrc-r1.1-2016)
```

**installation**

```
net install genotypeqc,         from(https://raw.github.com/ricanney/stata/master/code/g/) replace
```

**additional files**

[```rsid-hapmap-genome-location.dta```](<add-link>) | [```eur_1000g_phase3_chrall_impute_macgt5.bim```](<add-link>) | [```eur_1000g_phase3_chrall_impute_macgt5.bed```](<add-link>) | [```eur_1000g_phase3_chrall_impute_macgt5.fam```](<add-link>) | [```eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta```](<add-link>) | [```hapmap3-all-hg19-1.bim```](<add-link>) | [```hapmap3-all-hg19-1.bed```](<add-link>) | [```hapmap3-all-hg19-1.fam```](<add-link>) | [```hapmap3-all-hg19-1.population```](<add-link>) | [```hapmap3-all-hg19-1-aims.snp-list```](<add-link>) | [```genotype-array.tar.gz```](<add-link>)

## get_stata_bundle

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

## graphgene

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

## graphmanhattan

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

## graphmiami

**description** - this script plots a simple miami plot for two gwas datasets for a defined region. the plot also includes a geneplot. both input gwas require the variable rsid/p; co-ordinates are taken from a reference binary. the geneplot requires gene/exon boundaries derived using the ```get-ensembl-gtf.do``` script.

**remarks** 

**examples**

```
graphmiami , gwas1(file1) gwas2(fil2) title1(disease1) title2(disease1) region(chr7:100000000-120000000) exons(E:\data\other\ftp-ensembl\data\Homo_sapiens.GRCh37.87.gtf_exon.dta) ref(E:\data\genotypes\ref\1000-genomes\phase3\data\hg19\eur_1000g_phase3_chrall_impute_macgt5)

```
**installation**

```
net install -name-,         from(https://raw.github.com/ricanney/stata/master/code/-folder-/) replace
```

**additional files**

## graphplinkfrq

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

## graphplinkhet

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

## graphplinkhwe

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

## graphplinkimiss

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

## graphplinkkin0

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

## graphplinklmiss

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

## graphqq

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

## gwas2prs

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

## kin0filter

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

## loadunixreplicas

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

## symbol2ensembl

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

