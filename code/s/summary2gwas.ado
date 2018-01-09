program summary2gwas
syntax ,  reference(string asis) out(string asis)
qui di as text"#########################################################################"
qui di as text"# summary2gwas               "
qui di as text"# Creation Date: 9Jan2018            "
qui di as text"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
qui di as text"#########################################################################"
qui di as text"# This is a script to standardise gwas summary statistics - including  "
qui di as text"# some basic quality control  "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# syntax , reference(string asis) out(string asis) "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
qui { // Module 0 - check reference data exists
	*noi checkfile, file(`reference')
	noi checkfile, file(${ref}_bim.dta)
	noi checkfile, file(${ref}_frq.dta)
	}
qui { // Module 1 - report to screen
	noi di as text"# > "as input"summary2gwas "as text" .................... processing data to " as result`"`out'"'
	count
	global inputSNP `r(N)'
	noi di as text"# > markers in the dataset .............................. "as result"${inputSNP}" 
	}
qui { // Module 2 - duplicates drop
	duplicates drop 
	duplicates drop snp, force
	count
	global dupSNP `r(N)'
	noi di as text"# > markers in the dataset after removing duplicates .... "as result"${dupSNP}" 
	}
qui { // Module 3 - convert to hg19 via reference
	rename (a1 a2) (_a1 _a2)
	merge 1:1 snp using ${ref}_bim.dta
	keep if _m == 3
	count
	global mergeSNP `r(N)'
	noi di as text"# > markers in the dataset mapped to reference .......... "as result"${mergeSNP}" 
	drop _m
	}
qui { // Module 4 - check strand and convert to reference
	noi recodestrand, ref_a1(a1) ref_a2(a2) alt_a1(_a1) alt_a2(_a2)
	replace _a1 = _tmpb1 if _tmpflip == 1
	replace _a2 = _tmpb2 if _tmpflip == 1
	drop a1 - _tmpb2	
	rename (_a1 _a2) (a1 a2)
	count
	global strandSNP `r(N)'
	noi di as text"# > markers in the dataset after strand conversion ...... "as result"${strandSNP}" 
	}
qui { // Module 5 - perform other quality control
	qui { // info
		capture confirm numeric var info
		if !_rc {
			noi di as text"# > info is present and numeric ......................... apply qc"
			count if info < .8
			global infoSNP `r(N)'
			drop if info < .8
			drop info
			count
			global infoSNP `r(N)'
			noi di as text"# > markers in the dataset after info score clean ....... "as result"${infoSNP}" 
			}
		else {
			global infoSNP "info is not present or not numeric"
			}
		}
	qui { // direction
		capture confirm string var direction
		if !_rc {
			noi di as text"# > direction is present and numeric .................... apply qc"
			replace direction = subinstr(direction, "-", "",.)
			replace direction = subinstr(direction, "+", "",.)
			gen count = length(direction)
			count if count > 1
			global directionSNP `r(N)'
			drop if count > 1
			drop direction count
			count
			global directionSNP `r(N)'
			noi di as text"# > markers in the dataset after direction clean ........ "as result"${directionSNP}" 
			}
		else {
			global directionSNP "direction is not present or not string"
			}
		}
	}
qui { // Module 6 - add a1_frq if absent
	qui { // a1_frq
		capture confirm variable a1_frq
		if !_rc {
			noi di as text"# > a1_frq present"
			global a1_frq "a1_frq present in input and used in output"
			}
		else {
			rename (a1 a2) (_a1 _a2)
			merge 1:1 snp using ${ref}_frq.dta
			keep if _m == 3
			drop _m
			gen a1_frq = .
			replace a1_frq =   maf if _a1 == a1
			replace a1_frq = 1-maf if _a2 == a1	
			global a1_frq "a1_frq not present in input : mapped from ${ref}_frq.dta"
			drop a1 a2 maf gt
			rename (_a1 _a2) (a1 a2)
			}
		}
	}
qui { // Module 7 - export data
	order chr bp snp a1 a2 a1_frq p
	sort chr bp
	save ${out}.dta, replace
	count
	global outputSNP `r(N)'
	noi di as text"# > markers in the dataset after screening .............. "as result"${outputSNP}" 
	}
qui { // Module 8 - write a log file
	!echo #########################################################################  >  ${out}.log
	!echo # summary2gwas                                                             >> ${out}.log
	!echo # available from https://github.com/ricanney                               >> ${out}.log
	!echo # =======================================================================  >> ${out}.log
	!echo # Author:     Richard Anney                                                >> ${out}.log
	!echo # Institute:  Cardiff University                                           >> ${out}.log
	!echo # E-mail:     AnneyR@cardiff.ac.uk                                         >> ${out}.log
	!echo # Date:       9th January 2018                                             >> ${out}.log
	!echo #########################################################################  >> ${out}.log
	!echo # Output.................................................. ${out).dta      >> ${out}.log
	!echo # Date / Time of run ..................................... $S_DATE $S_TIME >> ${out}.log
	!echo # Number of snps imported ................................ ${inputSNP}     >> ${out}.log
	!echo # Number of snps in output................................ ${outputSNP}    >> ${out}.log
	!echo # Origin of a1_frq ....................................... ${a1_frq}       >> ${out}.log 
	!echo # Chromosome / Location from  ............................ ${ref}          >> ${out}.log 
	!echo #########################################################################  >> ${out}.log
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;

	
	

	
		
