/*
*program*
 sumstats2rg

*description* 
wrapper for python ldsc - using sumstats files
*/

program sumstats2rg
syntax ,  sumstats(string asis) w_hm3(string asis) ldsc(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# sumstats2rg               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
		clear 
		set obs 1
		gen a = "`sumstats'"
		split a, p(",")
		drop a
		sxpose, clear
		gen n = _n
		tostring n, replace
		replace _var1 = "global sumstats_input" + n + " " + _var1
		outsheet _var1 using temp.do , non noq replace
		do temp.do
		erase temp.do
		clear
		noi di as text"# > sumstats2rg .......................... input data # 1 "as result "${sumstats_input1}"
		noi di as text"# > sumstats2rg .......................... input data # 2 "as result "${sumstats_input2}"
		}
qui { // 2 - define output
	foreach i in 1 2 {
		clear 
		set obs 1
		gen a = "${sumstats_input`i'}"
		split a,p("\"".sumstats")
		sxpose, clear
		gen b = _n
		gsort -b
		keep in 1
		replace _var1 = "global sumstats_output`i' " + _var1
		outsheet _var1 using temp.do , non noq replace
		do temp.do
		erase temp.do
		clear
		}
noi di as text"# > sumstats2rg .................. processing sumstats to "as result "${sumstats_output1}-by-${sumstats_output2}.rg.log"
		}
qui { // 3 - define python scripts	
	global temp_ldsc `ldsc'
	}
qui { // 4 - calculate snp-heritability	
	!python "${temp_ldsc}" --rg `sumstats' --ref-ld `w_hm3'w_hm3\w_hm3 --w-ld `w_hm3'w_hm3\w_hm3 --out ${sumstats_output1}-by-${sumstats_output2}.rg
	noi checkfile, file(${sumstats_output1}-by-${sumstats_output2}.rg.log)
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
