/*
*program*
 graphplinkhet

*description* 
 command to use plot the distribution of heterozygosity from the plink *.het file
  
*syntax*
 graphplinkhet, het(-filename-) [sd(-sd-)]

 -filename- does not require the .bim filetype to be included - this is assumed
 -sd-       the sd differences fromteh mean that are considered out of bounds
*/

program graphplinkhet
syntax , het(string asis) [sd(real 4)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphplinkhet"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > graphplinkhet ............................. importing "as result"`het'.het"
	noi checkfile, file(`het'.het)
	checktabbed
	}
qui { // 2 - processing `het'.het
	!$tabbed `het'.het
	import delim using `het'.het.tabbed, clear case(lower)
	erase `het'.het.tabbed
	for var fid iid: tostring X, replace force
	for var ohom   : destring X, replace force
	for var ohom   : lab var X "Homozygosity (observed)"
	sum ohom
	gen sd   = `r(sd)'
	gen _ohom = ohom - `r(mean)'
	gen threshold = 0
	replace threshold = 1 if _ohom <  -(`sd' * sd) 
	replace threshold = 1 if _ohom >   (`sd' * sd) 
	gen u = (`sd' * sd) 
	gen l = -(`sd' * sd) 
	foreach i in u l { 
		sum `i'
		global `i'l `r(max)'
		}
	gen xu = round(((2+`sd') * sd),1000)
	gen xl = round(-((2+`sd') * sd),1000)
	foreach i in u l { 
		sum x`i'
		global `i'x `r(max)'
		}	
	count
	global nIND `r(N)'
	noi di as text"# > graphplinkhet ......... number of individuals in file "as result `r(N)'
	count if threshold == 1
	global nINDlow `r(N)'
	global sd_tmp `sd'
	noi di as text"# > graphplinkhet ....... heterozygosity threshold +/- sd "as result "`sd'x"
	noi di as text"# > graphplinkhet ...... individuals with het > threshold "as result "${nINDlow}"
	}
qui { // 3 - plotting heterozygosity to tmpHET.gph
	sum ohom
	if `r(min)' != `r(max)' {
		noi di as text"# > graphplinkhet ...................... plotting data to "as result "tmpHET.gph"
		tw hist _ohom,  ///
		   xtitle("Adjuster Homozygosity") ///
		   xlabel(${ux} 0 ${lx}) ///
		   xline(${ul}  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   xline(${ll}  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with Homozygosity < `sd' * Std. Dev. from Mean ; N = ${nINDlow}") ///
		   nodraw saving(tmpHET.gph, replace)
		}
	else {
		noi di as text"# > graphplinkhet ........ nothing to plot (create blank) "as result "tmpHET.gph"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))  
		graph save `i', replace
		}
	noi di as text"# > graphplinkhet .............. exporting identifiers to "as result "tmpHET.indlist"
	outsheet fid iid if threshold == 1 using tempHET.indlist, non noq replace
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	

