/*
*program*
 profilescore_beta

*description* 
 command to generate polygenic profile scores 

*syntax*
syntax , summaryqc(string_asis) genotypeqc(string_asis) premerge(string_asis) manhattan(string_asis) project(string_asis) ref(string_asis)

 -summaryqc-   input gwas (processed using summaryqc
 -genotypeqc-  test genotypes to be processed (comma-delimited)
*/

program profilescore_beta
syntax , summaryqc(string asis) genotypeqc(string asis) project(string asis) ref(string asis)

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# profilescore (beta)"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"

qui { // 1 - define analysis
	clear 
	set obs 1
	gen summaryqc  = "`summaryqc'"
	gen genotypeqc = "`genotypeqc'"
	gen premerge   = "`premerge'"
	gen manhattan  = "`manhattan'" 
	gen project    = "`project'"
	split genotypeqc , p(",")
	drop genotypeqc
	reshape long genotypeqc ,i(summaryqc premerge manhattan project) 
	save profilescore_beta_info.dta, replace
	noi di as text""
	noi di as text"# > profilescore ...................... current folder is "as result"`c(pwd)'"
	!mkdir `project'
	cd `project'
	noi di as text"# > profilescore ...................... working folder is "as result"`c(pwd)'"
	noi di as text"# > profilescore ........................ project name is "as result"`project'"
	noi di as text"# > profilescore ... 1000-genomes reference genotypes are "as result"`ref'"
	sum _j
	global profilescore_n `r(max)'
	noi di as text"# > profilescore .... number of genotype files to process "as result"$profilescore_n"
	tostring _j, replace
	gen a = "global data" + _j + " " + genotypeqc
	outsheet a using profilescore_data.do, non noq replace
	do profilescore_data.do
	erase profilescore_data.do
	foreach n of num 1 / $profilescore_n {
		noi di as text"# > profilescore ........................... dataset `n' is "as result"${data`n'}"
		}
	noi di as text"# > profilescore ............................. input gwas "as result"`summaryqc'"
	split summaryqc,p("/")
	gen summaryqc99 = ""
	gen gwas = ""
	for var summaryqc1-summaryqc99: replace gwas = X if X ! = ""
	for var summaryqc1-summaryqc99: drop X
	replace gwas = subinstr(gwas,"-summaryqc.dta","",.)
	replace a = "global gwas " + gwas
	outsheet a in 1 using profilescore_data.do, non noq replace
	do profilescore_data.do
	erase profilescore_data.do
	noi di as text"# > profilescore ............................. short name "as result"${gwas}"
	split genotypeqc,p("/")
	gen genotypeqc99 = ""
	for var genotypeqc1-genotypeqc99: replace genotypeqc = X if X ! = ""
	for var genotypeqc1-genotypeqc99: drop X
	replace a = "global data_min" + _j + " " + genotypeqc
	outsheet a using profilescore_data.do, non noq replace
	do profilescore_data.do
	erase profilescore_data.do
	noi di as text"#########################################################"
	}
