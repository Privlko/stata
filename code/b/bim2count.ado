/*
*program*
 bim2count

*description* 
 a command to count observations in a plink dataset

*syntax*
 bim2count, bim(-filename-) 
 
 -filename- does not require the .bim filetype to be included - this is assumed
*/

program bim2count
syntax , bim(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2count"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2count ................. counting observations for "as result"`bim'"
	noi checkfile, file(`bim'.bim)
	noi checkfile, file(`bim'.fam)
	}
qui { // 2 - counting bim observations
	!$wc -l `bim'.bim  > bim.count
	!wc -l `bim'.bim  > bim.count
	import delim using bim.count, clear varnames(nonames)
	erase bim.count
	split v1,p(" ")
	destring v11, replace
	sum v11
	global bim2count_snp `r(max)'
	noi di as text"# > bim2count .................... number of SNPs in file "as result "${bim2count_snp}"
	}
qui { // 3 - counting fam observations
	qui di as text"# > importing *.fam file"
	!$wc -l `bim'.fam  > fam.count
	!wc -l `bim'.fam  > fam.count
	import delim using fam.count, clear varnames(nonames)
	erase fam.count
	split v1,p(" ")
	destring v11, replace
	sum v11
	global bim2count_ind `r(max)'
	noi di as text"# > bim2count ............. number of individuals in file "as result "${bim2count_ind}"
	}	
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
