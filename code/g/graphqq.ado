/*
*program*
 graphqq

*description* 
 command to create a publication quality qq-plots from gwas summary data

*syntax*
	graphqq , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6) version(real 13.1)]
 
 -p-   		the varname containing p-value
 -max-   	the maximum observed -log10 p-values to plot (all others limited to `max'; default = 10)
 -min-   	the minimum observed -log10 p-values to plot (default = 2)
 -gws-    the -log10 p-value corresponding to genome-wide significance (default = 7.3)
 -str-    the -log10 p-value corresponding to "strong" significance (default = 6)
*/
program graphqq
syntax , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6) ]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphqq"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
preserve
qui { // 1 - introduction
	noi di as text"# > graphqq ............................................. "as result"checking that p is defined correctly"
	capture confirm numeric var `p'
	if _rc==0 {
		noi di as text"# > graphqq ........................................... p "as result"present"
		}
	else {
		noi di as text"# > graphqq ........................................... p "as result"absent"
		exit
		}
	}
qui { // 2 - calculating observed / expected values
	drop if `p' == .
	count
	global rN `r(N)'
	noi di as text"# > graphqq ............................ plot qq data for "as result "`r(N)'" as text " non missing data points"
	sum `p'
	noi di as text"# > graphqq ................... min observed p in dataset "as result "`: display %10.4e r(min)'"
	sort `p'
	gen graphqq_n = _n
	gen  graphqq_expected    = -log10(_n/${rN})			
	gen  graphqq_observed    = -log10(`p')					
	replace graphqq_observed  = `max' if graphqq_observed > `max'
	}
qui { // 3 - pruning data bins to speed up plotting
	egen graphqq_bin   = cut(graphqq_observed), at(0(1)`max')
	gen  graphqq_random = uniform()
	sort graphqq_random
	egen graphqq_instance = seq(),by(graphqq_bin)
	drop if graphqq_instance > 500
	save _tmp_qqgraph.dta, replace

	}
qui { // 4 - calculate binomal boundaries
	use _tmp_qqgraph.dta, clear
	append using _tmp_qqgraph.dta
	append using _tmp_qqgraph.dta
	sort graphqq_expected graphqq_n
	keep graphqq_observed graphqq_expected graphqq_n
	egen x  = seq(),by(graphqq_n)
	sort graphqq_n x
	tostring graphqq_n, replace
	gen script = ""
	replace script = "qui cii $rN " + graphqq_n if x == 1
	replace script = `"qui replace graphqq_ub = r(ub) if graphqq_n == ""' + graphqq_n + `"""' if x == 2
	replace script = `"qui replace graphqq_lb = r(lb) if graphqq_n == ""' + graphqq_n + `"""' if x == 3
	outsheet script using _tmp_qqgraph.do, non noq replace
	gen graphqq_ub = .
	gen graphqq_lb = .
	sort graphqq_observed x
	do _tmp_qqgraph.do
	gen graphqq_upper = -log10(graphqq_ub)
	gen graphqq_lower = -log10(graphqq_lb)
	keep graphqq_observed graphqq_expected graphqq_upper graphqq_lower
	for var graphqq_observed graphqq_expected: drop if X < `min'
	sort graphqq_expected
	}
qui { // 5 - plotting to tmpQQ.gph
	noi di as text"# > graphqq ............................... plotting from "as result "1e-`max'" as text " to "as result "1e-`min'" as text " to " as result "tmpQQ.gph"
	global gws red 
	global str midgreen
	colorscheme 8, palette(Reds)
	global level1	"mlc("`r(color4)'") mfc("`r(color4)'")"
	global level2	"mlc("`r(color6)'") mfc("`r(color6)'")"
	global level3	"mlc("`r(color8)'") mfc("`r(color8)'")"
	sum graphqq_observed
	gen tmpx =  `r(max)' + 1.1
	replace tmpx = round(tmpx,2)
	sum tmpx
	global tmpmax `r(max)'
	global tmp_symbol "msymbol(o) msize(small)"
	#delimit;
	tw line graphqq_expected graphqq_expected  , lwidth(vthin) lcolor(black)
	|| line graphqq_upper graphqq_expected     , lpattern(dash) lwidth(vthin) lcolor(black)
	|| line graphqq_lower graphqq_expected     , lpattern(dash) lwidth(vthin) lcolor(black)
	|| scatter graphqq_observed graphqq_expected if (observed <  `str')                   ,	${tmp_symbol} ${level1}
	|| scatter graphqq_observed graphqq_expected if (observed >= `str' & graphqq_observed < `gws'), ${tmp_symbol} ${level2}
	|| scatter graphqq_observed graphqq_expected if (observed >= `gws')                   ,	${tmp_symbol} ${level3}
	legend(off) 
	xtitle(" " "Expected (-log10(P))") 
	ytitle("Observed -log10(p)"" ")
	xlabel(`min'(1)${tmpmax})
	ylabel(`min'(1)${tmpmax})
	fysize(100) fxsize(100)
	nodraw saving(tmpQQ.gph, replace)
	;
	#delimit cr
	}
qui { // cleaning up temporary files
	erase _tmp_qqgraph.dta
	erase _tmp_qqgraph.do
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
restore
end;
		
