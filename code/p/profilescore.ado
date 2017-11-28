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
#download the following executables from
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
syntax , param(string asis) 
	
di in white"#########################################################################"
di in white"# profilescore                                                           "
di in white"# version:       0.3                                                     "
di in white"# Creation Date: 5September2017                                          "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME                                               "
di in white"#########################################################################"

di in white"# > checking dependencies are correctly defined"
qui { 
	qui { // plink v1.9
		capture confirm file "$plink"
		if _rc==0 {
			noi di in green"# plink v1.9+ exists and is correctly assigned as  $plink"
			}
		else {
			noi di in red"# plink v1.9 does not exists; download executable from https://www.cog-genomics.org/plink2 "
			noi di in red"# set plink v1.9 location using;  "
			noi di in red`"# global plink "folder\file"  "'
			exit
			}
		}
	qui { // tabbed
		clear
		set obs 1
		gen a = "$tabbed"
		replace a = subinstr(a,"perl ","capture confirm file ",.)
		outsheet a using _ooo.do, non noq replace
		do _ooo.do
		if _rc==0 {
			noi di in green"# the tabbed.pl script exists and is correctly assigned as  $tabbed"
			noi di in green"# ..... ensuring perl is working on your system and can be called from the command-line"
			clear 
			set obs 10
			gen a = "a b c d"
			outsheet a using test_pl.txt, noq replace
			!$tabbed test_pl.txt
			capture confirm file "test_pl.txt.tabbed"
			if _rc==0 {
				noi di in green"# ..... the tabbed.pl script is working"
				}
			else {
				noi di in red"# ..... the tabbed.pl script did not work"
				noi di in red"# download and install active perl on your computer https://www.activestate.com/activeperl/downloads"
				exit
				}
			erase test_pl.txt
			erase test_pl.txt.tabbed
			}
		else {
			noi di in red"# tabbed.pl does not exists; download executable from https://github.com/ricanney/perl "
			noi di in red"# set tabbed.pl location using;  "
			noi di in red`"# global tabbed "folder\file"  "'
			exit
			}
		erase _ooo.do
		}
	}
di in white"# > checking all parameters are set"
qui { 
	di in white"# >> The parameter file should include the following information as globals"
	di in white"#    e.g. global project_folder E:\data"
	di in white"# >> running `param'"
	qui {
		do `param'
		}
	di in white"# >> define project_folder = working folder"
	di in white"# >>                         ${project_folder}"
	di in white"# >> define project_name   = project name"
	di in white"# >>                         ${project_name}"
	di in white"# >> define kg_ref         = reference genotypes (1000-genomes phase3 hg19 european ancestry"
	di in white"# >>                         ${kg_ref}"
	di in white"# >> define Ndata          = number of input genotype files"
	di in white"# >>                         ${Ndata}"
	di in white"# >> define data<n>        = location of genotypes for dataset<n>"
	foreach data of num 1 / $Ndata {
		di in white"# >>                 data`data' = ${data`data'}"
		}
	di in white"# >> define gwas_short     = short name of gwas"
	di in white"# >>                         ${gwas_short}"
	di in white"# >> define gwas_prePRS    = location of *-prePRS.tsv file corresponding to gwas_short (do not include .gz on filename)"
	di in white"# >>                         ${gwas_prePRS}"
	}	
di in white"# > checking parameters are correctly defined"
di in white"# > checking if ${gwas_prePRS}.gz / ${gwas_prePRS} is present"
qui { 
	capture confirm file "${gwas_prePRS}.gz"
	if _rc==0 {
			noi di in green"# > the input gwas is $gwas_short and was located at $gwas.gz"
			}
	else {
			capture confirm file "${gwas_prePRS}"
			if _rc==0 {
				noi di in green"# > the input gwas is $gwas_short and was located at $gwas"
				}
			else {
				noi di in red"# > the input gwas is $gwas_short and was not located at $gwas.gz"
				noi di in red"# > the input gwas is $gwas_short and was not located at $gwas"
				exit
				}
			}
	}
di in white"# > checking if genotypes files are present"
qui { 
		di in white"# >> $Ndata datasets are to be used to calculate PRS"
		foreach data of num 1 / $Ndata {
			foreach file in bed bim fam meta-log {
				capture confirm file "${data`data'}.`file'"
				if _rc==0 {
					noi di in green"# >> dataset #`data' *.`file' is located at ${data`data'}.`file'"
					}
				else {
					noi di in red"# >> dataset #`data' *.`file' was not located at ${data`data'}.`file'"
					exit
					}
				}
			}
		}
