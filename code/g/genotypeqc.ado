/*
#########################################################################
# genotypeqc
# a command to perform a full quality-control pipeline in plink binaries
#
# command: genotypeqc, param(parameter-file)
#
#########################################################################
#
# prior to implementation, run the install-all.do file from
# https://github.com/ricanney/stata-genomics-ado
#
# download the following executables from
# plink1.9+ from https://www.cog-genomics.org/plink2
# plink2.+  from https://www.cog-genomics.org/plink/2.0/
#
# download the following perl-script from 
# tabbed.pl from https://github.com/ricanney/perl
# 
# prior to implementation map the following to global tags
#
# global tabbed perl <location of tabbed.pl>
# global plink <location of plink1.9+.exe>
# global plink2 <location of plink2+.exe>
#
#########################################################################

# version 5
# =======================================================================
# change maf to mac5
# remove allele freq check if data is imputed against hrc - mixed ancestry of samples removes non-eur alleles
# retain W/S and ID

# version 6
# =======================================================================
# update speed - ignore/rename where rebuild of plink not necessary

#########################################################################
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 12th July 2017
#########################################################################
*/
program genotypeqc
syntax

qui di as text"# > create temp directory"
qui {
	create_temp_dir
	}

noi di as text"#########################################################################"
noi di as text"# genotypeqc                                                             "
noi di as text"# version:       1.1                                                     "
noi di as text"# Creation Date: 17July2017                                              "
noi di as text"# Version Date:  06Dec2017                                               "
noi di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di as text"#########################################################################"
noi di as text"# > see " as result "https://github.com/ricanney/stata/edit/master/documents/genotypeqc.md "
noi di as text"# > for details of how to set up parameters"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"

qui { // Module #0 - preamble
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #0 - preamble"
	noi di as text"# > check path of dependent software is true"
	qui { 
		noi checkfile, file(${plink})
		noi checkfile, file(${plink2})
		noi checktabbed
		}
	noi di as text"# > check path of input files is true"
	qui { 
		noi checkfile, file(${build_ref})
		noi checkfile, file(${kg_ref_frq})
		noi checkfile, file(${aims})
		noi checkfile, file(${hapmap_data}.bed)
		noi checkfile, file(${hapmap_data}.bim)
		noi checkfile, file(${hapmap_data}.fam)
		noi checkfile, file(${input}.bed)
		noi checkfile, file(${input}.bim)
		noi checkfile, file(${input}.fam)
		}
	qui di as text"# > create new globals"
	qui { 
		global input    "${data_folder}\\${data_input}"
		global output   "${data_folder}\\${data_input}-qc-v6"
		global output_2 "${data_input}-qc-v6"
		}
	noi di as text"#"
	noi di as text"# > display output file and thresholds                                  "
	noi di as text"#########################################################################"
  noi	di as text"# >> input .............................................. "as result"${data_input}"
  noi	di as text"# >> output ............................................. "as result"${output_2}"
	noi di as text"# >> minimum minor-allele-frequency retained ............ "as result"mac5"
	noi di as text"# >> maximum genotype-missingness ....................... "as result"${geno2}" as text " (" as result"${geno1}"as text ")"
	noi di as text"# >> maximum individual-missingness ..................... "as result"${mind}"
	noi di as text"# >> maximum tolerated heterozygosity outliers (by-sd) .. "as result"${hetsd}"
	noi di as text"# >> maximum tolerated hardy-weinberg deviation ..... p < "as result"1E-${hwep}"
	noi di as text"# >> minimum kinship score for duplicates is  ........... "as result"${kin_d}"  
	noi di as text"# >> minimum kinship score for 1st degree relatives is .. "as result"${kin_f}"  
	noi di as text"# >> minimum kinship score for 2nd degree relatives is .. "as result"${kin_s}"  
	noi di as text"# >> minimum kinship score for 3rd degree relatives is .. "as result"${kin_t}"  
	noi di as text"#########################################################################"
	}
qui { // Module #1 - determining the original genotyping array 
	noi di as text" "
	noi di as text"#########################################################################"
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
		import delim using ${output}.arraymatch, clear delim(":") case(preserve)
		keep if _n <10
		graph hbar Jaccard , over(Array,sort(Jaccard) lab(labs(large))) title("Jaccard Index") yline(.9, lcol(red)) fxsize(200) fysize(100) ///
		caption("Based on overlap with our reference data (derived from http://www.well.ox.ac.uk/~wrayner/strand/) the best matched ARRAY is ${arrayType}" ///
						"Jaccard Index of  ${arrayType} = ${Jaccard}")
		graph export ${output}.arraymatch.png, height(1000) width(4000) as(png) replace 
		graph export  ${input}.arraymatch.png, height(1000) width(4000) as(png) replace 
		window manage close graph
		}
	noi di as text"# > most likely array (best match) is ................... "as result"${arrayType}" as text " (based on jaccard index = "as result"${Jaccard}"as text")"
	noi di as text"#########################################################################"
	}
