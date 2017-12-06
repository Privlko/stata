/*
#########################################################################
# bim2dta
# a command to convert *.bim files (plink-format marker files) to *.dta (
# stata-format).
#
# command: bim2dta, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# dependencies: recodeGenotype
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program bim2dta
syntax , bim(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2dta - version 0.1a 10sept2015 richard anney "
qui di as text"#########################################################################"
qui di as text"# A command to convert *.bim files (plink-format marker files) to *.dta  "
qui di as text"# (stata-format).                                                        " 
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > "as input"bim2dta "as text"............................................. "as result"`bim'.bim"
noi checkfile, file(`bim'.bim)

qui di as text"# > importing *.bim file"
qui { 
	import delim  using `bim'.bim, clear
	}
qui di as text"# > naming variables"
qui { 
	rename (v1 v2 v4 v5 v6) (chr snp bp a1 a2)
	}
qui di as text"# > creating a genotype variable"
qui { 
	recodegenotype , a1(a1) a2(a2)
	rename _gt_tmp gt
	}
qui di as text"# > cleaning file"
qui { 
	order chr snp bp a1 a2 gt
	keep  chr snp bp a1 a2 gt
	compress
	}
qui di as text"# > saving file as `bim'_bim.dta"
qui {
	save `bim'_bim.dta, replace
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
