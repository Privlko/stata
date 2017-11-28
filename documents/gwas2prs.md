# Title
![gwas2prs](https://github.com/ricanney/stata/blob/master/code/g/gwas2prs.ado) - a program that converts gwas summary data to prePRS format (for use in ```profilescore```)
# Installation
```net install gwas2prs,                from(https://raw.github.com/ricanney/stata/master/code/g/) replace```
# Syntax
```gwas2prs, name(filename) reference(filename)```

- ```name``` is the output name for the file 
- ```reference``` is the location of the allele frequency file ```reference```_frq.dta file. note, do not include "_frq.dta" in the filename location - this is assumed. To create *_frq.dta, use ```bim2frq``` 

# Description
This program formats GWAS summary data ready for use in the PRS program ```profilescore```. GWAS summary files come in all shapes and sizes. Therefore, we are not able to provide a one-size-fits-all. Some user interaction is required. The GWAS summary file needs to be imported and the following variables identifued and renamed (where applicable).
The GWAS summary data requires the following variables;

1. ```chr``` - chromosome code
2. ```bp``` - chromosome location (hg19 +1)
3. ```a1``` - allele 1 variable
4. ```a2``` - allele 2 variable
5. ```or``` - odds ratio 
6. ```p``` - association p-value
7. ```rsid``` - marker name
8. ```info``` - imputation info-score <OPTIONAL>
9. ```direction``` - imputation direction variable <OPTIONAL>
10. ```a1_frq``` - allele frequency of allelel a1 <OPTIONAL> **ideally, include sample based allele frequency if possible**

Briefly, ```gwas2prs``` is doing a number of simple qc checks, removing some difficult SNPS and formatting ready for ```profilescore```

1. checks whether ```chr``` exists, then limits to autosomes, removes missing and stored as <string>
1. checks whether ```bp``` exists, stores as <string>
1. checks whether ```a1``` and ```a2``` exist, then perform ```recodegenotypes``` to generate UIPAC genotype variable
1. drops genotypes with ID, W or S UIPAC codes and drops the genotype variable
1. checks whether ```info``` available, if present limits SNPS to ```info```> 0.8
1. checks whether ```direction``` available, if present limits SNPS to those observed in atleast N-1 of included studies
1. removes and duplicate observations at any ```rsid```
1. checks whether ```a1_frq``` exists, if not it assigns and aligns ```a1_frq``` from the reference genotypes
1. keeps ```chr``` ```bp``` ```rsid``` ```a1``` ```a2``` ```a1_frq``` ```or``` ```p``` 
1. saves as tab-seperated-variable text file to *-prePRS.tsv and archives using gzip
1. reports details of file to  *.meta-log

# Examples
An example of bespoke code for processing GWAS summary files from data downloaded from https://www.med.unc.edu/pgc/results-and-downloads
```
qui { // duncan-ratanatharathorn-aiello-2017 (ptsd)
	global ref        E:\data\genotypes\ref\1000-genomes\phase3\data\hg19\eur_1000g_phase3_chrall_impute_macgt5
	global input      E:\data\summary\duncan-ratanatharathorn-aiello-2017\data\sorted-ptsd-ea9-all-study-specific-pcs1.txt 
	global output     duncan-ratanatharathorn-aiello-2017-eur-ptsd
	qui { // extracting GWAS data and making tab-delimited
		!$gunzip ${input}.gz
		!$tabbed ${input}
		}
	qui { // convert to prePRS
		bim2dta, bim(${ref})
		import delim using ${input}.tabbed, clear 
		rename (markername allele1 allele2 effect pvalue) (snp b1 b2 effect p)
		gen or = exp(effect)
		merge 1:1 snp using ${ref}_bim.dta // created from bim2dta
		drop a1 a2
		keep if _m == 3
		rename (snp b1 b2) (rsid a1 a2)
		for var a1 a2: replace X = strupper(X)
		keep  chr bp rsid a1 a2 or p direction
		order chr bp rsid a1 a2 or p	
		gwas2prs , name(${output}) reference(${ref}) 
		}
	qui { // clean-up and re-archive data
		!del ${input}.tabbed
		!$gzip ${input}
		}
	}
```

# Dependencies
| Program | Installation Command
| :----- | :------
|```recodegenotypes``` | automatic installation with package
|```recodestrand``` | automatic installation with package