qui { // Module #2 - update marker identifiers to 1000-genomes compatible rsid
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #2 - update marker identifiers to 1000-genomes compatible rsid"
	noi di as text"# > count observations in ............................... "as result"${input}"
	qui { 
		!$wc -l ${input}.bim  > ${input}.count
		import delim using ${input}.count, clear varnames(nonames)
		erase ${input}.count
		split v1,p(" ")
		destring v11, replace
		sum v11
		noi di as text"# >> number of SNPs in file ............................. "as result `r(max)'		
		!$wc -l ${input}.fam  > ${input}.count
		import delim using ${input}.count, clear varnames(nonames)
		erase ${input}.count
		split v1,p(" ")
		destring v11, replace
		sum v11
		noi di as text"# >> number of individuals in file ...................... "as result `r(max)'		
		}
	qui di as text"#########################################################################"
	noi di as text"# > pre-process plink files (mac 5 / geno 0.99 / mind 0.99)"
	qui {
		global sub_mod_output tempfile-module2-01
		!$plink --bfile ${input} --mac 5 --geno 0.99 --mind 0.99 --make-bed --out ${sub_mod_output} 
		}
	qui di as text"#########################################################################"
	noi di as text"# > count observations in ............................... "as result"${sub_mod_output}"
	qui {
		noi bim2count, bim(${sub_mod_output})
		}	
	qui di as text"#########################################################################"
	noi di as text"# > update build to ..................................... "as result"hg19+1"
	qui {
		global sub_mod_input  tempfile-module2-01
		global sub_mod_output tempfile-module2-02
		qui di as text"# >> based on markernames - this array is most likely " as result"${arrayType}"
		qui di as text"# >> using " as result"${arrayType}" as text " as reference"
		use ${array_ref}\\${arrayType}\\${arrayType}.dta, clear
		replace chr = "23" if chr == "X"
		replace chr = "24" if chr == "Y"
		replace chr = "26" if chr == "MT"
		keep rsid chr bp
		save ${sub_mod_output}_array.dta, replace
		import delim using ${sub_mod_input}.bim, clear
		gen obs = _n
		rename v2 rsid
		merge 1:1 rsid using ${sub_mod_output}_array.dta
		erase ${sub_mod_output}_array.dta
		sort obs
		drop if _m == 2
		for var v1 v4: tostring X, replace
		gen _v1 = chr
		replace _v1 = v1 if _v1 == ""	
		gen _v4 = bp
		replace _v4 = v4 if _v4 == ""
		outsheet _v1 rsid v3 _v4 v5 v6 using ${sub_mod_input}_update.bim, non noq replace
		keep if _m == 3
		qui di as text"# >> limit to overlap via --extract "as result"${sub_mod_output}.extract"
		qui { 
			outsheet rsid   using ${sub_mod_output}.extract, non noq replace
			!$plink --bim ${sub_mod_input}_update.bim --bed ${sub_mod_input}.bed --fam ${sub_mod_input}.fam  --extract ${sub_mod_output}.extract --make-bed --out ${sub_mod_output} 
			foreach file in bim bed fam  {
				erase "${sub_mod_input}.`file'"
				}
			erase ${sub_mod_input}_update.bim
			erase ${sub_mod_output}.extract
			}
		}	
	qui di as text"#########################################################################"
	noi di as text"# > process varnames"
	qui {
		noi di as text"# >> remove duplicates (prioritise keep of rs# containing vars)"
		qui {
			global sub_mod_input  tempfile-module2-02
			global sub_mod_output tempfile-module2-03
			!$plink --bfile ${sub_mod_input} --list-duplicate-vars --out ${sub_mod_output}
			capture confirm file ${sub_mod_output}.dupvar
			if !_rc {
				import delim using ${sub_mod_output}.dupvar, clear
				count
				if `r(N)' > 0 {
					erase ${sub_mod_output}.dupvar
					drop if chr == 0
					compress
					split ids,p(" ")
					gen keep   = ""
					foreach i of num 1/999 {
					capture confirm variable ids`i'
					if !_rc {
						generate tmp`i' = substr(ids`i',1,2)	
						replace keep = ids`i' if tmp`i' == "rs"
						replace ids`i' = "" if ids`i' == keep
						drop tmp`i'
						}
					}
					drop if keep == ""
					preserve
					keep ids1
					save ${sub_mod_output}_dupvar.dta, replace
					restore
					foreach i of num 2/999 {
						capture confirm variable ids`i'
						if !_rc {
							preserve
							keep ids`i'
							ren ids`i' ids1
							append using ${sub_mod_output}_dupvar.dta
							save ${sub_mod_output}_dupvar.dta, replace
							restore
							}
						}
					use ${sub_mod_output}_dupvar.dta, clear
					erase ${sub_mod_output}_dupvar.dta
					drop if ids1 == ""
					duplicates drop
					outsheet ids1 using ${sub_mod_output}.exclude, non noq replace
					!$plink --bfile ${sub_mod_input} --exclude ${sub_mod_output}.exclude --make-bed --out ${sub_mod_output}
					foreach file in bim bed fam  {
						erase "${sub_mod_input}.`file'"
						}
					erase ${sub_mod_output}.exclude
					}
				else {
					foreach file in bim bed fam {
						!del "${sub_mod_output}.`file'"
						!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
						}		
					}
				}
			else {
				foreach file in bim bed fam {
					!del "${sub_mod_output}.`file'"
					!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
					}		
				}
			}
		noi di as text"# >> update names where rsid is in title (e.g. convert exm-rs1799853 to rs1799853)"
		qui{
			global sub_mod_input  tempfile-module2-03
			global sub_mod_output tempfile-module2-04
			import delim using ${sub_mod_input}.bim, clear case(lower)
			rename v2 snp
			keep snp
			split snp,p("rs")
			capture confirm variable snp2
			if !_rc {
				qui di as text "# >> the variable snp contains markers with rs in name"
				destring snp2, replace
				tostring snp2, replace
				gen rename_snp = "rs" + snp2
				drop if snp == rename_snp
				drop if rename_snp == "rs."
				count
				if `r(N)' == 0 {
					foreach file in bim bed fam {
						!del "${sub_mod_output}.`file'"
						!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
						}
					}
				else {
					outsheet snp rename_snp using  ${sub_mod_output}.update-name, non noq replace 
					di as text"# >> update name via --update-name "as result"${sub_mod_output}.update-name"
					!$plink --bfile ${sub_mod_input} --update-name ${sub_mod_output}.update-name --make-bed --out ${sub_mod_output}  
					foreach file in bim bed fam  {
						erase "${sub_mod_input}.`file'"
						}
					erase ${sub_mod_output}.update-name
					}
				}
			else {
				di as text "# >> the variable snp does not contains markers with rs in name"
				foreach file in bim bed fam {
					!del "${sub_mod_output}.`file'"
					!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
					}		
				}	
			}	
		noi di as text"# >> remove duplicates (prioritise keep of rs# containing vars)"
		qui {
			global sub_mod_input  tempfile-module2-04
			global sub_mod_output tempfile-module2-05
						!$plink --bfile ${sub_mod_input} --list-duplicate-vars --out ${sub_mod_output}
			capture confirm file ${sub_mod_output}.dupvar
			if !_rc {
				import delim using ${sub_mod_output}.dupvar, clear
				count
				if `r(N)' > 0 {
					erase ${sub_mod_output}.dupvar
					drop if chr == 0
					compress
					split ids,p(" ")
					gen keep   = ""
					foreach i of num 1/999 {
					capture confirm variable ids`i'
					if !_rc {
						generate tmp`i' = substr(ids`i',1,2)	
						replace keep = ids`i' if tmp`i' == "rs"
						replace ids`i' = "" if ids`i' == keep
						drop tmp`i'
						}
					}
					drop if keep == ""
					preserve
					keep ids1
					save ${sub_mod_output}_dupvar.dta, replace
					restore
					foreach i of num 2/999 {
						capture confirm variable ids`i'
						if !_rc {
							preserve
							keep ids`i'
							ren ids`i' ids1
							append using ${sub_mod_output}_dupvar.dta
							save ${sub_mod_output}_dupvar.dta, replace
							restore
							}
						}
					use ${sub_mod_output}_dupvar.dta, clear
					erase ${sub_mod_output}_dupvar.dta
					drop if ids1 == ""
					duplicates drop
					outsheet ids1 using ${sub_mod_output}.exclude, non noq replace
					!$plink --bfile ${sub_mod_input} --exclude ${sub_mod_output}.exclude --make-bed --out ${sub_mod_output}
					foreach file in bim bed fam  {
						erase "${sub_mod_input}.`file'"
						}
					erase ${sub_mod_output}.exclude
					}
				else {
					foreach file in bim bed fam {
						!del "${sub_mod_output}.`file'"
						!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
						}		
					}
				}
			else {
				foreach file in bim bed fam {
					!del "${sub_mod_output}.`file'"
					!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
					}		
				}
			}
		noi di as text"# >> rename duplicates "
		qui {
			global sub_mod_input  tempfile-module2-05
			import delim using ${sub_mod_input}.bim, clear
			egen x = seq(),by(v2)
			replace x = x -1
			tostring x,replace
			gen dup = "_dup" + x
			replace dup = "" if dup == "_dup0"
			replace v2 = v2 + dup
			outsheet v1 - v6 using ${sub_mod_input}_update.bim, non noq replace
			}
		noi di as text"# >> update names to rsid using reference array ......... "as result"${kg_ref_frq}"
		qui {
			global sub_mod_input  tempfile-module2-05
			global sub_mod_output tempfile-module2-06
		  noi bim2dta, bim(${sub_mod_input}_update)
			gen rs = substr(snp`i',1,2)	
			drop if rs == "rs"
			count
			if `r(N)' != 0 { 
				tostring chr, replace
				tostring bp, replace
				gen locname = "chr" + chr + "_" + bp + "_" + gt
				keep snp locname
				duplicates tag locname, gen(tag)
				keep if tag == 0
				drop tag
				save  ${sub_mod_input}_temp.dta,replace
				use ${kg_ref_frq} , clear
				gen locname = "chr" + chr + "_" + bp + "_" + kg_gt
				keep rsid locname
				save  ${sub_mod_input}_ref.dta,replace
				use ${kg_ref_frq} , clear
				gen compl_gt = ""
				replace compl_gt = "K" if kg_gt == "M"
				replace compl_gt = "M" if kg_gt == "K"
				replace compl_gt = "R" if kg_gt == "Y"
				replace compl_gt = "Y" if kg_gt == "R"
				gen locname = "chr" + chr + "_" + bp + "_" + compl_gt
				keep rsid locname
				append using ${sub_mod_input}_ref.dta
				duplicates tag locname, gen(tag)
				keep if tag == 0
				drop tag
				merge 1:1 locname using ${sub_mod_input}_temp.dta
				keep if _m == 3
				replace rsid = rsid + "_loc"
				keep snp rsid
				outsheet snp rsid using  ${sub_mod_output}.update-name, non noq replace 
				qui di as text"# >> update name via --update-name "as result"${sub_mod_output}.update-name"
				!$plink --bed ${sub_mod_input}.bed --bim ${sub_mod_input}_update.bim --fam ${sub_mod_input}.fam --update-name ${sub_mod_output}.update-name --make-bed --out ${sub_mod_output} 
				foreach file in bim bed fam  {
					erase "${sub_mod_input}.`file'"
					}
				erase ${sub_mod_input}_temp.dta
				erase ${sub_mod_input}_ref.dta
				erase ${sub_mod_output}.update-name
				erase ${sub_mod_input}_update.bim
				erase ${sub_mod_input}_update_bim.dta
				}
			else {
				foreach file in bim bed fam {
					!del "${sub_mod_output}.`file'"
					!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
					}		
				}				
			}			
		noi di as text"# >> rename / identify duplicates "
		qui {
			global sub_mod_input  tempfile-module2-06
			import delim using ${sub_mod_input}.bim, clear
			split v2,p("_dup""_loc")
			egen x = seq(),by(v21)
			replace x = x -1
			tostring x,replace
			gen dup = "_dup" + x
			replace dup = "" if dup == "_dup0"
			replace v2 = v21 + dup
			outsheet v1 - v6 using ${sub_mod_input}_update.bim, non noq replace
			outsheet v2 if x !="0" using  ${sub_mod_input}.exclude, non noq replace
			}
		noi di as text"# >> remove variants with divergent allele-frequencies with reference genotypes"
		qui {
			global sub_mod_input  tempfile-module2-06
			global sub_mod_output tempfile-module2-processed	
			!$plink --bed ${sub_mod_input}.bed --bim ${sub_mod_input}_update.bim --fam ${sub_mod_input}.fam  --freq --out ${sub_mod_input}
			noi bim2dta, bim(${sub_mod_input}_update)
			count
			qui di as text"# >>> "as result `r(N)' as text " varaints present in "as result"${sub_mod_input}_update.bim"
			!$tabbed ${sub_mod_input}.frq
			import delim using ${sub_mod_input}.frq.tabbed, clear	
			destring maf, replace force
			tostring snp,replace
			keep snp a1 maf
			merge 1:1 snp a1 using ${sub_mod_input}_update_bim.dta
			keep if _m == 3
			drop _m chr bp
			for var a1 a2 maf gt: rename X array_X
			rename snp rsid
			merge 1:1 rsid using ${kg_ref_frq}
			count if _m == 1
			qui di as text"# >>> "as result `r(N)' as text " variants not observed in "as result"${kg_ref_frq}"
			count if _m == 3
			qui di as text"# >>> "as result `r(N)' as text " variants observed in "as result"${kg_ref_frq}"
			drop if _m == 2
			qui di as text"# >>> checking allele-frequencies with reference (W/S excluded)"
			gen drop = .
			drop if _m == 1
			replace drop = 1 if array_gt == "M"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
			replace drop = 1 if array_gt == "K"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
			replace drop = 1 if array_gt == "R"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
			replace drop = 1 if array_gt == "Y"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
			replace drop = 1 if array_gt == "ID" & (kg_gt != "ID")
			outsheet rsid if drop == 1 using ${sub_mod_input}b.exclude, non noq replace
			replace drop = 2 if array_gt == "W"
			replace drop = 2 if array_gt == "S"
			sum if drop == 1
			qui di as text"# >>> "as result `r(N)' as text " variants dropped due to incompatible UIPAC codes"
			sum if drop == 2
			qui di as text"# >>> "as result `r(N)' as text " variants not examined due to W/S UIPAC codes"
			gen ref_maf = .
			replace ref_maf = kg_maf if (kg_gt == array_gt & kg_a1 == array_a1)
			replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "A" & array_a1 == "T")
			replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "C" & array_a1 == "G")
			replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "G" & array_a1 == "C")
			replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "T" & array_a1 == "A")
			replace ref_maf = 1-kg_maf if (kg_gt == array_gt & kg_a1 != array_a1)
			replace ref_maf = 1-kg_maf if ref_maf == .
			global format mlc(black) mfc(blue) mlw(vvthin) m(o) xtitle("allele-frequency-array") ytitle("allele-frequency-1000-genomes")
			tw scatter ref_maf array_maf if drop == . , $format saving(${sub_mod_input}-pre-clean,replace) nodraw
			replace drop = 1 if array_maf > ref_maf + .1 
			replace drop = 1 if array_maf < ref_maf - .1  
			tw scatter ref_maf array_maf if drop == . , $format saving(${sub_mod_input}-post-clean,replace) nodraw
			graph combine ${sub_mod_input}-pre-clean.gph ${sub_mod_input}-post-clean.gph, ycommon
			graph export  tempfile-module2-allele-frequency-check.png, as(png) height(500) width(2000) replace
			window manage close graph
			outsheet rsid if drop == 1 using ${sub_mod_input}c.exclude, non noq replace
			!type ${sub_mod_input}b.exclude > ${sub_mod_input}.exclude
			!type ${sub_mod_input}c.exclude >> ${sub_mod_input}.exclude	
			!$plink --bed ${sub_mod_input}.bed --bim ${sub_mod_input}_update.bim --fam ${sub_mod_input}.fam --exclude ${sub_mod_input}.exclude --make-bed --out ${sub_mod_output}
			foreach file in bim bed fam  {
				erase "${sub_mod_input}.`file'"
				}
			erase ${sub_mod_input}_update.bim
			erase ${sub_mod_input}_update_bim.dta
			erase ${sub_mod_input}.exclude
			erase ${sub_mod_input}b.exclude
			erase ${sub_mod_input}c.exclude
			erase ${sub_mod_input}-post-clean.gph
			erase ${sub_mod_input}-pre-clean.gph
			erase ${sub_mod_input}.frq.tabbed
			erase ${sub_mod_input}.frq
			!del *.nosex
			}
		}
	qui di as text"#########################################################################"
	noi di as text"# > count observations in ............................... "as result"${sub_mod_output}"
	qui {
		noi bim2count, bim(${sub_mod_output})
		}	
	noi di as text"#########################################################################"
	}
