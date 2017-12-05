/*
#########################################################################
# graphplinkhwe
# a command to plot distribution from *hwe plink file
#
# command: graphplinkhwe, hwe(input-file) 
# options: 
#          threshold(num) ..... -log10P to flag in output-file 
#
# dependencies: 
# tabbed.pl must be set to be called via ${tabbed}
#
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 10th September 2015
#########################################################################
*/
program graphplinkhwe

syntax , hwe(string asis) [threshold(real 6)]
qui di as text"#########################################################################"
qui di as text"# graphplinkhwe                                                          "
qui di as text"# version:       2a                                                      "
qui di as text"# Creation Date: 21April2017                                             "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# This is a script to plot the output from hwe file from the --hardy     "
qui di as text"# routine in plink.                                                      " 
qui di as text"# The input data comes in standard format from the hwe output.           "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : tabbed.pl via ${tabbed}                                 "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi checkfile, file(`hwe'.hwe)
qui di as text"# > processing `hwe'.hwe"
qui {
	!$tabbed `hwe'.hwe
	import delim using `hwe'.hwe.tabbed, clear case(lower)
	erase `hwe'.hwe.tabbed
	for var p : destring X, replace force
	replace test =  "ALL" if test == "ALL(NP)" 
	keep if test == "ALL"
	for var p : lab var X "HWE (p)"
	count
	global nSNPs `r(N)'
	noi di as text"# >> "as result"${nSNPs} "as text"snps imported from "as result"`hwe'.hwe"
	count if p <1e-`threshold' 
	global nSNPslow `r(N)'
	global threshold_tmp `threshold'
	noi di as text"# >> "as result"${nSNPslow} "as text"snps with HWE deviation p < "as result"1e-${threshold_tmp}"
	}
qui di as text"# > plotting HWE (P) deviation to tmpHWE.gph"
qui{
	sum p
	gen log10p = -log10(p)
	qui di as text"# >> pruning dataset for plotting"
	qui di as text"# >>> pruning if p > 1E-4"
	drop if log10p < 4
	qui di as text"# >>> applying ceiling to data for p < 1E-20"
	replace log10p = 20 if log10p >= 20
	if `r(min)' != `r(max)' {
		tw hist log10p , width(1) start(4) percent ///
		   xlabel(0(5)20) ///
		   xline(`threshold'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with HWE P < 1e-`threshold' ; N = ${nSNPslow}") ///
		   nodraw saving(tmpHWE.gph, replace)
		}
	}
qui di as text"# > exporting HWE (P) deviation SNPs to  tmpHWE.snplist"
qui { 
	outsheet snp if p <1e-`threshold' using tempHWE.snplist, non noq replace
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
