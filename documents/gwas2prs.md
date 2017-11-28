# Title
![gwas2prs](https://github.com/ricanney/stata/blob/master/code/g/gwas2prs.ado) - a program that converts gwas summary data to prePRS format (for use in ```profilescore```)
# Installation
```net install gwas2prs,                from(https://raw.github.com/ricanney/stata/master/code/g/) replace```
# Syntax
```gwas2prs, name(filename) reference(filename)```
# Description
This program formats GWAS summary data ready for use in the PRS program ```profilescore```. The GWAS summary data requires the following variables;
1. ```chr``` - chromosome code
2. ```bp``` - chromosome location (hg19 +1)
3. ```a1``` - allele 1 variable
4. ```a2``` - allele 2 variable
5. ```or``` - odds ratio 
6. ```p``` - association p-value
7. ```rsid``` - marker name
8. ``info``` - imputation info-score
9. ```direction``` - imputation direction variable 
10. ```a1_frq``` - allele frequency of allelel a1




## brief overview of the gwas2prs
1. checks whether ```chr``` exists, then limits to autosomes, removes missing and stored as <string>
1. checks whether ```bp``` exists, stores as <string>
1. checks whether ```a1``` and ```a2``` exist, then perform ```recodegenotypes``` to generate UIPAC genotype variable
1. drops genotypes with ID, W or S UIPAC codes and drops the genotype variable
1. checks whether ```info``` available, if present limits SNPS to ```info```> 0.8
1. checks whether ```direction``` available, if present limits SNPS to those observed in atleast N-1 of included studies
1. removes and duplicate observations at any ```rsid```
1. checks whether ```a1_frq``` exists, if not assigns and matches ```a1_frq``` from teh reference genotypes
1. keeps ```chr``` ```bp``` ```rsid``` ```a1``` ```a2``` ```a1_frq``` ```or``` ```p``` 
1. saves as tab-seperated-variable text file to *-prePRS.tsv and archives using gzip
1. reports details of file to  *.meta-log


Import your gwas summary data into ``STATA```, select (and rename where appropriate) the variables.

this program can be called 
The plink binary marker file contains information on marker identifiers, chromosome location and allele coding. It is often necessary to import these files into stata. This one line command imports the data, renames the variables, creates a genotype variable ```gt``` using the ```recodegenotype``` program and saves a copy of this coversion in the same directory as filename_bim.dta.



# Title
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sem ligula, fermentum at nulla eget, semper scelerisque diam. Mauris id libero vitae massa fringilla placerat ac ut nibh.
# Installation
```net install xxxxx,                from(https://raw.github.com/ricanney/stata/master/code/x/) replace```
# Syntax
```xxxxxx, xxxxx(filename)```
# Description
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sem ligula, fermentum at nulla eget, semper scelerisque diam. Mauris id libero vitae massa fringilla placerat ac ut nibh. Donec gravida quam est, at aliquam ex facilisis vel. Etiam quis ex sapien. Nulla sapien sem, auctor et neque egestas, scelerisque aliquet nunc. Vivamus venenatis massa velit, suscipit scelerisque nisi dapibus eget. Morbi commodo elementum ante, vel condimentum purus consectetur vel. Pellentesque efficitur risus in mauris elementum pellentesque. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce laoreet sem urna, sit amet varius leo tristique eu. Ut ultricies bibendum mi, vel convallis nulla egestas at. Integer fermentum nibh eget purus ornare pulvinar. Suspendisse a felis ac elit molestie consequat. Donec ac dui nunc. Vestibulum dapibus lorem non ante sagittis fringilla.

# Examples
```
example
```

# Dependencies
| Program | Installation Command
| :----- | :------
|```program``` | ```ssc install program```