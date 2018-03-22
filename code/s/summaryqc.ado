/*
*program*
 summaryqc

*description* 
perform basic quality control on summary gwas statistics
*/

program summaryqc
syntax ,  ref(string asis) input(string asis) out(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# summaryqc               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > summaryqc ................................ input data "as result "`input'"
	count
	global summaryqc_Nin `r(N)'
	noi di as text"# > summaryqc .............. markers in the input dataset "as result ${summaryqc_Nin}
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
		drop if p == .
		count
		gen a = ${summaryqc_runningtotal} - `r(N)'
		sum a
		global summaryqc_oobSNP `r(max)'
		drop a
		noi di as text"# > summaryqc ....... markers with p-values out-of-bounds "as result ${summaryqc_oobSNP} 
		}
	qui { // duplicates drop
		count 
		global summaryqc_runningtotal `r(N)'
		duplicates drop 
		duplicates drop snp, force
		count
		gen a = ${summaryqc_runningtotal} - `r(N)'
		sum a
		global summaryqc_dupSNP `r(max)'
		drop a
		noi di as text"# > summaryqc ................................ duplicates "as result ${summaryqc_dupSNP} 
		}
	qui { // qc-by-info score
		capture confirm numeric var info
		if !_rc {
			count 
			global summaryqc_runningtotal `r(N)'
			drop if info == .
			drop if info > 2 & info ! = .
			drop if info < .8
			drop info
			count
			gen a = ${summaryqc_runningtotal} - `r(N)'
			sum a
			global summaryqc_infoSNP `r(max)'
			drop a
			noi di as text"# > summaryqc .......... info score out-of-bounds or < .8 "as result ${summaryqc_infoSNP} 
			}
		else {
			global summaryqc_infoSNP "info score not present"
			noi di as text"# > summaryqc .......... info score out-of-bounds or < .8 "as result "${summaryqc_infoSNP}"
			}
		}
	qui { // qc-by-direction
		capture confirm string var direction
		if !_rc {
			count 
			global summaryqc_runningtotal `r(N)'
			replace direction = subinstr(direction, "-", "",.)
			replace direction = subinstr(direction, "+", "",.)
			gen count = length(direction)
			drop if count > 2
			drop direction count
			count
			gen a = ${summaryqc_runningtotal} - `r(N)'
			sum a
			global summaryqc_directionSNP `r(max)'
			drop a
			noi di as text"# > summaryqc ... data missing from > 2 study (direction) "as result ${summaryqc_directionSNP} 
			}
		else {
			global summaryqc_directionSNP "direction variable not present"
			noi di as text"# > summaryqc ... data missing from > 2 study (direction) "as result "${summaryqc_directionSNP}"
			}
		}	
	}
qui { // 3 - save as
	missings dropobs, force
	count
	global summaryqc_Nout `r(N)'
	noi di as text"# > summaryqc .................. markers in final dataset "as result ${summaryqc_Nout}
	noi di as text"# > summaryqc ............................ saving data to "as result "`out'-summaryqc.dta"
	save `out'-summaryqc.dta, replace
	}
qui { // 4 - report on processing
	qui { // plot manhattan
		gen logp = round(-log10(p),1) + 2
		sum logp
		graphmanhattan, chr(chr) bp(bp) p(p) max(`r(max)')
		drop logp
		graph use tmpManhattan.gph
		noi di as text"# > summaryqc .............. exporting manhattan graph to "as result "`out'-summaryqc-manhattan.png"
		graph export `out'-summaryqc-manhattan.png, as(png) height(1000) width(3000) replace
		window manage close graph
		erase tmpManhattan.gph
		}
	qui { // create - log file
		global summaryqc_input  `input'
		global summaryqc_out `out'
		global summaryqc_ref `ref'
		_sub_summaryqc_meta
		noi di as text"# > summaryqc .......................... reporting to log "as result "`out'-summaryqc.log"
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
