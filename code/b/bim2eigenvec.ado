/*
*program*
 bim2eigenvec

*description* 
 a command to generate ancestry informative eigenvectors from 
 plink-format files

*syntax*
 bim2eigenvec, bim(-filename-) [pc(real 10)]
 
 -filename- does not require the .bim filetype to be included - this is assumed

*options* 
 -pc-             defines the number of principle components to calculate
                  the default number of pcs to calculate is 10
*/

program bim2eigenvec
syntax , bim(string asis) [pc(real 10)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2eigenvec"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2eigenvec ................ estimating eigenvec for "as result"`bim'"
	noi checkfile, file(`bim'.bim)
	noi checkfile, file(`bim'.bed)
	noi checkfile, file(`bim'.fam)
	noi checkfile, file(${plink})
	noi checkfile, file(${plink2})
	checktabbed
	}
qui { // 2 - process input binaries
	bim2ldexclude, bim(`bim') 
	!$plink --bfile `bim' --exclude bim2ldexclude.exclude --indep-pairwise 1000 5 0.2  --out bim2eigenvec
	!$plink --bfile `bim' --extract bim2eigenvec.prune.in --make-bed                    --out bim2eigenvec
	}
qui { // 3 - defining principle component using ${plink2}
	!$plink2 --bfile bim2eigenvec --pca `pc' --out bim2eigenvec
	}
qui { // 4 - processing eigenvec file to `bim'_eigenvec.dta
	!$tabbed bim2eigenvec.eigenvec
	import delim using bim2eigenvec.eigenvec.tabbed, clear
	keep fid iid pc1 - pc`pc'
	for var fid iid: tostring X,replace
	noi di as text"# > bim2eigenvec ...................... eigenvec saved to "as result"`bim'_eigenvec.dta"
	save `bim'_eigenvec.dta,replace
	}
qui { // 5 - processing eigenval file to `bim'_eigenval.dta
	!$tabbed bim2eigenvec.eigenval
	import delim using bim2eigenvec.eigenval.tabbed, clear
	gen pc = _n
	ren v1 eigenval
	noi di as text"# > bim2eigenvec ...................... eigenval saved to "as result"`bim'_eigenval.dta"
	save `bim'_eigenval.dta,replace
	}
qui { // 6 - cleaning temp files
	!rm bim2eigenvec.* bim2ldexclude.exclude
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;


	
