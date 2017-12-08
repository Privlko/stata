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
# > bim2dta ............................................. atemp.bim
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
## recodegenotype
## recodestrand
## symbol2ensemble

