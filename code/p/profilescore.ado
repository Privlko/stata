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
syntax , param(string asis) 

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
		foreach data of num 1 / $Ndata {
			noi checkfile, file(${data`data'}.bed)
			noi checkfile, file(${data`data'}.bim)
			noi checkfile, file(${data`data'}.fam)
			noi checkfile, file(${data`data'}.meta-log)
			}
		noi checkfile, file(${kg_ref}.bed)
		noi checkfile, file(${kg_ref}.bim)
		noi checkfile, file(${kg_ref}.fam)
		}
	qui di as text"# > create temp directory"
	qui {
		cd ${project_folder}
		noi create_temp_dir
		}
	}
qui { // Module #1 - processing GWAS summary data
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #1 - processing GWAS summary data"
  noi	di as text"# > unzipping / importing / zipping ..................... "as result"${gwas_prePRS}.gz"
	qui {
		noi checkfile, file(${gwas_prePRS}.gz)
		!$gunzip ${gwas_prePRS}.gz
		noi checkfile, file(${gwas_prePRS})
		import delim using ${gwas_prePRS}, clear
		!$gzip ${gwas_prePRS}
		noi checkfile, file(${gwas_prePRS}.gz)
		}
  noi	di as text"# > processing gwas summary data ........................ "as result"${gwas_prePRS}"
	qui { 
		qui di as text"# >> create risk allele, riskOR and weight"
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
			}
		qui di as text"# >> removing duplicates"
		qui {
			duplicates drop
			duplicates tag rsid, gen(dups)
			keep if dups == 0
			drop dups
			}
		qui di as text"# >> saving as ........................................ "as result"tempfile-gwas.dta"
		qui {
			save tempfile-gwas.dta,replace	
			}
		}
	}
qui { // Module #2 - processing genotype data
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #2 - processing genotype data"
	noi	di as text"# > number of genotype datasets to process .............. "as result"$Ndata"
	foreach data of num 1 / $Ndata {
		noi di as text"# > processing .......................................... "as result"${data`data'}"as text"  (`data' of ${Ndata})"
		qui {
			noi di as text"# >> define a1_frq for .................................. " as result"${data`data'}"
			noi bim2frq, bim(${data`data'})
			rename (snp maf) (rsid a1_frq)
			keep rsid a1 a1_frq
			save ${data`data'}_frq2.dta,replace
			noi di as text"# >> process ............................................ " as result"${data`data'}.bim"
			noi bim2dta, bim(${data`data'})
			qui di as text"# >> limit to autosomes"
			qui { 
				for var chr bp: tostring X,replace
				drop if chr == "23" | chr == "24" | chr == "25"
				drop chr bp		
				}
			qui di as text"# >> drop problematic SNPs (ID/ W/ S)"
			qui { 
				drop if gt == "ID" | gt == "W" | gt == "S"
				}
			rename snp rsid
			qui di as text"# >> merge frq.dta"
			qui {
				merge 1:1 rsid a1 using ${data`data'}_frq2.dta
				erase ${data`data'}_frq2.dta
				keep if _m == 3
				drop _m
				for var a1 a2 gt a1_frq: rename X data`data'_X
				qui di as text"# >> removing duplicates"
				duplicates drop
				duplicates tag rsid, gen(dups)
				keep if dups == 0
				drop dups
				}
			noi di as text"# >> processed marker file saved as ..................... " as result"tempfile-data`data'.dta"
			qui {
				save tempfile-data`data'.dta, replace
				}
			}
		}
	}
qui { // Module #3 - merging GWAS and genotype data to define intersect
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #3 - merging GWAS and genotype data to define intersect"
	noi	di as text"# > opening  ............................................ "as result"tempfile-gwas.dta"
	qui {
		use tempfile-gwas.dta, clear
		}
	foreach data of num 1 / $Ndata {
		noi di as text"# > merge 1:1 rsid against .............................. " as result"tempfile-data`data'.dta"
		merge 1:1 rsid using tempfile-data`data'.dta
		keep if _m ==3
		drop _m
		save tempfile-combined.dta, replace
		}
	noi di as text"# > save combined file .................................. "as result"tempfile-combined.dta"
	}
qui { // Module #4 - mapping to the same strand
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #4 - map alleles to the same strand"	
	noi di as text"# > map all snps to a common strand [risk - alt] based on gwas data"
	foreach data of num 1 / $Ndata {
		noi di as text"# >> cross-tabulate gwas genotype coding with ........... "as result"data`data'"
		noi ta gwas_gt data`data'_gt
		drop data`data'_gt
		recodestrand, ref_a1(gwas_risk) ref_a2(gwas_alt) alt_a1(data`data'_a1) alt_a2(data`data'_a2)
		qui di as text"# >> recode allele from "as result"data`data' "as text "where there are strand flips"
		replace data`data'_a1 = _tmpb1 if _tmpflip == 1
		replace data`data'_a2 = _tmpb2 if _tmpflip == 1
		noi di as text"# >> list of SNPs to flip strand exported to ............ "as result"tempfile-data`data'.flip"
		outsheet rsid if _tmpflip == 1 using tempfile-data`data'.flip, non noq replace
		drop _tmpflip -_tmpb1 _tmpb2
		order chr bp rsid gwas_risk gwas_alt gwas_gt gwas_weight gwas_p gwas_risk_frq data`data'_a1 data`data'_a2 data`data'_a1_frq
		}
	qui di as text"# > plot allele-frequencies between datasets"
	qui {
		drop gwas_gt
		global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
		foreach data of num 1 / $Ndata {
			noi di as text"# >> plot two-way scatter of allele frq betweeen gwas and "as result"data`data'"as text" to "as result"tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph"
			gen data`data'_risk_frq = .
			replace data`data'_risk_frq =    data`data'_a1_frq if data`data'_a1 == gwas_risk
			replace data`data'_risk_frq = 1- data`data'_a1_frq if data`data'_a1 == gwas_alt
			tw scatter gwas_risk_frq data`data'_risk_frq, ${format} saving(tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph, replace)
			drop data`data'_a1 data`data'_a2 data`data'_a1_frq
			window manage close graph
			}
		}
	noi di as text"# > rename variables / save tempfile / create intersect.extract"
	qui {
		rename (gwas_risk gwas_alt) (risk alt)
		aorder
		order chr bp rsid risk alt gwas_weight gwas_p gwas_risk_frq
		sort chr bp
		noi di as text"# >> combined dataset saved as .......................... "as result"tempfile-combined-flipped.dta"
		save tempfile-combined-flipped.dta, replace
		noi di as text"# >> list of SNPs that intersect gwas/ genotypes ........ "as result"intersect.extract"
		outsheet rsid using intersect.extract, non noq replace
		}
	}
qui { // Module #5 - processing genotype data
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #5 - processing genotype data"			
	noi di as text"# > extract intersect and flip alleles using plink"
	qui {
		foreach data of num 1 / $Ndata {
			noi di as text"# >> extract intersect on ............................... "as result"${data`data'}"
			!$plink --bfile ${data`data'} --extract intersect.extract --make-bed --out data`data'-intersect
			noi di as text"# >> flip strands on .................................... "as result"${data`data'}"
			!$plink --bfile data`data'-intersect --flip tempfile-data`data'.flip --make-bed --out data`data'-intersect-flipped
			}
		noi di as text"# >> extract intersect on ............................... "as result"${kg_ref}"
		!$plink --bfile ${kg_ref} --extract intersect.extract --make-bed --out tempfile-ref
		}
	}
qui { // Module #6 - create profile scores
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #6 - create profile scores"	
	noi di as text"# > create profile score based on ....................... " as result "${gwas_short}"
	qui { 
		use tempfile-combined-flipped.dta, replace
		rename (rsid gwas_p) (SNP P)
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
				use tempfile-combined-flipped.dta, replace
				rename (rsid gwas_p) (SNP P)
				keep SNP P
				noi di as text"# >> processing SNPs at ............................. P < " as result `threshold'
				qui di as text"# >>> define SNPs at P < "as result"``threshold' "as text "for clumping"
				outsheet SNP P if P < `threshold' using tempfile-P`threshold'.input-clump, noq replace
				qui di as text"# >>>  clump SNPs at P < "as result"`threshold' "as text "to identify ld-independent set for scoring"
				!${plink} --bfile tempfile-ref --clump tempfile-P`threshold'.input-clump ${ldprune} --out tempfile-P`threshold'
				!${tabbed} tempfile-P`threshold'.clumped
				import delim using 	tempfile-P`threshold'.clumped.tabbed, clear
				keep snp
				rename (snp) (rsid)
				merge 1:1 rsid using tempfile-gwas.dta 
				keep if _m == 3
				qui di as text"# >> create *.score for P< `threshold'  "
				qui {
					outsheet rsid gwas_risk gwas_weight using tempfile-P`threshold'.score, non noq replace
					}
				qui di as text"# >> create *.q-score-file for P< `threshold'  "
				qui { 
					outsheet rsid gwas_p           using tempfile-P`threshold'.q-score-file, non noq replace
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
				qui di as text">> create data`data'-intersect-flipped.P`threshold'.profile"
				!${plink} --bfile         data`data'-intersect-flipped ///
									--score         tempfile-P`threshold'.score  ///
									--q-score-file  tempfile-P`threshold'.q-score-file ///
									--q-score-range tempfile-P`threshold'.q-score-range ///
									--out           data`data'-intersect-flipped
					}
				}
			}
		}
	}
qui { // Module #7 - combine profile scores into single file
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #7 - combine profile scores into single file"	
	foreach data of num 1 / $Ndata {
		noi di as text"# > join profile files into single file ................. " as result"data`data'-final-profiles.dta"
		noi fam2dta, fam(data`data'-intersect-flipped)
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
			noi di as text"# >> import data for data`data'-intersect-flipped.P`threshold'.profile"
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
qui { // Module #8 - make meta-log
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #8 - make meta-log"	
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
		noi di as text"# risk scores based on ..... "as result"${gwas_prePRS} "
		qui { 
		foreach data of num 1 / $Ndata {
			noi di as text"# data`data'  ................... "as result"${data`data'}"
			}
		}
		noi di as text"#########################################################################"
		qui { // calculate number of SNPs in datasets / gwas
			!$zcat ${gwas_prePRS}.gz | $wc -l > gwas-input.count
			insheet using gwas-input.count, clear
			sum v1
			noi di as text"# SNPs in original gwas file ........................ N = "as result `r(max)'
			use tempfile-combined.dta, clear
			count 
			noi di as text"# SNPs intrecepting all datasets and gwas ........... N = "as result `r(N)'
			count if gwas_p < 5e-8
			noi di as text"# Genome-wide-significant SNPs in gwas .............. N = "as result `r(N)'
			noi di as text"#########################################################################"	
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
				noi di as text"# ld-independent SNPs in model " as input" (at P < `threshold') " as text"....... N = "as result `r(max)'
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
			noi di as text"#########################################################################"
			noi di as text"# " as result "data`data' " as text ".................................................. "as result"${data`data'_file}"
			noi di as text"# " as result "data`data' " as text "array is ......................................... "as result"${data`data'_array}"
			noi di as text"# " as result "data`data' " as text "build is ......................................... "as result"${data`data'_build}"
			noi di as text"# " as result "data`data' " as text "N SNPs is original ........................... N = "as result"${data`data'_SNPs}"
			noi di as text"# " as result "data`data' " as text "N individuals is ............................. N = "as result"${data`data'_ind}"
			noi di as text"# " as result "data`data' " as text "profiles stored in ............................... "as result"${gwas_short}-by-${project_name}_data`data'_profiles.dta"
			}
		}
		noi di as text"#########################################################################"	
		log close
		}
	}
qui { // Module #9 - plot manhattan of intersect
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #9 - make meta-log"	
	noi di as text"# > plot manhattan of intersect"
	qui {
		use tempfile-combined.dta, clear
		graphmanhattan, chr(chr) bp(bp) p(gwas_p) max(100) min(1) 
		graph combine tmpManhattan.gph, title("manhattan-plot for PRS processed gwas ")  caption("CREATED: $S_DATE $S_TIME" "INPUT: ${gwas_prePRS}",	size(tiny))
		graph export gwas-processed-mahhattan.png, as(png) height(2000) width(4000) replace
		window manage close graph
		}	
	}
qui { // Module #10 - rename and clean
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #10 - move and clean"	
	qui {
		foreach data of num 1 / $Ndata {	
			!copy "data`data'-final-profiles.dta"   "..\\${gwas_short}-by-${project_name}_data`data'_profiles.dta"
			!copy "data`data'-final-profiles.csv"   "..\\${gwas_short}-by-${project_name}_data`data'_profiles.csv"
			graph use "tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph" 
			graph export "..\\${gwas_short}-by-${project_name}_sanity-check-gwas-vs-data`data'-allele-frequencies.png", as(png) height(500) width(1000) replace
			window manage close graph
			}
		foreach threshold in $thresholds {
			!copy "tempfile-P`threshold'.score"          "..\\${gwas_short}-by-${project_name}_P`threshold'.score"
			!copy "tempfile-P`threshold'.q-score-file"   "..\\${gwas_short}-by-${project_name}_P`threshold'.q-score-file"
			}
		!copy "tempfile.log"               "..\\${gwas_short}-by-${project_name}.meta-log"
		!copy "gwas-processed-mahhattan.png" "..\\${gwas_short}-by-${project_name}_intersect_manhattan.png"
		}
	qui di as text"# > removing temporary folder"
	qui {
		cd ..
		!rmdir ${temp_dir} /s /q 
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	