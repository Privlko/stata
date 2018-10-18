[back to opening page](https://github.com/ricanney/stata)
 
[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## genotypeqc
**description**
* a command to perform quality control of genotyping arrays

**syntax**

```
global bim2array_ref        E:\data\methods\bim2array\data\all
global bim2build_ref        E:\data\methods\bim2build\data\bim2build.dta
global ref                  E:\data\genotypes\ref\1000-genomes\phase3\data\ftp.1000genomes.ebi.ac.uk\eur-1000g-phase3-chrall-mac5
global bim2frq_compare_ref  E:\data\genotypes\ref\1000-genomes\phase3\data\ftp.1000genomes.ebi.ac.uk\eur-1000g-phase3-chrall-RYMKonly-mac5
global bim2hapmap_hapmap    E:\data\methods\bim2hapmap\data\hapmap3-all-hg19+1
global bim2hapmap_aims      E:\data\methods\bim2hapmap\data\bim2hapmap.aims 
global rounds      4 
global hwep        10 
global hetsd       4 
global mind        0.02 
global geno1       0.05 
global geno2       0.02 
global kin_d       0.3540 
global kin_f       0.1770 
global kin_s       0.0884 
global kin_t       0.0442 
net install genotypeqc, from(https://raw.github.com/ricanney/stata/master/code/g/) replace
noi genotypeqc, bim("E:\data\genotypes\add\image1\data\add-image1\add-image1")
```

* if the genotyping array is known then the flag ```known_array(-array-name-)``` can be added to skip the bim2array package

```
genotypeqc, bim(E:\data\genotypes\add\image1\data\add-image1-qc-v5-dose-info-0-8\add-image1-qc-v5-dose-info-0-8) known_array(michigan-imputation-server-v1.0.3-hrc-r1.1-2016)
```


**notes**

* this program is more of a pipeline to perform quality control genotype data from arrays or imputation. 
* the program acts as a wrapper for ```plink``` and ```plink2``` to run through a pipeline of checks and balances, along with a applying a range of quality controls. 
* the program creates a bundle of qc'd plink binaries along with a summary \*.meta-log and a quality control report in \*docx format containing numerous quality metrics. 
* as part of the pipeline the program identified the genome-build of the array as well as most likely source of array.
*  markers are renamed to rsid and processed to remove excessive cryptic relatedness, missingess, heterozygosity, minor allele frequency and hardy weinberg equilibrium. 
*  relatedess is plotted, so is ancestry.
*  ancestry is also inferred and plotted against references and files generated to allow individuals to be removed in downstream applications.

* to run ```genotypeqc``` you will first need to set a number of __global parameters__. 
* these parameters need to be called in teh script prior to running QC
	* ```bim2array_ref``` the location of the genotyping array folder 
	* ```bim2build_ref``` the genotyping build file (bim2build.dta)
	* ```ref``` location of the reference genotypes (e.g. for the 1000genome european reference datasets)
	* ```bim2frq_compare_ref``` location of the reference genotypes (e.g. for the 1000genome european reference datasets) - this can be ref, but to speed up QC the RYMKonly files are best
	* ```bim2hapmap_hapmap``` location of th hapmap3 (hg19+1) referenece genotype file + \*.population file
	* ```bim2hapmap_aims``` location of list of ancestry informative markers (bim2hapmap.aims)
	* ```rounds``` number of quality control rounds to cycle through (default = 4)
	* ```hwep``` min -log10 p-value tolerated for hardy-weinberg deviation (default = 10)
	* ```hetsd``` maximum standard deviations tolerated from mean heterozygosity (default = 4)
	* ```mind``` maximum missingness by individual tolerated (default = 0.02)
	* ```geno1``` maximum missingness by marker tolerated - round 1 (default = 0.05)
	* ```geno2``` maximum missingness by marker tolerated - final (default = 0.02)
	* ```kin_d``` kinship threshold for duplicates (default = 0.3540)
	* ```kin_f``` kinship threshold for first degree relatives (default = 0.1770)
	* ```kin_s``` kinship threshold for second degree relatives (default = 0.0884)
	* ```kin_t``` kinship threshold for third degree relatives (default = 0.0442)

**version history**
 - v4 - included a minor allele frequency threshold default = 0.01
 - v5 - alter maf to mac5 to retain additional "rarer" variation
 - v6 - convert script to include stand-alone subroutines; bug-fix: duplicate routine now retain one of the duplicated observations
 - xx - add known_array function - this skips array check for known arrays (e.g. post imputation) - assumes hg19+1 co-ordinates
 - v7 - convert modules to programs/packages, speed up rename markers, update print to screen

**installation**

```net install genotypeqc, from(https://raw.github.com/ricanney/stata/master/code/g/) replace```

**know bugs**
* the rename rsid module has some issues with complex non-rsid markers names (e.g. CLOZUK). the workaround is to rename prior to inclusion - however, the code needs to be updated to cope with these problems. - ```Richard Anney - 16Jan2018``` __fixed via bim2refid__


