/*
#########################################################################
# bim2unrelated
# a command to use plink-format genotype files and to select a subset of 
# unrelated individuals
#
#
# command: bim2unrelated, bim(<FILENAME>) [threshold(real 0.0221)]
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program bim2unrelated
syntax , bim(string asis) [threshold(real 0.0221)]

qui di as text"#########################################################################"
qui di as text"# bim2unrelated - version 0.1a 05dec2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to use plink-format genotype files and to select a subset of "
qui di as text"# unrelated individuals"
qui di as text"#"

qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > "as input"bim2unrelated "as text"....................................... "as result"`bim'.bim"
noi checkfile, file(${plink2})
noi checkfile, file(`bim'.bim)
noi checkfile, file(`bim'.bed)
noi checkfile, file(`bim'.fam)

qui di as text"# > make filter /2"
qui {
	clear
	set obs 1
	gen a = `threshold'/2
	sum a
	global filter `r(max)'
	}
qui di as text"# > make create kin0 files / and identify related by threshold"
qui { 
	noi bim2ld_subset, bim(`bim')
	!$plink2 --bfile `bim' --extract _subset50000.extract --make-king-table --king-table-filter ${filter}  --king-cutoff `threshold' --out `bim'
	!$plink2 --bfile ${sub_mod_input} --extract _subset50000.extract --king-cutoff `threshold' --out `bim'
	!$plink2 --bfile `bim' --keep  `bim'.king.cutoff.in --make-bed --out `bim'-unrelated
	!$plink2 --bfile `bim'-unrelated --extract _subset50000.extract --make-king-table --king-table-filter ${filter} --out `bim'-unrelated
	}
qui di as text"# > plot kin0"
qui {
	noi graphplinkkin0, kin0(`bim')
	foreach i in 1 2 {
		!del preKIN0_`i'.gph
		!rename tmpKIN0_`i'.gph preKIN0_`i'.gph
		}
	noi graphplinkkin0, kin0(`bim'-unrelated)
	foreach i in 1 2 {
		!del postKIN0_`i'.gph
		!rename tmpKIN0_`i'.gph postKIN0_`i'.gph
		}
	graph combine preKIN0_1.gph postKIN0_1.gph, col(1) ycommon
	graph export `bim'-unrelated-ibs-by-kin.png, as(png) height(2000) width(4000) replace
	window manage close graph
	graph combine preKIN0_2.gph postKIN0_2.gph, col(1) ycommon
	graph export `bim'-unrelated-kinship-histogram.png, as(png) height(2000) width(4000) replace
	window manage close graph
	}
qui di as text"# > clean up files"
qui { 
	foreach i in 1 2 {
		!del postKIN0_`i'.gph
		!del preKIN0_`i'.gph
		}
	!del tmpKIN0.relPairs `bim'.kin0 `bim'-unrelated.kin0 _subset50000.extract
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
