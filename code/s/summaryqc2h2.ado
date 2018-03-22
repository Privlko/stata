/*
*program*
 summaryqc2h2

*description* 
wrapper for python ldsc - using summaryqc files
*/

program summaryqc2h2
syntax ,  summaryqc(string asis) data_folder(string asis) munge_sumstats(string asis) ldsc(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# summaryqc2h2               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > ldscoreh2 ................................ input data "as result "`summaryqc'"
	noi checkfile, file(`summaryqc')
	qui { // create output
		clear 
		set obs 1
		gen a = "`summaryqc'"
		split a,p("\""-summaryqc.dta")
		sxpose, clear
		gen b = _n
		gsort -b
		keep in 1
		replace _var1 = "global ldscoreh2_output " + _var1
		outsheet _var1 using temp.do , non noq replace
		do temp.do
		erase temp.do
		clear
		}
	}
qui { // 2 - define ldscore folders
	noi di as text"# > ldscoreh2 ..................... reference data folder "as result "`data_folder'"
	noi checkfile, file(`data_folder'w_hm3.snplist)
	noi checkfile, file(`data_folder'w_hm3\w_hm3_bim.dta)
	}
qui { // 3 - define python scripts	
	global temp_munge `munge_sumstats'
	global temp_ldsc  `ldsc'
}
qui { // 4 - import summaryqc and convert to sumstats
	use `summaryqc', clear
	sort snp
	keep snp a1 a2 z p n
	renvars, upper
	outsheet SNP A1 A2 Z P N using	tempfile-ldscoreh2.in, noq replace
	noi di as text"# > ldscoreh2 .................................... create "as result "${ldscoreh2_output}_hw3.sumstats"
	!python "${temp_munge}" --sumstats tempfile-ldscoreh2.in --out ${ldscoreh2_output}_hw3 --merge-alleles `data_folder'w_hm3.snplist
	erase tempfile-ldscoreh2.in
	}
qui { // 5 - calculate snp-heritability	
	noi di as text"# > ldscoreh2 .................................... create "as result "${ldscoreh2_output}_hw3.h2.log"
	!python "${temp_ldsc}" --h2 ${ldscoreh2_output}_hw3.sumstats --ref-ld `data_folder'w_hm3\w_hm3 --w-ld `data_folder'w_hm3\w_hm3 --out ${ldscoreh2_output}_hw3.h2
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
