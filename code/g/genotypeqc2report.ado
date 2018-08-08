global version v7
program genotypeqc2report
syntax, bim(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# genotypeqc2report"
noi di as text"#########################################################################"
noi di as text"# Started:             $S_DATE $S_TIME"
noi di as text"# Username:            `c(username)'"
noi di as text"# Operating System:    `c(os)'"
noi di as text"# Version:             "as result"${version}"
noi di as text"#########################################################################"
noi di as text""
noi di as text"#########################################################################"
noi di as text"# SECTION - A: set files/ folders"
noi di as text"#########################################################################"
qui { // A
	qui { // A1 - define operating system
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			noi di as text"# > genotypeqc2report ............... operating system is "as result "Unix"
			global delimit "/"
			}
		else if os == "Windows" { 
			noi di as text"# > genotypeqc2report ............... operating system is "as result "Windows"
			global delimit "\"	
			}
		}
	qui { // A2 - define folders and files for analysis
		noi di as text"# > genotypeqc2report ................................... define folders and files for analysis form path using path2file"
		path2file, path(`bim')
		}
	qui { // A3 - report parameters to screen
		noi di as text"#########################################################################"
		noi di as text"# > genotypeqc2report ...................... input folder "as result"${path2file_folder}"
		noi di as text"# > genotypeqc2report .................... input binaries "as result"${path2file_file}"
		noi di as text"# > genotypeqc2report ................... output binaries "as result"${path2file_file}-qc-${version}"
		noi di as text"#########################################################################"
		}
	qui { // A4 - define parameters
		noi di as text"# > genotypeqc2report ............ define parameters from "as result"..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}.genotypeqc-meta.log "
		noi checkfile, file(..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}.genotypeqc-meta.log)
		qui { // parse log file and recreate globals
			import delim using ..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}.genotypeqc-meta.log, clear
			replace v1 = subinstr(v1," +1","+1",.)
			replace v1 = subinstr(v1,"..","$",.)
			replace v1 = subinstr(v1,"$.","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			replace v1 = subinstr(v1,"$$","$",.)
			split v1, p(" $ ")
			drop if v1 == v11
			keep v12
			rename v12 v
			split v, p(" ")
			gen v1v2 = v1 + " " + v2
			gen v1v2v3 = v1v2 + " " + v3 
			gen v1v2v3v4 = v1v2v3 + " " + v4 
			gen v1v2v3v4v5 = v1v2v3v4 + " " + v5 
			gen a = ""
			order a
			replace a = "global rounds " + v5 if v1v2v3v4 == "rounds of quality control"
			replace a = "global ref " + v5 if v1v2 == "reference genotypes"
			replace a = "global hwep " + v3 if v1 == "--hardy" 
			replace a = "global mac " + v3 if v1 == "--mac" 
			replace a = "global hetsd " + v5 if v1 == "std"  
			replace a = "global mind " + v3 if v1 == "--mind"
			split v3,p(";")
			replace a = "global geno1 " + v31 if v1 == "--geno"  
			replace a = a + ":global geno2 " + v32 if v1 == "--geno" 
			split v4,p(";")
			replace a = "global kin_d " + v41 if v1 == "kinship" 
			replace a = a + ":global kin_f " + v42 if v1 == "kinship" 
			replace a = a + ":global kin_s " + v43 if v1 == "kinship"  
			replace a = a + ":global kin_t " + v44 if v1 == "kinship" 
			replace a = "global bim2array_array " +  v3 if v1v2 == "input array"
			replace a = a + ":global bim2array_jaccard " +  v6 if v1v2 == "input array"
			replace a = subinstr(a,";","",.)
			replace a = "global bim2build_input " + v3 if v1v2 == "input build" 
			replace a = "global bim2build_output " + v3 if v1v2 == "output build" 
			replace a = "global snp_input " + v6 if v1v2v3v4 == "markers in the input" 
			replace a = "global snp_output " + v6 if v1v2v3v4 == "markers in the output"
 			replace a = "global ind_input " + v6 if v1v2v3v4 == "individuals in the input" 
			replace a = "global ind_output " + v6 if v1v2v3v4 == "individuals in the output" 
			replace a = "global ancestry_like " + v31 if v1v2 == "ancestry mapping" 
			replace a = "global ancestry_like_n " + v5 if v1v2v3v4 == "individuals mapped to ancestry" 
			keep v a
			keep a
			split a,p(":")
			drop a
			gen obs = _n
			reshape long a , i(obs)
			keep a
			drop if a == ""
			outsheet a using tmp.do, non noq replace
			do tmp.do
			erase tmp.do
			}
		}
	qui { // A5 - locate files
		noi di as text"#########################################################################"
		noi checkfile, file(${path2file_folder}${path2file_file}.bim)
		noi checkfile, file(${path2file_folder}${delimit}genotypeqc_data${delimit}bim2frq_compare.gph)
		foreach i in FRQ HET HWE IMISS KIN0_1 KIN0_2 LMISS {
			noi checkfile, file(${path2file_folder}genotypeqc_data${delimit}temp-preqc_`i'.gph)
			}
		cd ${path2file_folder}
		noi checkfile, file(..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}.bim)
		noi checkfile, file(..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}.genotypeqc-meta.log)
		foreach i in FRQ HET HWE IMISS KIN0_1 KIN0_2 LMISS {
			noi checkfile, file(..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}_`i'.gph)
			}
		noi checkfile, file(..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-pca.gph)
		noi checkfile, file(..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-${ancestry_like}-like.gph)
		}
	noi di as text"#########################################################################"
	noi di as text""
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - B: create /join graphs"
noi di as text"#########################################################################"
qui { // B
	qui { // B1 - plot number of markers per bim file
		noi di as text"# > genotypeqc2report ............................ create "as result"..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-chromosomes.png "
		capture confirm file "..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-chromosomes.png"
			if _rc == 0 {
				}
			else {
				qui { // input
					bim2count, bim(${path2file_folder}${path2file_file})
					capture confirm file "${path2file_folder}${path2file_file}_bim.dta"
					if _rc == 0 {
						}
					else {
						bim2dta, bim(${path2file_folder}${path2file_file})
						}
					use ${path2file_folder}${path2file_file}_bim.dta, clear
					destring chr, replace
					sum chr
					hist chr,  xlabel(1(1)`r(max)') title("${path2file_file}") xtitle("Chromosome") caption("count based on ${bim2count_snp} SNPs") discrete freq ylabel(#4,format(%9.0g)) nodraw saving(temp-hist-chr-1.gph, replace)
					}
				qui { // output
					bim2count, bim(..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version})
					capture confirm file "..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}_bim.dta"
					if _rc == 0 {
						}
					else {
						bim2dta, bim(..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version})
						}
					use ..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}_bim.dta, clear
					destring chr, replace
					sum chr
					hist chr,  xlabel(1(1)`r(max)') title("${path2file_file}-qc-${version}") xtitle("Chromosome") caption("count based on ${bim2count_snp} SNPs") discrete freq ylabel(#4,format(%9.0g)) nodraw saving(temp-hist-chr-2.gph, replace)
					}
				graph combine temp-hist-chr-1.gph  temp-hist-chr-2.gph, caption("CREATED: $S_DATE $S_TIME",	size(tiny)) col(1) ycommon xcommon
				graph export  ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-chromosomes.png, as(png) replace width(8000) height(4000)
				window manage close graph
				erase temp-hist-chr-1.gph 
				erase temp-hist-chr-2.gph
				}
			}
	qui { // B2 - combine quality control plots
		foreach i in FRQ HET HWE IMISS LMISS {
			noi di as text"# > genotypeqc2report ............................ create "as result"..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-`i'.png"
			capture confirm file "..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-`i'.png"
			if _rc == 0 {
					}
			else {
				graph combine ${path2file_folder}genotypeqc_data${delimit}temp-preqc_`i'.gph,  title("${path2file_file}") nodraw saving(temp-1-`i'.gph, replace)
				graph combine ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}_`i'.gph,  title("${path2file_file}-qc-${version}") nodraw saving(temp-2-`i'.gph, replace)
				graph combine temp-1-`i'.gph temp-2-`i'.gph, xcommon caption("CREATED: $S_DATE $S_TIME", size(tiny)) col(1) 
				graph export  ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-`i'.png, as(png) replace width(8000) height(4000)
				window manage close graph
				erase temp-1-`i'.gph
				erase temp-2-`i'.gph
				}
			}
		foreach i in KIN0_1 KIN0_2 {
			noi di as text"# > genotypeqc2report ............................ create "as result"..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-`i'.png"
			capture confirm file "..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-`i'.png"
			if _rc == 0 {
					}
			else {
				graph combine ${path2file_folder}genotypeqc_data${delimit}temp-preqc_`i'.gph,  title("${path2file_file}") nodraw saving(temp-1-`i'.gph, replace)
				graph combine ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}_`i'.gph,  title("${path2file_file}-qc-${version}") nodraw saving(temp-2-`i'.gph, replace)
				graph combine temp-1-`i'.gph temp-2-`i'.gph, xcommon caption("CREATED: $S_DATE $S_TIME", size(tiny)) col(1) 
				graph export  ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-hist-`i'.png, as(png) replace width(8000) height(3000)
				window manage close graph
				erase temp-1-`i'.gph
				erase temp-2-`i'.gph
				}
			}
		}
	qui { // B3 - convert gph to png
		noi di as text"# > genotypeqc2report ............................ create "as result"..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}bim2frq_compare.png"
		capture confirm file "..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}bim2frq_compare.png"
		if _rc == 0 {
					}
			else {
				graph combine ${path2file_folder}genotypeqc_data${delimit}bim2frq_compare.gph,  title("${path2file_file}") nodraw saving(temp-1.gph, replace)
				graph combine temp-1.gph,  caption("CREATED: $S_DATE $S_TIME", size(tiny)) col(1) 
				graph export  ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}bim2frq_compare.png, as(png) replace width(8000) height(4000)
				window manage close graph
				erase temp-1.gph
				}
		noi di as text"# > genotypeqc2report ............................ create "as result"..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}bim2hapmap.png"
		capture confirm file "..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}bim2hapmap.png"
		if _rc == 0 {
				}
		else {		
			graph combine ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-pca.gph, title("All HapMap3") nodraw saving(temp-1.gph, replace)
			graph combine ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}${path2file_file}-qc-${version}-${like}-like.gph, title("${like}") nodraw saving(temp-2.gph, replace)
			graph combine temp-1.gph temp-2.gph, xcommon title("${path2file_file}") caption("CREATED: $S_DATE $S_TIME", size(tiny)) col(1) 
			graph export ..${delimit}${path2file_file}-qc-${version}${delimit}genotypeqc_data${delimit}bim2hapmap.png, as(png) replace width(8000) height(4000)
			window manage close graph	
			}
		}
	}
noi di as text"#########################################################################"
noi di as text""
noi di as text"#########################################################################"
noi di as text"# SECTION - C: create report"
noi di as text"#########################################################################"
qui { // C
	noi di as text"# > genotypeqc2report ............................ create "as result"..${delimit}${path2file_file}-qc-${version}${delimit}${path2file_file}-qc-${version}-quality-control-report.docx"
	genotypeqc2report_subroutine
	noi di as text"#########################################################################"
	noi di as text""
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
