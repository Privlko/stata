[back to opening page](https://github.com/ricanney/stata)


## making the 1000 genomes reference datasets

**background** - many of the genomics based applications / packages require a genome reference dataset. for example, to compare allele frequencies in arrays.  you can either download a copy from the url below -```link not active```, access one from the cardiff rocks databank ```local users only```- or build your own. below is a tutorial as to how to build your own plink-ready 1000 genome reference. one of the key components of a *reference* is the ability to map, this requires unambiguous genotypes - importantly, this script **ommits ambiguous genotyes i.e. ID A C G T W and S**.

**1 - download the 1000 genome genotypes (*.vcf format) from ebi.**

```
cd E:\1000-genomes
!bash -c "wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/*"
```
**2 - convert the *.vcf to plink** - this section converts the \*.vcf, with a minor allele count  (```--mac 5```) filter . note that the the nomenclature of the autosome and sex-chromosome files prevent a loop script; the work around uses ```file2dta```to import a list of the files and create a \*.bat file to run the plink conversion. 

```
split file, p(".vcf.gz")  
keep if file2 != ""
keep file1
split file, p(".")
drop if file12 == "wgs"
drop if file12 == "chrY"
keep file1 file12
gen a = ""
replace a = "$plink --vcf " + file1 + ".vcf.gz --mac 5 --make-bed --out " + file1 + ".mac5"
outsheet a using vcf2plink.bat, non noq replace
!vcf2plink.bat
keep file1 file12
save _tmp.dta,replace
        
```
**3 - process plink files** - the 1000 genomes projects comes with a few problematic snps and some with multiple names - this renames those snps to rs#; esv# and chr#-bp-gt respectively.

```
use _tmp.dta, clear
foreach i of num 1/3 {
	append using _tmp.dta
	}
egen x = seq(), by(file12)
sort file12 x
gen a = ""
replace a = "import delim using " + file1 + ".mac5.bim, clear varnames(nonames)" if x == 1
replace a = "do _subprocess-1.do" if x == 2
replace a = "outsheet v1 v2 v3 v4 v5 v6 using  " + file1 + ".mac5_update.bim, non noq replace" if x == 3
replace a = "!$plink --bed " + file1 + ".mac5.bed --bim " + file1 + ".mac5_update.bim --fam " + file1 + ".mac5.fam 	 --make-bed --out all-" + file12 + "-phase3-mac5" if x == 4
outsheet a using _tmp.do, non noq replace
do _tmp.do
 ```
 
 **_subprocess-1.do**
```
	qui { // create loc_name
		for var v1 v2 v4: tostring X, replace
		gen a1 = v5 
		gen a2 = v6
		recodegenotype, a1(a1) a2(a2)
		replace _gt = "R"  if _gt == "Y"
		replace _gt = "M"  if _gt == "K" 
		gen loc_name = "chr" + v1 + ":" + v4 + "-" + _gt 
		}
	qui { // replace v2 = single rs#
		split v2,p(";")
		replace v2 = ""
		compress
		gen rs1 = ""
		foreach i in 21 22 23 24 25 26 27 28 29 {
			capture confirm variable v`i'
			if !_rc {
				replace rs1 = substr(v`i',1,2)
				replace v2 = v`i' if rs1 == "rs" & v2 == ""
				}
			}
		}
	qui { // replace v2 = single esv#
		gen esv1 = ""
		foreach i in 21 22 23 24 25 26 27 28 29 {
			capture confirm variable v`i'
			if !_rc {
				replace esv1 = substr(v`i',1,3)
				replace v2 = v`i' if esv1 == "esv" & v2 == ""
				}
			}
		}
	qui { // replace v2 = single ss#
		gen ss1 = ""
		foreach i in 21 22 23 24 25 26 27 28 29 {
			capture confirm variable v`i'
			if !_rc {
				replace ss1 = substr(v`i',1,2)
				replace v2 = v`i' if ss1 == "ss" & v2 == ""
				}
			}
		}
	qui { // replace v2 = loc_name if v2 == ""
			replace v2 = loc_name if v2 == ""
		}
	qui { // identify snps to drop
		gen drop = .
		qui { // tag duplicates to drop
			egen dup = seq(), by(loc_name)
			replace dup = dup - 1
			tostring dup, replace 
			replace dup = "_dup" + dup
			replace dup = ""     if dup == "_dup0"
			replace v2 = v2 + dup
			replace drop = 1 if dup != ""
			}
		qui { // drop ambiguous markers
			foreach gt in A C G T W S ID {
				replace drop = 1 if _gt == "`gt'"
				}
			}
		qui { // drop snps with known duplicate locations
			foreach snp in rs111307503 rs111577982 rs5988705 rs113189289 rs75766429 rs56110824 rs111664647 rs11952502 rs12334732 rs113937023 rs79245793 rs112702727 rs76545203 rs75240632 rs113853039 {
				replace drop = 1  if v2 =="`snp'"
				}
			}
		}
	qui { // export processed files
		outsheet v1 v2 v3 v4 v5 v6 using  tmp.mac5_update.bim, non noq replace
		outsheet v2 if drop == 1   using  tmp.mac5_update.exclude, non noq replace
		}
	
	

	
	

```

**merging the plink binaries** - as a preference i merge all the chromosomes into a single master file.

```
use _tmp.dta,clear
gen a = ""
replace a = "all-" + file12 + "-phase3-mac5.bed all-" + file12 + "-phase3-mac5.bim all-" + file12 + "-phase3-mac5.fam"
replace a ="!$plink --bfile all-" + file12 + "-phase3-mac5 --merge-list all.merge-list --make-bed --out all_1000g_phase3_chrall_impute_mac5" in 1
outsheet a if _n == 1 using _tmp.do, non noq replace
drop in 1
outsheet a using all.merge-list, non noq replace
do _tmp.do
```



 



