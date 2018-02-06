/*
*program*
 genotypeqc

*description* 
 a command to perform quality control of genotyping arrays

*syntax*
genotypeqc , param(-param-) [known_array(-array_name-)]

 -param-      name of the qc parameter file
 -array_name- name of array - if known
*/
qui { // version
/*
# version 5
# =======================================================================
# change maf to mac5
# remove allele freq check if data is imputed against hrc - mixed ancestry of samples removes non-eur alleles
# retain W/S and ID

# version 6
# =======================================================================
# update speed - ignore/rename where rebuild of plink not necessary

# version 7
# =======================================================================
# update speed - convert sub-routine to programs e.g. bim2build

*/
}
global version v7
program genotypeqc
syntax, [known_array(string asis)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# genotypeqc"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > genotypeqc .................................. version "as result"${version}"
	qui { // load parameters to memory
			global input    "${data_folder}\\${data_input}"
			global output   "${data_folder}\\${data_input}-qc-${version}"
			global output_2 "${data_input}-qc-${version}"
			noi di as text"# > genotypeqc ............................ running qc on "as result"${data_input}"
			noi di as text"# > genotypeqc ............................. reporting to "as result"${output_2}"
			noi di as text"# > genotypeqc ........................ --mac (threshold) "as result"5"
			noi di as text"# > genotypeqc ....................... --geno (threshold) "as result"${geno1}"as text";"as result"${geno2}"
			noi di as text"# > genotypeqc ....................... --mind (threshold) "as result"${mind}"
			noi di as text"# > genotypeqc ...................... --hardy (threshold) "as result"1e-${hwep}"
			noi di as text"# > genotypeqc ....... std dev heterozygosity (threshold) "as result"${hetsd}"
			noi di as text"# > genotypeqc .... kinship (dup;1st;2nd;3rd) (threshold) "as result"${kin_d}"as text";"as result"${kin_f}"as text";"as result"${kin_s}"as text";"as result"${kin_t}"
			noi di as text"#########################################################"
			}
	qui { // check path of dependent software is true
		noi di as text"# > genotypeqc .......................................... check path"
		noi checkfile, file(${plink})
		noi checkfile, file(${plink2})
			checktabbed
		noi checkfile, file(${bim2build_ref})
		foreach file in bim bed fam {
			noi checkfile, file(${ref}.`file')
			}
		foreach file in bim bed fam {
			noi checkfile, file(${bim2frq_compare_ref}.`file')
			}
		foreach file in bim bed fam {
			noi checkfile, file(${bim2hapmap_hapmap}.`file')
			}
		noi checkfile, file(${bim2hapmap_aims})
		foreach file in bim bed fam {
			noi checkfile, file(${data_folder}\\${data_input}.`file')
			}
		noi di as text"# > genotypeqc .................... bim2array_ref folder "as result"${bim2array_ref}"
		noi di as text"#########################################################################"
		}
	}
qui { // 2 - set working directory
	noi di as text""
	noi di as text"# > genotypeqc .......................................... "as result"setting working directory"
	cd ${data_folder}
	noi create_temp_dir
	}
qui { // 3 - determining the original genotyping array
	noi di as text""
	noi di as text"# > genotypeqc .......................................... "as result"determining original genotyping array"
	clear
	set obs 1
	gen known_array = "`known_array'"
	if  known_array == "" {
		noi di as text"# > genotypeqc ...... array unknown - determine array for "as result"${data_input}"
		noi bim2array, bim(${input}) dir(${bim2array_ref})
		}
	else {
		noi di as text"# > genotypeqc ........................ array defined for "as result"${data_input}"
		noi di as text"# > genotypeqc ................. array defined by user as "as result"`known_array'"
		global bim2array "`known_array'"
		noi di as text"# > genotypeqc ................. plotting blank graphs to "as result"${input}.arraymatch.png"
		tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))     
		graph export  ${input}.arraymatch.png, height(1000) width(4000) as(png) replace 
		window manage close graph
		}
	}
qui { // 4 - pre-cleaning and update build
	noi di as text""
	noi di as text"# > genotypeqc .......................................... basic pruning (pre-cleaning)"
	global sub_mod_output tempfile-4-01
	noi bim2count, bim(${input})
	qui bim2dta, bim(${input})
	gen keep = .
	foreach i of num 1/23 {
		replace keep = 1 if chr == "`i'"
		}
	keep if keep == 1
	outsheet snp using ${sub_mod_output}.extract, non noq replace
	!$plink --bfile ${input} --mac 5 --geno 0.99 --mind 0.99 --extract ${sub_mod_output}.extract --make-founders  --make-bed --out ${sub_mod_output} 
	noi bim2count, bim(${sub_mod_output})
	}
