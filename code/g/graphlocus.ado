/*
*program*
 graphlocus

*description* 
 command to plot a locus plot 

*syntax*
 graphlocus, index(-index-) snp(-snp-) chr(-chr-) bp(-bp-) p(-p-) ldref(-ldref-) recombref(-recombref-) generef(-generef-) [maxp(-maxp-) gwsp(-gwsp-) winkb(-winkb-)]
 
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
 -winkb-        window to plot (in kb)
 
*/

program graphlocus
syntax , index(string asis) snp(string asis) chr(string asis) bp(string asis) p(string asis) ldref(string asis) recombref(string asis) generef(string asis) [maxp(real 10) gwsp(real 7.3) win_kb(real 500)]

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
	noi checkfile, file(`recombref')
	noi checkfile, file(`generef')
	}
qui { // 2 - define window and globals
	gen graphlocus_window = `winkb' +10
	sum graphlocus_window
	global graphlocus_window `r(max)'
	gen graphlocus_lb = round(${graphlocus_bp} - ${graphlocus_window}000,100)
	replace graphlocus_lb = 0 if graphlocus_lb < 0
	gen graphlocus_ub = round(${graphlocus_bp} + ${graphlocus_window}000,100)
	sum graphlocus_lb
	global graphlocus_lb `r(max)'
	sum graphlocus_ub
	global graphlocus_ub `r(max)'
	global graphlocus_spacer (${graphlocus_ub} - ${graphlocus_lb})/2
	drop graphlocus_window graphlocus_lb graphlocus_ub
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
		!$plink `ldref' --extract graphlocus_assoc.extract --allow-no-sex --r2 --ld-window-kb `window' --ld-window 99999 --ld-window-r2 0 --ld-snp `index' --out graphlocus_ld
		}
	else {
		!$plink `ldref' --extract graphlocus_assoc.extract --allow-no-sex --r2 --ld-xchr 1 --ld-window-kb `window' --ld-window 99999 --ld-window-r2 0 --ld-snp `index' --out graphlocus_ld
		}
	!$tabbed graphlocus_ld.ld
	import delim using graphlocus_ld.ld.tabbed, varnames(1) clear
	keep snp_b r2
	rename (snp_b r2) (`snp' rsquare)
	merge 1:1 `snp' _tmpsnp using graphlocus_assoc.dta
	keep `snp' `chr' `bp' `p' rsquare
	replace rsquare = 1 if `snp' == "`index'" 
	save graphlocus_assoc_r2.dta,replace
	}
qui { // 5 - add recombination rate
		use `recombref', clear
		rename (chr bp recomb) (v1 v2 v3)
		rename (v1 v2 v3) (`chr' `bp' recombination_rate)
		keep if `chr' == ${graphlocus_chr}
		drop if `bp' < ${graphlocus_lb}
		drop if `bp' > ${graphlocus_ub}
		append using graphlocus_assoc_r2.dta
		save graphlocus_assoc_r2_recombination.dta,replace
		}
qui { // 6 - add plotting variables	
	qui { // snp density
		gen graphlocus_uspike = `maxp' + 2
		gen graphlocus_dspike = `maxp' + 4
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
		egen legend = seq(),by(rsquare)
		replace legend = . if rsquare != .
		replace legend = . if legend > 10
		gen graphlocus_p_s0_1 = `maxp' -2 if legend == 1
		gen graphlocus_p_s1_2 = 2 if legend == 2
		gen graphlocus_p_s2_3 = 2 if legend == 3
		gen graphlocus_p_s3_4 = 2 if legend == 4
		gen graphlocus_p_s4_5 = 2 if legend == 5
		gen graphlocus_p_s5_6 = 2 if legend == 6
		gen graphlocus_p_s6_7 = 2 if legend == 7
		gen graphlocus_p_s7_8 = 2 if legend == 8
		gen graphlocus_p_s8_9 = 2 if legend == 9
		gen graphlocus_p_s9_1 = 2 if legend == 10
		}
		save graphlocus_assoc_r2_recombination_pre-graph.dta,replace
		}
