/*
*program*
 bim2cryptic

*description* 
 a command to identify cryptic relatedness in plink binaries

*syntax*
 bim2cryptic , bim(-filename-) 
 
 -filename-    this is the test dataset - does not require the .bim filetype to be included - this is assumed
*/

program bim2cryptic
syntax , bim(string asis) 

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2cryptic"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi checkfile, file(${plink2})
	noi di as text"# > bim2cryptic ....... evaluating cryptic relatedness in "as result"`bim'"
	noi checkfile, file(`bim'.bim)
	    bim2count, bim(`bim')
	noi di as text"# > bim2count .................... number of SNPs in file "as result "${bim2count_snp}"
	noi di as text"# > bim2count ............. number of individuals in file "as result "${bim2count_ind}"
	noi di as text"# > bim2cryptic ................. creating kinship matrix "as result "${bim2count_ind}"as text" x "as result "${bim2count_ind}"	
	bim2ld_subset, bim(`bim')
	!$plink2 --bfile `bim' --extract bim2ld_subset50000.extract --make-king square --out `bim'
	}	
qui { // 2 - import kinship matrix
	import delim using `bim'.king, clear case(lower)
	count
	forvalues i=1/ `r(N)' {
	replace v`i' = . in `i'
		replace v`i' = 0 if v`i' < 0
		}
	gen obs = _n
	aorder
	save bim2cryptic.dta,replace
	}
qui { // 3 - merge kinship table to identifiers
	import delim using `bim'.king.id, clear case(lower)
	rename (v1 v2) (fid iid)
	for var fid iid: tostring X, replace
	gen obs = _n
	aorder
	merge 1:1 obs using bim2cryptic.dta, update
	erase bim2cryptic.dta
	drop _m
	}
qui { // 4 - blank out known family identifiers
	gen a = ""
	tostring obs, replace
	replace a = "replace v" + obs + `" = . if fid ==""' + fid + `"""'
	outsheet a using tmp.do, non noq replace
	do tmp.do
	erase tmp.do
	drop a obs
	}
qui { // 5 - calculate by-individual metrics
	count
	egen rm = rowmean(v1-v`r(N)')
	count
	egen rx = rowmax(v1-v`r(N)')	
	keep fid iid rm
	gen xs_relate = .
	sum rm
	foreach i of num 1/5 {
		sum rm
		replace xs_relate = `i' if rm > `r(mean)' + (`i' * `r(sd)')
		}
	}
qui { // 6 - identify individuals with excessive kinship coefficients
	count if xs > 3 & xs != .
	noi di as text"# > bim2cryptic ... individuals showing excessive kinship "as result "`r(N)'"	
	if `r(N)' != 0 {
		noi di as text"# > bim2cryptic .......... reporting excessive kinship to "as result "bim2cryptic.remove"	
		outsheet fid iid if xs > 3 & xs != . using bim2cryptic.remove, replace non noq
		}
	else {
		clear
		set obs 1
		outsheet using bim2cryptic.remove, replace non noq
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
