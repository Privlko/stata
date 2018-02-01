/*
*program*
 graphplinklmiss

*description* 
 command to plot distribution from *lmiss plink file

*syntax*
 graphplinklmiss, lmiss(-filename-) [geno(-geno-)]
 
 -filename- the name of the imiss file *.imiss not required
 -geno-     the missingness by marker to be plotted
*/

program graphplinklmiss
syntax , lmiss(string asis) [geno(real 0.05)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphplinklmiss"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > graphplinklmiss ........................... importing "as result"`lmiss'.lmiss"
	noi checkfile, file(`lmiss'.lmiss)
	checktabbed
	}
qui { // 2 - processing *.lmiss"
	!$tabbed `lmiss'.lmiss
	import delim using `lmiss'.lmiss.tabbed, clear case(lower)
	erase `lmiss'.lmiss.tabbed
	for var f_miss : destring X, replace force
	for var f_miss : lab var X "Frequency of Missing Genotypes per SNP"
	count
	global nSNPs `r(N)'
	noi di as text"# > graphplinklmiss .............. number of SNPs in file "as result `r(N)'
    count if f_miss > `geno'
	global nSNPlow `r(N)'
	global geno_tmp `geno'
	noi di as text"# > graphplinklmiss ............... missingness threshold "as result `geno'
	noi di as text"# > graphplinklmiss ..,,,,. markers with miss > threshold "as result "${nSNPlow}"
	replace f_miss = 0.1 if f_miss >0.1 & f_miss !=.
	}
qui { // 3 - plotting missingness to tmpLMISS.gph"
	sum f_miss
	if `r(min)' != `r(max)' {
		noi di as text"# > graphplinklmiss .................... plotting data to "as result "tmpLMISS.gph"
		tw hist f_miss , width(0.01) start(0) percent ///
		   xlabel(0(0.01)0.1) ///
		   xline(`geno'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with missingness > `geno' ; N = ${nSNPlow}" ///
		           "SNPs with missingness > 0.1 are recoded to 0.1 for plotting") ///
		   nodraw saving(tmpLMISS.gph, replace)
		}
	else {
		noi di as text"# > graphplinklmiss ...... nothing to plot (create blank) "as result "tmpLMISS.gph"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))  
		graph save `i', replace
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	
