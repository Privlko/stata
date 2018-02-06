/*
*program*
 graphplinkimiss

*description* 
 command to plot distribution from *imiss plink file

*syntax*
 graphplinkimiss, imiss(-filename-) [mind(-mind-)]
 
 -filename- the name of the imiss file *.imiss not required
 -mind-     the missingness by individual line to be plotted
*/

program graphplinkimiss
syntax , imiss(string asis) [mind(real 0.02)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphplinkimiss"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > graphplinkimiss ........................... importing "as result"`imiss'.imiss"
	noi checkfile, file(`imiss'.imiss)
	checktabbed
	}
qui { // 2 - processing `imiss'.imiss
	!$tabbed `imiss'.imiss
	import delim using `imiss'.imiss.tabbed, clear case(lower)
	erase `imiss'.imiss.tabbed
	for var fid iid: tostring X, replace force
	for var f_miss : destring X, replace force
	count
	global nIND `r(N)'
	noi di as text"# > graphplinkimiss ....... number of individuals in file "as result `r(N)'
	count if f_miss > `mind'
	global nINDlow `r(N)'
	global mind_tmp `mind'
	noi di as text"# > graphplinkimiss ............... missingness threshold "as result `mind'
	noi di as text"# > graphplinkimiss ... individuals with miss > threshold "as result "${nINDlow}"
	replace f_miss = 0.05 if f_miss >0.05 & f_miss !=.
	}
qui { // 3 - plotting missingness to tmpIMISS.gph
	sum f_miss
	if `r(min)' != `r(max)' {
		noi di as text"# > graphplinkimiss .................... plotting data to "as result "tmpIMISS.gph"
		tw hist f_miss , width(0.005) start(0) percent                       ///
		   xlabel(0(0.005)0.05)                                              ///
		   xline(`mind'  , lpattern(dash) lwidth(vthin) lcolor(red))         ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with missingness > `mind' ; N = ${nINDlow}") ///
		   nodraw saving(tmpIMISS.gph, replace)
		}
	else {
		noi di as text"# > graphplinkimiss ...... nothing to plot (create blank) "as result "tmpIMISS.gph"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))  
		graph save tmpIMISS.gph, replace
		}	
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	
