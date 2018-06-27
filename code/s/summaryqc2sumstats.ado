/*
*program*
 summaryqc2sumstats

*description* 
wrapper for python ldsc - using summaryqc files
*/

program summaryqc2sumstats
syntax ,  summaryqc(string asis) w_hm3(string asis) munge_sumstats(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# summaryqc2sumstats               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > summaryqc2sumstats ....................... input data "as result "`summaryqc'"
	noi checkfile, file(`summaryqc'-summaryqc.dta)
	noi checkfile, file(`w_hm3'w_hm3.dta)
	noi checkfile, file(`w_hm3'w_hm3.snplist)
	}
qui { // 2 - define python scripts	
	global temp_munge `munge_sumstats'
	}
qui { // 3 - convert summaryqc to sumstats
	use `summaryqc'-summaryqc.dta, clear
	merge 1:1 snp using `w_hm3'w_hm3.dta
	keep if _m == 3
	sort snp
	keep snp a1 a2 z p n
	renvars, upper
	missings dropobs, force
	for var  Z P N : tostring X, replace
	outsheet SNP A1 A2 Z P N     using tempfile-summaryqc.in, noq replace
	!python "${temp_munge}" --sumstats tempfile-summaryqc.in --out `summaryqc'-summaryqc_hw3 --merge-alleles `w_hm3'w_hm3.snplist
	erase tempfile-summaryqc.in
	noi checkfile, file(`summaryqc'-summaryqc_hw3.sumstats.gz)
	}

noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

	
