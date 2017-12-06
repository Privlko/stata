/*
#########################################################################
# bim2build
# a command to create check genome build from plink binaries
#
# command: bim2build, bim(<FILENAME>) build_ref(<FILENAME>)
# notes: the filename does not require the .bim to be added
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       04dec2017
# #########################################################################
*/

program bim2build
syntax , bim(string asis) build_ref(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2build - version 0.1a 04dec2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to create check genome build from plink binaries "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
noi checkfile, file(`bim'.bim)
noi checkfile, file(`build_ref')
qui {
	bim2dta, bim(`bim')
	erase `bim'_bim.dta
	rename snp rsid
	keep rsid chr bp
	duplicates drop rsid, force
	sort rsid
	merge 1:1 rsid using `build_ref'
	keep if _m == 3
	tostring bp, replace	
	gen hg17_0 = 1 if bp == hg17_chromStart 
	gen hg17_1 = 1 if bp == hg17_chromEnd 
	gen hg18_0 = 1 if bp == hg18_chromStart 
	gen hg18_1 = 1 if bp == hg18_chromEnd 
	gen hg19_0 = 1 if bp == hg19_chromStart 
	gen hg19_1 = 1 if bp == hg19_chromEnd 
	sum chr
	gen all = r(N)
	foreach i in 17_0 17_1 18_0 18_1 19_0 19_1 {
			sum hg`i'
			gen phg`i' = r(N) / all
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
	outsheet using `bim'.hg-buildmatch, replace noq	
	graph hbar percentMatched , over(build,sort(percentMatched) lab(labs(large))) title("Percentage Match Genome Build") yline(.9, lcol(red))  
	graph export `bim'.hg-buildmatch.png, as(png) height(1000) width(4000) replace
	window manage close graph
	keep in 1 
	tostring per, replace force
	gen a = ""
	replace a = "global buildType " + build
	outsheet a using _tmp.do, non noq replace
	do _tmp.do
	noi di as input"# > bim2build "as text"... " as result"${buildType} ......... "as text"`bim'.bim"
	erase _tmp.do
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
