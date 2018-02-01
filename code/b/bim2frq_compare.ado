/*
*program*
 bim2frq_compare

*description* 
 command to compare allelel frequencies by reference using plink binaries 

*syntax*
 bim2frq_compare, bim(-filename-) ref(-reference-)
 
 -filenames- 	does not require the .bim filetype to be included - this is assumed
 -reference-	does not require the .bim filetype to be included - this is assumed
				this is the bim file that others are strand aligned
*/

program bim2frq_compare
syntax , bim(string asis) ref(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2frq_compare"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2frq_compare .... comparing allele frequencies for "as result"`bim'"
	noi checkfile, file(`bim'.bim)
	noi di as text"# > bim2frq_compare ................................ with "as result"`ref'"
	noi checkfile, file(`ref'.bim)
	checkfile, file(${plink})
	}
qui { // 2 - check _frq.dta are created / create
	capture confirm file `ref'_frq.dta 
	if !_rc {
		}
	else {
		noi di as text"# > bim2frq_compare ........... create frequency file for "as result"`ref'_frq.dta"
		bim2frq, bim(`ref')
		}
	capture confirm file `bim'_frq.dta 
	if !_rc {
		}
	else {
		noi di as text"# > bim2frq_compare ........... create frequency file for "as result"`bim'_frq.dta"
		bim2frq, bim(`bim')
		}
	}
qui { // 3 - merge frq files
	use `bim'_frq.dta, clear
	for var a1 a2 maf gt: rename X in_X
	merge 1:1 snp using `ref'_frq.dta
	keep if _m == 3
	for var a1 a2 maf gt: rename X ref_X
	drop _m
	}
qui { // 4 - drop incompatible genotypes and fix strand
		recodestrand, ref_a1(ref_a1) ref_a2(ref_a2) alt_a1(in_a1) alt_a2(in_a2) 
		replace in_a1 = _tmpb1 if _tmpflip == 1
		replace in_a2 = _tmpb2 if _tmpflip == 1
		keep snp in_a1 in_maf ref_a1 ref_maf
		replace in_maf = 1-in_maf if in_a1 != ref_a1
		}
qui { // 5 - plot comparison
	global format mlc(black) mfc(blue) mlw(vvthin) m(o) xtitle("allele-frequency-array") ytitle("allele-frequency-1000-genomes") ylabel(0(.1)1) xlabel(0(.1)1)
	tw scatter ref_maf in_maf , $format saving(bim2frq_compare-1.gph,replace) nodraw
	gen drop = .
	replace drop = 1 if in_maf > ref_maf + .1 
	replace drop = 1 if in_maf < ref_maf - .1  
	tw scatter ref_maf in_maf if drop == . , $format saving(bim2frq_compare-2.gph,replace) nodraw
	graph combine bim2frq_compare-1.gph bim2frq_compare-2.gph, ycommon 
	noi di as text"# > bim2frq_compare ............... comparison plotted to "as result"bim2frq_compare.png"
	graph export  bim2frq_compare.png, as(png) height(500) width(2000) replace
	window manage close graph
	noi di as text"# > bim2frq_compare ....... divergent markers reported in "as result"bim2frq_compare.exclude"
	outsheet snp if drop == 1 using bim2frq_compare.exclude, non noq replace
	erase bim2frq_compare-1.gph
	erase bim2frq_compare-2.gph
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
