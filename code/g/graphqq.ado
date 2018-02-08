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
 -version- the version parameter is needed if your stata version is > 14.1; in this instance the underlying cci syntax is altered and needs to be modified
*/
program graphqq
syntax , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6) version(real 13.1)]
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
	gen n = _n
	gen  expected    = -log10(_n/${rN})			
	gen  observed    = -log10(`p')					
	replace observed  = `max' if observed > `max'
	}
qui { // 3 - pruning data bins to speed up plotting
	egen bin   = cut(observed), at(0(1)`max')
	gen  random = uniform()
	sort random
	egen instance = seq(),by(bin)
	drop if instance > 500
	save _tmp_qqgraph.dta, replace

	}
qui { // 4 - calculate binomal boundaries
	clear
	gen version = `version'
	if version <= 14.1 {
		use _tmp_qqgraph.dta, clear
		append using _tmp_qqgraph.dta
		append using _tmp_qqgraph.dta
		sort expected n
		keep observed expected n
		egen x  = seq(),by(n)
		sort n x
		tostring n, replace
		gen script = ""
		replace script = "qui cii $rN " + n if x == 1
		replace script = `"qui replace ub = r(ub) if n == ""' + n + `"""' if x == 2
		replace script = `"qui replace lb = r(lb) if n == ""' + n + `"""' if x == 3
		outsheet script using _tmp_qqgraph.do, non noq replace
		gen ub = .
		gen lb = .
		sort observed x
		do _tmp_qqgraph.do
		gen upper = -log10(ub)
		gen lower = -log10(lb)
		keep observed expected upper lower
		for var observed expected: drop if X < `min'
		sort expected
		}
	else {
		use _tmp_qqgraph.dta, clear
		append using _tmp_qqgraph.dta
		append using _tmp_qqgraph.dta
		sort expected n
		keep observed expected n
		egen x  = seq(),by(n)
		sort n x
		tostring n, replace
		gen script = ""
		replace script = "qui cii proportions $rN " + n if x == 1
		replace script = `"qui replace ub = r(ub) if n == ""' + n + `"""' if x == 2
		replace script = `"qui replace lb = r(lb) if n == ""' + n + `"""' if x == 3
		outsheet script using _tmp_qqgraph.do, non noq replace
		gen ub = .
		gen lb = .
		sort observed x
		do _tmp_qqgraph.do
		gen upper = -log10(ub)
		gen lower = -log10(lb)
		keep observed expected upper lower
		for var observed expected: drop if X < `min'
		sort expected
		}
	}
qui { // 5 - plotting to tmpQQ.gph
	noi di as text"# > graphqq ............................... plotting from "as result "1e-`max'" as text " to "as result "1e-`min'" as text " to " as result "tmpQQ.gph"
	global gws red 
	global str midgreen
	colorscheme 8, palette(Reds)
	global level1	"mlc("`r(color4)'") mfc("`r(color4)'")"
	global level2	"mlc("`r(color6)'") mfc("`r(color6)'")"
	global level3	"mlc("`r(color8)'") mfc("`r(color8)'")"
	sum observed
	gen tmpx =  `r(max)' + 1.1
	replace tmpx = round(tmpx,2)
	sum tmpx
	global tmpmax `r(max)'
	global tmp_symbol "msymbol(o) msize(small)"
	#delimit;
	tw line expected expected  , lwidth(vthin) lcolor(black)
	|| line upper expected     , lpattern(dash) lwidth(vthin) lcolor(black)
	|| line lower expected     , lpattern(dash) lwidth(vthin) lcolor(black)
	|| scatter observed expected if (observed <  `str')                   ,	${tmp_symbol} ${level1}
	|| scatter observed expected if (observed >= `str' & observed < `gws'), ${tmp_symbol} ${level2}
	|| scatter observed expected if (observed >= `gws')                   ,	${tmp_symbol} ${level3}
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
		
