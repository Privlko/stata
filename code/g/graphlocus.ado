/*
*program*
 graphlocus

*description* 
 command to plot a locus plot 

*syntax*
 graphlocus, index(-index-) snp(-snp-) chr(-chr-) bp(-bp-) p(-p-) ldref(-ldref-) recombref(-recombref-) generef(-generef-) [maxp(-maxp-) gwsp(-gwsp-)]
 
 -index-        index marker
 -snp-          varname of the marker variable
 -chr-          varname of the chromosome variable
 -bp-           varname of the bp variable (hg19)
 -p-            varname of the p variable
 -ldref-        reference genotype to calculate linkage disequilibrium
 -recombref-    reference recombination rate (hg19)
 -generef-      reference gene/exon co-ordinates (hg19)
 -maxp-         minimum p-value to display (default = 1e-10 (10))
 -gwsp-         gw-significant p-value (default 5e-8 (7.3))  
 
*/

program graphlocus
syntax , index(string asis) snp(string asis) chr(string asis) bp(string asis) p(string asis) ldref(string asis) generef(string asis) [maxp(real 10) gwsp(real 7.3) range(string asis)]

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphlocus"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
preserve
qui { // 1 - introduction
	noi di as text"# > graphlocus .................... plotting locus around "as result"`index'"
	sum `chr' if `snp' == "`index'"
	global graphlocus_chr `r(max)'
	noi di as text"# > graphlocus ...................................... chr "as result"${graphlocus_chr}"
	sum `bp' if `snp' == "`index'"
	global graphlocus_bp `r(max)'
	noi di as text"# > graphlocus ....................................... bp "as result"${graphlocus_bp}"
	noi checkfile, file(`ldref'.bim)
	noi checkfile, file(`ldref'.bed)
	noi checkfile, file(`ldref'.fam)
	noi checkfile, file(`generef')
	}
qui { // 2 - define window and globals
	gen graphlocus_range = "`range'"
	if graphlocus_range == "" {
		gen graphlocus_window = 250000
		sum graphlocus_window
		global graphlocus_window `r(max)'
		gen graphlocus_lb = round(${graphlocus_bp} - ${graphlocus_window},100)
		replace graphlocus_lb = 0 if graphlocus_lb < 0
		gen graphlocus_ub = round(${graphlocus_bp} + ${graphlocus_window},100)
		sum graphlocus_lb
		global graphlocus_lb `r(max)'
		sum graphlocus_ub
		global graphlocus_ub `r(max)'
		drop graphlocus_window 
		}
	else {
		split graphlocus_range,p("-")
		rename (graphlocus_range1 graphlocus_range2) (graphlocus_lb graphlocus_ub)
		for var graphlocus_lb graphlocus_ub: destring X,replace
		replace graphlocus_lb = round(graphlocus_lb,100)
		replace graphlocus_ub = round(graphlocus_ub,100)
		sum graphlocus_lb
		global graphlocus_lb `r(max)'
		sum graphlocus_ub
		global graphlocus_ub `r(max)'		
		}	
	gen graphlocus_spacer = (${graphlocus_ub} - ${graphlocus_lb})/2
	sum graphlocus_spacer 
	global graphlocus_spacer `r(max)'
	drop graphlocus_lb graphlocus_ub graphlocus_spacer
	}
qui { // 3 - limit dataset
	keep if `chr' == ${graphlocus_chr}
	drop if `bp' < ${graphlocus_lb}
	drop if `bp' > ${graphlocus_ub}
	noi di as text"# > graphlocus ................................. plotting "as result"chr${graphlocus_chr}:${graphlocus_lb}-${graphlocus_ub}"
	count
	noi di as text"# > graphlocus ............................ SNPs in model "as result"`r(N)'"
	save graphlocus_assoc.dta,replace
	outsheet `snp' using graphlocus_assoc.extract, non noq replace
	}
qui { // 4 - calculate ld region
	if `chr' != 23 {
		!$plink --bfile `ldref' --extract graphlocus_assoc.extract --allow-no-sex --r2 --ld-window-kb 100000 --ld-window 99999 --ld-window-r2 0 --ld-snp `index' --out graphlocus_ld
		}
	else {
		!$plink --bfile `ldref' --extract graphlocus_assoc.extract --allow-no-sex --r2 --ld-xchr 1 --ld-window-kb 100000 --ld-window 99999 --ld-window-r2 0 --ld-snp `index' --out graphlocus_ld
		}
	!$tabbed graphlocus_ld.ld
	import delim using graphlocus_ld.ld.tabbed, varnames(1) clear
	keep snp_b r2
	rename (snp_b r2) (`snp' rsquare)
	merge 1:1 `snp'  using graphlocus_assoc.dta
	keep if _m == 3
	keep `snp' `chr' `bp' `p' rsquare
	save graphlocus_assoc_r2.dta,replace
	}
qui { // 5 - add plotting variables	
	qui { // snp density
		gen graphlocus_uspike = `maxp' +1
		gen graphlocus_dspike = `maxp' +.5
		for var graphlocus_uspike graphlocus_dspike:  replace X = . if `snp' == ""
		}
	qui { // p-by-ld to `index'
		gen graphlocus_log10p = - log10(`p')
		gen graphlocus_p_index = graphlocus_log10p if `snp' == "`index'"
		gen graphlocus_p_r0_1 = graphlocus_log10p if inrange(rsquare,0.0,0.1)
		gen graphlocus_p_r1_2 = graphlocus_log10p if inrange(rsquare,0.1,0.2)
		gen graphlocus_p_r2_3 = graphlocus_log10p if inrange(rsquare,0.2,0.3)
		gen graphlocus_p_r3_4 = graphlocus_log10p if inrange(rsquare,0.3,0.4)
		gen graphlocus_p_r4_5 = graphlocus_log10p if inrange(rsquare,0.4,0.5)
		gen graphlocus_p_r5_6 = graphlocus_log10p if inrange(rsquare,0.5,0.6)
		gen graphlocus_p_r6_7 = graphlocus_log10p if inrange(rsquare,0.6,0.7)
		gen graphlocus_p_r7_8 = graphlocus_log10p if inrange(rsquare,0.7,0.8)
		gen graphlocus_p_r8_9 = graphlocus_log10p if inrange(rsquare,0.8,0.9)
		gen graphlocus_p_r9_1 = graphlocus_log10p if inrange(rsquare,0.9,1.0)
		}
	qui { // legend to r2 color
		gen graphlocus_p_s0_1 = . 
		gen graphlocus_p_s1_2 = . 
		gen graphlocus_p_s2_3 = .
		gen graphlocus_p_s3_4 = .
		gen graphlocus_p_s4_5 = .
		gen graphlocus_p_s5_6 = .
		gen graphlocus_p_s6_7 = .
		gen graphlocus_p_s7_8 = .
		gen graphlocus_p_s8_9 = .
		gen graphlocus_p_s9_1 = .
		}
		save graphlocus_assoc_r2_recombination_pre-graph.dta,replace
		}
qui { // 6 - plot genes
	graphgene, chr(${graphlocus_chr}) from(${graphlocus_lb}) to(${graphlocus_ub}) generef(`generef') save(yes)
	!del temp-graphgene.gph
	}
qui { // 7 - plot graph
	append using graphgene_pre-plot.dta
	replace order = -order
	replace order = order -2
	global graphlocus_legend_plot sort msymbol(S) msize(medium) mlwidth(vthin) mlc(gs0) ylabel(0(2)10)
	global graphlocus_log10p_plot sort msymbol(O)   mlwidth(vthin) mlc(gs0) ylabel(0(2)10)
	global graphlocus_index_plot sort  mlwidth(vthin) mlc(gs0) ylabel(0(2)10) 
	global graphlocus_spikes_plot sort lcolor(gs0) lwidth(vvthin) mlc(gs0) ylabel(0(2)10)
	colorscheme 9, palette(YlOrRd) 
	foreach color of num 1/9{
		global color`color' "`r(color`color')'"
		}	
	#delimit ;
	tw scatter graphlocus_p_s0_1 `bp', ${graphlocus_legend_plot} mcolor(white) 
	||scatter  graphlocus_p_s1_2 `bp', ${graphlocus_legend_plot} mcolor("$color1") 
	||scatter  graphlocus_p_s2_3 `bp', ${graphlocus_legend_plot} mcolor("$color2") 
	||scatter  graphlocus_p_s3_4 `bp', ${graphlocus_legend_plot} mcolor("$color3")
	||scatter  graphlocus_p_s4_5 `bp', ${graphlocus_legend_plot} mcolor("$color4") 
	||scatter  graphlocus_p_s5_6 `bp', ${graphlocus_legend_plot} mcolor("$color5")
	||scatter  graphlocus_p_s6_7 `bp', ${graphlocus_legend_plot} mcolor("$color6")
	||scatter  graphlocus_p_s7_8 `bp', ${graphlocus_legend_plot} mcolor("$color7")
	||scatter  graphlocus_p_s8_9 `bp', ${graphlocus_legend_plot} mcolor("$color8")
	||scatter  graphlocus_p_s9_1 `bp', ${graphlocus_legend_plot} mcolor("$color9") 
	||scatter  graphlocus_p_r0_1 `bp', ${graphlocus_log10p_plot} mcolor(white)     msize(small)
	||scatter  graphlocus_p_r1_2 `bp', ${graphlocus_log10p_plot} mcolor("$color1") msize(small)
	||scatter  graphlocus_p_r2_3 `bp', ${graphlocus_log10p_plot} mcolor("$color2") msize(small)
	||scatter  graphlocus_p_r3_4 `bp', ${graphlocus_log10p_plot} mcolor("$color3") msize(small)
	||scatter  graphlocus_p_r4_5 `bp', ${graphlocus_log10p_plot} mcolor("$color4") msize(small)
	||scatter  graphlocus_p_r5_6 `bp', ${graphlocus_log10p_plot} mcolor("$color5") msize(small)
	||scatter  graphlocus_p_r6_7 `bp', ${graphlocus_log10p_plot} mcolor("$color6") msize(small)
	||scatter  graphlocus_p_r7_8 `bp', ${graphlocus_log10p_plot} mcolor("$color7") msize(small)
	||scatter  graphlocus_p_r8_9 `bp', ${graphlocus_log10p_plot} mcolor("$color8") msize(small)
	||scatter  graphlocus_p_r9_1 `bp', ${graphlocus_log10p_plot} mcolor("$color9") msize(small)
	||scatter  graphlocus_p_r9_1 `bp' if `snp' == "`index'", ${graphlocus_index_plot} mcolor("107 174 214") msymbol(D) msize(large)
	||scatter  graphlocus_p_r9_1 `bp' if `snp' == "`index'", ${graphlocus_index_plot} mcolor(black) msymbol(o) msize(small) mlabel(`snp') mlabpos(11) mlabcolor(black) mlabsize(vsmall) 
	||rspike   graphlocus_uspike graphlocus_dspike `bp', ${graphlocus_spikes_plot}
	||rspike start end order , hor lcolor(green) lwidth(vvthin) 
	||rspike _txs _txe order , hor lcolor(green) lwidth(*4) 	
	||scatter order start if pos == 11  , msymbol(i) mlabel(symbol) mlabpos(11) mlabcolor(black) mlabsize(vsmall) 
	||scatter order end   if pos == 1   , msymbol(i) mlabel(symbol) mlabpos(1 ) mlabcolor(black) mlabsize(vsmall) 
		legend(region(lc(black)) order(10 "0.9" 9 "0.8" 8 "0.7" 7 "0.6" 6 "0.5" 5 "0.4" 4 "0.3" 3 "0.2" 2 "0.1" 1 "0.0" ) size(vsmall) rowgap(zero) symp(3) textfirst ring(0) bm(tiny) pos(11) row(10) subtitle("rsquare",size(vsmall)))
		xtitle(" ""Chromosome ${graphlocus_chr}", size(small)) xlabel(${graphlocus_lb} ${graphlocus_ub}, labs(small))
    ytitle(" ""              -log10 P-value", size(small))
    ytitle(" """, size(small))
		yline(5, lpattern(dash) lwidth(vthin) lcolor(orange))
		yline(7.3, lpattern(dash) lwidth(vthin) lcolor(red))
		yline(-1, lpattern(solid) lwidth(vthin) lcolor(black))
		ysize(5) xsize(10)
		fysize(150) fxsize(200)
		;
		#delimit cr
		noi di as text"# > graphlocus ......................... plotting data to "as result "temp-graphlocus.gph"
		noi di as text"# > graphlocus ............................. exporting to "as result "temp-graphlocus.png"
		graph save temp-graphlocus.gph, replace
		graph export temp-graphlocus.png, as(png) height(1000) width(3000) replace
		}
qui { // 8 - clean 
	!del graphgene_pre-plot.dta graphlocus*
	}
restore
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

   