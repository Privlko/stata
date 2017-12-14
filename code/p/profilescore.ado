/*
#########################################################################
# profilescore
# a command to generate polygenic profile scores 
#
# command: profilescore, param(parameter-file)
#
#########################################################################
# additional files
# download the following archive;
#  ...........
#
# prior to implementation, run the install-all.do file from
# https://github.com/ricanney/stata-genomics-ado
#
# download the following executables from
# plink1.9+ from https://www.cog-genomics.org/plink2
#
# download the following perl-script from 
# tabbed.pl from https://github.com/ricanney/perl
# 
# prior to implementation map the following to global tags
#
# global tabbed perl <location of tabbed.pl>
# global plink <location of plink1.9+.exe>
#
#########################################################################

#########################################################################
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 5th September 2017
#########################################################################
*/

program profilescore
syntax , param(string asis) [premerge(string asis) draw_manhattan(string asis)]

noi di as text"#########################################################################"
noi di as text"# profilescore                                                           "
noi di as text"# version:       0.3                                                     "
noi di as text"# Creation Date: 5September2017                                          "
noi di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME                                               "
noi di as text"#########################################################################"
noi di as text"# User Defined Parameter"
noi di as text"#########################################################################"
noi di as text"# \${project_folder}     = working folder"
noi di as text"# \${project_name}       = project name"
noi di as text"# \${kg_ref}             = reference genotypes (1000-genomes phase3 hg19 european ancestry"
noi di as text"# \${Ndata}              = number of input genotype files "
noi di as text"# \${data<#>}            = location of genotypes for dataset<#>"
noi di as text"# \${gwas_short}         = short name of gwas"
noi di as text"# \${gwas_prePRS}        = location of *-prePRS.tsv file corresponding to gwas_short (do not include .gz on filename)"
noi di as text"#########################################################################"

