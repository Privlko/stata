[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## recodegenotype

**description**
* a command to convert allele codes to genotype codes

**syntax**

```recodegenotype , a1(-allele1-) a2(-allele2-)```
 
* ```-a1-```   the varname containing allele 1 
* ```-a2-```   the varname containing allele 2 

**notes**
* this program creates a single letter IUPAC genotype code from the observed alleles stored as the variable ```gt```. 


| IUPAC nucleotide code	| Base | IUPAC nucleotide code	| Base
| -: | :-- | --: | :--
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


* [```recodegenotype```](#recodegenotype) works with biallelic markers and indels; *indels* 
* - allele codes of I = insert and D = deletion
* - longer indel allele codes are reduced to single letter with the longer of the 2 alleles being coded the insertion. 
* __future-proof warning__ the D allele code clashes with the IUPAC naming convention 
* -  *if* we update the program to deal with triallelic markers, then the D code will be used for "not **C**" and we will update the ID coding for indels. the program requires allele1 and allele2 to be varnames to be defined. 

**installation**

```net install recodegenotype,         from(https://raw.github.com/ricanney/stata/master/code/r/) replace```

