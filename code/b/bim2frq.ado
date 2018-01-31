/*
*program*
 bim2frq

*description* 
 command to create _frq.dta (plink-format marker files) from plink binaries 

*syntax*
 bim2frq, bim(-filename-) 
 
 -filename- does not require the .bim filetype to be included - this is assumed
*/

program bim2frq
syntax , bim(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2frq"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2frq ......... calculating allele frequencies from "as result"`bim'"
	noi checkfile, file(`bim'.bim)
	noi checkfile, file(`bim'.bed)
	noi checkfile, file(`bim'.fam)
	noi checkfile, file(${plink})
    checktabbed
	}
qui { // 2 - estimate frequency	
	!${plink} --bfile `bim' --freq --out bim2frq
	}
qui { // 3 - process frequency file
	!${tabbed} bim2frq.frq
	import delim using bim2frq.frq.tabbed, clear
	erase bim2frq.frq
	erase bim2frq.frq.tabbed
	recodegenotype, a1(a1) a2(a2)
	rename _gt gt
	keep snp a1 a2 gt maf
	noi di as text"# > bim2frq .............................. saving file as "as result"`bim'_frq.dta"
	save `bim'_frq.dta, replace
	!del bim2frq.fr*
	!del bim2frq.log
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
