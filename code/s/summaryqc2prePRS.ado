/*
*program*
 summaryqc2prePRS

*description* 
conversion to prePRS format - using summaryqc files
*/

program summaryqc2prePRS
syntax ,  summaryqc(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# summaryqc2prePRS               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > summaryqc2prePRS ......................... input data "as result "`summaryqc'"
	noi checkfile, file(`summaryqc')
	}
qui { // 2 - define output
		clear 
		set obs 1
		gen a = "`summaryqc'"
		split a,p("\""-summaryqc.dta")
		sxpose, clear
		gen b = _n
		gsort -b
		keep in 1
		replace _var1 = "global summaryqc2prePRS_output " + _var1
		outsheet _var1 using temp.do , non noq replace
		do temp.do
		erase temp.do
		clear
		noi di as text"# > summaryqc2prePRS .............. exporting sumstats to "as result "${summaryqc2prePRS_output}-prePRS.tsv"
		}
qui { // 4 - convert summaryqc to sumstats
	use `summaryqc', clear
	keep chr bp snp a1 a2 a1_frq or p
	rename (snp p) (rsid pval)
	missings dropobs, force
	outsheet using	${summaryqc2prePRS_output}-prePRS.tsv, noq replace
	!$gzip ${summaryqc2prePRS_output}-prePRS.tsv
	noi checkfile, file(${summaryqc2prePRS_output}-prePRS.tsv.gz)
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
