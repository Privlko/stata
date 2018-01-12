[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)
## recodegenotype

**description** - creates single letter IUPAC genotype code from the observed alleles. the program storesthe variable ```gt```. the bim data is preserved in memory (therefore any stored data is cleared from memory), and also saved a new file ```<bimname>_bim.dta```. 

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
