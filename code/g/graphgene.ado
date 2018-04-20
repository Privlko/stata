/*
*program*
 graphgene

*description* 
 command to plot genes a locus plot 

*syntax*
 graphgene,  chr(-chr-) from(-from-) to(-to-) generef(-generef-) 
 
 -chr-          chromosome to plot
 -from-         base-position to plot from (hg19)
 -to-           base-position to plot to (hg19)
 -generef-      reference exon co-ordinates (hg19)
*/

program graphgene
syntax  ,  chr(string asis) from(string asis) to(string asis) generef(string asis) [save(string asis)]

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphgene"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
preserve
qui { // 1 - introduction
	noi di as text"# > graphgene ................... plotting genes from chr "as result"`chr'"
	noi di as text"# > graphgene .................. plotting genes from from "as result"`from'"
	noi di as text"# > graphgene .................... plotting genes from to "as result"`to'"
	noi checkfile, file(`generef')
	}
qui { // 2 - create DUMMY gene data (for gene deserts)
	clear
	set obs 1
	gen symbol  = "DUMMY"
	gen chr     = `chr'
	gen txstart = `from' +1000
	gen txend   = `to'	 -1000
	gen start   = `from' +1
	gen end     = `to'   -1
	save graphgene_dummy.dta, replace
	}
qui { // 3 - identify genes in region
	use `generef', clear
	qui {
	*drop if biotype == "3prime_overlapping_ncrna" 
	*drop if biotype == "IG_C_gene"
	*drop if biotype == "IG_C_pseudogene"
	*drop if biotype == "IG_D_gene"
	*drop if biotype == "IG_J_gene"
	*drop if biotype == "IG_J_pseudogene"
	*drop if biotype == "IG_V_gene"
	*drop if biotype == "IG_V_pseudogene"
	*drop if biotype == "Mt_rRNA"
	*drop if biotype == "Mt_tRNA"
	*drop if biotype == "TR_C_gene"
	*drop if biotype == "TR_D_gene"
	*drop if biotype == "TR_J_gene"
	*drop if biotype == "TR_J_pseudogene"
	*drop if biotype == "TR_V_gene"
	*drop if biotype == "TR_V_pseudogene"
	*drop if biotype == "antisense"
	*drop if biotype == "lincRNA"
	*drop if biotype == "miRNA"
	*drop if biotype == "misc_RNA"
	*drop if biotype == "polymorphic_pseudogene"
	*drop if biotype == "processed_transcript"
	* drop if biotype == "protein_coding"
	*drop if biotype == "pseudogene"
	*drop if biotype == "rRNA"
	*drop if biotype == "sense_intronic"
	*drop if biotype == "sense_overlapping"
	*drop if biotype == "snRNA"
	*drop if biotype == "snoRNA"
	}
	keep if chr    ==  `chr'
	drop if start   > `to'
  drop if end     < `from'
	drop if txstart > `to'
	drop if txend   < `from'
	replace start   = `from' if start   < `from'
	replace end     = `to'   if end     > `to'
	replace txstart = `from' if txstart < `from'
	replace txend   = `to'   if txend   > `to'
	append using graphgene_dummy.dta
	keep chr start end txs txe symbol biotype
	duplicates drop
	}
qui { // 4 - how many genes are in the region
	encode symbol, gen(region_n)
	sum region_n
	gen region = `r(max)' -1
	sum region
	global region_n `r(max)'
	noi di as text"# > graphgene ........................ elements in region "as result"`r(max)'"
	}	
qui { // 5 - save co-ordinates file
	keep symbol	chr st en txs txe
	save graphgene_coordinates.dta, replace
	}
qui { // 6 - plot and define order of genes
	use graphgene_coordinates.dta, clear
	count
	if `r(N)' > 1 {
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
				replace pos = 1 if start < `from' + 500000
				}
			save graphgene_pre-plot.dta, replace
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
			noi di as text"# > graphgene ......................... plotting genes to "as result"temp-graphgene.gph"
			}
		}
	else {
		noi di as text"# > graphgene ............ nothing to plot (create blank) "as result"temp-graphgene.gph"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))  
		graph save temp-graphgene.gph, replace
		window manage close graph
		}
	}
qui { // 7 - clean up tmp files"
	clear
	set obs 1
	gen save = "`save'"
	if save == "" {
		!del graphgene_coordinates.dta graphgene_dummy.dta graphgene_pre-plot.dta
		}
	else {
			!del graphgene_coordinates.dta graphgene_dummy.dta 
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
