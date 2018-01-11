program summary2gwas
syntax ,  reference(string asis) in(string asis) out(string asis) munge(string asis) 
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
	noi checkfile, file(`reference'_bim.dta)
	noi checkfile, file(`reference'_frq.dta)
	}
qui { // Module 1 - report to screen
	noi di as text"# > "as input"summary2gwas "as text" .................... processing data to " as result"`out'"
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
	merge 1:1 snp using `reference'_bim.dta
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
			merge 1:1 snp using `reference'_frq.dta
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
	save "`out'-summary.dta", replace
	count
	global outputSNP `r(N)'
	noi di as text"# > markers in the dataset after screening .............. "as result"${outputSNP}" 
	}
qui { // Module 8 - write a log file
	!echo #########################################################################  >  "`out'-summary.log"
	!echo # summary2gwas                                                             >> "`out'-summary.log"
	!echo # available from https://github.com/ricanney                               >> "`out'-summary.log"
	!echo #########################################################################  >> "`out'-summary.log"
	!echo # Author:     Richard Anney                                                >> "`out'-summary.log"
	!echo # Institute:  Cardiff University                                           >> "`out'-summary.log"
	!echo # E-mail:     AnneyR@cardiff.ac.uk                                         >> "`out'-summary.log"
	!echo # Date:       9th January 2018                                             >> "`out'-summary.log"
	!echo #########################################################################  >> "`out'-summary.log"
	!echo # Input .................................................. `in'            >> "`out'-summary.log"
	!echo # Output.................................................. `out'.dta       >> "`out'-summary.log"
	!echo # Date / Time of run ..................................... $S_DATE $S_TIME >> "`out'-summary.log"
	!echo # Number of snps imported ................................ ${inputSNP}     >> "`out'-summary.log"
	!echo # Number of snps exported ................................ ${outputSNP}    >> "`out'-summary.log"
	!echo # Origin of a1_frq ....................................... ${a1_frq}       >> "`out'-summary.log" 
	!echo # Chromosome / Location from ............................. ${ref}          >> "`out'-summary.log" 
	!echo #########################################################################  >> "`out'-summary.log"
	!echo #                                                                          >> "`out'-summary.log"
	!echo # The original data set has been processed for down-stream use; a number   >> "`out'-summary.log" 
	!echo # of standard quality control routines have beed applied;                  >> "`out'-summary.log"
	!echo # 1- any duplicate observation were removed                                >> "`out'-summary.log"  
	!echo # 2- if duplicate identifiers were observed with different association     >> "`out'-summary.log"
	!echo #    results, both were removed                                            >> "`out'-summary.log"
	!echo # 3- all data was aligned to hg19+1 using 1000-genomes-reference data. we  >> "`out'-summary.log"
	!echo #    also convert allele code to the same strand of the reference data -   >> "`out'-summary.log"
	!echo #    this has many advantages and disadvantages such as;                   >> "`out'-summary.log"
	!echo #    a- data-loss as not all markers in the original gwas is included on   >> "`out'-summary.log"
	!echo #       the 1000-genomes reference (rsid) may have been updated to a newer >> "`out'-summary.log"
	!echo #       build                                                              >> "`out'-summary.log"
	!echo #    b- data-loss as some markers have ambiguous genotypes - making strand >> "`out'-summary.log"
	!echo #       alignment difficult to impossible; these markers are also dropped. >> "`out'-summary.log"
	!echo #       we also drop indels too.                                           >> "`out'-summary.log"
	!echo #    c- data-cleaning as some markers reveal genotypes that are            >> "`out'-summary.log"
	!echo #       incompatible for the reference or alternative strand               >> "`out'-summary.log"
	!echo # 4- we remove imputed markers if we have an info of <.8                   >> "`out'-summary.log"
	!echo # 5- we remove meta-analysed markers if they were absent from more than 1  >> "`out'-summary.log"
	!echo #    of the contributing datasets                                          >> "`out'-summary.log"
	!echo # 6- finally we add a dummy allele frequency if an allele frequency is     >> "`out'-summary.log"
	!echo #    absent - we use the 1000-genomes reference for this.                  >> "`out'-summary.log"
	!echo #########################################################################  >> "`out'-summary.log"

	}
qui { // Module 9 - convert to formats
	use "`out'-summary.dta", clear
	_gwas2sumstat , out(`out') munge(`munge') 
	noi di as text"# > "as input"summary2gwas "as text" ................... create sumstat file " as result"`out'.sumstats.gz"
	use "`out'-summary.dta", clear
	_gwas2prePRS , out(`out')
	noi di as text"# > "as input"summary2gwas "as text" .................... create prePRS file " as result"`out'.prePRS.tsv.gz"
	use "`out'-summary.dta", clear
	_gwas2magma , out(`out')
	noi di as text"# > "as input"summary2gwas "as text" ..................... create magma file " as result"`out'.pval.gz"
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;

	
	

	
		