di in white"# > checking if ${kg_ref} files are present"
qui { 
	foreach file in bed bim fam  {
		capture confirm file "${kg_ref}.`file'"
		if _rc==0 {
			noi di in green"# >> the reference genotypes are located at $kg_ref.`file'"
			}
		else {
			noi di in red"# >> the reference genotypes are not located at $kg_ref.`file'"
			exit
			}
		}
	}
di in white"# > the working directory is ${project_folder}"
qui { 
	cd ${project_folder}
	}
di in white"# > creating a temp folder in ${project_folder}"
qui { 
	clear
	set obs 1
	ralpha folderRandom, range(A/z) l(10)
	gen a = "global tmp_wd  " + folderRandom
	outsheet a using _setwd.do, non noq replace
	do _setwd.do
	erase _setwd.do
	!mkdir ${tmp_wd}
	cd     ${tmp_wd}
	}	
di in white"# > processing gwas data"
qui { 
	di in white"# >> unzipping archive"
	qui { 
		!$gunzip ${gwas}.gz
		}
	di in white"# >> importing prePRS format file"
	qui {
		import delim using ${gwas_prePRS}, clear
		}
	di in white"# >> create risk allele, riskOR and weight"
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
		rename _gt gt
		keep  chr bp rsid risk alt gt weight p risk_frq
		order chr bp rsid risk alt gt weight p risk_frq
		for var risk alt gt weight p risk_frq: rename X gwas_X
		di in white"# >> removing duplicates"
		duplicates drop
		duplicates tag rsid, gen(dups)
		keep if dups == 0
		drop dups
		}
	di in white"# >> saving tempfile"
	qui {
		save tempfile-gwas.dta,replace	
		}
	di in white"# >> zipping back to archive"
	qui { 
		!$gzip ${gwas_prePRS}
		}
	}