qui { // Module #3 - report the genome build
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #3 - report the genome build to file"
	noi di as text"# > check build for ..................................... "as result"${input}"
	qui {
		noi bim2build, bim(${input}) build_ref(${build_ref})
		}
	noi di as text"#########################################################################"
	noi di as text"# > check build for ..................................... "as result"${sub_mod_output}"
	qui {
		noi bim2build, bim(${sub_mod_output}) build_ref(${build_ref})
		}
	noi di as text"#########################################################################"
	}
qui { // Module #4 - prepare the plink binaries for QC
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #4 - prepare the plink binaries for QC"
	noi	di as text"# > restrict binaries to chromosomes 1 through 23 and make founders"
	qui {
		global sub_mod_input  tempfile-module2-processed	
		global sub_mod_output tempfile-module4-01		
		import delim using ${sub_mod_input}.bim, clear 
		keep if v1 >=1 & v1 < 24
		outsheet v2 using ${sub_mod_output}.extract, non noq replace
		!$plink --bfile ${sub_mod_input} --extract ${sub_mod_output}.extract --make-founders --make-bed --out ${sub_mod_output}
		foreach file in bim bed fam  {
			erase "${sub_mod_input}.`file'"
			}
		erase ${sub_mod_output}.extract
		noi bim2count, bim(${sub_mod_output})
		}
	qui di as text"#########################################################################"
	noi	di as text"# > impute sex from genotype data"
	qui {
		global sub_mod_input  tempfile-module4-01		
		global sub_mod_output tempfile-module4-processed
		import delim using ${sub_mod_input}.bim, clear 
		keep if v1 == 23
		sum v1
		if `r(N)' > 10000 {
			noi di as text"# >> chromosome 23 is present - and sufficient markers present - imputing sex"
			!$plink --bfile ${sub_mod_input} --impute-sex --make-bed --out ${sub_mod_output}
			foreach file in bim bed fam  {
				erase "${sub_mod_input}.`file'"
				}
			!del ${sub_mod_output}.sexcheck
			}
		else {
			noi di as text"# >> chromosome 23 is not present"
			foreach file in bim bed fam {
				!del "${sub_mod_output}.`file'"
				!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
				}	
			}
		!del *.nosex
		}
	noi di as text"#########################################################################"
	}	
