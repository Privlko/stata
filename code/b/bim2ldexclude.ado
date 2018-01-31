/*
*program*
 bim2ldexclude

*description* 
 command to use *.bim files (plink-format marker files) to identify SNPs
 to exclude that are located in areas of extended linkage disequilibrium

*syntax*
 bim2ldexclude, bim(-filename-) 

 -filename- does not require the .bim filetype to be included - this is assumed
*/

program bim2ldexclude
syntax , bim(string asis) 

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2ldexclude"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2ldexclude ........ SNPS in extended ld regions in "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	}
qui { // 2 - identifying SNPs
	import delim using `bim'.bim, clear 
	gen drop = .
	replace drop = 1 if (v1 == 1  & v4 >= 48000000  & v4 <= 52000000)
	replace drop = 1 if (v1 == 2  & v4 >= 86000000  & v4 <= 100500000)
	replace drop = 1 if (v1 == 2  & v4 >= 134500000 & v4 <= 138000000)
	replace drop = 1 if (v1 == 2  & v4 >= 183000000 & v4 <= 190000000)
	replace drop = 1 if (v1 == 3  & v4 >= 47500000  & v4 <= 50000000)
	replace drop = 1 if (v1 == 3  & v4 >= 83500000  & v4 <= 87000000)
	replace drop = 1 if (v1 == 3  & v4 >= 89000000  & v4 <= 97500000)
	replace drop = 1 if (v1 == 5  & v4 >= 44500000  & v4 <= 50500000)
	replace drop = 1 if (v1 == 5  & v4 >= 98000000  & v4 <= 100500000)
	replace drop = 1 if (v1 == 5  & v4 >= 129000000 & v4 <= 132000000)
	replace drop = 1 if (v1 == 5  & v4 >= 135500000 & v4 <= 138500000)
	replace drop = 1 if (v1 == 6  & v4 >= 24000000  & v4 <= 34000000)
	replace drop = 1 if (v1 == 6  & v4 >= 57000000  & v4 <= 64000000)
	replace drop = 1 if (v1 == 6  & v4 >= 140000000 & v4 <= 142500000)
	replace drop = 1 if (v1 == 7  & v4 >= 55000000  & v4 <= 66000000)
	replace drop = 1 if (v1 == 8  & v4 >= 8000000   & v4 <= 12000000)
	replace drop = 1 if (v1 == 8  & v4 >= 43000000  & v4 <= 50000000)
	replace drop = 1 if (v1 == 8  & v4 >= 112000000 & v4 <= 115000000)
	replace drop = 1 if (v1 == 10 & v4 >= 37000000  & v4 <= 43000000)
	replace drop = 1 if (v1 == 11 & v4 >= 46000000  & v4 <= 57000000)
	replace drop = 1 if (v1 == 11 & v4 >= 87500000  & v4 <= 90500000)
	replace drop = 1 if (v1 == 12 & v4 >= 33000000  & v4 <= 40000000)
	replace drop = 1 if (v1 == 12 & v4 >= 109500000 & v4 <= 112000000)
	replace drop = 1 if (v1 == 20 & v4 >= 32000000  & v4 <= 34500000)	
	noi di as text"# > bim2ldexclude .......................... exporting to "as result"bim2ldexclude.exclude"
	outsheet v2 if drop == 1 using "bim2ldexclude.exclude", replace non noq
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
	

	
