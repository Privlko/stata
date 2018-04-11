/*
*program*
 profilescore

*description* 
  command to generate polygenic profile scores 

*syntax*
syntax , param(-param-) [premerge(-premerge-) draw_manhattan(-manhattan-)]


 -param- 			name of parameter file
 -premerge- 	yes if you want to include premerging via bim2merge
 -manhattan-  yes if you want the intercept manhattan (for the processed gwas) to be drawn
*/


program profilescore
syntax , param(string asis) [premerge(string asis) draw_manhattan(string asis)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# profilescore"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"

qui { // 1 - introduction
	noi di as text"# > profilescore ........................................ checking parameters"
	noi checkfile, file(`param')
	noi di as text"# > profilescore ...................... working folder is "as result"${project_folder}"
	noi di as text"# > profilescore ........................ project name is "as result"${project_name}"
	noi di as text"# > profilescore ... 1000-genomes reference genotypes are "as result"${kg_ref}"
	noi checkfile, file(${kg_ref}.bim)
	noi checkfile, file(${kg_ref}.bed)
	noi checkfile, file(${kg_ref}.fam)
	noi di as text"# > profilescore ...... # input genotype files to process "as result"${Ndata}"
	foreach N of num 1 / $Ndata {
		noi di as text"# > profilescore ........................... dataset `N' is "as result"${data`N'}"
		noi checkfile, file(${data`N'}.bim)
		noi checkfile, file(${data`N'}.bed)
		noi checkfile, file(${data`N'}.fam)
		}
	noi di as text"# > profilescore ............................. input gwas "as result"${gwas_prePRS}"
	noi checkfile, file(${gwas_prePRS}.gz)
	noi checkfile, file(${gwas_prePRS})
	noi di as text"# > profilescore ............................. short name "as result"${gwas_short}"
	noi checkfile, file(${plink})
	checktabbed
	noi di as text"#########################################################"
	}
qui { // 2 - create temp directory
	noi di as text""
	noi di as text"# > profilescore ........................................ "as result"setting working directory"
	cd ${project_folder}
	noi create_temp_dir
	global profilescore_temp_dir "`c(pwd)'"
	}
qui { // 3 - processing genotype data
	noi di as text""
	noi di as text"# > profilescore ........................................ "as result"processing genotype data"
	clear
	set obs 1
	gen premerge ="`premerge'"
	if premerge != "yes" {
		noi di as text"# > profilescore ........................................ "as result"premerge not performed (run bim2merge)"
		gen a = `"global data_list "\${data1},"'
		foreach data of num 2 / $Ndata {
			replace a = a + "\${data`data'},"
			}
		replace a = a + "$$"
		replace a = subinstr(a, ",$$", `"""',.)
		outsheet a using tmp.do, non noq replace
		do tmp.do
		noi bim2merge , bim(${data_list}) ref_bim(${kg_ref}) project(${project_name})
		noi di as text""
		noi di as text"# > profilescore ........................................ "as result"define new globals for downstream processing"
		global profilescore_kg_ref ${bim2merge_newname1}
		noi checkfile, file(${profilescore_kg_ref}.bim)
		noi checkfile, file(${profilescore_kg_ref}.bed)
		noi checkfile, file(${profilescore_kg_ref}.fam)
		foreach data of num 1 / $Ndata {
			clear
			set obs 1
			gen a = "${data`data'}"
			split a, p("\")
			gen a999 = ""
			for var a1-a999: replace a999 = X 
			replace a999 = "global profilescore_data`data' " + a999 + "-intersect"
			outsheet a999 using tmp.do, non noq replace
			do tmp.do
			erase tmp.do
			noi checkfile, file(${profilescore_data`data'}.bim)
			noi checkfile, file(${profilescore_data`data'}.bed)
			noi checkfile, file(${profilescore_data`data'}.fam)
			}
		}
	else {
		noi di as text""
		noi di as text"# > profilescore ........................................ "as result"premerge was performed (skipping bim2merge)"
		global profilescore_kg_ref ${kg_ref}
		noi checkfile, file(${profilescore_kg_ref}.bim)
		noi checkfile, file(${profilescore_kg_ref}.bed)
		noi checkfile, file(${profilescore_kg_ref}.fam)
		foreach data of num 1 / $Ndata {
			global profilescore_data`data' ${data`data'}
			noi checkfile, file(${profilescore_data`data'}.bim)
			noi checkfile, file(${profilescore_data`data'}.bed)
			noi checkfile, file(${profilescore_data`data'}.fam)
			}
		}
	}	
qui { // 4 - processing GWAS summary data
	noi di as text""
	noi di as text"# > profilescore ........... processing gwas summary data "as result"${gwas_prePRS}"
	!$gunzip ${gwas_prePRS}.gz
	import delim using ${gwas_prePRS}, clear
	!$gzip ${gwas_prePRS}
	qui { // convert to risk
		gen flip = .
		replace flip = 1 if or < 1
		gen risk_or  = or
		gen risk     = a1
		gen alt      = a2
		gen risk_frq = a1_frq
		replace risk_or    = 1/or   if flip == 1
		replace risk       = a2     if flip == 1
		replace alt        = a1     if flip == 1
		replace risk_frq = 1-a1_frq if flip == 1
		gen weight = ln(risk_or)
		recodegenotype, a1(risk) a2(alt)
		rename (rsid _gt) (snp gt)
		keep snp risk alt gt weight p risk_frq
		for var risk alt gt weight p risk_frq: rename X gwas_X
		}
	qui { // removing duplicates
		duplicates drop
		duplicates tag snp, gen(dups)
		keep if dups == 0
		drop dups
		}
	save tempfile-gwas.dta,replace
	qui { // merging with ${profilescore_kg_ref}
		capture confirm file  ${profilescore_kg_ref}_frq.dta 
		if !_rc {
			noi di as text""
			noi di as text"# > profilescore .......... frequency files already exist "as result"${profilescore_kg_ref}_frq.dta"
			use ${profilescore_kg_ref}_frq.dta, clear
			}
		else {
			noi di as text""
			noi di as text"# > profilescore ................. create frequency files "as result"${profilescore_kg_ref}_frq.dta"
			noi bim2frq, bim(${profilescore_kg_ref})
			}
		merge 1:1 snp using tempfile-gwas.dta
		keep if _m == 3
		qui { // map allele code to same strand as ${profilescore_kg_ref}
			gen flip = .
			replace flip = 1 if (gwas_gt == gt) 
			replace flip = 2 if (gwas_gt == "R" & gt == "Y")
			replace flip = 2 if (gwas_gt == "Y" & gt == "R")
			replace flip = 2 if (gwas_gt == "K" & gt == "M")
			replace flip = 2 if (gwas_gt == "M" & gt == "K")
			drop if flip == .
			foreach i in risk alt {
				gen `i' = gwas_`i'
				replace `i' = "A" if gwas_`i' == "T" & flip == 2
				replace `i' = "C" if gwas_`i' == "C" & flip == 2
				replace `i' = "G" if gwas_`i' == "G" & flip == 2
				replace `i' = "T" if gwas_`i' == "A" & flip == 2
				}
			}
		qui { // map frequency of risk to same as a1 in ${profilescore_kg_ref}
			replace maf = 1-maf if flip == 2
			replace maf = 1-maf if risk != a1
			}
		qui { // plot allele frequency sanity check
			noi di as text""
			noi di as text"# > profilescore . plot maf between gwas and reference to "as result"${gwas_short}-by_reference-frq.png"
			global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
			tw scatter maf gwas_risk_frq, ${format} caption("data1 = ${gwas_prePRS}""data2 =${profilescore_kg_ref}") 
			graph export "..\\${gwas_short}-by_reference-frq.png", as(png) height(1000) width(3000) replace
			window manage close graph
			}
		qui { // saving data
			noi di as text"# > profilescore .................. saving merged data to "as result"tempfile-gwas.dta"
			keep snp risk alt gwas_weight gwas_risk gwas_p
			save tempfile-gwas.dta,replace	
			}
		}
	}
qui { // 5 - define GWAS and genotype overlapping snps
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# > profilescore ........................................ define overlapping snp list"
		bim2dta, bim($data1)
		keep snp
		merge 1:1 snp using tempfile-gwas.dta
		keep if _m == 3
		save tempfile-gwas.dta, replace
		}
qui { // 6 - create profile scores
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# > profilescore .......... create profile score based on "as result"${gwas_short}"
	use tempfile-gwas.dta, replace
	rename (snp gwas_p) (SNP P)
	keep SNP P
	qui { // define thresholds based on gwas data
		sum P
		noi di as text"# > profilescore ............... the minimum p in gwas is "as result "`: display %10.4e r(min)'"
		gen min = `r(min)'
		gen threshold = ""
		replace threshold =  "global thresholds 5E-1 1E-1 5E-2 "  if min < 1E-1
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
			di as text"# > profilescore .......................... processing P< "as result `threshold'
			outsheet SNP P if P < `threshold' using tempfile-P`threshold'.input-clump, noq replace
			!${plink} --bfile ${profilescore_kg_ref} --clump tempfile-P`threshold'.input-clump ${ldprune} --out tempfile-P`threshold'
			!${tabbed} tempfile-P`threshold'.clumped
			import delim using 	tempfile-P`threshold'.clumped.tabbed, clear
			keep snp
			merge 1:1 snp using tempfile-gwas.dta 
			keep if _m == 3
			outsheet snp risk gwas_weight using tempfile-P`threshold'.score, non noq replace
			outsheet snp gwas_p           using tempfile-P`threshold'.q-score-file, non noq replace
			clear
			set obs 1
			gen a = "P`threshold'	0	`threshold'"
			outsheet a using  tempfile-P`threshold'.q-score-range, non noq replace
			foreach data of num 1 / $Ndata {
				di as text"# > profilescore ............................. processing "as result "${profilescore_data`data'}"
				!${plink} --bfile          ${profilescore_data`data'} ///
									--score          tempfile-P`threshold'.score  ///
									--q-score-file   tempfile-P`threshold'.q-score-file ///
									--q-score-range  tempfile-P`threshold'.q-score-range ///
									--out            data`data'
					}
			}
		}
	}
qui { // 7 - combine profile scores into single file
	noi di as text" "
	noi di as text"#########################################################################"
	foreach data of num 1 / $Ndata {
		noi di as text"# > profilescore . join thresholds files into single file "as result"${profilescore_data`data'}-final-profiles.dta"
		fam2dta, fam(${profilescore_data`data'})
		keep fid iid sex
		save data`data'-final-profiles.dta, replace
		foreach threshold in $thresholds {
			clear
			set obs 1
			gen a = "`threshold'"
			replace a = subinstr(a, "-", "_",.)
			replace a = "global tag p" + a
			outsheet a using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			!$tabbed           data`data'.P`threshold'.profile
			import delim using data`data'.P`threshold'.profile.tabbed, case(lower) clear
			erase data`data'.P`threshold'.profile
			erase data`data'.P`threshold'.profile.tabbed
			keep fid - score
			for var fid iid: tostring X, replace
			for var cnt cnt2 score: rename X ${tag}_X
			merge 1:1 fid iid using data`data'-final-profiles.dta
			drop _m
			order fid iid sex 
			save           data`data'-final-profiles.dta, replace
			outsheet using data`data'-final-profiles.csv, comma noq replace
			}
		}
	}
qui { // 8 - make meta-log
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# > profilescore ...................... creating meta-log "as result"${project_name}-profilescore.meta-log"
	noi di as text" "
	qui { 
		log using tempfile.log, replace
		noi di as text"#########################################################################"
		noi di as text"# Polygenic Risk Score Processing Report - from GWAS + GENOTYPE > PROFILE"                                                                
		noi di as text"#########################################################################"
		noi di as text"# Author ................................................ Richard Anney (AnneyR@Cardiff.ac.uk)"
		noi di as text"# Date .................................................. $S_DATE $S_TIME"
		noi di as text"#########################################################################"			
		noi di as text"# codebook for *profile.dta "
		noi di as text"#########################################################################"
		noi di as text"# fid .................. family identifier ............................. string"
		noi di as text"# iid .................. individual identifier ......................... string"
		noi di as text"# sex .................. sex ........................................... 1 = male; 2= female"
		noi di as text"# P#E_#_cnt ............ number of alleles present in the model ........ numeric"
		noi di as text"# P#E_#_cnt2 ........... total number of named alleles observed ........ numeric"
		noi di as text"# P#E_#_score .......... weighted score ................................ numeric"
		noi di as text"#########################################################################"
		noi di as text"# Scores were calculated using PLINK. Scores are created using weights   "
		noi di as text"# (log(OR)). Final scores are averages of valid per-allele scores. By    "
		noi di as text"# default, copies of the unnamed allele contribute zero to score, while  "
		noi di as text"# missing genotypes contribute an amount proportional to the loaded (via "
		noi di as text"# --read-freq) or imputed allele frequency.                              "
		noi di as text"#########################################################################"
		noi di as text" "
		noi di as text"#########################################################################"
		noi di as text"# > report on gwas file"
		qui { 
			noi di as text"# > profilescore ............................. input gwas "as result"${gwas_prePRS}"
			noi di as text"# > profilescore ............................. short name "as result"${gwas_short}"
			!$zcat ${gwas_prePRS}.gz | $wc -l > gwas-input.count
			insheet using gwas-input.count, clear
			sum v1
			noi di as text"# > profilescore ................ SNPs in file (original) "as result"`r(max)'"
			use tempfile-gwas.dta, clear
			count 
			noi di as text"# > profilescore ............... SNPs in file (intersect) "as result"`r(N)'"
			count if gwas_p < 5e-8
			noi di as text"# > profilescore ........... GWS SNPs in file (intersect) "as result"`r(N)'"
			clear
			set obs 1
			gen a = "$thresholds"
			replace a = subinstr(a,"-","_",.)
			gen b = `"global tempThreshold ""'
			gen c =`"""'
			gen d = b + a + c
			outsheet d using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			foreach threshold in $thresholds { 
				!$cat tempfile-P`threshold'.q-score-file | $wc -l > tmp.count
				insheet using tmp.count, clear
				sum v1
				noi di as text"# > profilescore ........ LD-independent SNPs at P < `threshold' "as result"`r(max)'"
				}
			}
		noi di as text"# > report on genotype files"
		qui {
			foreach data of num 1 / $Ndata {
				noi di as text"# > profilescore .................................. data`data' "as result"${profilescore_data`data'}"
				bim2count, bim(${profilescore_data`data'})
				noi di as text"# > bim2count .................... number of SNPs in file "as result "${bim2count_snp}"
				noi di as text"# > bim2count ............. number of individuals in file "as result "${bim2count_ind}"
				noi di as text"# > profilescore ....................... scores stored in "as result"${gwas_short}-by-${profilescore_data`data'_short}_profiles.dta"
				}
			}
		noi di as text"#########################################################################"	
		log close
		}
	}
qui { // 9 - plot manhattan of intersect
	clear
	set obs 1
	gen a = "`draw_manhattan'"
	if a == "yes" {
		noi di as text" "
		noi di as text"#########################################################################"
		noi di as text"# > profilescore ...... plotting intersect manhattan plot " as result "${gwas_short}-profilescore-manhattan.png"
		capture confirm file ${profilescore_kg_ref}_bim.dta
		if !_rc {
			noi di as text"# > bim2dta .................. marker files already exist " as result "${profilescore_kg_ref}_bim.dta"
			}
		else {
			noi di as text"# > bim2dta .................................... creating "as result"${profilescore_kg_ref}_bim.dta"
			noi bim2dta, bim(${profilescore_kg_ref})
			}
		use tempfile-gwas.dta, clear
		merge 1:1 snp using ${profilescore_kg_ref}_bim.dta
		for var chr bp gwas_p: destring X, replace force
		noi graphmanhattan, chr(chr) bp(bp) p(gwas_p) max(100) min(1) 
		graph combine tmpManhattan.gph, title("manhattan-plot for PRS processed gwas ")  caption("CREATED: $S_DATE $S_TIME" "INPUT: ${gwas_prePRS}",	size(tiny))
		noi di as text"# > profilescore ...................... graph exported to "as result"${gwas_short}-profilescore-manhattan.png"
		graph export "..\\${gwas_short}-profilescore-manhattan.png", as(png) height(2000) width(4000) replace
		window manage close graph
		noi di as text"#########################################################################"
		}	
	else {
		}
	}
qui { // 10 - rename and clean
	!copy "tempfile.log" "..\\${project_name}-profilescore.meta-log"
	foreach data of num 1 / $Ndata {
		clear
		set obs 1
		gen a = "${data`data'}"
		split a, p("\")
		gen a999 = ""
		for var a1-a999: replace a999 = X 
		replace a999 = "global profilescore_data`data'_short " + a999
		replace a999 = subinstr(a999, "-intersect", "",.)
		outsheet a999 using tmp.do, non noq replace
		do tmp.do
		erase tmp.do
		!copy "data`data'-final-profiles.dta"   "..\\${gwas_short}-by-${profilescore_data`data'_short}_profiles.dta"
		!copy "data`data'-final-profiles.csv"   "..\\${gwas_short}-by-${profilescore_data`data'_short}_profiles.csv"
		}
	foreach threshold in $thresholds {
		!mkdir ..\score
		!mkdir ..\q-score-file
		!copy "tempfile-P`threshold'.score"          "..\score\\${gwas_short}_P`threshold'.score"
		!copy "tempfile-P`threshold'.q-score-file"   "..\q-score-file\\${gwas_short}_P`threshold'.q-score-file"
		}
	cd ..
	!rmdir "${profilescore_temp_dir}" /s /q 
	clear
	}
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	