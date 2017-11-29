/*
#########################################################################
# graphmanhattan
# a command to create a publication quality manhattan plot from gwas 
# summary data
#
# command: graphmanhattan, chr(chromosome-variable) bp(base-location-variable) p(p-value-variable)
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

program graphmanhattan
syntax , chr(string asis) bp(string asis) p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]

qui di as text"#########################################################################"
qui di as text"# graphmanhattan - version 1.0 04Aug2016 richard anney                  #"
qui di as text"#########################################################################"
qui di as text"# A command to create a publication quality manhattan plot from gwas    #"
qui di as text"# summary data.                                                         #"
qui di as text"# All chromosomes must be numeric 1-22, X = 23                          #"
qui di as text"# (XY and Y are not plotted)                                            #"
qui di as text"# All positions must numeric and in bp                                  #"
qui di as text"# The following thresholds are applied to the plot;                     #"
qui di as text"# maximum plotted -log(10) p-value displayed; P = 1E-`min'              #"
qui di as text"# minimum plotted -log(10) p-value displayed; P = 1E-`max'              #"
qui di as text"# Genomewide significance threshold line as P = 1E-`gws'                #"
qui di as text"# Strong associations threshold (Highlighted) as P < 1E-`str'           #"
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)
preserve
qui di as text"# > retaining working variables"
qui { 
	keep `chr' `p' `bp'
	}
qui di as text"# > checking variable in correct format"
qui { // chr
	capture confirm numeric var `chr' 
	if _rc==0 {
		noi di in green"# >> the chromosome variable `chr' is numeric ... continue"
		}
	else {
		noi di in red"# >> the chromosome variable `chr' is not numeric ... exiting"
		exit
		}
	}
qui { // p
	capture confirm numeric var `p' 
	if _rc==0 {
		noi di in green"# >> the p-value variable `p' is numeric ... continue"
		}
	else {
		noi di in red"# >> the p-value variable `p' is not numeric ... exiting"
		exit
		}
	}
qui { // bp
	capture confirm numeric var `bp' 
	if _rc==0 {
		noi di in green"# >> the chromosome location variable `bp' is numeric ... continue"
		}
	else {
		noi di in red"# >> the chromosome location variable `bp' is not numeric ... exiting"
		exit
		}
	}
qui di as text"# > processing variables (drop if chr > 23 and duplicate observations"
qui {
	drop if `chr' > 23			// drop chromosomes > X (X- XY and other)
	duplicates drop			 	// drop any duplicate observations
	}
qui di as text"# > report metrics"
qui {
	qui count
	qui di as text"# >> "as result "`r(N)' "as text" unique association signals were uploaded "
	sum `p'
	qui di as text"# >> the minimum P-value observed in this dataset is P = "as result `r(min)'
	}
qui di as text"# > create -log10 variable"
qui {
	gen tmpp = -log10(`p')
	drop if tmpp == .
	}
qui di as text"# > pruning dataset for plotting"
qui {
	qui di as text"# >> pruning if p > 1E-`min'"
	drop if tmpp < `min'
	qui di as text"# >> applying ceiling to data for p < 1E-`max'"
	replace tmpp = `max' if tmpp > `max'
	}
qui di as text"# > preparing bp for plotting "
qui { 
	foreach i of num 1 / 22 {
		sum `bp' if `chr' == `i'
		replace `bp' = (`bp' + `r(max)' + 20000000) if `chr' == `i' + 1
		}
	sum `chr'
	global maxchr `r(max)'
	gen tmpbp = round(`bp'/1000000,0.01)
	foreach i of num 1 / $maxchr {
		sum tmpbp if `chr' == `i'
		global mtick`i' `r(mean)'
		di ${mtick`i'}
		}
	}
qui di as text"# > plotting to tmpManhattan.gph"
qui { 
	colorscheme 8, palette(Blues)
	global color3	"mlc("`r(color7)'") mfc("`r(color7)'")"
	global color4	"mlc("`r(color8)'") mfc("`r(color8)'")"
	sum tmpp
	gen tmpx = `r(max)' + 1.1
	replace tmpx = round(tmpx,2)
	sum tmpx
	global tmpmax `r(max)'
	gen tmpmin = `min'
	global tmp_symbol "msymbol(o) msize(small)"
	#delimit;
	tw scatter tmpp tmpbp if `chr' == 1 ,  ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 2 ,  ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 3 ,  ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 4 ,  ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 5 ,  ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 6 ,  ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 7 ,  ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 8 ,  ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 9 ,  ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 10 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 11 , ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 12 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 13 , ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 14 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 15 , ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 16 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 17 , ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 18 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 19 , ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 20 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 21 , ${tmp_symbol} ${color3}
	|| scatter tmpp tmpbp if `chr' == 22 , ${tmp_symbol} ${color4}
	|| scatter tmpp tmpbp if `chr' == 23 , ${tmp_symbol} ${color3}
	ytitle("-log10(p)"" ")  ylabel(`min'(2)${tmpmax})
	xtitle(" ""Chromosome")	xlabel(none)
	yline(`gws', lp(dash) lc("203 024 029") lw(thin)) 
	yline(`str', lp(dash) lc("065 171 093") lw(thin)) 
	xmlabel(${mtick1} "1" ${mtick2} "2" ${mtick3} "3" ${mtick4} "4" ${mtick5} "5" ${mtick6} "6" ${mtick7} "7" ${mtick8} "8" ${mtick9} "9" ${mtick10} "10" ${mtick11} "11" ${mtick12} "12" ${mtick13} "13" ${mtick14} "14" ${mtick15} "15" ${mtick16} "16" ${mtick17} "17" ${mtick18} "18" ${mtick19} "19" ${mtick20} "20" ${mtick21} "21" ${mtick22} "22" , nogrid)
	fysize(100) fxsize(500)
	legend(off)
	nodraw saving(tmpManhattan.gph, replace)
	;
	#delimit cr
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
restore
end;
	
 