di in white"# > processing genotype data"
di in green"#   as of 27-November-2017, the profilescore calculates scores for all individuals in dataset"
di in green"#   exclusion based on ancestry is to be performed after calculations "
di in red  "#   caveat : ld clumping is based on ${kg_ref}"
qui { 
	foreach data of num 1 / $Ndata {
		di in white"# >> processing ${data`data'} (`data' of ${Ndata})"
		qui {
			di in white"# >> import plink *.bim file"
			bim2frq, bim(${data`data'})
			bim2dta, bim(${data`data'})
			di in white"# >> limit to autosomes"
			for var chr bp: tostring X,replace
			drop if chr == "23" | chr == "24" | chr == "25"
			drop chr bp		
			di in white "# >> drop problematic SNPs (ID/ W/ S)"
			drop if gt == "ID" | gt == "W" | gt == "S"
			di in green"# as of 27-November-2017, the profilescore does not rename to rsid"
			di in green"# this should have been applied in Module #3 of genoytpeqc"	
			rename snp rsid
			di in white"# >> merge frq.dta"
			merge 1:1 rsid a1 using ${data`data'}_frq.dta
			keep if _m == 3
			drop _m
			for var a1 a2 gt a1_frq: rename X data`data'_X
			di in white"# >> removing duplicates"
			duplicates drop
			duplicates tag rsid, gen(dups)
			keep if dups == 0
			drop dups
			di in white"# >> save processed file"
			save tempfile-data`data'.dta, replace
			di in white"# >> save processed file"
			}
		}
	}
di in white"# > merging rsid over files"
qui { 
	di in white"# >> open tempfile-gwas.dta"
	use tempfile-gwas.dta, clear
	foreach data of num 1 / $Ndata {
		di in white "# >> merge 1:1 rsid against tempfile-data`data'.dta"
		merge 1:1 rsid using tempfile-data`data'.dta
		keep if _m ==3
		drop _m
		save tempfile-combined.dta, replace
		}
	}
di in white"# > mapping to a common strand [risk - alt]"
qui { 
	foreach data of num 1 / $Ndata {
		di in white "# >> cross-tabulate gwas genotype coding with data`data'"
		noi ta gwas_gt data`data'_gt
		drop data`data'_gt
		recodestrand, ref_a1(gwas_risk) ref_a2(gwas_alt) alt_a1(data`data'_a1) alt_a2(data`data'_a2)
		di in white "# >> recode allele from data`data' where there are strand flips"
		replace data`data'_a1 = _tmpb1 if _tmpflip == 1
		replace data`data'_a2 = _tmpb2 if _tmpflip == 1
		di in white "# >> export list of SNPs to flip strand in data`data' plink binaries"
		outsheet rsid if _tmpflip == 1 using tempfile-data`data'.flip, non noq replace
		drop _tmpflip -_tmpb1 _tmpb2
		order chr bp rsid gwas_risk gwas_alt gwas_gt gwas_weight gwas_p gwas_risk_frq data`data'_a1 data`data'_a2 data`data'_a1_frq
		}
	}
di in white"# > plot allele-frequencies between datasets"
qui {
	drop gwas_gt
	global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
	foreach data of num 1 / $Ndata {
		di in white "# >> two-way scatter plot of allele frq betweeen gwas and data`data'"
		gen data`data'_risk_frq = .
		replace data`data'_risk_frq =    data`data'_a1_frq if data`data'_a1 == gwas_risk
		replace data`data'_risk_frq = 1- data`data'_a1_frq if data`data'_a1 == gwas_alt
		tw scatter gwas_risk_frq data`data'_risk_frq, ${format} saving(tempfile-2-gwas_risk_frq_x_data`data'_risk_frq.gph, replace)
		drop data`data'_a1 data`data'_a2 data`data'_a1_frq
		}
	}
di in white"# > rename variables / save tempfile / create intersect.extract"
qui {
	rename (gwas_risk gwas_alt) (risk alt)
	aorder
	order chr bp rsid risk alt gwas_weight gwas_p gwas_risk_frq
	sort chr bp
	save tempfile-combined-flipped.dta, replace
	outsheet rsid using intersect.extract, non noq replace
	}
di in white"# > extract intersect and flip alleles"
qui {
	foreach data of num 1 / $Ndata {
		di in white "# >> extract intersect for ${data`data'}"
		qui { 
			!$plink --bfile ${data`data'} --extract intersect.extract --make-bed --out data`data'-intersect
			}
		di in white "# >> flips strands"
		qui{ 
			!$plink --bfile data`data'-intersect --flip tempfile-data`data'.flip --make-bed --out data`data'-intersect-flipped
			}
		}
	}
di in white"# > extract intersect on ${kg_ref}"
qui { 
	!$plink --bfile ${kg_ref} --extract intersect.extract --make-bed --out tempfile-ref
	}
di in white"# > clump gwas intersect"
qui { 
	use tempfile-combined-flipped.dta, replace
	rename (rsid gwas_p) (SNP P)
	keep SNP P
	di in white"# >> define minimum p"
	qui {
		sum P
		gen min = `r(min)'
		gen threshold = ""
		replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4"  if min < 1E-4
		replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5" if min < 1E-5
		replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6"  if min < 1E-6
		replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7"  if min < 1E-7
		replace threshold =  "global thresholds 1E-0 5E-1 1E-1 5E-2 1E-2 1E-3 1E-4 1E-5 1E-6 1E-7 1E-8" if min < 1E-8
		outsheet threshold in 1 using _tmp.do, non noq replace
		do _tmp.do
		}
	di in white "# >> clump SNPs at ${thresholds}"
	qui {
		global ldprune        "--clump-p1 1 --clump-p2 1 --clump-r2 0.2 --clump-kb 1000" 
		foreach threshold in $thresholds {
			di in white "# >>> define SNPs at P < `threshold' for clumping"
			outsheet SNP P if P < `threshold' using tempfile-P`threshold'.input-clump, noq replace
			di in white "# >>>  clump SNPs at P < `threshold' to identify ld-independent set for scoring"
			!${plink} --bfile tempfile-ref --clump tempfile-P`threshold'.input-clump ${ldprune} --out tempfile-P`threshold'
			}
		}
	}
di in white"# > create *.score\ *.q-score file for each threshold"
qui {	
		foreach threshold in $thresholds {
			!${tabbed} tempfile-P`threshold'.clumped
			import delim using 	tempfile-P`threshold'.clumped.tabbed, clear
			keep snp
			rename (snp) (rsid)
			merge 1:1 rsid using tempfile-gwas.dta 
			keep if _m == 3
			di in white "# >> create *.score for P< `threshold'  "
			qui {
				outsheet rsid gwas_risk gwas_weight using tempfile-P`threshold'.score, non noq replace
				!copy "tempfile-P`threshold'.score"          "..\\${gwas_short}-by-${project_name}_P`threshold'.score"
				}
			di in white "# >> create *.q-score-file for P< `threshold'  "
			qui { 
				outsheet rsid gwas_p           using tempfile-P`threshold'.q-score-file, non noq replace
				!copy "tempfile-P`threshold'.q-score-file"   "..\\${gwas_short}-by-${project_name}_P`threshold'.q-score-file"
				}
			di in white "# >> create *.q-score-file-range for P< `threshold'  "
			qui { 
				clear
				set obs 1
				gen a = "P`threshold'	0	`threshold'"
				outsheet a using  tempfile-P`threshold'.q-score-range, non noq replace
				}
			}
		}
di in white"# > create *.profile file for each threshold for each dataset "
qui {	
	foreach data of num 1 / $Ndata {
		foreach threshold in $thresholds {
			di in white "- create *.profile for P< `threshold' for data`data'"
			!${plink} --bfile         data`data'-intersect-flipped ///
								--score         tempfile-P`threshold'.score  ///
								--q-score-file  tempfile-P`threshold'.q-score-file ///
								--q-score-range tempfile-P`threshold'.q-score-range ///
								--out           data`data'-intersect-flipped
				}
		}
	}
di in white"# > process *.profile files"
qui {
	foreach data of num 1 / $Ndata {
		fam2dta, fam(data`data'-intersect-flipped)
		keep fid iid sex
		save data`data'-final-profiles.dta, replace
		di in white" # >> converting thresholds to varnames"
		foreach threshold in $thresholds {
			clear
			set obs 1
			gen a = "`threshold'"
			replace a = subinstr(a, "-", "_",.)
			replace a = "global tag p" + a
			outsheet a using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			di in white"# >>import data for P`threshold'.profile"
			!$tabbed           data`data'-intersect-flipped.P`threshold'.profile
			import delim using data`data'-intersect-flipped.P`threshold'.profile.tabbed, case(lower) clear
			erase data`data'-intersect-flipped.P`threshold'.profile
			erase data`data'-intersect-flipped.P`threshold'.profile.tabbed
			keep fid - score
			for var fid iid: tostring X, replace
			for var cnt cnt2 score: rename X ${tag}_X
			merge 1:1 fid iid using data`data'-final-profiles.dta
			drop _m
			order fid iid sex 
			save data`data'-final-profiles.dta, replace
			outsheet using data`data'-final-profiles.csv, comma noq replace
			}
		}
	}
di in white"# > make *.meta-log"
qui { 
	log using tempfile-4.log, replace
	noi di"#########################################################################"
	noi di"# Polygenic Risk Score Processing Report - from GWAS + GENOTYPE > PROFILE"                                                                
	noi di"#########################################################################"
	noi di"# Author ........................... Richard Anney (AnneyR@Cardiff.ac.uk)"
	noi di"# Date ............................. $S_DATE $S_TIME"
	noi di"#########################################################################"			
	noi di"# codebook for *profile.dta "
	noi di"#########################################################################"
	noi di"# fid .................. family identifier ............................. string"
	noi di"# iid .................. individual identifier ......................... string"
	noi di"# sex .................. sex ........................................... 1 = male; 2= female"
	noi di"# P#E_#_cnt ............ number of alleles present in the model ........ numeric"
	noi di"# P#E_#_cnt2 ........... total number of named alleles observed ........ numeric"
	noi di"# P#E_#_score .......... weighted score ................................ numeric"
	noi di"#########################################################################"
	noi di"# Scores were calculated using PLINK. Scores are created using weights    "
	noi di"# (log(OR)). Final scores are averages of valid per-allele scores. By     "
	noi di"# default, copies of the unnamed allele contribute zero to score, while   "
	noi di"# missing genotypes contribute an amount proportional to the loaded (via  "
	noi di"# --read-freq) or imputed allele frequency.                               "
	noi di"#########################################################################"
	noi di"# risk scores based on ..... ${gwas_prePRS} "
	qui { 
		foreach data of num 1 / $Ndata {
			noi di"# data`data'  ................... ${data`data'}"
			}
		}
	noi di"#########################################################################"
	qui { // calculate number of SNPs in datasets / gwas
		!$zcat ${gwas_prePRS}.gz | $wc -l > gwas-input.count
		insheet using gwas-input.count, clear
		sum v1
		global N_snps_gwas_input `r(max)'
		noi di"# number of SNPs in original gwas file ........................ N = ${N_snps_gwas_input}"
		use tempfile-combined.dta, clear
		count 
		global N_snps_gwas_output `r(N)'
		noi di"# number of SNPs intrecepting all datasets and gwas  .......... N = ${N_snps_gwas_output}"
		count if gwas_p < 5e-8
		global N_snps_gws_output `r(N)'
		noi di"# number of genome-wide-significant SNPs in input file ........ N = ${N_snps_gws_output}"
		noi di"#########################################################################"	
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
		use data1-final-profiles.dta, clear		
		foreach threshold in $tempThreshold { 
			sum p`threshold'_cnt
			global N_snps_model_p`threshold' `r(max)'
			noi di"# number of ld-independent SNPs in model (P < `threshold') .... N = ${N_snps_model_p`threshold'}"
			}
		}
	qui { // calculate data specific information 
		foreach data of num 1 / $Ndata {
			qui { // pull information from meta-log
				import delim using  ${data`data'}.meta-log, clear delim("#")
				keep v2
				foreach num of num 1/50 {
					replace  v2 = subinstr(v2, "..", "$",.)
					}
				replace  v2 = subinstr(v2, "$.", "$",.)
				foreach num of num 1/50 {
					replace  v2 = subinstr(v2, "$$", "$",.)
					}
				replace  v2 = subinstr(v2, "  ", " ",.)
				replace  v2 = subinstr(v2, "  ", " ",.)
				replace  v2 = subinstr(v2, "  ", " ",.)
				split v2,p(" $ ")
				gen a = ""
				replace a = "global data`data'_file "  + `"""' + v22 + `"""' if v21 == "Input File" 
				replace a = "global data`data'_array " + `"""' + v22 + `"""' if v21 == "Input Array (Approximated)" 
				replace a = "global data`data'_build " + `"""' + v22 + `"""' if v21 == "Output Genome Build"  
				replace a = "global data`data'_SNPs "  + `"""' + v22 + `"""' if v21 == "Output Total Markers" 
				replace a = "global data`data'_ind "   + `"""' + v22 + `"""' if v21 == "Output Total Individuals"
				drop if a == ""
				outsheet a using tempfile.do, non noq replace
				do tempfile.do
				erase tempfile.do
				}
			noi di"#########################################################################"	
			noi di"# data`data'  ............................................... ${data`data'_file}"
			noi di"# > data`data' array is ..................................... ${data`data'_array}"
			noi di"# > data`data' build is ..................................... ${data`data'_build}"
			noi di"# > data`data' N SNPs is original ........................... N = ${data`data'_SNPs}"
			noi di"# > number of SNPs intrecepting all datasets and gwas .. N = ${N_snps_gwas_output}"
			noi di"# > data`data' N individuals is ............................. N = ${data`data'_ind}"
			noi di"# > data`data' profiles stored in ........................... ${gwas_short}-by-${project_name}_data`data'_profiles.dta"
			}
	}
	noi di"#########################################################################"	
	log close
	}
di in white"# > plotting manhattan for intersect"
qui {
	use tempfile-combined.dta, clear
	graphmanhattan, chr(chr) bp(bp) p(gwas_p) max(100) min(1) 
	graph combine tmpManhattan.gph, title("manhattan-plot for PRS processed gwas ")  caption("CREATED: $S_DATE $S_TIME" "INPUT: ${gwas_prePRS}",	size(tiny))
	graph export gwas-processed-mahhattan.png, as(png) height(2000) width(4000) replace
	window manage close graph
	}	
di in white"# > copy file from working folder to project folder  "
qui {
	foreach data of num 1 / $Ndata {	
		!copy "data`data'-final-profiles.dta"   "..\\${gwas_short}-by-${project_name}_data`data'_profiles.dta"
		!copy "data`data'-final-profiles.csv"   "..\\${gwas_short}-by-${project_name}_data`data'_profiles.csv"
		graph use "tempfile-2-gwas_risk_frq_x_data`data'_risk_frq.gph" 
		graph export "..\\${gwas_short}-by-${project_name}_sanity-check-gwas-vs-data`data'-allele-frequencies.png", as(png) height(500) width(1000) replace
		window manage close graph
		}
	!copy "tempfile-4.log"               "..\\${gwas_short}-by-${project_name}.meta-log"
	!copy "gwas-processed-mahhattan.png" "..\\${gwas_short}-by-${project_name}_intersect_manhattan.png"
	}
di in white"# > removing temporary folder"
qui {
	cd ..
	!rmdir ${tmp_wd} /s /q 
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;
	