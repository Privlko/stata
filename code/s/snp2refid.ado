/*
*program*
 snp2refid

*description* 
 a command to convert the marker names to a common (reference) name via 
 the snp location and genotype code

*syntax*
 snp2refid ,  ref(-reference-)


 -ref-   this is the reference dataset - does not require the .bim filetype to be included - this is assumed
*/

program snp2refid
syntax ,  ref(string asis)

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# snp2refid"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	save tmp_snp2refid.dta,replace
	count
	noi di as text"# > snp2refid .................... number of SNPs in file "as result "`r(N)'"
	noi di as text"# > snp2refid ............... updating marker names using "as result"`ref'"
	noi checkfile, file(`ref'.bim)
	checkfile, file(${plink})
	}
qui { // 2 - check _bim.dta are created / create
	capture confirm file `ref'_bim.dta 
	if !_rc {
		}
	else {
		noi di as text"# > snp2refid ..................... create reference file "as result"`ref'_bim.dta"
		bim2dta, bim(`ref')
		}
	}
qui { // 3 - update identifier 	
	use tmp_snp2refid ,clear
	recodegenotype , a1(a1) a2(a2)
	rename _gt_tmp gt
	compress
	for var chr bp: tostring X, replace force
	replace chr = subinstr(chr,"chr","",.)
	replace chr = strupper(chr)	
	replace chr = "23" if chr == "X"
	replace chr = "23" if chr == "X_nonPAR"
	replace chr = "24" if chr == "Y"
	replace chr = "25" if chr == "XY"
	replace chr = "26" if chr == "MT"
	gen _gt = gt
	replace _gt = "R" if gt == "Y"
	replace _gt = "M" if gt == "K"
	gen loc_name = "chr" + chr + ":" + bp + "-" + _gt
	drop chr bp _gt
	rename snp oldname
	merge m:1 loc_name using `ref'_bim.dta	
	keep if _m == 3
	compress
	duplicates tag snp, gen(tag)
	egen keep = seq(),by(snp tag)
	keep if keep == 1
	drop _m gt loc_name oldname tag keep 
	order chr bp snp
	for var chr bp: destring X, replace
	sort chr bp
	erase tmp_snp2refid.dta
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
