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
	count
	noi di as text"# > snp2refid .................... number of SNPs in file "as result "`r(N)'"
	noi di as text"# > snp2refid ............... updating marker names using "as result"`ref'"
	noi checkfile, file(`ref'.bim)
	checkfile, file(${plink})
	}
qui { // 2 - check _bim.dta are created / create
	preserve
	capture confirm file `ref'_loc_name.dta 
	if !_rc {
		}
	else {
		noi di as text"# > snp2refid ..................... create reference file "as result"`ref'_loc_name.dta "
		capture confirm file `ref'_loc_name.dta 
		if !_rc {
				use `ref'_bim.dta, clear
			keep snp loc_name
			save `ref'_loc_name.dta, replace
			}
		else {
			bim2dta, bim(`ref')
			use `ref'_bim.dta, clear
			keep snp loc_name
			save `ref'_loc_name.dta, replace
			}
		}
	restore
	}
qui { // 3 - update identifier 	
	drop snp
	for var a1 a2: replace X = strupper(X)
	use tmp_snp2refid ,clear
	noi checkloc_name
	egen x = seq(), by(loc_name)
	drop if x != 1
	drop x
	noi di as text"# > snp2refid .................... merging with reference "as result"`ref'_loc_name.dta"
	merge 1:1 loc_name using `ref'_loc_name.dta
	keep if _m == 3
	drop _m loc_name
	for var chr bp: destring X, replace
	count
	noi di as text"# > snp2refid ........ number of SNPs in file post rename "as result "`r(N)'"
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