qui { // Module #5 - apply quality control to genotypes
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #5 - apply quality control to genotypes"
	noi di as text"# > round #1 of quality control pipeline"
	qui { 
		qui di as text"#########################################################################"
		noi	di as text"# >> calculating pre-quality-control metrics"
		qui { 
			global sub_mod_input  tempfile-module4-processed
			global sub_mod_output tempfile-module5-round0
			qui	di as text"# >>> calculating frequency counts"
			qui { 
				!$plink  --bfile ${sub_mod_input} --freq counts --out ${sub_mod_input}
				}
			qui	di as text"# >>> calculating heterozygosity"
			qui { 
				!$plink  --bfile ${sub_mod_input} --maf 0.05 --het --out ${sub_mod_input}
				}
			qui	di as text"# >>> calculating hardy-weinberg equilibrium"
			qui { 
				!$plink  --bfile ${sub_mod_input} --hardy          --out ${sub_mod_input}
				}
			qui	di as text"# >>> calculating missingness"
			qui { 
				!$plink  --bfile ${sub_mod_input} --missing        --out ${sub_mod_input}
				}
			qui	di as text"# >>> calculating kinship / relatedness"
			qui {
				noi bim2ld_subset, bim(${sub_mod_input})
				!$plink2 --bfile ${sub_mod_input} --extract _subset50000.extract --make-king-table --king-table-filter ${kin_t} --out ${sub_mod_input}
				}
			}
		qui di as text"#########################################################################"
		noi	di as text"# >> plotting pre-quality-control metrics"
		qui { 
			qui di as text"# >>> create blank graphs"
			qui {
				tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))     
				foreach i in tmpFRQ tmpHET tmpHWE tmpIMISS tmpLMISS tmpKIN0_1 tmpKIN0_2 {
					graph save `i', replace
					}
				window manage close graph
				}	
			qui	di as text"# >>> plotting frequency counts"
			qui {
				noi graphplinkfrq, frq(${sub_mod_input}) 
				erase ${sub_mod_input}.frq.counts
				}
			qui	di as text"# >>> plotting heterozygosity"
			qui {
				noi graphplinkhet, het(${sub_mod_input}) sd(${hetsd})
				erase ${sub_mod_input}.het
				}
			qui	di as text"# >>> plotting hardy-weinberg equilibrium"
			qui {
				noi graphplinkhwe, hwe(${sub_mod_input}) threshold(${hwep})
				erase ${sub_mod_input}.hwe
				}
			qui	di as text"# >>> plotting missingness (individual)"
			qui {
				noi graphplinkimiss, imiss(${sub_mod_input}) mind(${mind})
				erase ${sub_mod_input}.imiss
				}
			qui	di as text"# >>> plotting missingness (variant)"
			qui {
				noi graphplinklmiss, lmiss(${sub_mod_input}) geno(${geno2})	
				erase ${sub_mod_input}.lmiss
				}
			qui	di as text"# >>> plotting kinship relationships"
			qui {	
				noi graphplinkkin0, kin0(${sub_mod_input}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
				erase ${sub_mod_input}.kin0
				}
			qui di as text"# >>> renaming plots"
			qui { 
				foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
					!del    "${sub_mod_output}_`graph'.gph"
					!rename "tmp`graph'.gph" "${sub_mod_output}_`graph'.gph"
					}
				}	
			}
		qui di as text"#########################################################################"
		noi	di as text"# >> apply quality-control to binaries"
		qui {
			qui di as text"# >>> remove individuals with heterozygosity errors"
			qui {
					global sub_mod_mid ${sub_mod_output}-01
					!$wc -l tempHET.indlist  > ${sub_mod_mid}.het-count
					import delim using ${sub_mod_mid}.het-count, clear varnames(nonames)
					erase ${sub_mod_mid}.het-count
					split v1,p(" ")
					destring v11, replace
					sum v11
					if `r(N)' > 0 {
						!$plink --bfile ${sub_mod_input} --remove tempHET.indlist --set-hh-missing --make-bed --out ${sub_mod_mid}
						foreach file in bim bed fam {
							!del "${sub_mod_input}.`file'"
							}
						}
					else {
						foreach file in bim bed fam {
						!del "${sub_mod_output}.`file'"
						!rename "${sub_mod_input}.`file'" "${sub_mod_mid}.`file'"
						}
					}
				}
			qui di as text"# >>> remove snps with hardy-weinberg errors"
			qui {	
					global sub_mod_input  ${sub_mod_output}-01
					global sub_mod_mid    ${sub_mod_output}-02
					!$wc -l tempHWE.snplist > ${sub_mod_mid}.hwe-count
					import delim using ${sub_mod_mid}.hwe-count, clear varnames(nonames)
					erase ${sub_mod_mid}.hwe-count
					split v1,p(" ")
					destring v11, replace
					sum v11	
					if `r(N)' > 0 {
						!$plink --bfile ${sub_mod_input} --exclude  tempHWE.snplist --make-bed --out ${sub_mod_mid}
						foreach file in bim bed fam {
							!del "${sub_mod_input}.`file'"
							}
						}
					else {
						foreach file in bim bed fam {
						!del "${sub_mod_mid}.`file'"
						!rename "${sub_mod_input}.`file'" "${sub_mod_mid}.`file'"
						}
					}
					}
			qui di as text"# >>> remove snps with missingness (first level)"
			qui {	
					global sub_mod_input  ${sub_mod_output}-02
					global sub_mod_mid    ${sub_mod_output}-03
					!$plink --bfile ${sub_mod_input} --geno ${geno1} --make-bed --out ${sub_mod_mid}
					foreach file in bim bed fam {
						!del "${sub_mod_input}.`file'"
						}
					}
			qui di as text"# >>> remove individuals with missingness"
			qui {	
					global sub_mod_input  ${sub_mod_output}-03
					global sub_mod_mid    ${sub_mod_output}-04
					!$plink --bfile ${sub_mod_input} --mind ${mind}  --make-bed --out ${sub_mod_mid}
					foreach file in bim bed fam {
						!del "${sub_mod_input}.`file'"
						}
					}
			noi di as text"# >>> remove snps with missingness (second level)"
			qui {	
					global sub_mod_input  ${sub_mod_output}-04
					global sub_mod_mid    ${sub_mod_output}-05
					!$plink --bfile ${sub_mod_input} --geno ${geno2} --make-bed --out ${sub_mod_mid}
					foreach file in bim bed fam irem{
						!del "${sub_mod_input}.`file'"
						}
					}
			}
		noi di as text"# >> remove individuals with excess cryptic relatedness"
		qui {
			qui di as text"# >>>> identify individuals with excess cryptic relatedness"
			qui {	
				global sub_mod_input  ${sub_mod_output}-05
				global sub_mod_output tempfile-module5-round1
				noi fam2dta, fam(${sub_mod_input})
				count
				global sampleSize `r(N)'
				noi di as text"# >> number of individuals in file ...................... "as result `r(N)'	
				noi di as text"# >> creating a kinship matrix .......................... "as result "`r(N)'" as text" x "as result "`r(N)'"
				noi bim2ld_subset, bim(${sub_mod_input})
				!$plink2 --bfile ${sub_mod_input} --extract _subset50000.extract --make-king square --out ${sub_mod_input}			
				import delim using ${sub_mod_input}.king, clear case(lower)
				count
				global countX `r(N)'
				keep v1-v$countX
				forvalues i=1/ $countX {
							replace v`i' = . in `i'
							}
				gen obs = _n
				aorder
				save ${sub_mod_input}.dta,replace
				qui di as text"# >>> merge kinship table to identifiers"
				import delim using ${sub_mod_input}.king.id, clear case(lower)
				rename (v1 v2) (fid iid)
				gen obs = _n
				aorder
				merge 1:1 obs using ${sub_mod_input}.dta, update
				drop obs _m
				qui di as text"# >>> calculate by-individual metrics"
				for var v1-v$countX: replace X = 0 if X < 0
				egen rm = rowmean(v1-v$countX)
				egen rx =  rowmax(v1-v$countX)
				keep fid iid rm rx
				qui di as text"# >>> identify individuals with excessive kinship coefficients"
				gen excessCryptic = ""
				sum rm
				gen lb = `r(mean)' - 2.5 *`r(sd)'
				gen ub = `r(mean)' + 2.5 *`r(sd)'
				replace excessCryptic = "1" if rm < (lb)
				replace excessCryptic = "1" if rm > (ub)
				count if ex == "1"
				global excessC `r(N)'
				noi di as text"# >> individuals showing excessive kinship .............. "as result `r(N)'
				outsheet fid iid if excessC == "1" using excessiveCryptic.remove, replace non noq
				}
			qui di as text"# >>>> remove individuals with excess cryptic relatedness"
			qui {
					!$plink --bfile ${sub_mod_input} --remove excessiveCryptic.remove   --make-bed --out ${sub_mod_output}
					foreach file in bim bed fam { 
							!del ${sub_mod_input}.`file'
							}	
					erase excessiveCryptic.remove
					erase ${sub_mod_input}_fam.dta
					erase ${sub_mod_input}.dta
					erase ${sub_mod_input}.king
					erase ${sub_mod_input}.king.id
					}
			qui di as text"# >>>> plot individuals with excess cryptic relatedness"
			qui {
						global format "mlc(black) mlw(vvthin) m(O)"
						tw scatter rx rm if excessCryptic != "1", $format mfc(blue)   ///
						|| scatter rx rm if excessCryptic == "1", $format mfc(red)    ///
							 legend(off) ytitle("maximum kinship") xtitle("average kinship") ///
							 caption("kinship is the estimated kinship coefficient from the SNP data. All kinship < 0 are reported as 0. " ///
											 "If an individual has excessive kinship it may indicate poor genotyping." ///
											 "In this sample of N = $sampleSize, N = $excessC are +/- 2.5 sd from the kinship mean")
							graph export ${sub_mod_output}-relate.png, as(png) height(1000) width(2000) replace
							window manage close graph
							}
			}
		qui di as text"#########################################################################"
		qui di as text"# >> clean up temporary files"
		qui {
			!del *.exclude *.remove *.relPairs *.snplist *.indlist
			}
		}
	qui di as text"#########################################################################"
	qui di as text"# > round #N of quality control pipeline"
	qui {
		foreach round of num  2 / $rounds {	
			qui di as text"#########################################################################"
			noi di as text"# > round #`round' of quality control pipeline"
			qui di as text"#########################################################################"
			qui	di as text"# >> define input output naming conventions"
			qui {
					clear
					set obs 2
					gen obs = _n
					tostring obs, replace
					gen x = `round'
					replace x = x - 1 in 1
					tostring x, replace
					gen round = "global round" + obs + " round" + x
					outsheet round using tempfile-round.do, non noq replace
					do tempfile-round.do
					erase tempfile-round.do
					}
			qui di as text"#########################################################################"
			noi	di as text"# >> calculating quality-control metrics"
			qui { 
					global sub_mod_input  tempfile-module5-${round1}
					global sub_mod_output tempfile-module5-${round2}
					qui	di as text"# >>> calculating heterozygosity"
					qui { 
						!$plink  --bfile ${sub_mod_input} --maf 0.05 --het --out ${sub_mod_input}
						}
					qui	di as text"# >>> calculating hardy-weinberg equilibrium"
					qui { 
						!$plink  --bfile ${sub_mod_input} --hardy          --out ${sub_mod_input}
						}
					}
			qui di as text"#########################################################################"
			noi	di as text"# >> plotting pre-quality-control metrics"
			qui { 
					qui	di as text"# >>> plotting heterozygosity"
					qui {
						noi graphplinkhet, het(${sub_mod_input}) sd(${hetsd})
						erase ${sub_mod_input}.het
						}
					noi	di as text"# >>> plotting hardy-weinberg equilibrium"
					qui {
						noi graphplinkhwe, hwe(${sub_mod_input}) threshold(${hwep}) 
						erase ${sub_mod_input}.hwe
						}
					}
			qui di as text"#########################################################################"
			noi	di as text"# >> apply quality-control to binaries"
			qui {
					qui di as text"# >>> remove individuals with heterozygosity errors"
					qui {
						global sub_mod_mid    ${sub_mod_output}-01
						!$wc -l tempHET.indlist  > ${sub_mod_mid}.het-count
						import delim using ${sub_mod_mid}.het-count, clear varnames(nonames)
						erase ${sub_mod_mid}.het-count
						split v1,p(" ")
						destring v11, replace
						sum v11
						if `r(N)' > 0 {
								!$plink --bfile ${sub_mod_input} --remove tempHET.indlist --set-hh-missing --make-bed --out ${sub_mod_mid}
								foreach file in bim bed fam {
									!del "${sub_mod_input}.`file'"
									}
								}
						else {
								foreach file in bim bed fam {
								!del "${sub_mod_mid}.`file'"
								!rename "${sub_mod_input}.`file'" "${sub_mod_mid}.`file'"
								}
							}
						}
					qui di as text"# >>> remove snps with hardy-weinberg errors"
					qui {	
						global sub_mod_input  ${sub_mod_output}-01
						global sub_mod_mid    ${sub_mod_output}-02
						!$wc -l tempHWE.snplist > ${sub_mod_input}.hwe-count
						import delim using ${sub_mod_input}.hwe-count, clear varnames(nonames)
						erase ${sub_mod_input}.hwe-count
						split v1,p(" ")
						destring v11, replace
						sum v11	
						if `r(N)' > 0 {
							!$plink --bfile ${sub_mod_input} --exclude  tempHWE.snplist --make-bed --out ${sub_mod_mid}
							foreach file in bim bed fam {
								!del "${sub_mod_input}.`file'"
								}
							}
						else {
							foreach file in bim bed fam {
								!del "${sub_mod_output}.`file'"
								!rename "${sub_mod_input}.`file'" "${sub_mod_output}.`file'"
								}
							}
						}
					qui di as text"# >>> remove individuals with missingness"
					qui {	
							global sub_mod_input  ${sub_mod_output}-02
							global sub_mod_mid    ${sub_mod_output}-03
							!$plink --bfile ${sub_mod_input} --mind ${mind}  --make-bed --out ${sub_mod_mid}
							foreach file in bim bed fam {
									!del "${sub_mod_input}.`file'"
									}
							}
					qui di as text"# >>> remove snps with missingness (second level)"
					qui {	
						global sub_mod_input  ${sub_mod_output}-03
						!$plink --bfile ${sub_mod_input} --geno ${geno2} --make-bed --out ${sub_mod_output}
						foreach file in bim bed fam irem{
							!del "${sub_mod_input}.`file'"
							}
						}
					}
			qui di as text"#########################################################################"
			qui di as text"# >> clean up temporary files"
			qui {
				!del *.exclude *.remove *.relPairs *.snplist *.indlist
				}
			}
		}
	qui di as text"#########################################################################"
	noi	di as text"# > calculating post-quality-control metrics"
	qui { 
		global sub_mod_input  tempfile-module5-${round2}
		qui	di as text"# >> calculating frequency counts"
		qui { 
			!$plink  --bfile ${sub_mod_input} --freq counts --out ${sub_mod_input}
			}
		qui	di as text"# >> calculating heterozygosity"
		qui { 
			!$plink  --bfile ${sub_mod_input} --maf 0.05 --het --out ${sub_mod_input}
			}
		qui	di as text"# >> calculating hardy-weinberg equilibrium"
		qui { 
			!$plink  --bfile ${sub_mod_input} --hardy          --out ${sub_mod_input}
			}
		qui	di as text"# >> calculating missingness"
		qui { 
			!$plink  --bfile ${sub_mod_input} --missing        --out ${sub_mod_input}
			}
		qui	di as text"# >> calculating kinship / relatedness"
		qui {
			noi bim2ld_subset, bim(${sub_mod_input})
			!$plink2 --bfile ${sub_mod_input} --extract _subset50000.extract --make-king-table --king-table-filter ${kin_t} --out ${sub_mod_input}
			}
		}
	qui di as text"#########################################################################"
	noi	di as text"# > plotting post-quality-control metrics"
	qui { 
		qui di as text"# >> create blank graphs"
		qui {
			tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))     
			foreach i in tmpFRQ tmpHET tmpHWE tmpIMISS tmpLMISS tmpKIN0_1 tmpKIN0_2 {
				graph save `i', replace
				}
			window manage close graph
			}	
		qui	di as text"# >> plotting frequency counts"
		qui {
			noi graphplinkfrq, frq(${sub_mod_input}) 
			erase ${sub_mod_input}.frq.counts
			}
		qui	di as text"# >> plotting heterozygosity"
		qui {
			noi graphplinkhet, het(${sub_mod_input}) sd(${hetsd})
			erase ${sub_mod_input}.het
		}
		qui	di as text"# >> plotting hardy-weinberg equilibrium"
		qui {
			noi graphplinkhwe, hwe(${sub_mod_input}) threshold(${hwep}) 		
			erase ${sub_mod_input}.hwe
			}
		qui	di as text"# >> plotting missingness (individual)"
		qui {
			noi graphplinkimiss, imiss(${sub_mod_input}) mind(${mind})
			erase ${sub_mod_input}.imiss
			}
		qui	di as text"# >> plotting missingness (variant)"
		qui {
			noi graphplinklmiss, lmiss(${sub_mod_input}) geno(${geno2})	
			erase ${sub_mod_input}.lmiss
			}
		qui	di as text"# >> plotting kinship relationships"
		qui {	
			noi graphplinkkin0, kin0(${sub_mod_input}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
			erase ${sub_mod_input}.kin0
			}
		qui di as text"# >> renaming plots"
		qui { 
			foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
				!del    "${sub_mod_input}_`graph'.gph"
				!rename "tmp`graph'.gph" "${sub_mod_input}_`graph'.gph"
				}
			}	
		}
	qui di as text"#########################################################################"
	qui di as text"# > clean up temporary files"
	qui {
		!del *.exclude *.remove *.relPairs *.snplist *.indlist *.hwe *.het *.hh *.irem
		}
	noi di as text"#########################################################################"
	}
