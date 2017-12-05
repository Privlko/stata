/*
#########################################################################
# graphplinkimiss
# a command to plot distribution from *imiss plink file
#
# command: graphplinkimiss, imiss(input-file) 
# options: 
#          mind(num) ..... missingness by individual threshold
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
program graphplinkimiss

syntax , imiss(string asis) [mind(real 0.02)]
qui di as text"#########################################################################"
qui di as text"# graphplinkimiss                                                        "
qui di as text"# version:       2a                                                      "
qui di as text"# Creation Date: 21April2017                                             "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# This is a script to plot the output from imiss file from the --missing "
qui di as text"# routine in plink.                                                      " 
qui di as text"# The input data comes in standard format from the imiss output          "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : tabbed.pl via ${tabbed}                                 "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi checkfile, file(`imiss'.imiss)
noi checktabbed

qui di as text"# > processing `imiss'.imiss"
qui {
	!$tabbed `imiss'.imiss
	import delim using `imiss'.imiss.tabbed, clear case(lower)
	erase `imiss'.imiss.tabbed
	for var fid iid: tostring X, replace force
	for var f_miss : destring X, replace force
	count
	global nIND `r(N)'
	noi di as text"# >> "as result"${nIND}"as text" individuals imported from "as result"`imiss'.imiss"
	count if f_miss > `mind'
	global nINDlow `r(N)'
	global mind_tmp `mind'
	noi di as text"# >> "as result"${nINDlow}"as text" individuals with missingess > "as result"${mind_tmp}"
	replace f_miss = 0.05 if f_miss >0.05 & f_miss !=.

	}
qui di as text"# > plotting missingness to tmpIMISS.gph"
qui{
	sum f_miss
	if `r(min)' != `r(max)' {
		tw hist f_miss , width(0.005) start(0) percent                       ///
		   xlabel(0(0.005)0.05)                                              ///
		   xline(`mind'  , lpattern(dash) lwidth(vthin) lcolor(red))         ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with missingness > `mind' ; N = ${nINDlow}") ///
		   nodraw saving(tmpIMISS.gph, replace)
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
