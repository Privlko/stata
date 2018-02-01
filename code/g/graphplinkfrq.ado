/*
*program*
 graphplinkfrq

*description* 
 command to plot distribution from *frq.counts plink file

*syntax*
 graphplinkfrq, frq(-filename-) 
 
 -filename- the name of the frq.counts file *.frq.counts not required
*/

program graphplinkfrq
syntax , frq(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2frq"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > graphplinkfrq ............................. importing "as result"`frq'.frq.counts"
	noi checkfile, file(`frq'.frq.counts)
    	checktabbed
	}
qui { // 2 - processing *.frq.counts
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
qui { // 3-  plotting frequency to tmpFRQ.gph
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
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	
