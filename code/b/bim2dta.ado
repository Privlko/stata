/*
*program*
 bim2dta

*description* 
 a command to convert *.bim files (plink-format marker files) to *.dta

*syntax*
 bim2dta, bim(-filename-) 
 
 -filename- does not require the .bim filetype to be included - this is assumed
*/

program bim2dta
syntax , bim(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2dta"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2dta ................................... importing "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	}
qui { // 2 - importing bim file
	import delim  using `bim'.bim, clear
		capture confirm variable v2
	if !_rc { 
		}
	else {
		rename v1 v
		split v,p(" ")
		drop v
		}
	rename (v1 v2 v4 v5 v6) (chr snp bp a1 a2)
	recodegenotype , a1(a1) a2(a2)
	rename _gt_tmp gt
	}
qui { // 3 - update variables
	order chr snp bp a1 a2 gt
	keep  chr snp bp a1 a2 gt
	compress
	for var chr bp: tostring X, replace force
	replace chr = subinstr(chr,"chr","",.)
	replace chr = strupper(chr)	
	replace chr = "23" if chr == "X"
	replace chr = "24" if chr == "Y"
	replace chr = "25" if chr == "XY"
	replace chr = "26" if chr == "MT"
	gen _gt = gt
	replace _gt = "R" if gt == "Y"
	replace _gt = "M" if gt == "K"
	gen loc_name = "chr" + chr + ":" + bp + "-" + _gt
	drop _gt
	}
qui { 
	noi di as text"# > bim2dta .............................. saving file as "as result"`bim'_bim.dta"
	save `bim'_bim.dta, replace
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
