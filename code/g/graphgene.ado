/*
#########################################################################
# graphgene
# a command to plot gene based on an input of gene locations
#
# command: graphgene, chr(string asis) start(string asis) end(string asis) ensembl(string asis) 
#
#########################################################################
# additional files
# this file requires the Homo_sapiens.GRCh37.87.gtf_exon.dta file 
# this can be created using the code stata/code/get-ensembl-gtf.do
#
#########################################################################

#########################################################################
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 7th September 2017
#########################################################################
*/

program graphgene
syntax  ,  chr(string asis) start(string asis) end(string asis) gene_file(string asis) 

qui { // introduce program
	qui di as text"#########################################################################"
	qui di as text"# graphgene                                                              "
	qui di as text"# version:       1.0                                                     "
	qui di as text"# Creation Date: 7th September 2017                                      "
	qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
	qui di as text"#########################################################################"
	qui di as text"# Note:       The genome build is based on the ensembl gene-location file"
	qui di as text"#########################################################################"
	qui di as text""
	}
qui { // check file dependencies
	qui di as text"# checking ensembl gene-location file;"
	noi checkfile, file(`gene_file')
	}
qui { // display region to plot
	qui di as text "# This script will plot genes on chromosome `chr': from `start' to `end'"
	}
qui { // create DUMMY gene data (for gene deserts)
	qui di as text"# > create DUMMY gene data (for gene deserts)"
	clear
	set obs 1
	gen symbol  = "DUMMY"
	gen chr     = `chr'
	gen txstart = `start' +1000
	gen txend   = `end'	 -1000
	gen start   = `start' +1
	gen end     = `end'   -1
	save tmpDUMMY.dta, replace
	}
qui { // identify genes in region
	use `gene_file', clear
	qui { // limit transcripts
		drop if biotype == "3prime_overlapping_ncrna" 
		drop if biotype == "IG_C_gene"
		drop if biotype == "IG_C_pseudogene"
		drop if biotype == "IG_D_gene"
		drop if biotype == "IG_J_gene"
		drop if biotype == "IG_J_pseudogene"
		drop if biotype == "IG_V_gene"
		drop if biotype == "IG_V_pseudogene"
		drop if biotype == "Mt_rRNA"
		drop if biotype == "Mt_tRNA"
		drop if biotype == "TR_C_gene"
		drop if biotype == "TR_D_gene"
		drop if biotype == "TR_J_gene"
		drop if biotype == "TR_J_pseudogene"
		drop if biotype == "TR_V_gene"
		drop if biotype == "TR_V_pseudogene"
		drop if biotype == "antisense"
		drop if biotype == "lincRNA"
		drop if biotype == "miRNA"
		drop if biotype == "misc_RNA"
		drop if biotype == "polymorphic_pseudogene"
		drop if biotype == "processed_transcript"
		*	drop if biotype == "protein_coding"
		drop if biotype == "pseudogene"
		drop if biotype == "rRNA"
		drop if biotype == "sense_intronic"
		drop if biotype == "sense_overlapping"
		drop if biotype == "snRNA"
		drop if biotype == "snoRNA"
		}
	keep if chr    ==  `chr'
	drop if start   > `end'
	drop if end     < `start'
	drop if txstart > `end'
	drop if txend   < `start'
	replace start   = `start' if start   < `start'
	replace end     = `end'   if end     > `end'
	replace txstart = `start' if txstart < `start'
	replace txend   = `end'   if txend   > `end'
	append using tmpDummy.dta
	}
qui { // remove duplicates # this plot will focus on gene units not alternative transcripts
	keep chr start end txs txe symbol biotype
	duplicates drop
	}
qui { // how many genes are in the region
	encode symbol, gen(region_n)
	sum region_n
	global region_n `r(max)'
	noi di as text"# > graphgene"as text" ........................ elements in region "as result"$region_n"
	}	
qui { // save co-ordinates file
	keep symbol	chr st en txs txe
	save tmpGENEcoords.dta, replace
	}
qui { // define order of genes
	use tmpGENEcoords.dta, clear
	drop if symbol == "DUMMY"
	sort chr start end
	encode symbol,gen(y)
	gen order = .
	qui { // order == 1
		replace order = 1 if y == 1
		sum y
		foreach i of num 1 / `r(max)' {
			sum start if order == 1
			replace order = 1 if y == `i' & order == . & end < `r(min)' - 1000000
			}
		sum y
		foreach i of num 1 / `r(max)' {
			sum end if order == 1
			replace order = 1 if y == `i' & order == . & start > `r(max)' + 1000000
			}		
		}
	qui { // order == `j' to 100
		foreach j of num 1 / 100 {
			sum y if order == .
			if `r(N)' != 0 {
				replace order = `j' if y == `r(min)'
				sum y
				foreach i of num 1 / `r(max)' {
					sum start if order == `j'
					replace order = `j' if y == `i' & order == . & end < `r(min)' - 1000000
					}
				sum y
				foreach i of num 1 / `r(max)' {
					sum end if order == `j'
					replace order = `j' if y == `i' & order == . & start > `r(max)' + 1000000
					}		
				}
			}
		}
	}
qui { // plot region 
	qui { // expand exons to minimum of 1000
		gen _txs = txs
		gen _txe = txe
		gen siz = txe - txs
		replace _txe = txe - (siz/2) + 1000
		replace _txs = txs + (siz/2) - 1000
		replace _txe = txe if txe > _txe
		replace _txs = txs if txs < _txs
		}
	qui { // define label position
		gen pos = 11
		replace pos = 1 if start < `start' + 500000
		}
	save temp-graphgene-data.dta, replace
	qui { // plot genes
		#delim;
		twoway rspike start end order , hor lcolor(green) lwidth(vvthin) 
		||     rspike _txs _txe order , hor lcolor(green) lwidth(*10) 	
		||     scatter order start if pos == 11  , msymbol(i) mlabel(symbol) mlabpos(11) mlabcolor(black) mlabsize(vsmall) 
		||     scatter order end   if pos == 1   , msymbol(i) mlabel(symbol) mlabpos(1 ) mlabcolor(black) mlabsize(vsmall) 
		legend(off) 
		ylab(,labc(white)) ytitle("genes")
		xtitle("Chromosome `chr'")   
		graphregion(margin(zero)) 
		saving(temp-graphgene, replace) 
		;
		#delim cr
		}
	noi di as text"# > graphgene"as text" .............................. plot gene to "as result"temp-graphgene.gph"
	}
qui { //clean up tmp files"
	!del tmpGENEcoords.dta tmpDUMMY.dta
	}
end;
