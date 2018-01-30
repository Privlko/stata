/*
#########################################################################
# fam2dta
# a command to convert *.fam file (plink-format) into *.dta files
#
# command: fam2dta, fam(<filename>)
# notes: the filename does not require the .fam to be added
#
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
#########################################################################
*/

program fam2dta
syntax , fam(string asis)
qui di as text"#########################################################################"
qui di as text"# fam2dta - version 0.1a 10sept2015 richard anney "
qui di as text"#########################################################################"
qui di as text"# A command to convert *.fam files (plink-format fam files) to *.dta     "
qui di as text"# (stata-format).                                                        " 
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > fam2dta ............................................. "as result"`fam'.fam"

qui di as text"# > check path of plink *.fam file is true"
noi checkfile, file(`fam'.fam)
qui {
	import delim  using `fam'.fam, clear delim(" ")
	
	}
qui di as text"# > naming variables"
qui { 
	rename (v1-v6) (fid iid fatid motid sex pheno)
	for var fid iid fatid motid: tostring X, replace
	}
qui di as text"# > cleaning file"
qui { 
	order fid iid fatid motid sex pheno
	keep  fid iid fatid motid sex pheno
	compress
	}
qui di as text"# > saving file as `fam'_fam.dta"
qui {
	save `fam'_fam.dta, replace
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;		