qui { // 5 - confirm / update genome build 	
	noi di as text""
	noi di as text"# > genotypeqc .......................................... update / confirm hg19 +1"
	noi bim2build, bim(${sub_mod_output}) ref(${bim2build_ref})
	!rename "${sub_mod_output}.bim2build.png" "${input}.bim2build.png"
	clear
	set obs 1
	gen build = "${bim2build}"
	if build == "hg19 +1" {
		noi di as text"# > genotypeqc ......................... build is hg19 +1 "as result"do nothing"
		}
	else {
		noi di as text"# > genotypeqc ......................... build is ${bim2build} "as result"convert to hg19 +1"
		noi di as text""
		noi di as text"# > genotypeqc .......................................... update to hg19 +1"		
		bim2dta, bim(${sub_mod_output})
		keep snp
		merge 1:1 snp using $array_ref\\$bim2array.dta
		keep if _m == 3
		outsheet snp using bim2build.extract, non noq replace
		outsheet snp chr using bim2build.update-chr, non noq replace
		outsheet snp bp  using bim2build.update-map, non noq replace
		!$plink --bfile ${sub_mod_output} --extract bim2build.extract --make-bed --out bim2build-1 
		!$plink --bfile bim2build-1 --update-chr bim2build.update-chr --make-bed --out bim2build-2 
		!$plink --bfile bim2build-2 --update-map  bim2build.update-map  --make-bed --out ${sub_mod_output} 
		noi bim2build, bim(${sub_mod_output}) ref(${build_ref})
		!del bim2build-1.* bim2build-2.* bim2build.*
		}
	}
qui { // 6 - convert snp-name to reference
	noi di as text""
	noi di as text"# > genotypeqc .......................................... converting snp-name to reference"
	noi bim2refid, bim(${sub_mod_output}) ref(${ref})
	!del ${sub_mod_output}.*
	}
qui { // 7 - check allele frequencies
	noi di as text""
	noi di as text"# > genotypeqc .......................................... compare allele frequencies with reference"
	noi bim2frq_compare, bim(${sub_mod_output}-refid) ref(${bim2frq_compare_ref})
	!$plink --bfile ${sub_mod_output}-refid --exclude bim2frq_compare.exclude --make-bed --out ${sub_mod_output}-preclean
	!copy "bim2frq_compare.png" "${sub_mod_output}-preclean-bim2frq_compare.png"
	!del ${sub_mod_output}-refid.* bim2frq_compare.exclude bim2frq_compare.png
	}
qui { // 8 - calculate pre-qc metrics
	noi di as text""
	noi di as text"# > genotypeqc .......................................... calculate pre-quality control metrics"
	global sub_mod_input  ${sub_mod_output}-preclean
	!$plink  --bfile ${sub_mod_input} --freq counts    --out ${sub_mod_input}
	!$plink  --bfile ${sub_mod_input} --maf 0.05 --het --out ${sub_mod_input}
	!$plink  --bfile ${sub_mod_input} --hardy          --out ${sub_mod_input}
	!$plink  --bfile ${sub_mod_input} --missing        --out ${sub_mod_input}
	bim2ld_subset, bim(${sub_mod_input})
	!$plink2 --bfile ${sub_mod_input} --extract bim2ld_subset50000.extract --make-king-table --king-table-filter .0221 --out ${sub_mod_input}
	}
