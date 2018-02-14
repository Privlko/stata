/*
*program*
 summaryqc

*description* 
perform basic quality control on summary gwas statistics
*/

program summaryqc
syntax ,  ref(string asis) input(string asis) out(string asis)
noi di as text"#########################################################################"
noi di as text"# summaryqc               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > summaryqc ................................ input data "as result "`input'"
	count
	global summaryqc_input `r(N)'
	noi di as text"# > summaryqc .............. markers in the input dataset "as result ${summaryqc_input}
	capture confirm file `ref'_bim.dta 
	if !_rc {
		}
	else {
		noi di as text"# > summaryqc .................. create reference file "as result"`ref'_bim.dta"
		bim2dta, bim(`ref')
		}
	capture confirm file `ref'_frq.dta 
	if !_rc {
		}
	else {
		noi di as text"# > summaryqc .................. create reference file "as result"`ref'_frq.dta"
		bim2frq, bim(`ref')
		}
	}
qui { // 2 - perform quality control
	qui { // drop if p out-of-bounds
		count 
		global summaryqc_runningtotal `r(N)'
		drop if p > 1
		drop if p < 0
		count
		global summaryqc_oobSNP ${summaryqc_runningtotal} - `r(N)'
		noi di as text"# > summaryqc ....... markers with p-values out-of-bounds "as result ${summaryqc_oobSNP} 
		}
	qui { // duplicates drop
		count 
		global summaryqc_runningtotal `r(N)'
		duplicates drop 
		duplicates drop snp, force
		count
		global summaryqc_dupSNP ${summaryqc_runningtotal} - `r(N)'
		noi di as text"# > summaryqc ................................ duplicates "as result ${summaryqc_dupSNP} 
		}
	qui { // qc-by-info score
		capture confirm numeric var info
		if !_rc {
			count 
			global summaryqc_runningtotal `r(N)'
			drop if info > 2 & info ! = .
			drop if info < .8
			drop info
			count
			global summaryqc_infoSNP ${summaryqc_runningtotal} - `r(N)'
			noi di as text"# > summaryqc .......... info score out-of-bounds or < .8 "as result ${summaryqc_infoSNP} 
			}
		else {
			global summaryqc_infoSNP "info score not present"
			noi di as text"# > summaryqc .......... info score out-of-bounds or < .8 "as result "${summaryqc_infoSNP}"
			}
	qui { // qc-by-direction
		capture confirm string var direction
		if !_rc {
			count 
			global summaryqc_runningtotal `r(N)'
			replace direction = subinstr(direction, "-", "",.)
			replace direction = subinstr(direction, "+", "",.)
			gen count = length(direction)
			drop if count > 1
			drop direction count
			count
			global summaryqc_directionSNP ${summaryqc_runningtotal} - `r(N)'
			noi di as text"# > summaryqc ... data missing from > 1 study (direction) "as result ${summaryqc_directionSNP} 
			}
		else {
			global summaryqc_directionSNP "direction variable not present"
			noi di as text"# > summaryqc ... data missing from > 1 study (direction) "as result "${summaryqc_directionSNP}"
			}
		}
	}	
qui { // 3 - save as
	count
	global summaryqc_output `r(N)'
	noi di as text"# > summaryqc .................. markers in final dataset "as result ${summaryqc_output}
	noi di as text"# > summaryqc ............................ saving data to "as result "`out'-summaryqc.dta"
	save `out'-summaryqc.dta, replace
	}
qui { // 4 - report on processing
	qui { // plot manhattan
		noi graphmanhattan, chr(chr) bp(bp) p(p)
		graph use tmpManhattan.gph
		graph export `out'-summaryqc-manhattan.png, as(png) height(1000) width(3000) replace
		}
	qui { // create - log file
		clear
		input strL v1
		"#########################################################################"
		"# summaryqc"
		"#########################################################################"
		"# Started: " 
		"#########################################################################"
		"# > summaryqc ................................ input data " 
		"# > summaryqc ............................... output data "
		"# > summaryqc .......... reference genotypes (for naming) "
		"# > summaryqc .............. markers in the input dataset "
		"# > summaryqc ....... markers with p-values out-of-bounds "
		"# > summaryqc ................................ duplicates "
		"# > summaryqc .......... info score out-of-bounds or < .8 "
		"# > summaryqc ... data missing from > 1 study (direction) "
		"# > summaryqc .................. markers in final dataset "
		"# > summaryqc ............................. saved data to "
		"# > summaryqc ................ exported manhattan plot to "
		"#########################################################################"
		end
		gen v2 = ""
		gen v3 = .
		replace v2 = "$S_DATE $S_TIME" in 4 
		replace v2 = "`input'" in 6
		replace v2 = "`output'" in 7
		replace v2 = "`ref'" in 8
		replace v3 = ${summaryqc_input} in 9 
		replace v3 = ${summaryqc_oobSNP} in 10 
		replace v3 = ${summaryqc_dupSNP} in 11
		replace v3 = ${summaryqc_infoSNP} in 12 
		replace v3 = ${summaryqc_directionSNP} in 13
		replace v3 = ${summaryqc_output} in 14
		replace v2 = "`out'-summaryqc.dta" in 15
		replace v2 = "`out'-summaryqc-manhattan.png}" in 16
		tostring v3, replace
		replace v2 = v3 if v3 != "."
		drop v3
		outsheet using "`out'-summaryqc.log", delim("") non noq replace
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;

	
	

	
		
