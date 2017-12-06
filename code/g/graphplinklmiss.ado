/*
#########################################################################
# graphplinklmiss
# a command to plot distribution from *imiss plink file
#
# command: graphplinklmiss, lmiss(input-file) 
# options: 
#          geno(num) ..... missingness by genotype threshold
#
# dependencies: 
# tabbed.pl must be set to be called via ${tabbed}
#
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 10th September 2015
#########################################################################
*/

program graphplinklmiss
syntax , lmiss(string asis) [geno(real 0.05)]

qui di as text"#########################################################################"
qui di as text"# graphplinklmiss                                                          "
qui di as text"# version:       2a                                                      "
qui di as text"# Creation Date: 21April2017                                             "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# This is a script to plot the output from lmiss file from the --missing "
qui di as text"# routine in plink.                                                      " 
qui di as text"# The input data comes in standard format from the lmiss output.         "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : tabbed.pl via ${tabbed}                                 "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > "as input"graphplinklmiss "as text"..................................... "as result"`lmiss'.lmiss"
noi checkfile, file(`lmiss'.lmiss)
noi checktabbed

qui di as text"# > processing *.lmiss"
qui {
	!$tabbed `lmiss'.lmiss
	import delim using `lmiss'.lmiss.tabbed, clear case(lower)
	erase `lmiss'.lmiss.tabbed
	for var f_miss : destring X, replace force
	for var f_miss : lab var X "Frequency of Missing Genotypes per SNP"
	count
	global nSNPs `r(N)'
	noi di as text"# >> number of SNPs in file ............................. "as result `r(N)'
    count if f_miss > `geno'
	global nSNPlow `r(N)'
	global geno_tmp `geno'
	noi di as text"# >> missingness (by variant) threshold ................. "as result"${geno_tmp}"
	noi di as text"# >> number of variants with missingness > threshold .... "as result"${nSNPlow}"
		replace f_miss = 0.1 if f_miss >0.1 & f_miss !=.
	}
qui di as text"# > plotting missingness to tmpLMISS.gph"
qui {
	sum f_miss
	if `r(min)' != `r(max)' {
		tw hist f_miss , width(0.01) start(0) percent ///
		   xlabel(0(0.01)0.1) ///
		   xline(`geno'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with missingness > `geno' ; N = ${nSNPlow}" ///
		           "SNPs with missingness > 0.1 are recoded to 0.1 for plotting") ///
		   nodraw saving(tmpLMISS.gph, replace)
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