qui { // 9 - plot metrics
	noi di as text"# > genotypeqc .......................................... plotting pre-quality control metrics"
	noi graphplinkfrq, frq(${sub_mod_input}) 
	noi graphplinkhet, het(${sub_mod_input}) sd(${hetsd})
	noi graphplinkhwe, hwe(${sub_mod_input}) threshold(${hwep})
	noi graphplinkimiss, imiss(${sub_mod_input}) mind(${mind})
	noi graphplinklmiss, lmiss(${sub_mod_input}) geno(${geno2})	
	noi graphplinkkin0, kin0(${sub_mod_input}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
	foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
		!copy /y  "tmp`graph'.gph" "${sub_mod_input}_`graph'.gph"
		erase "tmp`graph'.gph"
		}
	!copy /y  "tmpKIN0.relPairs" "${sub_mod_input}.relPairs"
	foreach file in frq.counts het hwe nosex lmiss imiss log kin0 {
		!del ${sub_mod_input}.`file' tmpKIN0.relPairs
		}
	}	
qui { // 10 - apply quality-control to binaries
	noi di as text""
	noi di as text"# > genotypeqc .......................................... applying quality control - round 1 "
	noi di as text""
	qui { // het
		noi di as text"# > genotypeqc ................................. (round1) "as result "het"
		global sub_mod_mid ${sub_mod_output}-01
		!$wc -l tmpHET.indlist  > ${sub_mod_mid}.het-count
		import delim using ${sub_mod_mid}.het-count, clear varnames(nonames)
		erase ${sub_mod_mid}.het-count
		split v1,p(" ")
		destring v11, replace
		sum v11
		if `r(N)' > 0 {
			!$plink --bfile ${sub_mod_input} --remove tmpHET.indlist --set-hh-missing --make-bed --out ${sub_mod_mid}
			!del tmpHET.indlist
			foreach file in bim bed fam log nosex {
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
	qui {	// hwe
		noi di as text"# > genotypeqc ................................. (round1) "as result "hwe"
		global sub_mod_input  ${sub_mod_output}-01
		global sub_mod_mid    ${sub_mod_output}-02
		!$wc -l tmpHWE.snplist > ${sub_mod_mid}.hwe-count
		import delim using ${sub_mod_mid}.hwe-count, clear varnames(nonames)
		erase ${sub_mod_mid}.hwe-count
		split v1,p(" ")
		destring v11, replace
		sum v11	
		if `r(N)' > 0 {
			!$plink --bfile ${sub_mod_input} --exclude  tmpHWE.snplist --make-bed --out ${sub_mod_mid}
			!del tmpHWE.snplist
			foreach file in bim bed fam log nosex {
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
	qui {	// lmiss (1)
		noi di as text"# > genotypeqc ................................. (round1) "as result "lmiss (1)"
		global sub_mod_input  ${sub_mod_output}-02
		global sub_mod_mid    ${sub_mod_output}-03
		!$plink --bfile ${sub_mod_input} --geno ${geno1} --make-bed --out ${sub_mod_mid}
		foreach file in bim bed fam log nosex {
			!del "${sub_mod_input}.`file'"
			}
		}
	qui {	// imiss
		noi di as text"# > genotypeqc ................................. (round1) "as result "imiss"
		global sub_mod_input  ${sub_mod_output}-03
		global sub_mod_mid    ${sub_mod_output}-04
		!$plink --bfile ${sub_mod_input} --mind ${mind}  --make-bed --out ${sub_mod_mid}
		foreach file in bim bed fam log nosex {
			!del "${sub_mod_input}.`file'"
			}
		}
	qui {	// lmiss (2)
		noi di as text"# > genotypeqc ................................. (round1) "as result "lmiss (2)"
		global sub_mod_input  ${sub_mod_output}-04
		global sub_mod_mid    ${sub_mod_output}-05
		!$plink --bfile ${sub_mod_input} --geno ${geno2} --make-bed --out ${sub_mod_mid}
		foreach file in bim bed fam log nosex {
			!del "${sub_mod_input}.`file'"
			}
		}
	qui {	// cryptic relatedness
		noi di as text"# > genotypeqc ................................. (round1) "as result "cryptic relatedness"
		global sub_mod_input  ${sub_mod_output}-05
		global sub_mod_mid tempfile-10
		bim2cryptic, bim(${sub_mod_input})
		!$plink --bfile ${sub_mod_input} --remove bim2cryptic.remove --make-bed --out ${sub_mod_mid}-round1
		!del ${sub_mod_output}-05* bim2cryptic.remove
		}
	}
qui { // 11 - apply quality-control to binaries (rounds 2 through $rounds )
	foreach round of num  2 / $rounds {	
		qui { // define round
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
		qui { // calculate metrics
			noi di as text""
			noi di as text"# > genotypeqc .......................................... calculate quality control metrics - round `round'"
			global sub_mod_input  ${sub_mod_mid}-${round1}
			global sub_mod_output ${sub_mod_mid}-${round2}
			!$plink  --bfile ${sub_mod_input} --maf 0.05 --het --out ${sub_mod_input}
			!$plink  --bfile ${sub_mod_input} --hardy          --out ${sub_mod_input}
			}
		qui { // plotting metrics
			noi di as text"# > genotypeqc .......................................... plotting quality control metrics - round `round'"
			noi graphplinkhet, het(${sub_mod_input}) sd(${hetsd})
			noi graphplinkhwe, hwe(${sub_mod_input}) threshold(${hwep}) 
			}
		qui { // apply quality-control to binaries
			noi di as text""
			noi di as text"# > genotypeqc .......................................... applying quality control - round `round' "
			qui { // het
				noi di as text""
				noi di as text"# > genotypeqc ................................. (round`round') "as result "het"
				global sub_mod_mid    ${sub_mod_output}-01
				!$wc -l tmpHET.indlist  > ${sub_mod_mid}.het-count
				import delim using ${sub_mod_mid}.het-count, clear varnames(nonames)
				erase ${sub_mod_mid}.het-count
				split v1,p(" ")
				destring v11, replace
				sum v11
				if `r(N)' > 0 {
					!$plink --bfile ${sub_mod_input} --remove tmpHET.indlist --set-hh-missing --make-bed --out ${sub_mod_mid}
					!del tmpHET.indlist ${sub_mod_input}*
					}
				else {
					foreach file in bim bed fam {
						!rename "${sub_mod_input}.`file'" "${sub_mod_mid}.`file'"
						}
					}
				}
			qui { // hwe
				noi di as text"# > genotypeqc ................................. (round`round') "as result "hwe"
				global sub_mod_input  ${sub_mod_output}-01
				global sub_mod_mid    ${sub_mod_output}-02
				!$wc -l tmpHWE.snplist > ${sub_mod_mid}.hwe-count
				import delim using ${sub_mod_mid}.hwe-count, clear varnames(nonames)
				erase ${sub_mod_mid}.hwe-count
				split v1,p(" ")
				destring v11, replace
				sum v11	
				if `r(N)' > 0 {
					!$plink --bfile ${sub_mod_input} --exclude  tmpHWE.snplist --make-bed --out ${sub_mod_mid}
					!del tmpHWE.snplist ${sub_mod_input}.*
					}
				else {
					foreach file in bim bed fam {
						!del "${sub_mod_mid}.`file'"
						!rename "${sub_mod_input}.`file'" "${sub_mod_mid}.`file'"
						}
					}
				}
			qui { // imiss
				noi di as text"# > genotypeqc ................................. (round`round') "as result "imiss"
				global sub_mod_input  ${sub_mod_output}-02
				global sub_mod_mid    ${sub_mod_output}-03
				!$plink --bfile ${sub_mod_input} --mind ${mind}  --make-bed --out ${sub_mod_mid}
				!del ${sub_mod_input}.*
				}
			qui { // lmiss 
				noi di as text"# > genotypeqc ................................. (round`round') "as result "lmiss"
				global sub_mod_input  ${sub_mod_output}-03
				global sub_mod_mid tempfile-10
				!$plink --bfile ${sub_mod_input} --geno ${geno2} --make-bed --out ${sub_mod_mid}-${round2}
				!del ${sub_mod_input}.*
				}
			}
		!del tmpHWE.gph tmpHET.gph *.log *.nosex *.hwe *.het
		}
	}	
