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
		gen graphlocus_uspike = 100
		gen graphlocus_dspike = 110
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
		gen graphlocus_p_s0_1 = 2 if legend == 1
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
qui { // 7 - plot genes
	graphgene, chr(${graphlocus_chr}) start(${graphlocus_lb}) end(${graphlocus_ub}) ensembl(`generef')
	xchr
	noi di"...defining gene panel data for plots"
		qui { // create DUMMY gene data (for gene deserts)
				noi di"...create DUMMY gene data (for gene deserts)"
				clear
				set obs 1
				noi di"...create dummy file for gene deserts"
				gen name2 = "DUMMY"
				gen exonStarts = ${start}
				gen exonEnds   = ${end}	
				gen txStart = ${start}
				gen txEnd   = ${end}
				save tmpDUMMY.dta, replace
		
			}
		qui { // create REFGENE gene data
				noi di"...create REFGENE gene data"
				qui {
					use `refgene', clear
					keep name2 chrom strand txStart txEnd exonEnds exonStarts
					noi di"...selecting region"
					keep if chrom == ${chr}
					drop if txStart > ${end}
					drop if txEnd   < ${start}
					replace txStart =  ${start} if txStart < ${start}
					replace txEnd =  ${end} if txEnd > ${end}
					replace exonStarts = . if (exonStarts < $start & exonEnds < $start)
					replace exonEnds   = . if (exonStarts ==.)
					replace exonEnds   = . if (exonStarts > $end & exonEnds > $end)
					replace exonStarts  = . if (exonEnds ==.)
					replace name = name2
					append using tmpDUMMY.dta
					duplicates drop
					encode name2, gen(encode)
					sum encode
					global encmax `r(max)'
					di $encmax
					foreach i of num  $encmax / 1 {
						sum txStart if encode == `i'
						replace txStart = `r(min)' if encode == `i'
						sum txEnd if encode == `i'
						replace txEnd = `r(max)' if encode == `i'
						}
					drop encode 
					duplicates drop
					rename name2 name
					sort name	
					save tmpGENEcoords.dta, replace
					keep name
					duplicates drop
					sort name 
					save tmpGENEname.dta, replace
					}
				}
		qui { // adding eQTL data to refgene
				noi di"...adding eQTL data to refgene"
				use ${GWAS_eQTL_LCL}, clear
				gen CELL = "LCL"
				append using ${GWAS_eQTL_CNS}
				replace CELL = "CNS" if CELL ==  ""
				keep if CHR == ${chr} & inrange(BP, ${start}, ${end})
				rename GENESYMBOL name
				rename CHR chrom
				drop if QVALUE > 0.05 & QVALUE != .
				keep chrom BP SNP name TYPE CELL
				sort name	
				merge m:m name using tmpGENEname.dta
				replace TYPE = "TRANS" if _merge !=3
				drop if _merge == 2
				drop _merge
				append using tmpGENEcoords.dta
				save tmpGENEcoords_eQTL.dta, replace
				*/
				}
		qui { // defining the order to display genes
				noi di"...defining the order to display genes"
				use tmpGENEcoords_eQTL.dta,clear
				keep if (strand != "" | CELL != "")
				sort name txStart
				encode name, gen(Name)
				foreach j of num 1/100 {
					sum txStart if Name == `j'
					replace txStart = r(min) if Name == `j'
					sum txEnd if Name == `j'
					replace txEnd = r(max) if Name == `j'
					}
				duplicates drop
				sort name
				save tmp_x.dta,replace
				use  tmp_x.dta, clear
				keep if strand != "" 

				keep name txStart txEnd
				duplicates drop
				sort txStart
				local N = _N
				global tmp_split 100000	
				gen ORDER = .
				replace ORDER = 1 in 1
				sum txEnd
				foreach i of num 2 / `r(N)' {
					sum txEnd if ORDER == 1
					replace ORDER = 1 if txStart > (r(max) + ${tmp_split}) & _n == `i' & ORDER == .
					}
				foreach j of num 2/100 { 
					sort ORDER txStart
					egen x = seq(),by(ORDER)
					replace ORDER = `j' if ORDER == . & x == 1
					sum txEnd
					foreach i of num 2 / `r(N)' {
						sum txEnd if ORDER == `j'
						replace ORDER = `j' if txStart > (r(max) + ${tmp_split}) & _n == `i' & ORDER == .
						}
					drop x
					}	
				
				keep name ORDER
				sort name
				merge m:m name using tmp_x.dta
				drop _merge
				ta ORDER
								
					
				order ORDER
				sort ORDER txStart
				replace name = "zzzz eQTL" if TYPE == "TRANS"
				
				replace name = "zzzz eQTL" if TYPE == "TRANS"
					gen label = name + " [" + strand + "]"
					replace label = "" if TYPE != ""
					keep  ORDER name txStart txEnd exonStarts exonEnds strand label BP TYPE CELL 
					order ORDER name BP txStart txEnd exonStarts exonEnds strand label BP TYPE CELL 
					sum ORDER
					replace ORDER = `r(max)' + 2 if name == "zzzz eQTL"
					replace name = "eQTL" if name == "zzzz eQTL"
					sort ORDER exonStarts
					noi di"...adjust exon size for plotting purposes"
					qui {
						gen max = (${end} - ${start}) / 1000
						sum max
						global max `r(max)'
						gen exonSize = exonEnds - exonStarts
						gen exonMid  = exonStarts + (exonSize/2)
						replace exonStarts = exonMid - (${max} /2) if exonSize < ${max}
						replace exonEnds   = exonMid + (${max} /2) if exonSize < ${max}
						}
					keep  ORDER name txStart txEnd exonStarts exonEnds strand label BP TYPE CELL  
					order ORDER name BP txStart txEnd exonStarts exonEnds strand label BP TYPE CELL 
					save tmpGENEcoords_eQTL_label.dta, replace
				}
		}
	qui { // join data sets
		use tmpGENEcoords_eQTL_label.dta, replace
		append using tmpR2_recomb_density_byR2.dta
		save tmpASSOC_GENE.dta, replace
		}
	qui { // defining panel size
		noi di"...defining panel size"	
		use tmpASSOC_GENE.dta, replace
		noi di"...define spacer"
		qui {
			gen _tmp_spacer  = round(${start} + ((${end} - ${start})/2),1)
			sum _tmp_spacer
			global spacer `r(max)'
			drop _tmp_spacer
			}
		
		sum ORDER	
		gen a = ORDER * (10 / `r(max)')
		replace a = -2 - a
		egen x = seq(), by(label txStart)
		replace label = "" if x !=1 & txStart != .
		gen top = -15
		drop if name == "DUMMY"	
		noi di"...determine position of labels"
		gen labpos = txStart
		replace labpos = txEnd if txStart == ${start}
		replace labpos = ${start} + (${spacer}-${start}) if labpos == ${end}
		gen labpos2 = BP if BP != .
		gen mlabpos = 11
		replace mlabpos = 1 if labpos == txEnd
		replace mlabpos = 12 if labpos == ${end}
		}
	qui { // plot graph
		noi di "plotting graph"
		duplicates drop
		sum a
		gen b = r(min) * 13
		replace b = -160 if b > -160

		gen xy = .
		sum a
		replace a = r(min) -2 if TYPE != ""
				replace xy = a -1 if TYPE !=""
				replace txStart = . if TYPE != ""
				replace txEnd = . if TYPE != ""
				sum b
				
		#delimit ;
		twoway line recomb_rate _tmpbp, sort color(blue) lpattern(solid) yscale(range(`r(min)'(20)80)) ylabel(0 20 40 60 80, axis(1) labs(small))
		||scatter s000 _tmpbp, sort yaxis(2) msymbol(S) msize(medium) mcolor(white) 	mlwidth(vthin) mlc(gs0) ylabel(0(2)10, axis(2) labs(small))
		||scatter s020 _tmpbp, sort yaxis(2) msymbol(S) msize(medium) mcolor(ltblue) 	mlwidth(vthin) mlc(gs0)
		||scatter s040 _tmpbp, sort yaxis(2) msymbol(S) msize(medium) mcolor(lime)  	mlwidth(vthin) mlc(gs0)
		||scatter s060 _tmpbp, sort yaxis(2) msymbol(S) msize(medium) mcolor(yellow) 	mlwidth(vthin) mlc(gs0)
		||scatter s080 _tmpbp, sort yaxis(2) msymbol(S) msize(medium) mcolor(orange) 	mlwidth(vthin) mlc(gs0)
		||scatter s100 _tmpbp, sort yaxis(2) msymbol(S) msize(medium) mcolor(red) 		mlwidth(vthin) mlc(gs0)
		||scatter r000 _tmpbp, sort yaxis(2) msymbol(O) msize(vsmall) mcolor(white) 	mlwidth(vthin) mlc(gs0)
		||scatter	r020 _tmpbp, sort yaxis(2) msymbol(O) msize(small)  mcolor(ltblue)	mlwidth(vthin) mlc(gs0)
		||scatter r040 _tmpbp, sort yaxis(2) msymbol(O) msize(small)  mcolor(lime)  	mlwidth(vthin) mlc(gs0)
		||scatter r060 _tmpbp, sort yaxis(2) msymbol(O) msize(small)  mcolor(yellow)	mlwidth(vthin) mlc(gs0)
		||scatter r080 _tmpbp, sort yaxis(2) msymbol(O) msize(medium) mcolor(orange)	mlwidth(vthin) mlc(gs0)
		||scatter r100 _tmpbp, sort yaxis(2) msymbol(O) msize(medium) mcolor(red)   	mlwidth(vthin) mlc(gs0)
		||scatter ridx _tmpbp, sort yaxis(2) msymbol(D) msize(large)  mcolor(purple)	mlwidth(vthin) mlc(gs0)          
		||scatter ridx _tmpbp, sort yaxis(2) msymbol(o) msize(small)  mcolor(black) 	mlwidth(vthin) mlc(gs0)          
		||rspike uspike dspike _tmpbp , sort lcolor(gs0) lwidth(vvthin) mlc(gs0)
		||rspike  a xy labpos2 if CELL == "LCL",   yaxis(2)sort lcolor(blue) lwidth(thin) mlc(blue)
		||scatter a   labpos2 if TYPE == "CIS"   & CELL == "LCL", yaxis(2) msymbol(T) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(blue) mlc(black) mlw(vthin)
		||scatter a   labpos2 if TYPE == "TRANS" & CELL == "LCL", yaxis(2) msymbol(d) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(blue) mlc(black) mlw(vthin)
		||rspike  a xy labpos2 if CELL == "CNS" ,  yaxis(2)sort lcolor(red) lwidth(thin) mlc(red)
		||scatter a   labpos2 if TYPE == "CIS"   & CELL == "CNS", yaxis(2) msymbol(T) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(red) mlc(black) mlw(vthin)
		||scatter a   labpos2 if TYPE == "TRANS" & CELL == "CNS", yaxis(2) msymbol(d) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(red) mlc(black) mlw(vthin)				||rspike txStart txEnd a , yaxis(2) hor lcolor(green) lwidth(thin) 
		||rspike exonStarts exonEnds a,  yaxis(2) hor lcolor(green) lwidth(vvthick) 	
		||scatter a   labpos if mlabpos == 1, yaxis(2) msymbol(i) mlabel(label) mlabpos(3) mlabcolor(black) mlabsize(tiny)
		||scatter a   labpos if mlabpos == 11, yaxis(2) msymbol(i) mlabel(label) mlabpos(9) mlabcolor(black) mlabsize(tiny)
		||scatter a   labpos if mlabpos == 12, yaxis(2) msymbol(i) mlabel(label) mlabpos(12) mlabcolor(black) mlabsize(tiny)
		||scatter a   labpos2 if TYPE == "CIS"   & CELL == "CNS", yaxis(2) msymbol(T) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(red) mlc(black) mlw(vthin)
		||scatter a   labpos2 if TYPE == "TRANS" & CELL == "CNS", yaxis(2) msymbol(D) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(red) mlc(black) mlw(vthin)
		||scatter a   labpos2 if TYPE == "CIS"   & CELL == "LCL", yaxis(2) msymbol(T) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(blue) mlc(black) mlw(vthin)
		||scatter a   labpos2 if TYPE == "TRANS" & CELL == "LCL", yaxis(2) msymbol(D) mlabel(label) mlabpos(0) mlabcolor(black) mlabsize(vsmall) mfc(blue) mlc(black) mlw(vthin)
		||scatter top labpos , yaxis(2) msymbol(i) mlabpos(9) 
		legend(region(lc(black)) order(8 "1.0" 7 "0.8" 6 "0.6" 5 "0.4" 4 "0.2" 3 "0" ) size(vsmall) rowgap(zero) symp(3) textfirst ring(0) bm(tiny) pos(11) row(6) subtitle("r2",size(vsmall)))
		xtitle(" ""Chromosome ${chr}", size(small)) xlabel(${start} ${spacer} ${end}, labs(small))
		ytitle("             Recombination Rate (cM/Mb)"" ", axis(1) size(small)) ytitle(" ""             -log10 P-value", axis(2) size(small))
		yline(5, axis(2) lpattern(dash) lwidth(vthin) lcolor(orange))
		yline(7.3, axis(2) lpattern(dash) lwidth(vthin) lcolor(red))
		yline(-1,  axis(2) lpattern(solid) lwidth(vthin) lcolor(black))
		ysize(5) xsize(10)
		fysize(150) fxsize(200)
		;
		#delimit cr
		graph save tmplocus.gph, replace
		}
	restore
	qui { // clean up
		!del _tmp*
		foreach i in ASSOC_GENE DUMMY eQTL GENE R2 SNPs _x{
			!del tmp`i'*
			}
		}
	}
	noi di "done!"
	end;
   
  
rename variables
		rename `chr' _tmpchr
		rename `bp'  _tmpbp
		rename `p'   _tmpp
		rename `snp' _tmpsnp
		replace      _tmpp  = -log10(_tmpp)
		keep _tmpchr _tmpbp _tmpp _tmpsnp
		}