qui { // 2 - check files
	noi di as text""
	noi checkfile, file(${ref}.bim)
	noi checkfile, file(${ref}.bed)
	noi checkfile, file(${ref}.fam)
	foreach n of num 1 / $profilescore_n {
		noi checkfile, file(${data`n'}.bim)
		noi checkfile, file(${data`n'}.bed)
		noi checkfile, file(${data`n'}.fam)
		}
	noi checkfile, file(`summaryqc')
	noi checkfile, file(${plink})
	checktabbed
	noi di as text"#########################################################"
	}
qui { // 2 - create temp directory
	noi di as text"# > profilescore ........................................ "as result"creating temp directory"
	noi create_temp_dir
	global profilescore_temp_dir "`c(pwd)'"
	}
qui { // 3 - processing genotype data
	noi di as text""
	noi di as text"# > profilescore ........................................ "as result"importing snp list from reference"
	capture confirm file  `ref'_bim.dta 
	if !_rc {
		noi di as text""
		noi di as text"# > profilescore ........... _bim.dta files already exist "as result"`ref'_bim.dta"
		use `ref'_bim.dta, clear
		}
	else {
		noi di as text""
		noi di as text"# > profilescore .................. create _bim.dta files "as result"`ref'_bim.dta"
		noi bim2dta, bim(`ref')
		}
	count
	noi di as text"# > profilescore ...................... imported SNPs (N) "as result"`r(N)'"
	rename gt ref_gt
	keep snp ref_gt
	save temp-profilescore_beta-snps.dta, replace
	foreach n of num 1 / $profilescore_n {
		noi di as text"# > profilescore ........................................ "as result"importing snp list from ${data_min`n'}"
		capture confirm file  ${data`n'}_bim.dta 
		if !_rc {
			noi di as text""
			noi di as text"# > profilescore ........... _bim.dta files already exist "as result"${data`n'}_bim.dta"
			use ${data`n'}_bim.dta, clear
			}
		else {
			noi di as text""
			noi di as text"# > profilescore .................. create _bim.dta files "as result"${data`n'}_bim.dta"
			noi bim2dta, bim(${data`n'})
			}
		rename gt data`n'_gt
		keep snp data`n'_gt
		count
		noi di as text"# > profilescore ...................... imported SNPs (N) "as result"`r(N)'"
		noi di as text"# > profilescore ........................................ "as result"merging with reference"
		merge 1:1 snp using  temp-profilescore_beta-snps.dta
		keep if _m == 3
		drop if data`n'_gt == "R" & ref_gt == "K"
		drop if data`n'_gt == "R" & ref_gt == "M"
		drop if data`n'_gt == "Y" & ref_gt == "K"
		drop if data`n'_gt == "Y" & ref_gt == "M"
		drop if data`n'_gt == "K" & ref_gt == "R"
		drop if data`n'_gt == "K" & ref_gt == "R"
		drop if data`n'_gt == "M" & ref_gt == "Y"
		drop if data`n'_gt == "M" & ref_gt == "Y"
		gen byte data`n'_flip = 1 if data`n'_gt != ref_gt
		drop _merge
		save temp-profilescore_beta-snps.dta, replace
		}
	count
	noi di as text"# > profilescore ...... SNPs remaining after merge(s) (N) "as result"`r(N)'"
	noi di as text"#########################################################################"
	}
qui { // 4 - processing GWAS summary data
	noi di as text""
	noi di as text"# > profilescore ........... processing gwas summary data "as result"`summaryqc'"
	use `summaryqc', clear
	qui { // drop if snp is ambiguous
		drop if a1 == "A" & a2 == "T"
		drop if a1 == "T" & a2 == "A"
		drop if a1 == "C" & a2 == "G"
		drop if a1 == "G" & a2 == "C"
		}
	qui { // merge with genotypes
		noi di as text"# > profilescore ........................................ "as result"merging with GWAS"
		merge 1:1 snp using  temp-profilescore_beta-snps.dta
		keep if _m == 3	
		drop _m
		recodegenotype, a1(a1) a2(a2)
		drop if _gt == "R" & ref_gt == "K"
		drop if _gt == "R" & ref_gt == "M"
		drop if _gt == "Y" & ref_gt == "K"
		drop if _gt == "Y" & ref_gt == "M"
		drop if _gt == "K" & ref_gt == "R"
		drop if _gt == "K" & ref_gt == "R"
		drop if _gt == "M" & ref_gt == "Y"
		drop if _gt == "M" & ref_gt == "Y"
		gen byte _flip = 1 if _gt != ref_gt
		}
	save temp-profilescore_beta-snps.dta, replace
	}
qui { // 5 - flip to reference strand
	use temp-profilescore_beta-snps.dta, clear
	qui { // flip genotypes
		foreach n of num 1 / $profilescore_n {
			outsheet snp if data`n'_flip == 1 using  data`n'.flip, non noq replace
			drop data`n'_flip
			noi di as text"# > profilescore ..... flipping genotypes to reference in "as result"data`n'"
			!${plink} --bfile ${data`n'} --flip data`n'.flip --make-bed --out data`n'
			}
		}
	qui { // flip associations
		noi di as text"# > profilescore ..... flipping associations to reference"
		for var a1 a2: gen _X = ""
		for var a1 a2: replace _X = X if _flip == .
		for var a1 a2: replace _X = "A" if X == "T" & _flip == 1 & _X == ""
		for var a1 a2: replace _X = "C" if X == "G" & _flip == 1 & _X == ""
		for var a1 a2: replace _X = "G" if X == "C" & _flip == 1 & _X == ""
		for var a1 a2: replace _X = "T" if X == "A" & _flip == 1 & _X == ""
		for var a1 a2: drop X
		rename (_a1 _a2) (a1 a2)
		}
	rename ref_gt gt
	}
qui { // 6 - flip to risk
	noi di as text"# > profilescore .......... flipping associations to risk"
	gen flip = .
	replace flip = 1 if or < 1
	gen risk_or  = or
	gen risk     = a1
	gen alt      = a2
	replace risk_or    = 1/or   if flip == 1
	replace risk       = a2     if flip == 1
	replace alt        = a1     if flip == 1
	gen weight = ln(risk_or)
	keep snp risk alt gt weight p 
	for var  risk alt gt weight p : rename X gwas_X	
	}
qui { // 7 - removing duplicates and report
	duplicates drop
	duplicates tag snp, gen(dups)
	keep if dups == 0
	drop dups
	keep snp gwas_weight gwas_risk gwas_p
	save tempfile-gwas.dta,replace
	count
	noi di as text"# > profilescore ......... SNPs remaining after merge (N) "as result"`r(N)'"
	noi di as text"#########################################################################"
	}
qui { // 8 - create profile scores
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# > profilescore .......... create profile score based on "as result"${gwas}"
	use tempfile-gwas.dta, replace
	rename (snp gwas_p) (SNP P)
	keep SNP P
	qui { // define thresholds for clumping based on gwas data
		sum P
		noi di as text"# > profilescore ............... the minimum p in gwas is "as result "`: display %10.4e r(min)'"
		gen min = `r(min)'
		gen threshold = ""
		replace threshold =  "global thresholds 5E-1 "  if min < 5E-1 
		replace threshold =  "global thresholds 5E-1 1E-1 "  if min < 1E-1 
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 "  if min < 5E-2 
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 "  if min < 1E-2
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 "  if min < 1E-3 
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4"  if min < 1E-4 
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5" if min < 1E-5
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6"  if min < 1E-6 
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7"  if min < 1E-7 
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7 1E-8" if min < 1E-8 
		outsheet threshold in 1 using _tmp.do, non noq replace
		do _tmp.do
		erase _tmp.do
		noi di as text"# > profilescore .......................... clump SNPs at "as result `"${thresholds}"'
		global ldprune        "--clump-p1 1 --clump-p2 1 --clump-r2 0.2 --clump-kb 1000"
		noi di as text"# > profilescore ........................................ "as result "processing"
		foreach threshold in $thresholds {
			use tempfile-gwas.dta, replace
			rename (snp gwas_p) (SNP P)
			keep SNP P
			outsheet SNP P if P < `threshold' using tempfile-P`threshold'.input-clump, noq replace
			di as text"# > profilescore ............... clumping reference for P< "as result `threshold'		
			!${plink} --bfile ${ref} --clump tempfile-P`threshold'.input-clump ${ldprune} --out tempfile-P`threshold'
			!${tabbed} tempfile-P`threshold'.clumped
			import delim using 	tempfile-P`threshold'.clumped.tabbed, clear
			keep snp
			merge 1:1 snp using tempfile-gwas.dta 
			keep if _m == 3
			outsheet snp gwas_risk gwas_weight using tempfile-P`threshold'.score, non noq replace
			outsheet snp gwas_p                using tempfile-P`threshold'.q-score-file, non noq replace
			clear
			set obs 1
			gen a = "P`threshold'	0	`threshold'"
			outsheet a using  tempfile-P`threshold'.q-score-range, non noq replace
			}
		}
	qui { // define threshold for profile scoring based on clumped data
		foreach threshold in $thresholds {
			import delim using 	tempfile-P`threshold'.clumped.tabbed, clear
			keep snp
			merge 1:1 snp using tempfile-gwas.dta 
			keep if _m == 3
			gen threshold = "`threshold'"
			count
			if threshold == "5E-1" & `r(N)' >= 5 {
				global thresholds 5E-1
			}
			else if threshold == "1E-1" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1
				}
			else if threshold == "5E-2" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2
			}		
			else if threshold == "1E-2" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2 1E-2
				}
			else if threshold == "1E-3" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3
				}
			else if threshold == "1E-4" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4
				}
			else if threshold == "1E-5" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5
				}
			else if threshold == "1E-6" & `r(N)' >= 5 { 
				global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6
				}
			else if threshold == "1E-7" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7
				}
			else if threshold == "1E-8" & `r(N)' >= 5 {
				global thresholds 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7 1E-8
				}
			}
		noi di as text"# > profilescore ........ following clumping threshold is "as result `"${thresholds}"'
		}
	qui { // calculate scores
		foreach threshold in $thresholds {
			foreach n of num 1 / $profilescore_n {
				noi di as text"# > profilescore .................. calculating scores for "as result "${data`n'}"
				noi di as text"# > profilescore ..................... at threshold for P< "as result `threshold'
				!${plink} --bfile                            data`n' ///
				--score          tempfile-P`threshold'.score         ///
				--q-score-file   tempfile-P`threshold'.q-score-file  ///
				--q-score-range  tempfile-P`threshold'.q-score-range ///
				--out                                        data`n'
				}
			}
		}
	noi di as text"#########################################################################"
	}
qui { // 9 - combine profile scores into single file
	noi di as text" "
	noi di as text"#########################################################################"
	foreach n of num 1 / $profilescore_n {
		noi di as text"# > profilescore . join thresholds files into single file "as result"${data_min`n'}-profiles.dta"
		fam2dta, fam(${data`n'})
		keep fid iid sex
		save ../${gwas}-in-${data_min`n'}-profiles.dta, replace
		foreach threshold in $thresholds {
			clear
			set obs 1
			gen a = "`threshold'"
			replace a = subinstr(a, "-", "_",.)
			replace a = "global tag p" + a
			outsheet a using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			!$tabbed           data`n'.P`threshold'.profile
			import delim using data`n'.P`threshold'.profile.tabbed, case(lower) clear
			erase data`n'.P`threshold'.profile
			erase data`n'.P`threshold'.profile.tabbed
			keep fid - score
			for var fid iid: tostring X, replace
			for var cnt cnt2 score: rename X ${tag}_X
			merge 1:1 fid iid using ../${gwas}-in-${data_min`n'}-profiles.dta
			drop _m
			order fid iid sex 
			save           ../${gwas}-in-${data_min`n'}-profiles.dta, replace
			outsheet using ../${gwas}-in-${data_min`n'}-profiles.csv, comma noq replace
			}
		}
	noi di as text"#########################################################################"
	}
qui { // 10 - make meta-log
	noi di as text"# > profilescore ...................... creating meta-log "as result"`project'-profilescore_beta-meta.log"
	qui { // write meta log
		file open myfile using "../`project'-profilescore_beta-meta.log", write replace
		file write myfile "#########################################################################" _n
		file write myfile "# profilescore_beta" _n
		file write myfile "#########################################################################" _n
		file write myfile "# Started: $S_DATE $S_TIME " _n
		file write myfile "#########################################################################" _n
		file write myfile `"# > summaryqc ................................ input data `summaryqc'"' _n
		use `summaryqc', clear
		count
		file write myfile `"# > summaryqc .................... number of SNPs in file `r(N)'"' _n
		count if p < 5e-8
		file write myfile `"# > summaryqc ................ number of GWS SNPs in file `r(N)'"' _n
		foreach n of num 1 / $profilescore_n {
			file write myfile `"# > genotypeqc ............................... input data ${data`n'}"' _n
			bim2count, bim(${data`n'})
			file write myfile `"# > bim2count .................... number of SNPs in file ${bim2count_snp}"' _n
			file write myfile `"# > bim2count ............. number of individuals in file ${bim2count_ind}"' _n
			}
		use tempfile-gwas.dta, clear
		count 
		file write myfile `"# > profilescore .............. number of SNPs in overlap `r(N)'"' _n
		count if gwas_p < 5e-8
		file write myfile `"# > profilescore .......... number of GWS SNPs in overlap `r(N)'"' _n
		file write myfile "#########################################################################" _n
		file write myfile "# codebook for *profile.dta " _n
		file write myfile "#########################################################################" _n
		file write myfile "# fid .......... (family identifier) ........................ string"  _n
		file write myfile "# iid .......... (individual identifier) .................... string"  _n
		file write myfile "# sex .......... (sex) ...................................... 1 = male; 2= female" _n
		file write myfile "# P#E_#_cnt .... (number of alleles present in the model) ... numeric" _n
		file write myfile "# P#E_#_cnt2 ... (total number of named alleles observed) ... numeric" _n
		file write myfile "# P#E_#_score .. (weighted score) ........................... numeric" _n
		file write myfile "#########################################################################" _n
		file write myfile "# Scores were calculated using PLINK. Scores are created using weights   " _n
		file write myfile "# (log(OR)). Final scores are averages of valid per-allele scores. By    " _n
		file write myfile "# default, copies of the unnamed allele contribute zero to score, while  " _n
		file write myfile "# missing genotypes contribute an amount proportional to the loaded (via " _n
		file write myfile "# --read-freq) or imputed allele frequency.                              " _n
		file write myfile "# A minimum of 5 LD-indep. SNPs are required per threshold to generate a " _n
		file write myfile "# score.                             " _n
		file write myfile "#########################################################################" _n
		foreach n of num 1 / $profilescore_n {
			file write myfile `"# > profilescore_beta : ${gwas}-in-${data_min`n'}-profiles.dta"' _n
			foreach threshold in $thresholds { 
				!cat tempfile-P`threshold'.q-score-file | wc -l > tmp.count
				insheet using tmp.count, clear
				erase tmp.count
				sum v1
				file write myfile `"# > profilescore_beta ........ LD-indep. SNPs at P < `threshold' `r(max)'"' _n
				}
			file write myfile "#########################################################################" _n
			}
		file close myfile
		}
	}
qui { // 11 - plot manhattan of intersect
		noi di as text" "
		noi di as text"#########################################################################"
		noi di as text"# > plotting manhattan plot of modelled SNPs ............ " as result "`project'-profilescore-manhattan.png"
		capture confirm file ${data1}_bim.dta
		if !_rc {
			noi di as text"# > bim2dta .................. marker files already exist "as result "${data1}_bim.dta"
			}
		else {
			noi di as text"# > bim2dta .................................... creating "as result "${data1}_bim.dta"
			noi bim2dta, bim(${data1})
			}
		use tempfile-gwas.dta, clear
		merge 1:1 snp using ${data1}_bim.dta
		for var chr bp gwas_p: destring X, replace force
		noi graphmanhattan, chr(chr) bp(bp) p(gwas_p) max(100) min(1) 
		graph combine tmpManhattan.gph, title("Manhattan plot for overlapping SNPs""($gwas)")  caption("CREATED: $S_DATE $S_TIME" `"PRS PROJECT: `project'"',	size(tiny))
		noi di as text"# > profilescore ...................... graph exported to "as result"`project'-profilescore-manhattan.png"
		graph export "../`project'-profilescore-manhattan.png", as(png) height(2000) width(4000) replace
		window manage close graph
		noi di as text"#########################################################################"
		}
qui { // 12 - move and clean
	!mkdir ../score
	!mkdir ../q-score-file
	foreach threshold in $thresholds {
		!mv tempfile-P`threshold'.score        ../score/${gwas}_P`threshold'.score
		!mv tempfile-P`threshold'.q-score-file ../q-score-file/${gwas}_P`threshold'.q-score-file
		}
	cd ..
	noi di as text"# > profilescore ........... cleaning and moving files to "as result"`c(pwd)'"
	!rm -r $profilescore_temp_dir
	clear
	}
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	
