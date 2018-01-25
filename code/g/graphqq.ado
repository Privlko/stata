	/*
	#########################################################################
	# graphqq
	# a command to create a publication quality qq-plots from gwas 
	# summary data
	#
	# command: graphqq,  p(p-value-variable)
	# options: 
	# 			max(num) .....maximum -log10P to plot - default = 10
	# 			min(num) .....minimum -log10P to plot - default = 2
	# 			gws(num) .....where to plot gws line - default = 7.3 (5e-8)
	# 			str(num) .....what to consider as a strong association - default = 6
	#
	# dependencies: colorscheme
	# net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)
	# =======================================================================
	# Author: Richard Anney
	# Institute: Cardiff University
	# E-mail: AnneyR@cardiff.ac.uk
	# Date: 10th September 2015
	#########################################################################
	*/

	program graphqq
	syntax , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]

	preserve
	qui { // check variables
		capture confirm numeric var `p' 
		if _rc==0 {
			noi di as text"# > "as input"graphqq"as text" ............. the p-value variable is numeric "as result "continue"
			}
		else {
			noi di as text"# > "as input"graphqq"as text" ......... the p-value variable is not numeric "as error "exit"
			exit
			}
		}
	qui { // calculate lambda
		*THIS HAS NOT BEEN IMPLEMENTED FULLY - NEED TO MAKE SURE I AM USING THE CORRECT MATHEMATICS UNDERPINNING THE CALCULATION*
		/*	
		noi di as text"...calculate lambda"
		gen tmpchi = invchi2tail(1,`p')
		sum tmpchi,detail
		gen lambda = round(r(p50)/0.4549364,0.01)
		sum lambda
		global lowerambda `r(max)'
		noi di as text"lambda = ${lowerambda}"
		keep tmpp tmpchi
		noi di as text"...calculate lambda1000"
		keep tmpp tmpchi
		gen tmprandom = uniform()
		sort tmprandom
		egen obs = seq()
		sum tmpchi if obs <1000, detail
		gen lambda1000 = round(r(p50)/0.4549364,0.01)
		sum lambda1000
		global lowerambda1000 `r(max)'
		noi di as text"lambda1000 = ${lowerambda1000} (10)"
		foreach i of num 9/1 {
			keep tmpp tmpchi
			gen tmprandom = uniform()
			sort tmprandom
			egen obs = seq()
			sum tmpchi if obs <1000, detail
			gen     lambda1000 = round(r(p50)/0.4549364,0.001)
			replace lambda1000 = round(((lambda1000 + ${lowerambda1000}) / 2),0.001)
			sum lambda1000
			global lowerambda1000 `r(max)'
			noi di as text"lambda1000 = ${lowerambda1000} (`i')"
			}
		replace lambda1000 = round(lambda1000,0.01)
		sum lambda1000
		global lowerambda1000 `r(max)'
		noi di as text"lambda1000 = ${lowerambda1000} (`i')"
		*/
		}
		
	qui { // calculating observed / expected values
		drop if `p' == .
		count
		global rN `r(N)'
		noi di as text"# > "as input"graphqq"as text" ............................ plot qq data for "as result "`r(N)'" as text " non missing data points"
		sum `p'
		noi di as text"# > "as input"graphqq"as text" ................... min observed p in dataset "as result "`r(min)'"
		sort `p'
		gen n = _n
		gen  expected    = -log10(_n/${rN})			
		gen  observed    = -log10(`p')					
		replace observed  = `max' if observed > `max'
		}
	qui { // pruning data bins to speed up plotting
		egen bin      = cut(observed), at(0(1)`max')
		gen  random   = uniform()
		sort random
		egen instance = seq(),by(bin)
		drop if instance > 500
		}
	qui { // calculate binomal boundaries"
		save _tmp_qqgraph.dta, replace
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
	qui { // plotting to tmpQQ.gph"
		noi di as text"# > "as input"graphqq"as text" ............................... plotting from "as result "1e-`max'" as text " to "as result "1e-`min'" as text " to " as result "tmpQQ.gph"
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
	qui { // cleaning up temporary files"
		erase _tmp_qqgraph.dta
		erase _tmp_qqgraph.do
		}
	qui di as text"#########################################################################"
	qui di as text"# Completed: $S_DATE $S_TIME"
	qui di as text"#########################################################################"
	restore
	end;
		