qui { // Module #6 - remove duplicates; 2nd and 3rd degree relatives 
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #6 - remove duplicates; 2nd and 3rd degree relatives"
	qui	di as text"# > identify duplicates; 2nd and 3rd degree relatives "
	qui {
		global sub_mod_input  tempfile-module5-${round2}
		global sub_mod_output tempfile-module6-final
		qui di as text"# >> create "as result "${sub_mod_input}_kinship.remove"
		qui {
				!type > ${sub_mod_input}_kinship.remove
				}	
		qui di as text"# >> create _subset50000.extract"
		qui { 
			noi bim2ld_subset, bim(${sub_mod_input})
			!$plink2 --bfile ${sub_mod_input} --extract _subset50000.extract --make-bed --out ${sub_mod_input}_subset50000
			}
		qui di as text"# >> create kinship matrix and remove most related individual whilst looping through thresholds"
		noi di as text"# > ignoring first degree relatives i.e. pairs where kinship > "as result"${kin_f}"as text" & kinship < "as result"${kin_d}"
		qui {
			foreach kin_threshold in $kin_d $kin_s $kin_t {
				qui di as text"#########################################################################"
				!del _x_.stop
				foreach num of num 1/ 999 {
					capture confirm file _x_.stop
					if _rc==0 {
						continue
						}
					else {
						noi di as text"# > identify pairs with kinship thresholds ............ > "as result "`kin_threshold'"
						!$plink2 --bfile ${sub_mod_input}_subset50000 --remove ${sub_mod_input}_kinship.remove --make-king-table --king-table-filter `kin_threshold' --out ${sub_mod_input}
						qui di as text"# >> removing first degree relatives from dataset"
						qui {
							import delim using ${sub_mod_input}.kin0, clear
							gen keep = 1
							replace keep = 0 if kinship > ${kin_f} & kinship < ${kin_d}
							keep if keep == 1
							drop keep
							outsheet using ${sub_mod_input}_no1dr.kin0, noq replace
							}
						count
						if `r(N)' != 0 {
							noi di as text"# > iteration ........................................... "as result"`num'"
							noi kin0filter, kin0(${sub_mod_input}_no1dr) filter(`kin_threshold')
							!type ${sub_mod_input}_no1dr_filter_`kin_threshold'.remove >> ${sub_mod_input}_kinship.remove
							erase ${sub_mod_input}_no1dr_filter_`kin_threshold'.remove 
							erase ${sub_mod_input}_no1dr.kin0 
							erase ${sub_mod_input}.kin0 
							}
						else {
							noi di as text"# >> all pairs with kinship > threshold identified as added to ........"as result"${sub_mod_input}_kinship.remove"
							!type > _x_.stop
							}
						}
					}
				!del _x_.stop ${sub_mod_input}.kin0 ${sub_mod_input}_no1dr.kin0 
				}
			}	
		}
	qui di as text"#########################################################################"
	noi	di as text"# > remove duplicates; 2nd and 3rd degree relatives "
	qui {
		!$plink --bfile ${sub_mod_input} --remove ${sub_mod_input}_kinship.remove --make-bed --out ${sub_mod_output} 
		erase ${sub_mod_input}_kinship.remove
		foreach file in bim bed fam {
			!del "${sub_mod_input}.`file'"
			}
		}
	noi di as text"#########################################################################"
	noi	di as text"# > plot post-removal relatedness "
	qui { 
		noi bim2ld_subset, bim(${sub_mod_output})
		!$plink2 --bfile ${sub_mod_output} --extract _subset50000.extract --make-king-table --king-table-filter ${kin_t} --out ${sub_mod_output}
		noi graphplinkkin0, kin0(${sub_mod_output})	
		!del "${sub_mod_output}_KIN0_2_noRel.gph"
		!rename "tmpKIN0_2.gph" "${sub_mod_output}_KIN0_2_noRel.gph"
		}
	qui { 
		!del ${sub_mod_output}.kin0 *.remove *.exclude tmpK* *.kin0 *.extract
		!del ${sub_mod_input}_subset*
		}
	noi di as text"#########################################################################"

	}

qui { // Module #7 - define european (ceu-tsi-like) subset 
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #7 - define / plot ancestry"
	qui { 
		global sub_mod_input  tempfile-module6-final
		global sub_mod_hapmp  ${hapmap_data} 
		noi bim2hapmap, bim (${sub_mod_input}) like(CEU TSI) hapmap(${sub_mod_hapmp}) aims(${aims})
		!rename "bim2hapmap_CEU_TSI-like.keep" "${sub_mod_output}_CEU_TSI-like.keep"
		}
	noi di as text"#########################################################################"
	}
qui { // Module #8 - create quality-control mini-log and docx-report
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #8 - create quality-control mini-log and docx-report"
	noi di as text"# > create final plots as(png) for reports"
	qui { 
		qui di as text"# >> plotting markers by chromosome by input / output"
		qui { 
			global sub_mod_input  tempfile-module6-final
			noi bim2dta,bim(${input})
			hist chr,  xlabel(1(1)25) xtitle("Chromosome") discrete freq ylabel(#4,format(%9.0g))
			graph save _1.gph, replace
			noi bim2dta,bim(${sub_mod_input})
			hist chr,  xlabel(1(1)25) xtitle("Chromosome") discrete freq ylabel(#4,format(%9.0g))
			graph save _2.gph, replace
			graph combine _1.gph  _2.gph, caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}",	size(tiny)) col(1) ycommon
			graph export  ${sub_mod_input}-chromosomes.png, as(png) replace width(4000) height(2000)
			window manage close graph
			erase _1.gph
			erase _2.gph
			}	
		qui di as text"# >> plotting pre- post quality control graphs"
		qui { 
			global sub_mod_pre  tempfile-module5-round0
			global sub_mod_post tempfile-module5-round4
			foreach i in FRQ HET HWE IMISS LMISS KIN0_1 {
				noi checkfile, file(${sub_mod_pre}_`i'.gph)
				noi checkfile, file(${sub_mod_post}_`i'.gph)
				graph combine ${sub_mod_pre}_`i'.gph,  title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
				graph combine ${sub_mod_post}_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace)
				graph combine x_`i'.gph y_`i'.gph, xcommon caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny)) col(1) 
				graph export ${sub_mod_output}-`i'.png, as(png) replace width(4000) height(2000)
				window manage close graph
				!del x_`i'* y_`i'*
				}
			foreach i in  KIN0_2 {
				noi checkfile, file(${sub_mod_pre}_`i'.gph)
				noi checkfile, file(${sub_mod_post}_`i'.gph)
				noi checkfile, file(${sub_mod_output}_`i'_noRel.gph)
				graph combine ${sub_mod_pre}_`i'.gph,  title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
				graph combine ${sub_mod_post}_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace) 
				graph combine ${sub_mod_output}_`i'_noRel.gph,    title("post-quality-control (no-relatives)") nodraw saving(z_`i'.gph, replace) 
				graph combine x_`i'.gph y_`i'.gph z_`i'.gph, col(3) caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny))
				graph export ${sub_mod_output}-`i'.png, as(png) replace width(4000) height(2000)
				!del x_`i'* y_`i'* z_`i'*
				window manage close graph
				}
			}	
		}
	qui di as text"# > counting metrics and storing in memory"
	qui {
		!$wc -l "${input}.bim"                          > "${sub_mod_output}.counts"
		!$wc -l "${sub_mod_output}.bim"                >> "${sub_mod_output}.counts"
		!$wc -l "${input}.fam"                         >> "${sub_mod_output}.counts"
		!$wc -l "${sub_mod_output}.fam"                >> "${sub_mod_output}.counts"
		!$wc -l "${sub_mod_output}_CEU_TSI-like.keep"  >> "${sub_mod_output}.counts"
		import delim using ${sub_mod_output}.counts, clear varnames(nonames)
		erase ${sub_mod_output}.counts
		split v1,p(" ")
		replace v1 = "global count_markers_1" in 1 
		replace v1 = "global count_markers_3" in 2
		replace v1 = "global count_individ_1" in 3 
		replace v1 = "global count_individ_3" in 4
		replace v1 = "global count_European " in 5
		outsheet v1 v11 using tempfile.do, non noq replace
		do tempfile.do
		erase tempfile.do
		}	
	noi di as text"# > create report"
	qui {
		_sub_genotypeqc_report
		}
	noi di as text"# > create meta-log"
	qui {
		_sub_genotypeqc_meta
		}
	noi di as text"#########################################################################"
	}
qui { // Module #9 - rename and clean
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# Module #9 - move and clean"	
	noi di as text"# > create destination folder ............................"as result "${output_2}"
	qui di as text"# > move files to data directory"
	qui {
		!copy "${sub_mod_output}-quality-control-report.docx"   "${output}.quality-control-report.docx"
		!copy "${sub_mod_output}.meta-log"                      "${output}.meta-log"
		!copy "${sub_mod_output}.bed"                           "${output}.bed"
		!copy "${sub_mod_output}.bim"                           "${output}.bim"
		!copy "${sub_mod_output}.fam"                           "${output}.fam"
		!copy "${sub_mod_output}_CEU_TSI-like.keep"             "${output}_CEU_TSI-like.keep"
		}
	noi di as text"# > move files to new directory"
	qui {
		cd ..
		!del *_bim.dta
		!del ${output}.hg-buildmatc* ${output}.arraymatc*
		noi di as text"# > remove temporary directory"
		!rmdir  $wd /S /Q
		cd ..
		!mkdir "${output_2}"
		cd "${output_2}"
		!copy "${output}.bed"                           "${output_2}.bed"
		!copy "${output}.bim"                           "${output_2}.bim"
		!copy "${output}.fam"                           "${output_2}.fam"
		!copy "${output}_CEU_TSI-like.keep"             "${output_2}_CEU_TSI-like.keep  "
		!copy "${output}.meta-log"                      "${output_2}.meta-log"
		!copy "${output}.quality-control-report.docx"   "${output_2}.quality-control-report.docx"
		!del  ${output}*
		}
	noi di as text"#########################################################################"
	noi di as text" "
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