qui { // Module #0 - preamble
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #0 - preamble"
	noi	di as text"# > run parameters file ................................. "as result"`param'"
	qui {
		noi checkfile, file(`param')
		do `param'
		}
	noi di as text"# > check path of dependent software is true"
	qui { 
		noi checkfile, file(${plink})
		noi checktabbed
		}
	noi di as text"# > check path of input files is true"
	qui {
		noi checkfile, file(${gwas_prePRS}.gz)
		}
	qui di as text"# > create temp directory"
	qui {
		cd ${project_folder}
		noi create_temp_dir
		global profilescore_temp_dir "`c(pwd)'"
		}
	}
qui { // Module #1 - processing genotype data
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #1 - processing genotype data"
	noi	di as text"# > number of genotype datasets to process .............. "as result"$Ndata"
	clear
	set obs 1
	gen premerge ="`premerge'"
	if premerge != "yes" {
		noi	di as text"# > premerge not performed .............................. "as result"running bim2merge"
		foreach data of num 1 / $Ndata {
			noi checkfile, file(${data`data'}.bed)
			noi checkfile, file(${data`data'}.bim)
			noi checkfile, file(${data`data'}.fam)
			noi checkfile, file(${data`data'}.meta-log)
			}
		noi checkfile, file(${kg_ref}.bed)
		noi checkfile, file(${kg_ref}.bim)
		noi checkfile, file(${kg_ref}.fam)	
		gen a = `"global data_list "\${data1},"'
		foreach data of num 2 / $Ndata {
			replace a = a + "\${data`data'},"
			}
		replace a = a + "$$"
		replace a = subinstr(a, ",$$", `"""',.)
		outsheet a using tmp.do, non noq replace
		do tmp.do
		noi bim2merge , bim(${data_list}) ref_bim(${kg_ref}) project(${gwas_short}-by-${project_name})
		qui di as text"# > define new globals for downstream processing - also save redundent copy"
		qui { // kg_ref
			global profilescore_kg_ref ${bim2merge_newname1}
			noi checkfile, file(${profilescore_kg_ref}.bim)
			noi checkfile, file(${profilescore_kg_ref}.bed)
			noi checkfile, file(${profilescore_kg_ref}.fam)
			}
		qui { // data2 - dataN
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
		}
	else {
		noi	di as text"# > premerge was performed .............................. "as result"skip bim2merge"
		qui { // kg_ref
			global profilescore_kg_ref ${kg_ref}
			noi checkfile, file(${profilescore_kg_ref}.bim)
			noi checkfile, file(${profilescore_kg_ref}.bed)
			noi checkfile, file(${profilescore_kg_ref}.fam)
			}
		qui { // data2 - dataN
			foreach data of num 1 / $Ndata {
				global profilescore_data`data' ${data`data'}
				noi checkfile, file(${profilescore_data`data'}.bim)
				noi checkfile, file(${profilescore_data`data'}.bed)
				noi checkfile, file(${profilescore_data`data'}.fam)
				}
			}
		}
	}		
qui { // Module #2 - processing GWAS summary data
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #2 - processing GWAS summary data"
	noi	di as text"# > unzipping / importing / zipping ..................... "as result"${gwas_prePRS}.gz"
	qui {
		noi checkfile, file(${gwas_prePRS}.gz)
		!$gunzip ${gwas_prePRS}.gz
		noi checkfile, file(${gwas_prePRS})
		import delim using ${gwas_prePRS}, clear
		*!$gzip ${gwas_prePRS}
		*noi checkfile, file(${gwas_prePRS}.gz)
		}
  noi	di as text"# > processing gwas summary data ........................ "as result"${gwas_prePRS}"
	qui {
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
		gen weight = log(risk_or)
		recodegenotype, a1(risk) a2(alt)
		rename (rsid _gt) (snp gt)
		keep snp risk alt gt weight p risk_frq
		for var risk alt gt weight p risk_frq: rename X gwas_X
		qui di as text"# >> removing duplicates"
		qui {
			duplicates drop
			duplicates tag snp, gen(dups)
			keep if dups == 0
			drop dups
			}
		save tempfile-gwas.dta,replace	
	  noi	di as text"# > merging with ${profilescore_kg_ref}"
		qui {
			noi bim2frq, bim(${profilescore_kg_ref})
			merge 1:1 snp using tempfile-gwas.dta
			keep if _m == 3
			noi di as text"# >> cross-tabulate gwas genotype coding with ........... "as result"${profilescore_kg_ref}"
			noi ta gt gwas_gt,m
			gen flip = .
			replace flip = 1 if (gwas_gt == gt) 
			replace flip = 2 if (gwas_gt == "R" & gt == "Y")
			replace flip = 2 if (gwas_gt == "Y" & gt == "R")
			replace flip = 2 if (gwas_gt == "K" & gt == "M")
			replace flip = 2 if (gwas_gt == "M" & gt == "K")
			drop if flip == .
			noi di as text"# >> map allele code to same strand as .................. "as result"${profilescore_kg_ref}"
			foreach i in risk alt {
				gen `i' = gwas_`i'
				replace `i' = "A" if gwas_`i' == "T" & flip == 2
				replace `i' = "C" if gwas_`i' == "C" & flip == 2
				replace `i' = "G" if gwas_`i' == "G" & flip == 2
				replace `i' = "T" if gwas_`i' == "A" & flip == 2
				}
			noi di as text"# >> map frequency of risk to same as a1 in ............. "as result"${profilescore_kg_ref}"
			qui {
				replace maf = 1-maf if flip == 2
				replace maf = 1-maf if risk != a1
				global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
				noi di as text"# >> plot two-way scatter of allele frq betweeen gwas and "as result"${profilescore_kg_ref}"as text" to "as result"tempfile-gwas_risk_frq_x_kg_ref_risk_frq.gph"
				tw scatter maf gwas_risk_frq, ${format} caption("data1 = ${gwas_prePRS}""data2 =${profilescore_kg_ref}") saving(tempfile-gwas_risk_frq_x_kg_ref_risk_frq.gph, replace)
				window manage close graph
				keep snp risk alt gwas_weight gwas_risk gwas_p
				qui di as text"# >> saving as ........................................ "as result"tempfile-gwas.dta"
				qui {
					save tempfile-gwas.dta,replace	
					}
				}
			}
		}
	}
qui { // Module #3 - create profile scores
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #3 - create profile scores"	
	noi di as text"# > create profile score based on ....................... " as result "${gwas_short}"
	qui { 
		use tempfile-gwas.dta, replace
		rename (snp gwas_p) (SNP P)
		keep SNP P
		qui di as text"# >> define thresholds based on gwas data"
		qui {
			sum P
			noi di as text"# >> the minimum p in gwas .......................... p = " as result `r(min)'
			gen min = `r(min)'
			gen threshold = ""
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 "  if min < 1E-1
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 "  if min < 1E-2
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 "  if min < 1E-3
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4"  if min < 1E-4
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5" if min < 1E-5
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6"  if min < 1E-6
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7"  if min < 1E-7
			replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7 1E-8" if min < 1E-8
			outsheet threshold in 1 using _tmp.do, non noq replace
			do _tmp.do
			erase _tmp.do
			}
		noi di as text"# >> clump SNPs at the following thresholds ............. " as result`"${thresholds}"'
		qui {
			global ldprune        "--clump-p1 1 --clump-p2 1 --clump-r2 0.2 --clump-kb 1000" 
			noi di as text"# > process files - clump / make *.score *.q-score-file *.q-score-file-range *.profile file at each threshold"
			foreach threshold in $thresholds {
				use tempfile-gwas.dta, replace
				rename (snp gwas_p) (SNP P)
				keep SNP P
				noi di as text"# >> processing SNPs at ............................. P < " as result `threshold'
				qui di as text"# >>> define SNPs at P < "as result"``threshold' "as text "for clumping"
				outsheet SNP P if P < `threshold' using tempfile-P`threshold'.input-clump, noq replace
				qui di as text"# >>>  clump SNPs at P < "as result"`threshold' "as text "to identify ld-independent set for scoring"
				!${plink} --bfile ${profilescore_kg_ref} --clump tempfile-P`threshold'.input-clump ${ldprune} --out tempfile-P`threshold'
				!${tabbed} tempfile-P`threshold'.clumped
				import delim using 	tempfile-P`threshold'.clumped.tabbed, clear
				keep snp
				merge 1:1 snp using tempfile-gwas.dta 
				keep if _m == 3
				qui di as text"# >> create *.score for P< `threshold'  "
				qui {
					outsheet snp risk gwas_weight using tempfile-P`threshold'.score, non noq replace
					}
				qui di as text"# >> create *.q-score-file for P< `threshold'  "
				qui { 
					outsheet snp gwas_p           using tempfile-P`threshold'.q-score-file, non noq replace
					}
				qui di as text"# >> create *.q-score-file-range for P< `threshold'  "
				qui { 
					clear
					set obs 1
					gen a = "P`threshold'	0	`threshold'"
					outsheet a using  tempfile-P`threshold'.q-score-range, non noq replace
					}
				qui di as text"# > create *.profile file for each threshold for each dataset "
				foreach data of num 1 / $Ndata {
				qui di as text">> create data`data'.P`threshold'.profile"
				!${plink} --bfile         ${profilescore_data`data'} ///
									--score         tempfile-P`threshold'.score  ///
									--q-score-file  tempfile-P`threshold'.q-score-file ///
									--q-score-range tempfile-P`threshold'.q-score-range ///
									--out           data`data'
					}
				}
			}
		}
	}
qui { // Module #4 - combine profile scores into single file
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #4 - combine profile scores into single file"	
	foreach data of num 1 / $Ndata {
		noi di as text"# > join profile files into single file ................. " as result"${profilescore_data`data'}-final-profiles.dta"
		noi fam2dta, fam(${profilescore_data`data'})
		keep fid iid sex
		save data`data'-final-profiles.dta, replace
		qui di as text"# >> converting thresholds to varnames"
		foreach threshold in $thresholds {
			clear
			set obs 1
			gen a = "`threshold'"
			replace a = subinstr(a, "-", "_",.)
			replace a = "global tag p" + a
			outsheet a using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			noi di as text"# >> import data for ${profilescore_data`data'}.P`threshold'.profile"
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
qui { // Module #5 - make meta-log
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #5 - make meta-log"	
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
		noi di as text"# > report of gwas file"
		qui { 
			noi	di as text"# gwas ................................................. "as result"${gwas_prePRS}"
			noi	di as text"# gwas file short name ................................. "as result"${gwas_short}"
			!$zcat ${gwas_prePRS}.gz | $wc -l > gwas-input.count
			insheet using gwas-input.count, clear
			sum v1
			noi di as text"# >> number of SNPs in file (original) .................. N = "as result `r(max)'
			use tempfile-gwas.dta, clear
			count 
			noi di as text"# >> number of SNPs in file (intercept) ................. N = "as result `r(N)'
			count if gwas_p < 5e-8
			noi di as text"# >> number of SNPs in file (intercept + gws)............ N = "as result `r(N)'
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
				noi di as text"# >> number of SNPs in model (ld-independent + P < `threshold')  N = "as result `r(max)'
				}
			}
		noi di as text"# > report of genotype files"
		qui {
			foreach data of num 1 / $Ndata {
				noi di as text"# data`data' ................................................. "as result"${${profilescore_data`data'}}"
				noi bim2count, bim(${profilescore_data`data'})
				noi di as text"# >> data`data' profiles stored in ........................... "as result"${gwas_short}-by-${project_name}_data`data'_profiles.dta"
				}
			}
		noi di as text"#########################################################################"	
		log close
		}
	}
qui { // Module #6 - plot manhattan of intersect
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #6 - plot manhattan"	
	noi di as text"# > plot manhattan of intersect"
	clear
	set obs 1
	gen a = "`draw_manhattan'"
	if a == "yes" {
		qui {
		capture confirm file ${profilescore_kg_ref}_bim.dta
		if !_rc {
			noi di as text"# > "as input"bim2dta "as text".................. marker files already exist " as result "${profilescore_kg_ref}_bim.dta"
			}
		else {
			noi di as text"# > "as input"bim2dta "as text".............................. create marker  " as result "${profilescore_kg_ref}_bim.dta"
			noi bim2dta, bim(${profilescore_kg_ref})
			}
			use tempfile-gwas.dta, clear
			merge 1:1 snp using ${profilescore_kg_ref}_bim.dta
			graphmanhattan, chr(chr) bp(bp) p(gwas_p) max(100) min(1) 
			graph combine tmpManhattan.gph, title("manhattan-plot for PRS processed gwas ")  caption("CREATED: $S_DATE $S_TIME" "INPUT: ${gwas_prePRS}",	size(tiny))
			graph export gwas-processed-mahhattan.png, as(png) height(2000) width(4000) replace
			window manage close graph
			}	
		}
	else {
	}
	}
qui { // Module #7 - rename and clean
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #7 - move and clean"	
	qui {
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
			!copy "tempfile-P`threshold'.score"          ".\score\${gwas_short}_P`threshold'.score"
			!copy "tempfile-P`threshold'.q-score-file"   "..\q-score-file\${gwas_short}_P`threshold'.q-score-file"
			}
		!copy "tempfile.log"                 "..\\${gwas_short}-profilescore.meta-log"
		!copy "gwas-processed-mahhattan.png" "..\\${gwas_short}-profilescore-manhattan.png"
		}
	qui di as text"# > removing temporary folder"
	qui {
		cd ..
		!rmdir ${profilescore_temp_dir} /s /q 
		}
	clear
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	