qui { // 7 - plot graph
	gen top = 0
	global graphlocus_recomb_plot sort color(blue) lpattern(solid) yscale(range(0(20)80)) ylabel(0 20 40 60 80, axis(1) labs(small))
	global graphlocus_legend_plot sort yaxis(2) msymbol(S) msize(medium) mlwidth(vthin) mlc(gs0) ylabel(0(2)10, axis(2) labs(small))
	global graphlocus_log10p_plot sort yaxis(2) msymbol(O) msize(small)  mlwidth(vthin) mlc(gs0) ylabel(0(2)10, axis(2) labs(small))
	global graphlocus_spikes_plot sort lcolor(gs0) lwidth(vvthin) mlc(gs0) ylabel(0(2)10, axis(2) labs(small))
	global graphlocus_spikes_plot sort lcolor(gs0) lwidth(vvthin) mlc(gs0) ylabel(0(2)10, axis(2) labs(small))
	colorscheme 9, palette(YlOrRd) display
	#delimit ;
	twoway line recomb `bp', ${graphlocus_recomb_plot}
	||scatter graphlocus_p_r0_1 `bp', ${graphlocus_log10p_plot} mcolor(white) 
	||scatter graphlocus_p_r1_2 `bp', ${graphlocus_log10p_plot} mcolor(`r(color1)') 
	||scatter graphlocus_p_r2_3 `bp', ${graphlocus_log10p_plot} mcolor(`r(color2)') 
	||scatter graphlocus_p_r3_4 `bp', ${graphlocus_log10p_plot} mcolor(`r(color3)')
	||scatter graphlocus_p_r4_5 `bp', ${graphlocus_log10p_plot} mcolor(`r(color4)') 
	||scatter graphlocus_p_r5_6 `bp', ${graphlocus_log10p_plot} mcolor(`r(color5)') 
	||scatter graphlocus_p_r6_7 `bp', ${graphlocus_log10p_plot} mcolor(`r(color6)') 
	||scatter graphlocus_p_r7_8 `bp', ${graphlocus_log10p_plot} mcolor(`r(color7)')
	||scatter graphlocus_p_r8_9 `bp', ${graphlocus_log10p_plot} mcolor(`r(color8)') 
	||scatter graphlocus_p_r9_1 `bp', ${graphlocus_log10p_plot} mcolor(`r(color9)')     
	||rspike  graphlocus_uspike graphlocus_dspike `bp', ${graphlocus_spikes_plot})
	||scatter top `bp' , yaxis(2) msymbol(i) mlabpos(9) 
		legend(region(lc(black)) order(11 "0.9" 10 "0.8" 9 "0.7" 8 "0.6" 7 "0.5" 6 "0.4" 5 "0.3" 4 "0.2" 3 "0.1" 2 "0.0" ) ///
		size(vsmall) rowgap(zero) symp(3) textfirst ring(0) bm(tiny) pos(11) row(6) subtitle("r2",size(vsmall)))
		xtitle(" ""Chromosome ${graphlocus_chr}", size(small)) xlabel(${graphlocus_lb} ${graphlocus_spacer} ${graphlocus_ub}, labs(small))
		ytitle("             Recombination Rate (cM/Mb)"" ", axis(1) size(small)) ytitle(" ""             -log10 P-value", axis(2) size(small))
		yline(5, axis(2) lpattern(dash) lwidth(vthin) lcolor(orange))
		yline(7.3, axis(2) lpattern(dash) lwidth(vthin) lcolor(red))
		ysize(5) xsize(10)
		fysize(150) fxsize(200)
		;
		#delimit cr
		graph save graphlocus_assoc.gph, replace
		}
qui { // 8 - plot genes
	graphgene, chr(${graphlocus_chr}) from(${graphlocus_lb}) to(${graphlocus_ub}) generef(`generef')
	graph combine graphlocus_assoc.gph temp-graphgene.gph
	x
	}
	restore
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

   