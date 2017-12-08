![back to opening page](https://github.com/ricanney/stata)
## information on packages
### b
| Programs        | Description | Help Files | ado-file
| :-------------- | :----------------------------------------------------------------	| :-------------- | :-------------- |
| ```bim2build```   | a command to create check genome build from plink binaries | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2build.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2build.ado)	
| ```bim2count```   | a command to count observations in a plink dataset | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2count.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2count.ado)	
| ```bim2dta```   | a command to convert plink \*.bim file to stata \*.dta format | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2dta.ado)	
| ```bim2eigenvec```   | command to generate \*.dta eigenval calculations from plink binaries | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2eigenvec.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2eigenvec.ado)	
| ```bim2frq```   | a command to create \_frq.dta (plink-format marker files) from plink binaries  | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2frq.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2frq.ado)	
| ```bim2hapmap```   | command to use plink-format genotype files to plot againsts hapmap ancestries and define ancestral similarities to a defined hapmap set | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2hapmap.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2hapmap.ado)	
| ```bim2ld_subset```   | a command to use \*.bim files (plink-format marker files) to generate a subset of ld independent snps (\_subset#.extract) | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2ld_subset.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2ld_subset.ado)	
| ```bim2ldexclude```   | command to generate ld-exclude regions for plink | ![link](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md) | ![link](https://github.com/ricanney/stata/blob/master/code/b/bim2ldexclude.ado)	

### c
| Programs        | Description | Help Files | ado-file
| :-------------- | :----------------------------------------------------------------	| :-------------- | :-------------- |


1. 

| Programs        | Description | Files
| :-------------- | :----------------------------------------------------------------	| :---------	
| ```bim2dta```         | convert plink \*.bim file to stata \*.dta format                                      | ![info](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md) ![ado]
| ```bim2eigenvec```	  | generate \*.eigenvec and \*.eigenval files from plink \*.bim file                   	| ![info](https://github.com/ricanney/stata/blob/master/documents/bim2eigenvec.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2eigenvec.ado)	
| ```bim2ldexclude```	  | generate the long-range linkage disequilibrium exclude region from plink \*.bim file	| ![info](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2exclude.ado)	
| ```datestamp```	      | create a non-space datestamp in global that can be accessed via $DATA               	| ![info](https://github.com/ricanney/stata/blob/master/documents/datestamp.md) ![ado](https://github.com/ricanney/stata/blob/master/code/d/datestamp.ado)	
| ```ensembl2symbol``` 	| maps gene symbols to ensembl identifiers                                            	| ![info](https://github.com/ricanney/stata/blob/master/documents/ensembl2symbol.md) ![ado](https://github.com/ricanney/stata/blob/master/code/e/ensembl2symbol.ado)	
| ```fam2dta```	        | convert plink \*.fam file to stata \*.dta format                                    	| ![info](https://github.com/ricanney/stata/blob/master/documents/fam2dta.md) ![ado](https://github.com/ricanney/stata/blob/master/code/f/fam2dta.ado)	
| ```genotypeqc```	    | perform qc-pipeline on genotype array data                                          	| ![info](https://github.com/ricanney/stata/blob/master/documents/genotypeqc.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/genotypeqc.ado)	
| ```graphgene```	      | plot exon/gene structure from chromosome location (hg19)                            	| ![info](https://github.com/ricanney/stata/blob/master/documents/graphgene.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphgene.ado)	
| ```graphmanhattan``` 	| plot simple manhattan plot from association data (chr bp p)                         	| ![info](https://github.com/ricanney/stata/blob/master/documents/graphmanhattan.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphmanhattan.ado)	
| ```graphplinkfrq```	  | plot allele frequency distribution from plink generated \*.frq file                 	| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkfrq.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkfrq.ado)	
| ```graphplinkhet```	  | plot heterozygosity distribution from plink generated \*.het file                  		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkhet.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkhet.ado)	
| ```graphplinkhwe```	  | plot hardy-weinberg p-value distribution from plink generated \*.hwe file          		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkhwe.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkhwe.ado)	
| ```graphplinkimiss```	| plot missingness (by individual) from plink generated \*.imiss file                		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkimiss.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkimiss.ado)	
| ```graphplinkkin0```	| plot kinship distribution from plink generated \*.kin0 file                        		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkkin0.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkkin0.ado)	
| ```graphplinklmiss```	| plot missingness (by locus) from plink generated \*.lmiss file                     		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinklmiss.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinklmiss.ado)	
| ```graphqq```	        | plot simple qq (pp) plot from association data (p)                                 		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphqq.md)	![ado](https://github.com/ricanney/stata/blob/master/code/g/graphqq.ado)	
| ```gwas2prs```	      | prepare association files for profilescore (PRS) analysis                           	| ![info](https://github.com/ricanney/stata/blob/master/documents/gwas2prs.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/gwas2prs.ado)	
| ```loadUnixReplicas```| load windows executables that mimic unix commands                                    | ![info](https://github.com/ricanney/stata/blob/master/documents/loadUnixReplicas.md) ![ado](https://github.com/ricanney/stata/blob/master/code/l/loadUnixReplicas.ado)
| ```profilescore```	  | create profile (polygenic risk score) from ```gwas2prs``` and ```genotypeqc``` processed data	| ![info](https://github.com/ricanney/stata/blob/master/documents/profilescore.md) ![ado](https://github.com/ricanney/stata/blob/master/code/p/profilescore.ado)	
| ```recodegenotype```  | converts ACGT+ID coded alleles to UIPAC genotype codes                              	| ![info](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md) ![ado](https://github.com/ricanney/stata/blob/master/code/r/recodegenotype.ado)	
| ```recodestrand```	  | flip alleles to a refrence strand including reverse complementary coding            	| ![info](https://github.com/ricanney/stata/blob/master/documents/recodestrand.md) ![ado](https://github.com/ricanney/stata/blob/master/code/r/recodestrand.ado)	
| ```symbol2ensembl```	| maps ensembl identifiers to gene symbols                                            	| ![info](https://github.com/ricanney/stata/blob/master/documents/symbol2ensembl.md) ![ado](https://github.com/ricanney/stata/blob/master/code/s/symbol2ensembl.ado)	
