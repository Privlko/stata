/*
*program*
 snp2refbuild

*description* 
 a command to convert the to a common build (reference) via snpid

*syntax*
 snp2refbuild ,  ref(-reference-)

 -ref-   this is the reference dataset - does not require the .bim filetype to be included - this is assumed
*/

program snp2refbuild
syntax ,  ref(string asis)

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# snp2refbuild"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"

qui { // 1 - introduction
	count
	noi di as text"# > snp2refbuild ................. number of SNPs in file "as result "`r(N)'"
	noi di as text"# > snp2refbuild ..... updating chromosome location using "as result"`ref'"
	noi checkfile, file(`ref'.bim)
	checkfile, file(${plink})
	}
qui { // 2 - check _min (_bim.dta) are created / create
	preserve
	capture confirm file `ref'_min.dta 
	if !_rc {
		}
	else {
		noi di as text"# > snp2refbuild .................. create reference file "as result"`ref'_min.dta "
		capture confirm file `ref'_min.dta 
		if !_rc {
			use `ref'_bim.dta, clear
			keep snp chr bp
			save `ref'_min.dta, replace
			}
		else {
			bim2dta, bim(`ref')
			use `ref'_bim.dta, clear
			keep snp chr bp
			save `ref'_min.dta, replace
			}
		}
	restore
	}
qui { // 3 - update identifier 	
	drop chr bp
	noi di as text"# > snp2refbuild ................. merging with reference "as result"`ref'_min.dta"
	merge 1:1 snp using `ref'_min.dta
	keep if _m == 3
	drop _m 
	count
	noi di as text"# > snp2refbuild ..... number of SNPs in file post rename "as result "`r(N)'"
	for var chr bp: destring X, replace
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
