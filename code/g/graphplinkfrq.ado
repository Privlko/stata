/*
#########################################################################
# graphplinkfrq
# a command to plot distribution from *frq.counts plink file
#
# command: graphplinkfrq, frq(input-file) 
# options: 
#          maf(num) ..... minor/major allele frequency line to plot
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
program graphplinkfrq
syntax , frq(string asis) 

qui di as text"#########################################################################"
qui di as text"# graphplinkfrq                                                          "
qui di as text"# version:       2a                                                      "
qui di as text"# Creation Date: 21April2017                                             "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# This is a script to plot the output from frq.counts file from the --freq      "
qui di as text"# routine in plink.                                                      " 
qui di as text"# The input data comes in standard format from the frq.counts output.         "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : tabbed.pl via ${tabbed}                                 "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
qui di as text"# > check path of plink *.frq.counts file is true"

qui { 
	noi di as text"# > graphplinkfrq ............................. importing "as result"`frq'.frq.counts"
	noi checkfile, file(`frq'.frq.counts)
    checktabbed
	}
qui di as text"# > processing *.frq.counts"
qui {
	!$tabbed `frq'.frq.counts
	import delim using `frq'.frq.counts.tabbed, clear case(lower)
	erase `frq'.frq.counts.tabbed
	for var c1 c2 : destring X, replace force
	for var c1 c2 : drop if  X == .
	gen maf = round(c1/(c1+c2),0.001)
	for var maf : lab var X "minor allele frequency"
	count
	global nSNPs `r(N)'
	noi di as text"# > graphplinkfrq ................ number of SNPs in file "as result `r(N)'
	count if c1 < 5
	global nSNPlow `r(N)'
	noi di as text"# > graphplinkfrq ........... number of SNPs with mac < 5 "as result `r(N)'
	gen total = c1 + c2
	sum total
	global mac5 = 5/`r(max)'
	}
qui di as text"# > plotting frequency to tmpFRQ.gph"
qui {
	sum maf
	if `r(min)' != `r(max)' {
		noi di as text"# > graphplinkfrq ...................... plotting data to "as result "tmpFRQ.gph"
		tw hist maf,  width(0.004) start(0) percent ///
		   xlabel(0(.1)0.5) ///
		   xline($mac5 , lpattern(dash) lwidth(vthin) lcolor(red) ) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with mac < 5 ; N = ${nSNPlow}" ///
							 "mac 5 = $mac5 %") ///
		   nodraw saving(tmpFRQ.gph, replace)
		}
	else {
		noi di as text"# > graphplinkfrq ........ nothing to plot (create blank) "as result "tmpFRQ.gph"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))  
		graph save `i', replace
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
