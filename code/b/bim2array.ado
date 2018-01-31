/*
*program*
 bim2array

*description* 
 a command to check array from plink binaries

*syntax*
 bim2array, bim(-filename-) dir(-folder-)
 
 -filename- does not require the .bim filetype to be included - this is assumed
 -folder- this refers to a folder containing the reference arrays - download bim2array.gz from github.com/ricanney
*/

program bim2array
syntax , bim(string asis) dir(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2array"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2array ................... checking array of (bim) "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	}
qui { // 2 - import snps from bim file
	import delim using `bim'.bim, clear
	keep v2
	tostring v2, replace
	rename v2 snp
	save bim2array.dta, replace
	}
qui { // 3 - define reference panel
	clear
	set obs 1
	gen a = "array jaccard-index"
	outsheet a using bim2array.out, non noq replace
	files2dta, dir(`dir')
	erase _files2dta.dta
	drop if file == "_files2dta.dta"
	drop if file == "bim2array.dta"
	split file, p(".dt")
	keep if file2 == "a"
	keep file1
	duplicates drop
	gen n = _n
	tostring n, replace
	gen a = "global bim2array" + n + " " + file1
	outsheet a using _tmp.do, non noq replace
	do _tmp.do
	count
	foreach num of num 1 / `r(N)' { 
		di "${bim2array`num'}"
		use bim2array.dta, replace 
		duplicates drop
		merge 1:1 snp using `dir'\\${bim2array`num'}.dta
		gen array = "${bim2array`num'}"
		sum _m 
		gen all = `r(N)'
		count if _m == 3
		gen ab = `r(N)'
		gen jaccard = ab/(all)
		keep array jaccard
		sum jaccard
		di as text"# > bim2array .................... jaccard index = " as result trim("`: display %5.4f r(min)'") as text " for array " as result "${bim2array`num'}" 
		filei + "${bim2array`num'} `r(min)'" bim2array.out
		}
	erase bim2array.dta
	}
qui { // 4 - define most likely and jaccard globals
	import delim using "bim2array.out", clear delim(" ") varnames(1) case(preserve)
	duplicates drop
	gsort -j
	gen a1 = "global bim2array " + array in 1
	gen str6 jaccard2 = string(jaccard, "%5.4f") 
	gen a2 = "global Jaccard " + jaccard2 in 1 
	keep a1 a2
	gen n = 1
	keep in 1
	reshape long a, j(x) i(n)
	keep a
	outsheet a using _tmp.do, non noq replace
	do _tmp.do
	erase _tmp.do
	noi di as text"# > bim2array ......................... most likely array "as result "${bim2array}" 
	noi di as text"# > bim2array ........................ with jaccard index "as result "${Jaccard}" 
	}
qui { // 5 - plot most likely 
	import delim using "bim2array.out", clear delim(" ") varnames(1) case(preserve)
	erase bim2array.out
	duplicates drop
	gsort -j
	keep if _n <10
	graph hbar jaccard , over(array,sort(jaccard) lab(labs(large))) title("Jaccard Index") yline(.9, lcol(red)) ylabel(0(.1)1) fxsize(200) fysize(100) ///
			caption("Based on overlap with our reference data the best matched ARRAY is ${bim2array}" ///
							"Jaccard Index of  ${bim2array} = ${Jaccard}")
	noi di as text"# > bim2array .................. build overlap plotted to "as result"`bim'.arraymatch.png"
	graph export  `bim'.arraymatch.png, height(1000) width(4000) as(png) replace 
	window manage close graph
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	

