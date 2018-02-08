/*
*program*
 graphmanhattan

*description* 
 a command to create a publication quality manhattan plot from gwas 

*syntax*
	graphmanhattan , chr(-chr-) bp(-bp-) p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]
 
 -chr-    the varname containing the numeric chromosome data
 -bp-    the varname containing the numeric base-pair position data
 -p-   		the varname containing p-value
 -max-   	the maximum observed -log10 p-values to plot (all others limited to `max'; default = 10)
 -min-   	the minimum observed -log10 p-values to plot (default = 2)
 -gws-    the -log10 p-value corresponding to genome-wide significance (default = 7.3)
 -str-    the -log10 p-value corresponding to "strong" significance (default = 6)
*/

program graphmanhattan
syntax , chr(string asis) bp(string asis) p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphmanhattan"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
preserve
qui { // 1 - introduction
	noi di as text"# > graphmanhattan ...................................... "as result"checking that chr is defined correctly"
	capture confirm numeric var `chr'
	if _rc==0 {
		noi di as text"# > graphmanhattan .................................. chr "as result"present"
		}
	else {
		noi di as text"# > graphmanhattan .................................. chr "as result"absent"
		exit
		}
	noi di as text"# > graphmanhattan ...................................... "as result"checking that bp is defined correctly"
	capture confirm numeric var `bp'
	if _rc==0 {
		noi di as text"# > graphmanhattan ................................... bp "as result"present"
		}
	else {
		noi di as text"# > graphmanhattan ................................... bp "as result"absent"
		exit
		}
	noi di as text"# > graphmanhattan ...................................... "as result"checking that p is defined correctly"
	capture confirm numeric var `p'
	if _rc==0 {
		noi di as text"# > graphmanhattan .................................... p "as result"present"
		}
	else {
		noi di as text"# > graphmanhattan .................................... p "as result"absent"
		exit
		}
	}
qui { // 2 - processing variables
	drop if `p' == .
	gen observed = -log10(`p')
	count
	global rN `r(N)'	
	noi di as text"# > graphmanhattan .............. plot manhattan data for "as result "`r(N)'" as text " non missing data points"
	sum `p'
	noi di as text"# > graphmanhattan ............ min observed p in dataset "as result "`: display %10.4e r(min)'"
	drop if `chr' > 23		   // drop chromosomes > X (X- XY and other)
	duplicates drop			 	 // drop any duplicate observations
	drop if observed < `min' // apply floor
	replace observed = `max' if observed > `max' // apply ceiling
	}
qui { // 3 - preparing bp for plotting
	sum `chr'
	global maxchr `r(max)'
	foreach i of num 1 / $maxchr {
		sum `bp' if `chr' == `i'
		replace `bp' = (`bp' + `r(max)' + 20000000) if `chr' == `i' + 1
		}
	gen location = round(`bp'/1000000,0.01)
	foreach i of num 1 / $maxchr {
		sum location if `chr' == `i'
		global mtick`i' `r(mean)'
		di ${mtick`i'}
		}
	}
qui { // 4 - plotting to tmpManhattan.gph
	noi di as text"# > graphmanhattan ........................ plotting from "as result "1e-`max'" as text " to "as result "1e-`min'" as text " to " as result "tmpManhattan.gph"
	colorscheme 8, palette(Blues)
	global color3	"mlc("`r(color7)'") mfc("`r(color7)'")"
	global color4	"mlc("`r(color8)'") mfc("`r(color8)'")"
	sum observed
	gen tmpx = `r(max)' + 1.1
	replace tmpx = round(tmpx,2)
	sum tmpx
	global tmpmax `r(max)'
	gen tmpmin = `min'
	global tmp_symbol "msymbol(o) msize(small)"
	#delimit;
	tw scatter observed location if `chr' == 1 ,  ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 2 ,  ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 3 ,  ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 4 ,  ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 5 ,  ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 6 ,  ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 7 ,  ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 8 ,  ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 9 ,  ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 10 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 11 , ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 12 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 13 , ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 14 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 15 , ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 16 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 17 , ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 18 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 19 , ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 20 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 21 , ${tmp_symbol} ${color3}
	|| scatter observed location if `chr' == 22 , ${tmp_symbol} ${color4}
	|| scatter observed location if `chr' == 23 , ${tmp_symbol} ${color3}
	ytitle("-log10(p)"" ")  ylabel(`min'(1)${tmpmax})
	xtitle(" ""Chromosome")	xlabel(none)
	yline(`gws', lp(dash) lc("203 024 029") lw(thin)) 
	yline(`str', lp(dash) lc("065 171 093") lw(thin)) 
	xmlabel(${mtick1} "1" ${mtick2} "2" ${mtick3} "3" ${mtick4} "4" ${mtick5} "5" ${mtick6} "6" ${mtick7} "7" ${mtick8} "8" ${mtick9} "9" ${mtick10} "10" ${mtick11} "11" ${mtick12} "12" ${mtick13} "13" ${mtick14} "14" ${mtick15} "15" ${mtick16} "16" ${mtick17} "17" ${mtick18} "18" ${mtick19} "19" ${mtick20} "20" ${mtick21} "21" ${mtick22} "22" ${mtick23} "23" , nogrid)
	fysize(100) fxsize(500)
	legend(off)
	nodraw saving(tmpManhattan.gph, replace)
	;
	#delimit cr
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
restore
end;
	
 