qui { // 12 - calculate post-qc metrics
	noi di as text""
	noi di as text"# > genotypeqc .......................................... calculate post-quality control metrics"
	global sub_mod_input  ${sub_mod_mid}-${round2}
	!$plink  --bfile ${sub_mod_input} --freq counts    --out ${sub_mod_input}
	!$plink  --bfile ${sub_mod_input} --maf 0.05 --het --out ${sub_mod_input}
	!$plink  --bfile ${sub_mod_input} --hardy          --out ${sub_mod_input}
	!$plink  --bfile ${sub_mod_input} --missing        --out ${sub_mod_input}
	!$plink2 --bfile ${sub_mod_input} --extract bim2ld_subset50000.extract --make-king-table --king-table-filter .0221 --out ${sub_mod_input}
	}
qui { // 13 - plot metrics
	noi di as text"# > genotypeqc .......................................... plotting post-quality control metrics"
	noi graphplinkfrq, frq(${sub_mod_input}) 
	noi graphplinkhet, het(${sub_mod_input}) sd(${hetsd})
	noi graphplinkhwe, hwe(${sub_mod_input}) threshold(${hwep})
	noi graphplinkimiss, imiss(${sub_mod_input}) mind(${mind})
	noi graphplinklmiss, lmiss(${sub_mod_input}) geno(${geno2})	
	noi graphplinkkin0, kin0(${sub_mod_input}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
	foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
		!copy /y  "tmp`graph'.gph" "${sub_mod_input}_`graph'.gph"
		erase "tmp`graph'.gph"
		}
	!copy /y  "tmpKIN0.relPairs" "${sub_mod_input}.relPairs"
	foreach file in frq.counts het hwe nosex lmiss imiss log kin0 {
		!del ${sub_mod_input}.`file' tmpKIN0.relPairs 
		}
	!del *.snplist *.indlist
	}	
qui { // 14 - define ancestry
	noi di as text""
	noi di as text"# > genotypeqc .......................................... define ancestry"
	noi bim2hapmap, bim (${sub_mod_input}) like(CEU TSI) hapmap(${bim2hapmap_hapmap}) aims(${bim2hapmap_aims})
	!rename "bim2hapmap_pca-CEU_TSI-like.png" "${sub_mod_input}_pca-CEU_TSI-like.png"
	!rename "bim2hapmap_pca.png" "${sub_mod_input}_pca.png"
	!rename "bim2hapmap_CEU_TSI-like.keep" "${sub_mod_input}_CEU_TSI-like.keep"
	}
qui { // 15 - creating final reports	
	noi di as text"#########################################################################"
	noi di as text"# creating final reports"
	noi di as text"#########################################################################"
	noi di as text"# Started: $S_DATE $S_TIME"
	noi di as text"#########################################################################"
	qui { // plotting markers by chromosome by input / output"
		noi di as text""
		noi di as text"# > genotypeqc .......................................... plotting histogram of markers per chromosome (pre/post)"
		bim2dta,bim(${input})
		count
		destring chr, replace
		hist chr,  xlabel(1(1)25) xtitle("Chromosome") caption("count based on `r(N)' SNPs") discrete freq ylabel(#4,format(%9.0g))
		graph save _1.gph, replace
		window manage close graph
		bim2dta,bim(${sub_mod_output})
		count
		destring chr, replace
		hist chr,  xlabel(1(1)25) xtitle("Chromosome") caption("count based on `r(N)' SNPs") discrete freq ylabel(#4,format(%9.0g))
		graph save _2.gph, replace
		window manage close graph
		graph combine _1.gph  _2.gph, caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}",	size(tiny)) col(1) ycommon
		graph export  ${sub_mod_output}-chromosomes.png, as(png) replace width(4000) height(2000)
		window manage close graph
		erase _1.gph
		erase _2.gph
		}
	qui { // plotting pre- post quality control graphs
		noi di as text"# > genotypeqc .......................................... plotting metrics (pre/post)"
		qui { 
			global sub_mod_pre  tempfile-4-01-preclean
			global sub_mod_post ${sub_mod_output}
			foreach i in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2{
				noi checkfile, file(${sub_mod_pre}_`i'.gph)
				noi checkfile, file(${sub_mod_post}_`i'.gph)
				graph combine ${sub_mod_pre}_`i'.gph,  title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
				graph combine ${sub_mod_post}_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace)
				graph combine x_`i'.gph y_`i'.gph, xcommon caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny)) col(1) 
				graph export ${sub_mod_output}-`i'.png, as(png) replace width(4000) height(2000)
				window manage close graph
				!del x_`i'* y_`i'* ${sub_mod_pre}_`i'.gph ${sub_mod_post}_`i'.gph
				}
			}	
		}
	qui { // counting markers in pre/post files
		noi di as text"# > genotypeqc .......................................... counting metrics and storing in memory"
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
	noi di as text"# > genotypeqc .......................................... creating quality control report (docx)"
	_sub_genotypeqc_report
	noi di as text"# > genotypeqc .......................................... creating quality control report (meta-log)"
	_sub_genotypeqc_meta
	}
