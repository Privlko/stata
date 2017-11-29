/*
#########################################################################
# bim2frq
# a command to create _frq.dta (plink-format marker files) from plink binaries 
#
# command: bim2frq, bim(<FILENAME>)
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

program bim2frq
syntax , bim(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2frq - version 0.1a 21Nov2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to create _frq.dta (plink-format marker files) from plink binaries"
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
noi checkfile, file(`bim'.bim)
noi checkfile, file(${plink})
noi checktabbed
qui di as text"# > running plink --freq"
qui { 
	!${plink} --bfile `bim' --freq --out tmp-bim2frq
	}
qui di as text"# > processing file"
qui { 
	!${tabbed} tmp-bim2frq.frq
	}
qui di as text"# > importing file"
qui { 
	import delim using tmp-bim2frq.frq.tabbed, clear
	}
qui di as text"# > create genotype variable"
qui { 
	recodegenotype, a1(a1) a2(a2)
	}
qui di as text"# > naming variables"
qui { 
	rename _gt gt
	keep snp a1 a2 gt maf
	}
qui di as text"# > saving file as `bim'_frq.dta"
qui {
	save `bim'_frq.dta, replace
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
