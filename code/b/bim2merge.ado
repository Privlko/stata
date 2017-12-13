program bim2merge
syntax , bim(string asis) ref_bim(string asis) project(string asis)

qui di as text"#########################################################################"
qui di as text"# profilescore_merge_gt - a routine to merge genotype datasets "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME                                               "
qui di as text"#########################################################################"

qui di as text"# > define files to merge"
qui {
	clear
	set obs 1
	gen a = "`ref_bim',`bim'"
	split a,p(",")
	drop a
	gen x = 1
	reshape long a, i(x) j(obs)
	count
	noi di as text"# > "as input"bim2merge "as text" - number of bim files to merge ........... " as result `r(N)'
	gen b = _n
	tostring b, replace
	gen c = "global bim2merge_data" + b + " " + a
	outsheet c using _tmp.do, non noq replace
	do _tmp.do
	erase _tmp.do
	split a,p("\")
	gen a_final = ""
	for var a1-a_final: replace a_final = X if X!="" 	
	gen d = "global bim2merge_newname" + b + " " + a_final + "-intersect"
	outsheet d using _tmp.do, non noq replace
	do _tmp.do
	erase _tmp.do
	}
noi di as text"# > check path of input files is true"
qui{
	count
	global bim2merge_dataN `r(N)'
	foreach num of num 1 / $bim2merge_dataN {
		noi checkfile, file(${bim2merge_data`num'}.bim)
		noi checkfile, file(${bim2merge_data`num'}.bed)
		noi checkfile, file(${bim2merge_data`num'}.fam)
		}
	}	
noi di as text"# > check path of dependent software is true"
qui { 
	noi checkfile, file(${plink})
	noi checktabbed
	}
qui di as text"# > create temp directory"
qui {
	noi create_temp_dir
	}
noi di as text"# > "as input"bim2merge "as text" create frq files "
qui {
	foreach num of num 1 / $bim2merge_dataN {
		capture confirm file ${bim2merge_data`num'}_frq.dta 
		if !_rc {
			noi di as text"# > "as input"bim2merge "as text"............. frequency files already exist " as result "${bim2merge_data`num'}_frq.dta"
			}
		else {
			noi di as text"# > "as input"bim2merge "as text".................... create frequency files " as result "${bim2merge_data`num'}_frq.dta"
			noi bim2frq, bim(${bim2merge_data`num'})
			}

		}
	}
qui di as text"# > limit to autosome"
qui {
	capture confirm file ${bim2merge_data1}_bim.dta 
	if !_rc {
		noi di as text"# > "as input"bim2merge "as text"................ marker files already exist " as result "${bim2merge_data1}_bim.dta"
		use ${bim2merge_data1}_bim.dta ,clear
		}
	else {
		noi di as text"# > "as input"bim2merge "as text"............................ create marker  " as result "${bim2merge_data1}_bim.dta"
		noi bim2dta, bim(${bim2merge_data1})
		}
	for var chr bp: tostring X,replace
	drop if chr == "23" | chr == "24" | chr == "25"
	}
qui di as text"# > remove ambiguous markers"
qui {
	drop if gt == "W" | gt == "S"
	}
qui di as text"# > merge _frq files"
qui {
	keep chr bp snp
	foreach num of num 1 / $bim2merge_dataN {
		merge 1:1 snp using ${bim2merge_data`num'}_frq.dta
		keep if _m == 3
		drop a2 _m
		for var gt a1 maf: rename X X_data`num'
		}
	}
noi di as text"# > "as input"bim2merge "as text" map snps to common strand "
qui{
	foreach data of num 2 / $bim2merge_dataN {
		noi di as text"# >> cross-tabulate gwas genotype coding with ........... "as result"data`data'"
		noi ta gt_data1 gt_data`data',m
		gen flip`data' = .
		replace flip`data' = 1 if (gt_data1 == gt_data`data') 
		replace flip`data' = 2 if (gt_data1 == "R" & gt_data`data' == "Y")
		replace flip`data' = 2 if (gt_data1 == "Y" & gt_data`data' == "R")
		replace flip`data' = 2 if (gt_data1 == "K" & gt_data`data' == "M")
		replace flip`data' = 2 if (gt_data1 == "M" & gt_data`data' == "K")
		drop if flip`data' == .
		}
	outsheet snp using intersect.extract, non noq replace
	noi di as text"# >> extract intersect on ............................... "as result"${bim2merge_data1}"
	noi di as text"# >> create ............................................. "as result"${bim2merge_newname1}"
	!$plink --bfile ${bim2merge_data1} --extract intersect.extract --make-bed --out ${bim2merge_newname1}
	foreach data of num 2 / $bim2merge_dataN {
		noi di as text"# >> extract intersect on ............................... "as result"${bim2merge_data`data'}"
		!$plink --bfile ${bim2merge_data`data'} --extract intersect.extract --make-bed --out data`data'-intersect
		outsheet snp if flip`data' == 2 using tempfile-data`data'.flip, non noq replace
		noi di as text"# >> flip strands on .................................... "as result"${data`data'}"
		noi di as text"# >> create ............................................. "as result"${bim2merge_newname`data'}"
		!$plink --bfile data`data'-intersect --flip tempfile-data`data'.flip --make-bed --out ${bim2merge_newname`data'}
		!del data`data'-intersect.* tempfile-data`data'.flip
		}
	}
qui di as text"# > plot allele-frequencies between datasets"
qui {
	global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
	foreach data of num 2 / $bim2merge_dataN {
		replace maf_data`data' = 1- maf_data`data' if flip`data' == 2
		replace maf_data`data' = 1- maf_data`data' if a1_data1 != a1_data`data'
		noi di as text"# >> plot two-way scatter of allele frq betweeen data1 and "as result"data`data'"as text" to "as result"tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph"
		tw scatter maf_data1 maf_data`data', ${format} caption("data1 = ${bim2merge_data1}""data`data' = ${bim2merge_data`data'}") saving(tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph, replace)
		window manage close graph
		}
	}
noi di as text"# > "as input"bim2merge "as text" create log to ............................ " as result "`project'.log"
qui { 
	log using `project'.log, replace
	noi di as text"#########################################################################"
	noi di as text"# Polygenic Risk Score Processing Report - from GWAS + GENOTYPE > PROFILE"                                                                
	noi di as text"#########################################################################"
	noi di as text"# Author ................................................ Richard Anney (AnneyR@Cardiff.ac.uk)"
	noi di as text"# Date .................................................. $S_DATE $S_TIME"
	noi di as text"#########################################################################"			
	noi di as text"# merge details for `project' "
	noi di as text"#########################################################################"
	foreach data of num 1 / $bim2merge_dataN {
		noi di as text"# data`data'  .......................................... input "as result"${bim2merge_data`data'}"
		noi bim2count, bim(${bim2merge_data`data'})
		noi di as text"# data`data'  ......................................... output "as result"${bim2merge_newname`data'}"
		noi bim2count, bim(${bim2merge_newname`data'})
		capture confirm file  ${data`data'}.meta-log 
		if !_rc {
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
			drop if a == ""
			outsheet a using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			noi di as text"# " as result "data`data' " as text "................................................. "as result"${data`data'_file}"
			noi di as text"# " as result "data`data' " as text "array is ........................................ "as result"${data`data'_array}"
			noi di as text"# " as result "data`data' " as text "build is ........................................ "as result"${data`data'_build}"
			}
		else {
			}
		}
	noi di as text"#########################################################################"	
	log close
	}
noi di as text"# > move and clean"	
qui {
	foreach data of num 1 / $bim2merge_dataN {
		foreach file in bed bim fam {
			!copy "${bim2merge_newname`data'}.`file'"   "..\\${bim2merge_newname`data'}.`file'"
			}
		capture confirm file "tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph" 
		if !_rc {
			graph use "tempfile-gwas_risk_frq_x_data`data'_risk_frq.gph" 
			graph export "..\\`project'_sanity-check-data1-vs-data`data'-allele-frequencies.png", as(png) height(500) width(1000) replace
			window manage close graph
			}
		else {
			}
		!copy "`project'.log"               "..\\`project'.log.meta-log"
		}	
	qui di as text"# > removing temporary folder"
	qui {
		cd ..
		!rmdir ${temp_dir} /S /Q 
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	