/*
*program*
 mapfrq

*description* 
maps a1_frq from reference
*/

program mapfrq
syntax ,  ref(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# mapfrq               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > mapfrq ........................... map from reference "as result "`ref'"
	}
qui { // 2 - preparing reference
	noi di as text"# > mapfrq ................ preparing reference file from "as result "`ref'_bim.dta"
	noi di as text"# > mapfrq ................ preparing reference file from "as result "`ref'_frq.dta"
	preserve
	noi checkfile, file(`ref'_bim.dta)
	noi checkfile, file(`ref'_frq.dta)
	use `ref'_bim.dta, clear
	keep loc_name snp
	merge 1:1 snp using `ref'_frq.dta
	keep if _m == 3
	keep loc_name a1 a2 maf
	rename (a1 a2) (ref alt)
	save tempfile-mapfrq.dta, replace
	restore
	}
qui { // 3 - join files
	capture confirm string var loc_name
	if !_rc {
		}
	else {
		noi di as text"# > mapfrq .............................................. "as result "variable loc_name absent (creating)"
		checkloc_name
		}
	noi di as text"# > mapfrq .............................................. "as result "merging with reference"
	duplicates tag loc_name, gen(tag)
	keep if tag == 0
	drop tag
	merge 1:1 loc_name using tempfile-mapfrq.dta
	drop if _m == 2
	drop _m
	}
qui { // 4 - check strand alignment
	noi di as text"# > mapfrq .............................................. "as result "checking strand alignment"
	recodestrand, ref_a1(a1) ref_a2(a2) alt_a1(ref) alt_a2(alt)
	}
qui { // 5 - create a1_frq
	gen a1_frq = .
	replace a1_frq = maf if a1 == _tmpb1
	replace a1_frq = 1-maf if a1 == _tmpb2
	drop loc_name-_tmpb2
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
