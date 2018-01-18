/*
#########################################################################
# bim2array
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       16jan2018
# #########################################################################
*/

program bim2array
syntax , bim(string asis) array_folder(string asis)

qui di as text"#########################################################################"
qui di as text"# bim2array - version 0.1a 16jan2018 richard anney "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
noi checkfile, file(`bim'.bim)
noi checkfile, file(`ref')
qui { // create list of snps
	bim2count, bim(`bim')
	import delim using `bim'.bim, clear
	keep v2
	rename v2 snp
	save _bim2array.dta, clear
	}
qui { // create list of arrays to check 
	
	
	


noi di as text" "
	noi di as text"#########################################################################"
	clear
	set obs 1
	gen known_array = "`known_array'"
	if  known_array == "" {
		noi	di as text"# Module #1 - determing most likely genotyping array from "as result"${input}.bim"
		qui di as text"# > importing ........................................... "as result"${input}.bim"
		qui {
			global sub_mod_output tempfile-module1-01
			noi bim2dta,bim(${input})
			rename snp rsid
			keep rsid
			sort rsid
			save ${sub_mod_output}.dta, replace
			}
		qui di as text"# > calculate overlap with references and reporting to .. "as result"${output}.arraymatch"
		qui {
			global sub_mod_input  tempfile-module1-01
			global sub_mod_output tempfile-module1-02
			file open myfile using "${output}.arraymatch", write replace
			file write myfile "Array:Overlap:SNPsinModel:Jaccard Index" _n
			file close myfile
			clear
			set obs 1								
			gen folder = ""							
			save ${sub_mod_output}.dta,replace
			local myfiles: dir "${array_ref}" dirs "*" 	, respectcase				
			foreach folder of local myfiles {
				clear								
				set obs 1							
				gen folder = "`folder'" 					
				append using ${sub_mod_output}.dta						
				save ${sub_mod_output}.dta,replace						
				}
			drop if folder == ""
			foreach i of num 1/20 {
				append using ${sub_mod_output}.dta
				}
			erase ${sub_mod_output}.dta
			sort folder
			drop if folder == ""
			egen obs = seq(),by(folder)
			gen a = ""
			replace a = `"use ${sub_mod_input}.dta, clear"'     if obs == 1 
			replace a = `"merge m:m rsid using ${array_ref}\"' + folder + "\" + folder + ".dta"  if obs == 2 
			replace a = `"count if _merge == 3"' if obs == 3
			replace a = `"global ab \`r(N)'"' if obs == 4
			replace a = `"gen ab = \${ab}"' if obs == 5
			replace a = `"count "' if obs == 6
			replace a = `"global all \`r(N)'"' if obs == 7
			replace a = `"gen all = \${all}"' if obs == 8
			replace a = `"gen JaccardIndex = ab/all"' if obs == 9 
			replace a = `"sum JaccardIndex"' if obs == 10
			replace a = `"global ji \`r(min)'"' if obs == 11 
			replace a = `"di"... "' + folder + `" overlap = \${ab} of \${all}""' if obs == 12 
			replace a = `"filei + ""' + folder + `":\${ab}:\${all}:\${ji}" \${output}.arraymatch"' if obs == 13 
			outsheet a using ${sub_mod_input}.do, non noq replace
			do ${sub_mod_input}.do
			erase ${sub_mod_input}.dta
			import delim using "${output}.arraymatch", clear delim(":") varnames(1) case(preserve)
			gsort -J
			gen MostLikely = "+++" in 1
			replace MostLikely = "++" if J > 0.9 & MostLikely == ""
			replace MostLikely = "+" if J > 0.8 & MostLikely == ""
			outsheet using ${input}.arraymatch, replace noq
			qui di as text"# > determining most likely array"
			keep in 1
			gen a = ""
			replace a = "global arrayType "
			outsheet a Array using ${sub_mod_input}.do, non noq replace
			do ${sub_mod_input}.do
			erase ${sub_mod_input}.do 
			replace a = "global Jaccard "
			outsheet a J using ${sub_mod_input}.do, non noq replace
			do ${sub_mod_input}.do
			erase ${sub_mod_input}.do
			}
		qui di as text"# > plotting most likely arrays to ...................... "as result"${output}.arraymatch.png"
		qui {
			import delim using ${input}.arraymatch, clear case(preserve)
			keep if _n <10
			graph hbar Jaccard , over(Array,sort(Jaccard) lab(labs(large))) title("Jaccard Index") yline(.9, lcol(red)) ylabel(0(.1)1) fxsize(200) fysize(100) ///
			caption("Based on overlap with our reference data (derived from http://www.well.ox.ac.uk/~wrayner/strand/) the best matched ARRAY is ${arrayType}" ///
							"Jaccard Index of  ${arrayType} = ${Jaccard}")
			graph export  ${input}.arraymatch.png, height(1000) width(4000) as(png) replace 
			window manage close graph

			}
		noi di as text"# > most likely array (best match) is ................... "as result"${arrayType}" as text " (based on jaccard index = "as result"${Jaccard}"as text")"
		noi di as text"#########################################################################"
		}
	else {
		noi	di as text"# Module #1 - determing most likely genotyping array from "as result"set by user"
		noi di as text"# > array defined by user as  ........................... "as result"`known_array'"
		global arrayType "`known_array'"
		qui di as text"# > plotting blank graphs to ............................ "as result"${output}.arraymatch.png"

		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))     
		graph export ${output}.arraymatch.png, height(1000) width(4000) as(png) replace 
		graph export  ${input}.arraymatch.png, height(1000) width(4000) as(png) replace 
		window manage close graph
		}
		
		
		
		



qui {
	noi bim2dta, bim(`bim')
	qui { // pre-screen
		drop if gt == ""
		}
	qui { // define classes
		gen class = 0
		qui { // 1- marker name is rsid (e.g. rs1234)
			gen rs1 =substr(snp,1,2)
			gen rs2 =substr(snp,3,30)
			replace rs1 = "" if rs1 != "rs"
			destring rs2, replace force
			tostring rs2, replace force
			gen rs3 = rs1 + rs2
			replace class = 1 if snp == rs3
			drop rs1 rs2 rs3
			}
		qui { // 2- marker name has rsid embedded in marker name (e.g. local_rs1234)
			split snp,p("rs")
			rename snp2 rs2
			replace rs2 = subinstr(rs2, "_", "",.) 
			replace rs2 = subinstr(rs2, "-", "",.) 
			replace rs2 = subinstr(rs2, ".", "",.) 
			foreach i in `c(alpha)' `c(ALPHA)' {
				replace rs2 = subinstr(rs2, "`i'", "",.) 
				}
			destring rs2, replace force
			tostring rs2, replace force	
			gen rename = "rs" + rs2
			replace rename = "" if rename == "rs."
			replace class = 2 if rename ! = "" & class != 1
			keep chr snp bp gt class rename
			}
		qui { // 3- marker name not rsid - chromosome / bp known
			replace class = 3 if (chr > 0 & chr < 27 & bp > 0 & gt !="") & class == 0
			}
		count
		noi di as text"# > "as input"bim2rsid "as text" ....... markers loaded from bim file " as result `r(N)'
		count if class == 0
		noi di as text"# > "as input"bim2rsid "as text" .... unable to map to rsid (class 0) " as result `r(N)'
		count if class == 1
		noi di as text"# > "as input"bim2rsid "as text" .... already names as rsid (class 1) " as result `r(N)'
		count if class == 2
		noi di as text"# > "as input"bim2rsid "as text" .... rsid embedded in name (class 2) " as result `r(N)'
		count if class == 3
		noi di as text"# > "as input"bim2rsid "as text" ........ map via reference (class 3) " as result `r(N)'
		}		
	qui { // process classes seperately
		qui { // process class 0
			drop if class == 0
			save  _bim2rsid-class0-excluded.dta, replace
			}
		qui { // process class 1
			use  _bim2rsid-class0-excluded.dta, clear
 			keep if class == 1
			keep snp
			save  _bim2rsid-class1.dta, replace
			}
		qui { // process class 2 (remove duplicates)
			use  _bim2rsid-class0-excluded.dta, clear
			drop if class == 3
			gen final = ""
			replace final = snp    if class == 1
			replace final = rename if class == 2
			sort class final
			egen dup = seq(), by(final)
			replace dup = . if dup == 1
			drop if dup != .
			drop if snp == rename
			keep snp rename 
			save  _bim2rsid-class2.dta, replace
			}
		qui { // process class 3
			use  _bim2rsid-class0-excluded.dta, clear
			keep if class == 3
			for var ch bp: tostring X, replace
			replace gt = "R"  if gt == "Y"
			replace gt = "M"  if gt == "K"
			replace gt = "ID" if gt == "DI"
			gen loc_name =  "chr" + chr + ":" + bp + "-" + gt
			rename snp original
			keep loc_name original
			save _bim2rsid-update-class3-1.dta,replace		
			use `ref', clear
			for var ch bp: tostring X, replace
			replace gt = "R"  if gt == "Y"
			replace gt = "M"  if gt == "K"
			replace gt = "ID" if gt == "DI"
			gen loc_name =  "chr" + chr + ":" + bp + "-" + gt
			rename snp rsid
			keep loc_name rsid
			sort rsid
			merge 1:m  loc_name using _bim2rsid-update-class3-1.dta
			keep if _m == 3	
			rename (original rsid) (snp rename)
			keep snp rename 
			count 
			noi di as text"# > "as input"bim2rsid "as text" ..... mapped via reference (class 3) " as result `r(N)'
			save  _bim2rsid-class3.dta, replace		
			}
		}
	qui { // remove duplicates
		use  _bim2rsid-class1.dta, clear
		append using _bim2rsid-class2.dta
		append using _bim2rsid-class3.dta
		replace rename = snp if rename == ""
		egen dup = seq(),by(rename)
		keep if dup == 1
		}	
	qui { // export snp lists
		outsheet snp using _bim2dta.extract, non noq replace
		preserve
		drop if snp == rename
		outsheet snp rename using _bim2dta.update-name, non noq replace
		restore
		}
	qui { // create updated plink file
		!$plink --bfile `bim'         --extract _bim2dta.extract         --make-bed      --out _bim2dta_tmp1
		!$plink --bfile _bim2dta_tmp1 --update-name _bim2dta.update-name --make-just-bim --out _bim2dta_tmp2
		}
	qui { // update chromosome - location	
		import delim using _bim2dta_tmp2.bim, clear
		gen order = _n
		rename v2 snp
		merge 1:1 snp using `ref'
		drop if _m == 2
		sort order
		replace v1 = chr if v1 != chr & chr != .
		replace v4 =  bp if v4 !=  bp &  bp != .
		outsheet v1 - v6 using _bim2dta_tmp2_update.bim, non noq replace
		!$plink --bed _bim2dta_tmp1.bed --bim _bim2dta_tmp2_update.bim --fam _bim2dta_tmp1.fam --make-bed --out `bim'_rsid
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
