/*
#########################################################################
# graphplinkhet
# a command to plot distribution from *hwe plink file
#
# command: graphplinkhet, het(input-file) 
# options: 
#          sd(num) ..... standard deviations from mean to falg in output file
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

program graphplinkhet
syntax , het(string asis) [sd(real 4)]

qui di as text"#########################################################################"
qui di as text"# graphplinkhet                                                        "
qui di as text"# version:       2a                                                      "
qui di as text"# Creation Date: 21April2017                                             "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# This is a script to plot the output from het file from the --het "
qui di as text"# routine in plink.                                                      " 
qui di as text"# The input data comes in standard format from the imiss output          "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : tabbed.pl via ${tabbed}                                 "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Syntax : graphplinkhet, het(filename) [sd(real 4)]            "
qui di as text"# for filename, .het is not needed                                     "
qui di as text"#########################################################################"

noi di as text"# > "as input"graphplinkhet "as text"....................................... "as result"`het'.het"
noi checkfile, file(`het'.het)
noi checktabbed

qui di as text"# > processing `het'.het"
qui { 
	!$tabbed `het'.het
	import delim using `het'.het.tabbed, clear case(lower)
	erase `het'.het.tabbed
	for var fid iid: tostring X, replace force
	for var ohom   : destring X, replace force
	for var ohom   : lab var X "Homozygosity (observed)"
	sum ohom
	qui di as text"# >> calculateing standard deviation of ohom"
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
	noi di as text"# >> number of individuals in file ...................... "as result `r(N)'		
	count if threshold == 1
	global nINDlow `r(N)'
	global sd_tmp `sd'
	noi di as text"# >> number of individuals in file with het > "as result"`sd'"as text" x ....... "as result "${nINDlow}"
	}
qui di as text"# > plotting heterozygosity to tmpHET.gph"
qui{
	sum ohom
	if `r(min)' != `r(max)' {
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
	}
qui di as text"# > exporting individual ids where heterozygosity outside the ${sd_tmp}x threshold to tmpHET.indlist"
qui {
	outsheet fid iid if threshold == 1 using tempHET.indlist, non noq replace
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	

