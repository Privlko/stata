/*
#########################################################################
# bim2count
# a command to count observations in a plink dataset
#
# command: bim2count, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program bim2count
syntax , bim(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2count - version 0.1a 06dec2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to count observations in a plink dataset  "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

qui {
	noi di as text"# > bim2count ........................................... "as result"`bim'"
	checkfile, file(`bim'.bim)
	checkfile, file(`bim'.fam)
	}
qui { 
	qui di as text"# > importing *.bim file"
	!$wc -l `bim'.bim  > bim.count
	import delim using bim.count, clear varnames(nonames)
	erase bim.count
	split v1,p(" ")
	destring v11, replace
	sum v11
	global bim2count_snp `r(max)'
	noi di as text"# > number of SNPs in file .............................. "as result `r(max)'
	}
qui {
	qui di as text"# > importing *.fam file"
	!$wc -l `bim'.fam  > fam.count
	import delim using fam.count, clear varnames(nonames)
	erase fam.count
	split v1,p(" ")
	destring v11, replace
	sum v11
	global bim2count_ind `r(max)'
	noi di as text"# > number of individuals in file ....................... "as result `r(max)'		
	}	
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
