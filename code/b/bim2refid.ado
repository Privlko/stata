/*
*program*
 bim2refid

*description* 
 a command to convert the marker names to a common (reference) name via 
 the snp location and genotype code

*syntax*
 bim2refid , bim(-filename-) ref(-reference-)

 
 -filename-    this is the test dataset - does not require the .bim filetype to be included - this is assumed
 -reference-   this is the reference dataset - does not require the .bim filetype to be included - this is assumed
*/

program bim2refid
syntax , bim(string asis) ref(string asis)

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2refid"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2refid ................. updating marker names for "as result"`bim'"
	noi checkfile, file(`bim'.bim)
	    bim2count, bim(`bim')
	noi di as text"# > bim2count .................... number of SNPs in file "as result "${bim2count_snp}"
	noi di as text"# > bim2refid ............... updating marker names using "as result"`ref'"
	noi checkfile, file(`ref'.bim)
	checkfile, file(${plink})
	}
qui { // 2 - check _bim.dta are created / create
	capture confirm file `ref'_bim.dta 
	if !_rc {
		}
	else {
		noi di as text"# > bim2refid ...................... create reference file "as result"`ref'_bim.dta"
		bim2dta, bim(`ref')
		}
	capture confirm file `bim'_bim.dta 
	if !_rc {
		}
	else {
		noi di as text"# > bim2refid ......................... create marker file "as result"`bim'_bim.dta"
		bim2dta, bim(`bim')
		}
	}
qui { // 3 - update identifier 	
	use `bim'_bim.dta ,clear
	keep loc_name snp
	rename snp oldname
	merge m:1 loc_name using `ref'_bim.dta	
	keep if _m == 3
	keep snp oldname
	rename snp newname
	compress
	duplicates tag newname, gen(tag)
	egen keep = seq(),by(newname tag)
	keep if keep == 1
	outsheet oldname using bim2refid.extract, non noq replace
	outsheet oldname newname using bim2refid.update-name, non noq replace
	!$plink --bfile `bim'        --extract bim2refid.extract         --make-bed --out bim2refid-01
	!$plink --bfile bim2refid-01 --update-name bim2refid.update-name --make-bed --out `bim'-refid
	!del bim2refid-01.*
	noi di as text"# > bim2refid ................. updated binaries saved as "as result"`bim'-refid"
	    bim2count, bim(`bim'-refid)
	noi di as text"# > bim2count .................... number of SNPs in file "as result "${bim2count_snp}"
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
