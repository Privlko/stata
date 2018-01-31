/*
*program*
 bim2ld_subset

*description* 
 command to use *.bim files (plink-format marker files) to generate a 
 subset of linkage disequilibrium independent snps (_subset#.extract)

*syntax*
 bim2ld_subset, bim(-filename-) [n(-n-)]

 -filename- does not require the .bim filetype to be included - this is assumed
 -n- this refers to the number of SNPs retained in dataset (default - 50000)
*/

program bim2ld_subset
syntax , bim(string asis) [n(real 50000)]

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2ld_subset"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2ld_subset ... extracting ld independent SNPs from "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	noi checkfile, file(${plink})
	}
qui { // 2 - define subset	
	bim2ldexclude, bim(`bim')
	!$plink  --bfile `bim' --maf 0.05 --exclude long-range-ld.exclude --make-bed --out bim2ld_subset
	!$plink  --bfile bim2ld_subset --indep-pairwise 1000 5 0.2 --out bim2ld_subset
	import delim using bim2ld_subset.prune.in, clear
	gen x = uniform()
	sort x
	drop if _n > `n'
	outsheet v1 using bim2ld_subset`n'.extract, non noq replace
	count
	noi di as text"# > bim2ld_subset ........................ SNPs extracted "as result"`r(N)'"
	noi di as text"# > bim2ld_subset ........................... exported to "as result"bim2ld_subset`n'.extract"
	}
qui di as text"# > clean"
qui {
	!del bim2ld_subset.* long-range-ld.exclude
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
