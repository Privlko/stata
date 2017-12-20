/*
#########################################################################
# graphmiami
# a command to create a publication quality miami plot from overlapping regions of a gwas 
# assumes both input files have rsid and p as outcome variable
# 
# command: graphmiami, gwas1() gwas2() title1() title2() hg19()
# options: 
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

program graphmiami
syntax , gwas1(string asis) gwas2(string asis) title1(string asis) title2(string asis) region(string asis) exons(string asis) ref(string asis)

qui di as text"#########################################################################"
qui di as text"# graphmiami - version 1.0 04Aug2016 richard anney                      #"
qui di as text"#########################################################################"
qui di as text"# A command to create a publication quality miami plot from overlapping #"
qui di as text"# regions of a gwas.                                                    #"
qui di as text"# The program assumes both input files have rsid and p as outcome       #"
qui di as text"# variable.                                                             #"
qui di as text"#                                                                       #"
qui di as text"# titles for each gwas can be added                                     #"
qui di as text"# exon locations are derived from Homo_sapiens.GRCh37.87.gtf_exon.dta   #"
qui di as text"# Homo_sapiens.GRCh37.87.gtf_exon.dta created using                     #"
qui di as text"# https://github.com/ricanney/stata/blob/master/code/get-ensembl-gtf.do #"
qui di as text"#                                                                       #"
qui di as text"# region to plot format is bed format: chr#:start-end                 #"
qui di as text"#                                                                       #"
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

qui di as text"# > checking location of files"
qui {
	noi checkfile, file(`gwas1')
	noi checkfile, file(`gwas2')
	noi checkfile, file(`exons')
	noi checkfile, file(`ref')
	}
qui di as text"# > setting region to plot"
qui { 
	clear
	set obs 1
	gen a = "`region'"
	split a,p("chr"":""-")
	keep a2-a4
	for var a2 - a4: destring X,replace
	sum a2
	global chr `r(max)'
	sum a3
	global start `r(max)'
	sum a4
	global stop `r(max)'
	noi di as text"# > "as input"graphmiami"as text" ........................... plot region to "as result"chr${chr}:${start}-${stop}"
	}
qui di as text"# > plot genes in region"
qui { 
	noi graphgene, chr(${chr}) start(${start}) end(${stop}) gene_file(`exons')
	}
qui di as text"# > load/limit reference"
qui { 
	use `ref', clear
	keep if chr == ${chr}
	drop if bp < ${start}
	drop if bp > ${stop}
	rename snp rsid
	keep rsid chr bp
	rename (chr bp) (chr_ bp_)
	}
qui di as text"# > merge rsid and p from `gwas1'"
qui { 
	merge 1:1 rsid using `gwas1'
	keep if _m == 3
	gen gwas1_log10p = -log10(p)
	keep rsid chr_ bp_ gwas1_log10p
	}
qui di as text"# > merge rsid and p from `gwas2'"
qui {
	merge 1:1 rsid using `gwas2'
	keep if _m == 3
	gen gwas2_log10p = -log10(p)
	keep rsid chr_ bp_ gwas1_log10p gwas2_log10p
	}
qui di as text"# > plot regions to tmpMiami.gph"
qui { 
	append using temp-graphgene-data.dta
	for var gwas1_log10p : replace X = 15  if X > 15
	for var gwas2_log10p : replace X = -15 if X < -15
	for var gwas2_log10p : replace X = X -20
	sum order
	gen _x = 15/(`r(max)'+1)
	replace order = (order * _x) - _x
	sum order
	replace order = order -4 -`r(max)'
	sort bp
	gen dx_1 = "`title1'" in 1 
	gen dx_2 = "`title2'" in 1 
	gen dx_1p = 15
	gen dx_2p = -35
	tw scatter gwas1_log10p bp, mfc("107 174 214") mlc("107 174 214") m(O)  ///
	|| scatter gwas2_log10p bp, mfc("203 024 029") mlc("0203 024 029")  m(O) ///
	|| scatter dx_1p bp, m(none) mlabel(dx_1) mlabpos(3) mlabcolor(black)   ///
	|| scatter dx_2p bp, m(none) mlabel(dx_2) mlabpos(3) mlabcolor(black)   ///
	|| rspike start end order , hor lcolor("035 139 069") lwidth(vvthin) ///
	|| rspike _txs _txe order , hor lcolor("035 139 069") lwidth(*10) ///
	|| scatter order start if pos == 11  , msymbol(i) mlabel(symbol) mlabpos(11) mlabcolor(black) mlabsize(vsmall) 			///
	|| scatter order end   if pos == 1   , msymbol(i) mlabel(symbol) mlabpos(1 ) mlabcolor(black) mlabsize(vsmall)      ///
	ylab(-35"15" -30"10" -25"5" -20"0" 0"0" 5"5" 10"10" 15"15" ) legend(off) ytitle("-log10(P)") xtitle("Chromosome ${chr}") yline(7.2) yline(-27.2) nodraw saving(tmpMiami.gph, replace)
	}
qui di as text"# > cleaning"
qui {
	erase temp-graphgene.gph
	erase temp-graphgene-data.dta
	}
clear 
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
