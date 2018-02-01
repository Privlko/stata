/*
*program*
 bim2merge

*description* 
 command to identify / join multiple *.bim files (plink-format marker files) 

*syntax*
 bim2merge , bim(-filenames-)  ref_bim(-reference-) project(-project_name- [join(-join-)]

 -filenames- 	does not require the .bim filetype to be included - this is assumed
				this includes a comma delimited set of bims
 -reference-	does not require the .bim filetype to be included - this is assumed
				this is the bim file that others are strand aligned
 -project_name-	this is the name of the project
 -join-         this can be -yes- and initiates the merge protocol in plink
*/

program bim2merge
syntax , bim(string asis) ref_bim(string asis) project(string asis) [join(string asis)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2merge"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	clear
	set obs 1
	gen a = "`ref_bim',`bim'"
	split a,p(",")
	drop a
	gen x = 1
	reshape long a, i(x) j(obs)
	count
	noi di as text"# > bim2merge ............... number of binaries to merge "as result"`r(N)'"
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
	count
	global bim2merge_dataN `r(N)'
	foreach num of num 1 / $bim2merge_dataN {
		noi checkfile, file(${bim2merge_data`num'}.bim)
		noi checkfile, file(${bim2merge_data`num'}.bed)
		noi checkfile, file(${bim2merge_data`num'}.fam)
		}
	noi checkfile, file(${plink})
	    checktabbed
	}
qui { // 2 - generate metrics
	create_temp_dir
	qui { // create frq files 
		foreach num of num 1 / $bim2merge_dataN {
			capture confirm file ${bim2merge_data`num'}_frq.dta 
			if !_rc {
			noi di as text"# > bim2merge ............. frequency files already exist "as result"${bim2merge_data`num'}_frq.dta"
			}
		else {
			noi di as text"# > bim2merge .................... create frequency files "as result"${bim2merge_data`num'}_frq.dta"
			noi bim2frq, bim(${bim2merge_data`num'})
			}
		}
		}
	qui { // limit to autosome
		capture confirm file ${bim2merge_data1}_bim.dta 
		if !_rc {
			noi di as text"# > bim2merge ................ marker files already exist "as result"${bim2merge_data1}_bim.dta"
			use ${bim2merge_data1}_bim.dta ,clear
			}
		else {
			noi di as text"# > bim2merge ......................... create marker file "as result"${bim2merge_data1}_bim.dta"
			noi bim2dta, bim(${bim2merge_data1})
			}
		for var chr bp: tostring X,replace
		drop if chr == "23" | chr == "24" | chr == "25"
		}
	qui { // remove ambiguous markers
		drop if gt == "W" | gt == "S"
		}
	}
qui { // 3 - merge _files
	keep chr bp snp
	foreach num of num 1 / $bim2merge_dataN {
		merge 1:1 snp using ${bim2merge_data`num'}_frq.dta
		keep if _m == 3
		drop _m
		for var a1 a2 gt maf: rename X X_data`num'
		}
	qui { // map snps to common strand
		foreach data of num 2 / $bim2merge_dataN {
			recodestrand, ref_a1(a1_data1) ref_a2(a2_data1) alt_a1(a1_data`data') alt_a2(a2_data`data') 
			rename _tmpflip flip_data`data'
			drop _tmpb1 _tmpb2
			}
		outsheet snp using bim2merge.extract, non noq replace
		!$plink --bfile ${bim2merge_data1} --extract bim2merge.extract --make-bed --out ${bim2merge_newname1}
		foreach data of num 2 / $bim2merge_dataN {
			!$plink --bfile ${bim2merge_data`data'} --extract bim2merge.extract --make-bed --out data`data'-intersect
			outsheet snp if flip_data`data' == 1 using bim2merge-data`data'.flip, non noq replace
			!$plink --bfile data`data'-intersect --flip bim2merge-data`data'.flip --make-bed --out ${bim2merge_newname`data'}
			!del data`data'-intersect.* bim2merge-data`data'.flip
			}
		}
	}
qui { // 4 - plot allele frequencies over datasets
	global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
	foreach data of num 2 / $bim2merge_dataN {
		replace maf_data`data' = 1- maf_data`data' if flip_data`data' == 1
		replace maf_data`data' = 1- maf_data`data' if a1_data1 != a1_data`data'
		noi di as text"# > bim2merge ................ plot allele frequencies of "as result"${bim2merge_newname1}"
		noi di as text"# > bim2merge .................................... versus "as result"${bim2merge_newname`data'}"
		noi di as text"# > bim2merge ........................................ to "as result "${bim2merge_newname1}-by-${bim2merge_newname`data'}-sanity-check-allele-frequencies-vs-ref.png"
		tw scatter maf_data1 maf_data`data', xlabel(0(.1)1) ylabel(0(.1)1) ${format} caption("data1 = ${bim2merge_newname1}""data`data' = ${bim2merge_newname`data'}") 
		graph export "..\\${bim2merge_newname1}-by-${bim2merge_newname`data'}-sanity-check-allele-frequencies-vs-ref.png", as(png) height(500) width(1000) replace
		window manage close graph
		}
	}
qui { // 5 - create meta-log
	noi di as text"# > bim2merge ................... reporting processing to "as result"`project'.log"
	log using `project'.log, replace
	noi di as text"#########################################################################"
	noi di as text"# bim2merge report"                                                                
	noi di as text"#########################################################################"
	noi di as text"# Author ................................................ Richard Anney (AnneyR@Cardiff.ac.uk)"
	noi di as text"# Date .................................................. $S_DATE $S_TIME"
	noi di as text"#########################################################################"			
	noi di as text"# merge details for `project' "
	noi di as text"#########################################################################"
	noi di as text"# > bim2merge ........................reference genotypes "as result"`ref_bim'"
	bim2count, bim(`ref_bim')
	noi di as text"# > bim2count .................... number of SNPs in file "as result"${bim2count_snp}"
	noi di as text"# > bim2count .................... number of SNPs in file "as result"${bim2count_ind}"
	foreach data of num 1 / $bim2merge_dataN {
		noi di as text"# > bim2merge ................................ input file "as result"${bim2merge_data`data'}"
		bim2count, bim(${bim2merge_newname`data'})
		capture confirm file  ${bim2merge_data`data'}-genotypeqc.meta-log 
		if !_rc {
			import delim using  ${bim2merge_data`data'}-genotypeqc.meta-log, clear delim("#")
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
			}
		else {
			global data`data'_file 		"-"
			global data`data'_array		"-"	
			global data`data'_build		"-"	
			}
		noi di as text"# > bim2merge ............................... input array "as result"${data`data'_array}"
		noi di as text"# > bim2merge ............................ intercept file "as result"${bim2merge_newname`data'}"
		noi di as text"# > bim2count .................... number of SNPs in file "as result"${bim2count_snp}"
		noi di as text"# > bim2count ................. overlapping SNPs in model "as result"${bim2count_ind}"
		}
	else {
		}
	noi di as text"#########################################################################"	
	log close
	}
qui { // 6 - create data merge and clean up
	clear 
	set obs 1
	gen a = "`join'"
	if a == "yes" {
		noi di as text"# > bim2merge ....................... merging binaries to "as result"`project'.bim/bed/fam"
		set obs ${bim2merge_dataN}
		gen b = ""
		foreach data of num 3 / $bim2merge_dataN {
			replace b = "${bim2merge_newname`data'}.bed ${bim2merge_newname`data'}.bim ${bim2merge_newname`data'}.fam" in `data'
			}
		drop if b == ""
		outsheet b using bim2merge.merge-list, non noq replace
		!$plink --bfile ${bim2merge_newname2} --merge-list bim2merge.merge-list --make-bed --out ..\\`project'
		erase bim2merge.merge-list
		}
	else {
		}
	foreach data of num 1 / $bim2merge_dataN {
		foreach file in bed bim fam {
			!copy "${bim2merge_newname`data'}.`file'"   "..\\${bim2merge_newname`data'}.`file'"
			}
		}
	!copy "`project'.log"               "..\\`project'-bim2merge.meta-log"
	cd ..
	!rmdir ${temp_dir} /S /Q 
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	