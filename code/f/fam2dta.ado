/*
*program*
 fam2dta

*description* 
 a command to convert *.fam files (plink-format marker files) to *.dta

*syntax*
 fam2dta, fam(-filename-) 
 
 -filename- does not require the .fam filetype to be included - this is assumed
*/

program fam2dta
syntax , fam(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# fam2dta"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > fam2dta ................................... importing "as result"`bim'.fam"
	noi checkfile, file(`fam'.fam)
	}
qui { // 2 - import file
	import delim  using `fam'.fam, clear delim(" ")
	rename (v1-v6) (fid iid fatid motid sex pheno)
	for var fid iid fatid motid: tostring X, replace
	order fid iid fatid motid sex pheno
	keep  fid iid fatid motid sex pheno
	compress
	noi di as text"# > fam2dta .............................. saving file as "as result"`bim'_fam.dta"
	save `fam'_fam.dta, replace
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;		