qui { // 16 - rename and clean
	noi di as text"# > genotypeqc .......................................... moving and cleaning"

	!copy "${sub_mod_post}-quality-control-report.docx"   "${output}.quality-control-report.docx"
	!copy "${sub_mod_post}.meta-log"                      "${output}-genotypeqc.meta-log"
	!copy "${sub_mod_post}.bed"                           "${output}.bed"
	!copy "${sub_mod_post}.bim"                           "${output}.bim"
	!copy "${sub_mod_post}.fam"                           "${output}.fam"
	!copy "${sub_mod_post}_CEU_TSI-like.keep"             "${output}_CEU_TSI-like.keep"
	cd ..
	!rmdir  "$temp_dir" /S /Q
	cd ${data_folder}
	cd ..
	!rmdir "${output_2}"  /S /Q
	!mkdir "${output_2}"
	!copy "${output}.bed"                           "${output_2}\\${output_2}.bed"
	!copy "${output}.bim"                           "${output_2}\\${output_2}.bim"
	!copy "${output}.fam"                           "${output_2}\\${output_2}.fam"
	!copy "${output}_CEU_TSI-like.keep"             "${output_2}\\${output_2}_CEU_TSI-like.keep  "
	!copy "${output}-genotypeqc.meta-log"           "${output_2}\\${output_2}-genotypeqc.meta-log"
	!copy "${output}.quality-control-report.docx"   "${output_2}\\${output_2}.quality-control-report.docx"
	cd ${data_folder}
	!del ${output_2}* *arraymatch.png *.parameters *_bim.dta
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
