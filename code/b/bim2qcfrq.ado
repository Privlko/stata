/*
#########################################################################
# bim2qcfrq
# a command to create _qcfrq.dta (plink-format marker files) from plink binaries  - for genotypeqc
#
# command: bim2qcfrq, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# dependencies: tabbed.pl
#               plink
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       21st November 2017
# #########################################################################
*/

program bim2qcfrq
syntax , bim(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2qcfrq - version 0.1a 21Nov2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to create _qcfrq.dta (plink-format marker files) from plink binaries"
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > bim2qcfrq ........................................... "as result"`bim'.bim"
noi checkfile, file(`bim'.bim)
noi checkfile, file(${plink})
noi checktabbed

qui di as text"# > running plink --freq"
qui { 
	!${plink} --bfile `bim' --freq --out tmp-bim2qcfrq
	}
qui di as text"# > processing file"
qui { 
	!${tabbed} tmp-bim2qcfrq.frq
	}
qui di as text"# > importing file"
qui { 
	import delim using `bim'.bim, clear
	keep v1 v2 v4
	rename (v1 v2 v4) (chr snp bp)
	save tmp_loc.dta, replace
	import delim using tmp-bim2qcfrq.frq.tabbed, clear
	merge 1:1 snp using tmp_loc.dta
	keep if _m == 3
	keep chr bp snp maf a1 a2
	}
qui di as text"# > create genotype variable"
qui { 
	recodegenotype, a1(a1) a2(a2)
	}
qui di as text"# > naming variables"
qui { 
	rename (snp a1 maf _gt) (rsid kg_a1 kg_maf kg_gt)
	sort chr bp
	for var chr bp : tostring X, replace
	keep chr bp rsid kg_a1 kg_maf kg_gt
	order chr bp rsid kg_a1 kg_maf kg_gt
	}
qui di as text"# > saving file as `bim'_frq.dta"
qui {
	save `bim'_qcfrq.dta, replace
	!del tmp-bim2qcfrq.fr*
	erase tmp-bim2qcfrq.log
	erase tmp_loc.dta
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
