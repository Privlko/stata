/*
*program*
 graphplinkhwe

*description* 
 command to use plot distribution from *hwe plink file
  
*syntax*
 graphplinkhwe, hwe(-filename-) [threshold(-threshold-)]

 -filename- does not require the .bim filetype to be included - this is assumed
 -sd-       the -log10P to flag in output-file
*/

program graphplinkhwe
syntax , hwe(string asis) [threshold(real 6)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphplinkhwe"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > graphplinkhwe ............................. importing "as result"`hwe'.hwe"
	noi checkfile, file(`hwe'.hwe)
	    checktabbed
	}
qui { // 2 - processing `hwe'.hwe
	!$tabbed `hwe'.hwe
	import delim using `hwe'.hwe.tabbed, clear case(lower)
	erase `hwe'.hwe.tabbed
	for var p : destring X, replace force
	replace test =  "ALL" if test == "ALL(NP)" 
	keep if test == "ALL"
	for var p : lab var X "HWE (p)"
	count
	global nSNPs `r(N)'
	noi di as text"# > graphplinkhwe ................ number of SNPs in file "as result `r(N)'
	count if p <1e-`threshold' 
	global nSNPslow `r(N)'
	global threshold_tmp `threshold'
	noi di as text"# > graphplinkhwe ......................... P < threshold "as result "1e-`threshold'"
	noi di as text"# > graphplinkhwe ..... number of SNPs with P < threshold "as result "${nSNPslow}"
	}
qui { // 3 - plotting HWE (P) deviation to tmpHWE.gph"
	sum p
	gen log10p = -log10(p)
	qui { // pruning plot to nearest p or p < 1e-4
		sum log10p
		gen x = round(`r(max)',1)
		replace x = x -1
		replace x = 4 if x > 4
		sum x
		global hwelimit `r(max)'
		drop if log10p < ${hwelimit}
		}
	qui { // applying ceiling to data for p < 1E-20"
		replace log10p = 20 if log10p >= 20
		}
	sum p
	if `r(min)' != `r(max)' {
		noi di as text"# > graphplinkhwe ...................... plotting data to "as result "tmpHWE.gph"
		tw hist log10p , width(1) start(${hwelimit}) percent ///
		   xlabel(0(5)20) ///
		   xline(`threshold'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with HWE P < 1e-`threshold' ; N = ${nSNPslow}") ///
		   nodraw saving(tmpHWE.gph, replace)
		}
	else {
		noi di as text"# > graphplinkhwe ........ nothing to plot (create blank) "as result "tmpHWE.gph"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))  
		graph save `i', replace
		}
	noi di as text"# > graphplinkhwe .............. exporting identifiers to "as result "tmpHWE.snplist"
	outsheet snp if p <1e-`threshold' using tmpHWE.snplist, non noq replace
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	
