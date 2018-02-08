/*
*program*
 bim2unrelated

*description* 
 a command to use plink-format genotype files and to select a subset of unrelated individuals

*syntax*
 bim2unrelated , bim(-filename-) [threshold(-threshold-)]
 
 -filename-   does not require the .bim filetype to be included - this is assumed
 -threshold-  kinship threshold for unrelated default = 0.0221
*/
program bim2unrelated
syntax , bim(string asis) [threshold(real 0.0221)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2unrelated"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2unrelated .......... defining unrelated subset in "as result"`bim'"
	noi checkfile, file(${plink})
	noi checkfile, file(${plink2})
	noi checkfile, file(`bim'.bim)
	noi checkfile, file(`bim'.bed)
	noi checkfile, file(`bim'.fam)
	}
qui { // 2- define filter = threshold /2
	clear
	set obs 1
	gen a = `threshold'/2
	sum a
	global bim2unrelated_filter `r(max)'
	}
qui { // 3 - make kin0 files / and identify related by threshold"
	bim2count, bim(`bim')
	noi di as text"# > bim2count .............. individuals in original file "as result "${bim2count_ind}"
	noi di as text"# > bim2unrelated ............... creating kinship matrix "as result "${bim2count_ind}"as text" x "as result "${bim2count_ind}"	
	bim2ld_subset, bim(`bim')
	!$plink2 --bfile `bim'           --extract bim2ld_subset50000.extract --make-king-table --king-table-filter ${bim2unrelated_filter} --king-cutoff `threshold' --out `bim'
	!$plink2 --bfile `bim'           --extract bim2ld_subset50000.extract --king-cutoff `threshold' --out `bim'
	noi di as text"# > bim2unrelated ........... creating unrelated binaries "as result "`bim'-unrelated"	
	!$plink --bfile `bim' --keep  `bim'.king.cutoff.in --make-bed --out `bim'-unrelated
	!$plink2 --bfile `bim'-unrelated --extract bim2ld_subset50000.extract --make-king-table --king-table-filter ${bim2unrelated_filter} --king-cutoff `threshold' --out `bim'-unrelated
	bim2count, bim(`bim'-unrelated)
	noi di as text"# > bim2count ............. individuals in processed file "as result "${bim2count_ind}"
	}
qui { // 4 - plot kin0
	graphplinkkin0, kin0(`bim')
	foreach i in 1 2 {
		!del preKIN0_`i'.gph
		!rename tmpKIN0_`i'.gph preKIN0_`i'.gph
		}
	graphplinkkin0, kin0(`bim'-unrelated)
	foreach i in 1 2 {
		!del postKIN0_`i'.gph
		!rename tmpKIN0_`i'.gph postKIN0_`i'.gph
		}
	graph combine preKIN0_1.gph postKIN0_1.gph, col(1) ycommon
	noi di as text"# > bim2unrelated ........ exporting relatedness plots to "as result"bim2unrelated-ibs-by-kin.png"
	graph export bim2unrelated-ibs-by-kin.png, as(png) height(2000) width(4000) replace
	window manage close graph
	graph combine preKIN0_2.gph postKIN0_2.gph, col(1) ycommon
	noi di as text"# > bim2unrelated ........ exporting relatedness plots to "as result"bim2unrelated-kinship-histogram.png"
	graph export bim2unrelated-kinship-histogram.png, as(png) height(2000) width(4000) replace
	window manage close graph
	}
qui { // 5 - clean up files
	foreach i in 1 2 {
		!del postKIN0_`i'.gph
		!del preKIN0_`i'.gph
		}
	!del tmpKIN0.relPairs `bim'.kin0 `bim'-unrelated.kin0 bim2ld_subset50000.extract
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
