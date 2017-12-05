/*
#########################################################################
# bim2hapmap
# a command to use plink-format genotype files to plot againsts hapmap 
# ancestries and define ancestral similarities to a defined hapmap set
#
# populations to compare against include;
# ASW LWK MKK YRI CEU TSI MEX GIH CHB CHD JPT
#
# command: bim2hapmap, bim(<FILENAME>) hapmap(hapmap genotypes) aims(ancestry informative markers file) like(ancestry list)
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program bim2hapmap
syntax , bim(string asis) like(string asis) hapmap(string asis) aims(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2hapmap - version 0.1a 05dec2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to use plink-format genotype files to plot againsts hapmap"
qui di as text"# ancestries and define ancestral similarities to a defined hapmap set"
qui di as text"#"
qui di as text"# populations to compare against include;"
qui di as text"# ASW LWK MKK YRI CEU TSI MEX GIH CHB CHD JPT"
qui di as text"#"
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
noi checkfile, file(${plink})
noi checkfile, file(`bim'.bim)
noi checkfile, file(`bim'.bed)
noi checkfile, file(`bim'.fam)
noi checkfile, file(`hapmap'.bim)
noi checkfile, file(`hapmap'.bed)
noi checkfile, file(`hapmap'.fam)
noi checkfile, file(`hapmap'.population)
noi checkfile, file(`aims')

qui di as text"# > limit genotype files to allele informative markers"
qui { 
	!$plink --bfile `bim'    --extract `aims' --make-founders --make-bed --out _test
	!$plink --bfile `hapmap' --extract `aims' --make-founders --make-bed --out _hapmap
	}
qui di as text"# > align _test_ to _hapmap_strand"
qui { 
	qui di as text"# >> merge bim files"
	qui {
		bim2dta, bim(_test)
		keep snp a1 a2 gt
		rename (a1 a2 gt) (_test_a1 _test_a2 _test_gt)
		save _test_bim.dta,replace
		bim2dta, bim(_hapmap)
		keep snp a1 a2 gt
		rename (a1 a2 gt) (_hapmap_a1 _hapmap_a2 _hapmap_gt)
		merge 1:1 snp using _test_bim.dta
		keep if _m == 3
		keep snp _test_a1 _test_a2 _test_gt _hapmap_a1 _hapmap_a2 _hapmap_gt
		}
	qui di as text"# >> drop incompatible genotypes"
	qui {
		foreach gt in S W ID A B C D DI {
			for var _hapmap_gt _test_gt: drop if X == "`gt'"
			}
		drop if _hapmap_gt == "K" & _test_gt =="R"
		drop if _hapmap_gt == "K" & _test_gt =="Y"
		drop if _hapmap_gt == "M" & _test_gt =="R"
		drop if _hapmap_gt == "M" & _test_gt =="Y"
		drop if _hapmap_gt == "R" & _test_gt =="K"
		drop if _hapmap_gt == "R" & _test_gt =="M"
		drop if _hapmap_gt == "Y" & _test_gt =="K"
		drop if _hapmap_gt == "Y" & _test_gt =="M"	
		outsheet snp                           using overlap.extract, non noq replace
		outsheet snp if _hapmap_gt != _test_gt using _test.flip, non noq replace
		}
	qui di as text"# >> flip/ merge datasets"
	qui {	
		!$plink --bfile _test --flip _test.flip --make-founders --extract overlap.extract --make-bed --out  _test_flip_intersect
		!$plink --bfile _hapmap                   --make-founders --extract overlap.extract --make-bed --out  _hapmap_intersect
		!$plink --bfile _test_flip_intersect --bmerge _hapmap_intersect.bed _hapmap_intersect.bim _hapmap_intersect.fam  --make-bed --out _combined
		}
	qui di as text"# >> calculate eigenvec/ eigenval"
	qui { 
		bim2eigenvec, bim(_combined)
		}
		
		
	}
qui di as text"# > plot scree of eigenvalues"
qui { 
	use _combined_eigenval.dta,clear
	twoway scatter eigenval pc, xtitle("Principle Components") connect(l) xlabel(1(1)10) mfc(red) mlc(black) mlw(vthin) ms(O) saving(_combined_eigenval-scree.gph, replace) nodraw
	}
qui di as text"# > plot eigenvectors"
qui {
	qui di as text"# >> define legend"
	qui { 
		clear
		set obs 25
		egen x = seq(),block(5)	
		egen y = seq(),by(x)
		gen POPULATION = ""
		replace POPULATION = "Test (European)"     if x == 1 & y == 5
		replace POPULATION = "Test (non-European)" if x == 3 & y == 5
		replace POPULATION = "ASW"                 if x == 1 & y == 4
		replace POPULATION = "LWK"                 if x == 2 & y == 4
		replace POPULATION = "MKK"                 if x == 3 & y == 4
		replace POPULATION = "YRI"                 if x == 4 & y == 4
		replace POPULATION = "CEU"                 if x == 1 & y == 3
		replace POPULATION = "TSI"                 if x == 2 & y == 3
		replace POPULATION = "MEX"                 if x == 1 & y == 2
		replace POPULATION = "GIH"                 if x == 2 & y == 2
		replace POPULATION = "CHB"                 if x == 1 & y == 1
		replace POPULATION = "CHD"                 if x == 2 & y == 1
		replace POPULATION = "JPT"                 if x == 3 & y == 1
		replace POPULATION = " "                   if x == 5 & y == 5
		}
	qui di as text"# >> define plot colors"
	qui {
		global format msiz(medlarge) msymbol(S) mlc(black) mlabel(POP) mlabposition(3) mlabsize(medium) mlw(vvthin)
		colorscheme 8, palette(Blues) 
		global ceu mfcolor("`=r(color8)'")
		global tsi mfcolor("`=r(color4)'")
		colorscheme 8, palette(Oranges) 
		global chb mfcolor("`=r(color8)'")
		global chd mfcolor("`=r(color6)'")
		global jpt mfcolor("`=r(color4)'")
		colorscheme 8, palette(Purples) 
		global mex mfcolor("`=r(color8)'")
		global gih mfcolor("`=r(color6)'")			
		colorscheme 8, palette(Greens) 
		global yri mfcolor("`=r(color8)'")
		global lwk mfcolor("`=r(color7)'")
		global mkk mfcolor("`=r(color6)'")			
		global asw mfcolor("`=r(color5)'")
		global test1 mfcolor(red)
		global test2 mfcolor(gs8)	
		}
	qui di as text"# >> plot legend"
	qui { 
		tw scatter y x if POP == "Test (European)" ,     $format $test1  ///
		|| scatter y x if POP == "Test (non-European)" , $format $test2  ///  
		|| scatter y x if POP == "ASW"                 , $format $asw  ///
		|| scatter y x if POP == "LWK"                 , $format $lwk  ///
		|| scatter y x if POP == "MKK"                 , $format $mkk  ///
		|| scatter y x if POP == "YRI"                 , $format $yri  ///
		|| scatter y x if POP == "CEU"                 , $format $ceu  ///
		|| scatter y x if POP == "TSI"                 , $format $tsi  ///
		|| scatter y x if POP == "MEX"                 , $format $mex  ///	
		|| scatter y x if POP == "GIH"                 , $format $gih  ///
		|| scatter y x if POP == "CHB"                 , $format $chb  ///
		|| scatter y x if POP == "CHD"                 , $format $chd  ///
		|| scatter y x if POP == "JPT"                 , $format $jpt  ///
		|| scatter y x if POP == " "                   , msymbol(none)                   ///
			legend(off) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank)) 
			graph save legend.gph, replace
			window manage close graph
			}	
	qui di as text"# >> import eigenvecs "
	qui { 
		import delim using "`hapmap'.population", clear case(lower)
		merge 1:1 fid iid using _combined_eigenvec.dta
		replace pop = "TEST" if pop == ""
		}
	qui di as text"# >> define individuals as -like- "
	qui { 
		count if pop == "TEST"
		noi di as text"# > "as result `r(N)' as text" test samples included in analysis"
		gen like = .
		foreach i in `like'  {
			replace like = 1 if pop =="`i'"
			}
		foreach i of num 1/3 {
			gen nr`i' = .
			sum pc`i' if (like == 1)
			gen min = r(mean) - 2*r(sd)
			gen max = r(mean) + 2*r(sd)
			foreach j in min max {
					sum `j'
					global pc`i'`j' `r(mean)'
					di" `j' bounds of pc`i' == ${pc`i'`j'}"
					drop `j'
					}
			replace nr`i' = 1 if  pc`i' < ${pc`i'max} & pc`i' > ${pc`i'min}
			}
		replace pop = "nr" if pop == "TEST" & nr1 == 1 & nr2 == 1 & nr3 == 1
		count if pop == "nr"
		noi di as text"# > "as result `r(N)' as text" test samples defined as "as result"`like'"
		gen a = "`like'"
		replace  a = subinstr(a, " ", "_",.)
		replace  a = subinstr(a, " ", "_",.)
		replace  a = subinstr(a, " ", "_",.)
		replace  a = subinstr(a, " ", "_",.)
		replace a = "global like " + a
		outsheet a in 1 using _temp_.do, non noq replace
		do _temp_.do
		erase _temp_.do
		outsheet fid iid if pop == "nr" using bim2hapmap_${like}-like.keep, non noq replace
		}
	qui di as text"# >> plot eigenvecs against all reference ancestries"
	qui {  
		global format "msiz(large) msymbol(o) mlc(black) mlw(vvthin)"
		foreach i of num 1/3 { 
			foreach j of num 1/3 { 
				tw scatter pc`j' pc`i' if pop == "ASW" ,  $format $asw ///
				|| scatter pc`j' pc`i' if pop == "LWK" ,  $format $lwk ///
				|| scatter pc`j' pc`i' if pop == "MKK" ,  $format $mkk ///
				|| scatter pc`j' pc`i' if pop == "YRI" ,  $format $yri ///
				|| scatter pc`j' pc`i' if pop == "CEU" ,  $format $ceu ///
				|| scatter pc`j' pc`i' if pop == "TSI" ,  $format $tsi ///
				|| scatter pc`j' pc`i' if pop == "MEX" ,  $format $mex ///	
				|| scatter pc`j' pc`i' if pop == "GIH" ,  $format $gih ///
				|| scatter pc`j' pc`i' if pop == "CHB" ,  $format $chb ///
				|| scatter pc`j' pc`i' if pop == "CHD" ,  $format $chd ///
				|| scatter pc`j' pc`i' if pop == "JPT" ,  $format $jpt ///
				|| scatter pc`j' pc`i' if pop == "TEST",  $format $test2 ///
				|| scatter pc`j' pc`i' if pop == "nr", $format $test1 ///
					 legend(off) saving(_cpc`j'pc`i'.gph, replace) ///
					 yline(${pc`j'max}, lw(.1) lc(black) lp(solid)) ///
					 yline(${pc`j'min}, lw(.1) lc(black) lp(solid)) ///
					 xline(${pc`i'max}, lw(.1) lc(black) lp(solid)) ///
					 xline(${pc`i'min}, lw(.1) lc(black) lp(solid)) nodraw
					}
				}
			graph combine _combined_eigenval-scree.gph  _cpc1pc2.gph _cpc1pc3.gph _cpc2pc3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
			graph export  bim2hapmap_pca.png, height(2500) width(8000) replace
			window manage close graph
			}
	qui di as text"# >> plot eigenvecs against all reference ancestries (like-focus)"
	qui { 
		foreach i of num 1/3{
			sum pc`i' if like == 1 
			drop if pc`i' > (r(mean) + 6*r(sd)) 
			drop if pc`i' < (r(mean) - 6*r(sd))
			}
		foreach i of num 1/3 { 
			foreach j of num 1/3 { 
				tw scatter pc`j' pc`i' if pop == "ASW" ,  $format $asw ///
				|| scatter pc`j' pc`i' if pop == "LWK" ,  $format $lwk ///
				|| scatter pc`j' pc`i' if pop == "MKK" ,  $format $mkk ///
				|| scatter pc`j' pc`i' if pop == "YRI" ,  $format $yri ///
				|| scatter pc`j' pc`i' if pop == "CEU" ,  $format $ceu ///
				|| scatter pc`j' pc`i' if pop == "TSI" ,  $format $tsi ///
				|| scatter pc`j' pc`i' if pop == "MEX" ,  $format $mex ///	
				|| scatter pc`j' pc`i' if pop == "GIH" ,  $format $gih ///
				|| scatter pc`j' pc`i' if pop == "CHB" ,  $format $chb ///
				|| scatter pc`j' pc`i' if pop == "CHD" ,  $format $chd ///
				|| scatter pc`j' pc`i' if pop == "JPT" ,  $format $jpt ///
				|| scatter pc`j' pc`i' if pop == "TEST",  $format $test2 ///
				|| scatter pc`j' pc`i' if pop == "nr", $format $test1 ///
					 legend(off) saving(_cpc`j'pc`i'.gph, replace) ///
					 yline(${pc`j'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
					 yline(${pc`j'min}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
					 xline(${pc`i'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
					 xline(${pc`i'min}, lsty(refline) lw(.1) lc(black) lp(solid)) nodraw
					}
				}
		graph combine _combined_eigenval-scree.gph  _cpc1pc2.gph _cpc1pc3.gph _cpc2pc3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
		graph export  bim2hapmap_pca-${like}-like.png, height(2500) width(8000) replace
		window manage close graph
			}
	}
	
qui di as text"# > clean files"
qui {
	foreach i of num 1/3 {
		foreach j of num 1/3 {
			erase _cpc`i'pc`j'.gph
			}
		}
	!del _combined*
	!del _hapmap*
	!del _test*
	erase legend.gph
	erase overlap.extract
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
