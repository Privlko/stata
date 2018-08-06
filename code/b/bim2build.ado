/*
*program*
 bim2build

*description* 
 a command to check genome build from plink binaries

*syntax*
 bim2build, bim(-filename-) ref(-reference-)
 
 -filename- does not require the .bim filetype to be included - this is assumed
 -reference- download bim2build.dta from github.com/ricanney
*/

program bim2build
syntax , bim(string asis) ref(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2build"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2build ................... checking build of (bim) "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	noi di as text"# > bim2build .............. checking build against (ref) "as result"`ref'"
	noi checkfile, file(`ref')
	}
qui { // 2 - measure overlap
	qui { // import bim file
		noi di as text"# > bim2build .................................... import "as result"`bim'.bim"
		bim2dta, bim(`bim')
		erase `bim'_bim.dta
		keep snp chr bp
		}
	qui { // merge against reference 
		duplicates drop snp, force
		merge 1:1 snp using `ref'
		keep if _m == 3
		tostring bp, replace
		compress
		}
	qui { // measure overlap with reference
		foreach i in 17 18 19 { 
			gen hg`i'_0 = .
			gen hg`i'_1 = .
			replace hg`i'_0 = 1 if bp == hg`i'_chromStart 
			replace hg`i'_1 = 1 if bp == hg`i'_chromEnd 
			}		
		count
		gen all = `r(N)'
		foreach i in 17 18 19 { 
			foreach j in 0 1 { 
				sum hg`i'_`j'
				gen phg`i'_`j' = r(N) / all
				}
			}
		keep in 1
		keep phg17_0 - phg19_1
		xpose, clear v
		rename v1 percentMatched
		rename _v build
		replace build = "hg17 +0" if build == "phg17_0"
		replace build = "hg17 +1" if build == "phg17_1"
		replace build = "hg18 +0" if build == "phg18_0"
		replace build = "hg18 +1" if build == "phg18_1"
		replace build = "hg19 +0" if build == "phg19_0"
		replace build = "hg19 +1" if build == "phg19_1"
		gsort -p
		gen MostLikely = "+++" in 1
		replace MostLikely = "++" if p > 0.9 & MostLikely == ""
		replace MostLikely = "+" if p > 0.8 & MostLikely == ""
		}
	qui { // report findings 
		noi di as text"# > bim2build ................. build overlap reported in " as result"`bim'.bim2build"
		outsheet using `bim'.bim2build, replace noq	
		*graph hbar percentMatched , over(build,sort(percentMatched) lab(labs(large))) title("Percentage Match Genome Build") yline(.9, lcol(red))  
		*graph export `bim'.bim2build.png, as(png) height(1000) width(4000) replace
		*window manage close graph
		*noi di as text"# > bim2build .................. build overlap plotted to " as result"`bim'.bim2build.png"
		keep in 1 
		tostring per, replace force
		gen a = ""
		replace a = "global bim2build " + build
		outsheet a using _tmp.do, non noq replace
		do _tmp.do
		noi di as text"# > bim2build ........... build identified as " as result"${bim2build}"as text" for "as result"`bim'.bim"
		erase _tmp.do
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
