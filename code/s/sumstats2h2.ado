/*
*program*
 sumstats2h2

*description* 
wrapper for python ldsc - using summaryqc files
*/

program sumstats2h2
syntax ,  sumstats(string asis) w_hm3(string asis) ldsc(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# sumstats2h2               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > sumstats2h2 .............................. input data "as result "`sumstats'"
	noi checkfile, file(`sumstats')
	noi checkfile, file(`w_hm3'w_hm3.snplist)
	}
qui { // 2 - define output
		clear 
		set obs 1
		gen a = "`sumstats'"
		split a,p("\"".sumstats")
		sxpose, clear
		gen b = _n
		gsort -b
		keep in 1
		replace _var1 = "global sumstats_output " + _var1
		outsheet _var1 using temp.do , non noq replace
		do temp.do
		erase temp.do
		clear
		noi di as text"# > sumstats2h2 .................. processing sumstats to "as result "${sumstats_output}.h2.log"
		}
qui { // 3 - define python scripts	
	global temp_ldsc `ldsc'
	}
qui { // 4 - calculate snp-heritability	
	!python "${temp_ldsc}" --h2 `sumstats' --ref-ld `w_hm3'w_hm3\w_hm3 --w-ld `w_hm3'w_hm3\w_hm3 --out ${sumstats_output}.h2
	noi checkfile, file(${sumstats_output}.h2.log)
	}

noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
