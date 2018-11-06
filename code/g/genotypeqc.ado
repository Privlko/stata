*! 1.0.7 Richard Anney 05nov2018
program genotypeqc
syntax, bim(string asis) [known_array(string asis)]

qui { // hard coded path / functions
	global version v7
	}
qui { // print boiler plate to screen
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# genotypeqc"
	noi di as text"#########################################################################"
	noi di as text"# Started:             $S_DATE $S_TIME"
	noi di as text"# Username:            `c(username)'"
	noi di as text"# Version:             "as result"${version}"
	noi di as text"#########################################################################"
	noi di as text""
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - A: set files/ folders"
noi di as text"#########################################################################"
qui { // A
	qui { // A1 - define operating system
		noi di as text"# Operating System:    `c(os)'"
		}
	qui { // A2 - define folders and files for analysis
		noi di as text"# > genotypeqc .......................................... define folders and files for analysis form path using path2file"
		path2file, path(`bim')
		noi di as text"#########################################################################"
		noi di as text"# > genotypeqc ............................. input folder "as result"${path2file_folder}"
		noi di as text"# > genotypeqc ........................... input binaries "as result"${path2file_file}"
		noi di as text"# > genotypeqc .......................... output binaries "as result"${path2file_file}-qc-${version}"
		noi di as text"#########################################################################"
		}
	qui { // A3 - report soft coded parameters to screen
		noi di as text"# > genotypeqc ........................ --mac (threshold) "as result"5"
		noi di as text"# > genotypeqc ....................... --geno (threshold) "as result"${geno1}"as text";"as result"${geno2}"
		noi di as text"# > genotypeqc ....................... --mind (threshold) "as result"${mind}"
		noi di as text"# > genotypeqc ...................... --hardy (threshold) "as result"1e-${hwep}"
		noi di as text"# > genotypeqc ....... std dev heterozygosity (threshold) "as result"${hetsd}"
		noi di as text"# > genotypeqc .... kinship (dup;1st;2nd;3rd) (threshold) "as result"${kin_d}"as text";"as result"${kin_f}"as text";"as result"${kin_s}"as text";"as result"${kin_t}"
		noi di as text"#########################################################################"
		}
	qui { // A4 - check path of dependent software is true
		noi di as text"# > genotypeqc .......................................... check path of files/ software"
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
			noi checkfile, file(${path2file_folder}/${path2file_file}.`file')
			}
		noi di as text"# > genotypeqc ..................... bim2array_ref folder "as result"${bim2array_ref}"
		noi di as text"#########################################################################"
		}
	qui { // A5 - create temporary working directory
		qui { // define temporary working directory
			cd ${path2file_folder}
			cd ..
			create_temp_dir
			!mkdir ${path2file_file}
			!mkdir ${path2file_file}/genotypeqc_data
			!mkdir ${path2file_file}-qc-${version}
			!mkdir ${path2file_file}-qc-${version}/genotypeqc_data
			}
		qui { // create output folder
			!mkdir ${path2file_folder}/genotypeqc_data
			!mkdir ${path2file_folder}-qc-${version}
			!mkdir ${path2file_folder}-qc-${version}/genotypeqc_data
			}
		noi di as text"# > genotypeqc .................................. created "as result"`c(pwd)'"
		noi di as text"#########################################################################"
		noi di as text""
		global home_folder `c(pwd)'
		}
	qui { // A6 - copy files to temp folder
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			!cp ${path2file_folder}/${path2file_file}.bed   ${home_folder}/${path2file_file}/${path2file_file}.bed
			!cp ${path2file_folder}/${path2file_file}.bim   ${home_folder}/${path2file_file}/${path2file_file}.bim
			!cp ${path2file_folder}/${path2file_file}.fam   ${home_folder}/${path2file_file}/${path2file_file}.fam
			!cp ${path2file_folder}/${path2file_file}.array ${home_folder}/${path2file_file}/${path2file_file}.array
			}
		else if os == "Windows" {
			!copy ${path2file_folder}/${path2file_file}.bed   ${home_folder}/${path2file_file}/${path2file_file}.bed
			!copy ${path2file_folder}/${path2file_file}.bim   ${home_folder}/${path2file_file}/${path2file_file}.bim
			!copy ${path2file_folder}/${path2file_file}.fam   ${home_folder}/${path2file_file}/${path2file_file}.fam
			!copy ${path2file_folder}/${path2file_file}.array ${home_folder}/${path2file_file}/${path2file_file}.array
			}
		foreach file in bim bed fam array {
			noi checkfile, file(${home_folder}/${path2file_file}/${path2file_file}.`file')
			}	
		noi di as text""	
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - B: define array"
noi di as text"#########################################################################"
qui { // B
	qui { // B1 - determining the original genotyping array
		clear
		set obs 1
		gen known_array = "`known_array'"
		if  known_array == "" {	
			noi di as text"# > genotypeqc .......................................... "as result"determining original genotyping array"
			capture confirm file "${home_folder}/${path2file_file}/${path2file_file}.array"
			if _rc==0 {
				import delim using "${home_folder}/${path2file_file}/${path2file_file}.array", clear delim(" ") varnames(1) case(preserve)
				duplicates drop
				gsort -j
				gen a1 = "global bim2array_array " + array in 1
				gen str6 jaccard2 = string(jaccard, "%5.4f") 
				gen a2 = "global bim2array_jaccard " + jaccard2 in 1 
				keep a1 a2
				gen n = 1
				keep in 1
				reshape long a, j(x) i(n)
				keep a
				outsheet a using bim2array_array_tmp.do, non noq replace
				do bim2array_array_tmp.do
				erase bim2array_array_tmp.do
				noi di as text"# > bim2array ...................................... from "as result "${home_folder}/${path2file_file}/${path2file_file}.array" 
				noi di as text"# > bim2array ......................... most likely array "as result "${bim2array_array}" 
				noi di as text"# > bim2array ........................ with jaccard index "as result "${bim2array_jaccard}" 
				}
			else {
				noi di as text"# > genotypeqc .................................. version "as result"${version}"
				noi di as text"# > genotypeqc ........................... file not found "as result"${home_folder}/${path2file_file}/${path2file_file}.array"
				bim2array, bim(${path2file_folder}/${path2file_file}) dir(${bim2array_ref})
				noi di as text"# > bim2array ...................................... from "as result "${path2file_folder}/${path2file_file}.array" 
				noi di as text"# > bim2array ......................... most likely array "as result "${bim2array_array}" 
				noi di as text"# > bim2array ........................ with jaccard index "as result "${bim2array_jaccard}" 
				}
			}
		else {
			noi di as text"# > genotypeqc ........................ array defined for "as result"${home_folder}/${path2file_file}/${path2file_file}"
			noi di as text"# > genotypeqc ................. array defined by user as "as result"`known_array'"
			global bim2array_array "`known_array'"
			}
		noi di as text"#########################################################################"
		noi di as text""
		}
	} 
noi di as text"#########################################################################"
noi di as text"# SECTION - C: pre-clean "
noi di as text"#########################################################################"
qui { // C
	global sub_ temp-preqc
	qui { // C1 - define name of cleaned binaries
		noi di as text"# > genotypeqc .......................................... pre-clean plink binaries"
		}
	qui { // C2 - count markers and individuals in binary using bim2count
		noi bim2count, bim(${home_folder}/${path2file_file}/${path2file_file})
		}
	qui { // C3 - define snps on chromosomes 1-23
		qui bim2dta, bim(${home_folder}/${path2file_file}/${path2file_file})
		gen keep = .
		foreach i of num 1/23 {
			replace keep = 1 if chr == "`i'"
			}
		keep if keep == 1
		outsheet snp using ${sub_}.extract, non noq replace
		}
	qui { // C4 - perform initial clean - limit to chr 1-23, mac 5 geno 0.99 mind 0.99
		noi di as text"# > genotypeqc .......................................... perform initial clean - limit to chr 1-23, mac 5 geno 0.99 mind 0.99"
		noi di as text"# > genotypeqc ................ save preclean binaries to "as result "${sub_}"
		clear
		set obs 1
		gen array = "${bim2array_array}"
		gen update = .
		replace update = 1 if array == "genomewidesnp-6-na35-affyid"  
		replace update = 1 if array == "genomewidesnp-5-na35-affyid"
		if update == 1 { 		
			use ${bim2array_ref}/${bim2array_array}.dta, replace
			keep snp rsid chr
			order snp rsid
			drop if snp == ""
			drop if rsid == ""
			duplicates tag snp, gen(tag)
			keep if tag == 0
			drop tag
			duplicates tag rsid, gen(tag)
			keep if tag == 0
			drop tag
			gen keep = .
			foreach i of num 1/23 {
				replace keep = 1 if chr == "`i'"
				}
			keep if keep == 1
			outsheet rsid using affy-to-rsid.extract, non noq replace
			outsheet snp rsid using affy-to-rsid.update-name, non noq replace		
			!$plink --bfile ${home_folder}/${path2file_file}/${path2file_file} --mac 5 --geno 0.99 --mind 0.99 --extract affy-to-rsid.extract --update-name affy-to-rsid.update-name --make-founders --make-bed --out ${sub_} 		
			erase affy-to-rsid.extract
			erase affy-to-rsid.update-name
			}
		else {
			!$plink --bfile ${home_folder}/${path2file_file}/${path2file_file} --mac 5 --geno 0.99 --mind 0.99 --extract ${sub_}.extract --make-founders  --make-bed --out ${sub_} 
			erase ${sub_}.extract
			}
		}
	qui { // C5 - count markers and individuals in cleaned binary using bim2count
		noi bim2count, bim(${sub_})
		noi di as text"#########################################################################"
		noi di as text""
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - D: define build and rename markers according to reference "
noi di as text"#########################################################################"
qui { // D
	qui { // D1 - check genome build 	
		noi di as text"# > genotypeqc ............................................... check genome build of plink binaries using bim2build"
		bim2build, bim(${sub_}) ref(${bim2build_ref})
		global input_bim2build $bim2build
		noi di as text"# > bim2build ....................................... build is "as result"${bim2build}"
		}
	qui { // D2 - update map
		clear
		set obs 1
		gen build = "${bim2build}"
		if build == "hg19 +1" {
			noi di as text"# > genotypeqc .............................. build is hg19 +1 "as result"do nothing"
			}
		else {
			noi di as text"# > genotypeqc .............................. build is ${bim2build} "as result"convert to hg19 +1"
			bim2dta, bim(${sub_})
			keep snp
			merge 1:1 snp using ${bim2array_ref}/${bim2array_array}.dta
			keep if _m == 3
			outsheet snp using bim2build.extract, non noq replace
			outsheet snp chr using bim2build.update-chr, non noq replace
			outsheet snp bp  using bim2build.update-map, non noq replace
			!$plink --bfile ${sub_} --extract bim2build.extract --make-bed --out bim2build-1 
			!$plink --bfile bim2build-1 --update-chr bim2build.update-chr --make-bed --out bim2build-2 
			!$plink --bfile bim2build-2 --update-map bim2build.update-map --make-bed --out ${sub_} 
			bim2build, bim(${sub_}) ref(${bim2build_ref})
			noi di as text"# > bim2build ................................... build is now "as result"${bim2build}"
			files2dta, dir(`c(pwd)')
			split file, p("bim2build")
			keep if file1 == ""
			replace file = "erase " + file
			outsheet file using temp-do.do, non noq replace
			do temp-do.do
			erase temp-do.do
			erase _files2dta.dta
			}
		}
	qui { // D3 - convert snp-name to reference
		noi di as text"# > genotypeqc ............................................... converting snp-name to reference using bim2refid"
		noi bim2refid, bim(${sub_}) ref(${ref})
		files2dta, dir(`c(pwd)')
		split file, p("${sub_}.")
		keep if file1 == ""
		replace file = "erase " + file
		outsheet file using temp-do.do, non noq replace
		do temp-do.do
		erase temp-do.do
		erase _files2dta.dta	
		}
	qui { // D4 - check allele frequencies
		noi di as text"# > genotypeqc ............................................... compare allele frequencies to reference using bim2frq_compare"
		noi bim2frq_compare, bim(${sub_}-refid) ref(${bim2frq_compare_ref})
		!$plink --bfile ${sub_}-refid --exclude bim2frq_compare.exclude --make-bed --out ${sub_}
		graph combine bim2frq_compare.gph, nodraw
		graph save ${path2file_folder}/genotypeqc_data/bim2frq_compare.gph, replace
		files2dta, dir(`c(pwd)')
		split file, p("${sub_}")
		drop if file1 == ""
		replace file = "erase " + file
		outsheet file using temp-do.do, non noq replace
		do temp-do.do
		erase temp-do.do
		noi di as text"#########################################################################"
		noi di as text""
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - E: calculate pre-quality control metrics "
noi di as text"#########################################################################"
qui { // E
	global sub_input  ${sub_}
	qui { // E1 - calculate pre-qc metrics
		noi di as text"# > genotypeqc .......................................... calculate pre-quality control metrics"
		!$plink  --bfile ${sub_input} --freq counts    --out ${sub_input}
		!$plink  --bfile ${sub_input} --maf 0.05 --het --out ${sub_input}
		!$plink  --bfile ${sub_input} --hardy          --out ${sub_input}
		!$plink  --bfile ${sub_input} --missing        --out ${sub_input}
		bim2ld_subset, bim(${sub_input})
		!$plink2 --bfile ${sub_input} --extract bim2ld_subset50000.extract --make-king-table --king-table-filter .0221 --out ${sub_input}
		}
	qui { // E2 - plot metrics
		noi di as text"# > genotypeqc .......................................... plotting pre-quality control metrics"
		graphplinkfrq, frq(${sub_input}) 
		graphplinkhet, het(${sub_input}) sd(${hetsd})
		graphplinkhwe, hwe(${sub_input}) threshold(${hwep})
		graphplinkimiss, imiss(${sub_input}) mind(${mind})
		graphplinklmiss, lmiss(${sub_input}) geno(${geno2})	
		graphplinkkin0, kin0(${sub_input}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
		}
	qui { // E3 - move graphs
		foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
			clear
			set obs 1
			gen os = "`c(os)'"
			if os == "Unix" { 
				!cp tmp`graph'.gph ${path2file_folder}/genotypeqc_data/${path2file_file}_`graph'.gph
				}
			else if os == "Windows" { 
				!copy tmp`graph'.gph ${path2file_folder}/genotypeqc_data/${path2file_file}_`graph'.gph
				}
			}
		}
	qui { // E4 - move relpairs
		insheet using tmpKIN0.relPairs, clear
		for var fid1-rel: tostring X, replace
		renvars, upper
		outsheet using ${home_folder}/${path2file_file}/genotypeqc_data/${sub_}.relPairs, noq replace
		}
		
	noi di as text"#########################################################################"
	noi di as text""
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - F: apply quality control metrics (ROUND 1)"
noi di as text"#########################################################################"
qui { // F
	qui { // F1 - apply quality-control to binaries - round 1
		noi di as text"# > genotypeqc .......................................... applying quality control - round 1 "
		}
	global sub_input  ${sub_}
	global sub_output ${sub_}-01
	qui { // F2 - het
		noi di as text"# > genotypeqc ................................. (round1) "as result "het"
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			!wc -l tmpHET.indlist  > ${sub_input}.het-count
			import delim using ${sub_input}.het-count, clear varnames(nonames)
				erase ${sub_input}.het-count
				split v1,p(" ")
				destring v11, replace
				sum v11
				if `r(N)' > 0 { 
					!$plink --bfile ${sub_input} --remove tmpHET.indlist --set-hh-missing --make-bed --out ${sub_output}
					!rm tmpHET.indlist
					foreach file in bim bed fam log nosex {
						!rm "${sub_input}.`file'"
						}
					}
				else {
					foreach file in bim bed fam {
					!rm "${sub_output}.`file'"
					!mv "${sub_input}.`file'" "${sub_output}.`file'"
					}
				}
				}
		else if os == "Windows" { 	
				import delim using  tmpHET.indlist, clear varnames(nonames)
				count
				if `r(N)' > 0 { 
					!$plink --bfile ${sub_input} --remove tmpHET.indlist --set-hh-missing --make-bed --out ${sub_output}
					!erase tmpHET.indlist
					foreach file in bim bed fam log nosex {
						!erase "${sub_input}.`file'"
						}
					}
				else {
					foreach file in bim bed fam {
						!del "${sub_output}.`file'"
						!rename "${sub_input}.`file'" "${sub_output}.`file'"
						}
					}
				}
			}
	global sub_input  ${sub_}-01
	global sub_output ${sub_}-02
	qui { // F3 - hwe
		noi di as text"# > genotypeqc ................................. (round1) "as result "hwe"
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			!wc -l tmpHWE.snplist > ${sub_input}.hwe-count
			import delim using ${sub_input}.hwe-count, clear varnames(nonames)
			erase ${sub_input}.hwe-count
			split v1,p(" ")
			destring v11, replace
			sum v11	
			if `r(N)' > 0 {
				!$plink --bfile ${sub_input} --exclude  tmpHWE.snplist --make-bed --out ${sub_output}
				!rm tmpHWE.snplist
				foreach file in bim bed fam log nosex {
					!rm "${sub_input}.`file'"
					}
				}
			else {
				foreach file in bim bed fam {
					!rm "${sub_output}.`file'"
					!mv "${sub_input}.`file'" "${sub_output}.`file'"
					}
				}

			}
		else if os == "Windows" { 	
			import delim using  tmpHWE.snplist, clear varnames(nonames)
			count
			if `r(N)' > 0 {
				!$plink --bfile ${sub_input} --exclude  tmpHWE.snplist --make-bed --out ${sub_output}
				!del tmpHWE.snplist
				foreach file in bim bed fam log nosex {
					!del "${sub_input}.`file'"
					}
				}
			else {
				foreach file in bim bed fam {
					!del "${sub_output}.`file'"
					!rename "${sub_input}.`file'" "${sub_output}.`file'"
					}
				}
			}		
		
		}
	global sub_input  ${sub_}-02
	global sub_output ${sub_}-03
	qui { // F4 - lmiss (1)
		noi di as text"# > genotypeqc ................................. (round1) "as result "lmiss (1)"
		!$plink --bfile ${sub_input} --geno ${geno1} --make-bed --out ${sub_output}
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			foreach file in bim bed fam log nosex {
				!rm "${sub_input}.`file'"
				}
			}
		else if os == "Windows" { 
			foreach file in bim bed fam log nosex {
				!del "${sub_input}.`file'"
				}	
			}
		}
	global sub_input  ${sub_}-03
	global sub_output ${sub_}-04
	qui { // F5 - imiss
		noi di as text"# > genotypeqc ................................. (round1) "as result "imiss"
		!$plink --bfile ${sub_input} --mind ${mind}  --make-bed --out ${sub_output}
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			foreach file in bim bed fam log nosex {
				!rm "${sub_input}.`file'"
				}
			}
		else if os == "Windows" { 
			foreach file in bim bed fam log nosex {
				!del "${sub_input}.`file'"
				}	
			}
		}
	global sub_input  ${sub_}-04
	global sub_output ${sub_}-05
	qui { // F6 - lmiss (2)
		noi di as text"# > genotypeqc ................................. (round1) "as result "lmiss (2)"
		!$plink --bfile ${sub_input} --geno ${geno2} --make-bed --out ${sub_output}
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			foreach file in bim bed fam log nosex {
				!rm "${sub_input}.`file'"
				}
			}
		else if os == "Windows" { 
			foreach file in bim bed fam log nosex {
				!del "${sub_input}.`file'"
				}	
			}
		}
	global sub_input  ${sub_}-05
	global sub_output ${sub_}-round1
	qui { // F7 - cryptic relatedness
		noi di as text"# > genotypeqc ................................. (round1) "as result "cryptic relatedness"
		bim2cryptic, bim(${sub_input})
		!$plink --bfile ${sub_input} --remove bim2cryptic.remove --make-bed --out ${sub_}-round1
		files2dta, dir(`c(pwd)')
		gen keep = .
		replace keep = 1 if file == "${sub_}-round1.bim"
		replace keep = 1 if file == "${sub_}-round1.bed"
		replace keep = 1 if file == "${sub_}-round1.fam"
		gen a = "erase " + file
		outsheet a if keep == . using tmp.do, non noq replace
		do tmp.do 
		erase tmp.do
		noi di as text"#########################################################################"
		noi di as text""
		}
	} 
noi di as text"#########################################################################"
noi di as text"# SECTION - G: apply quality control metrics (ROUND 2 through $rounds)"
noi di as text"#########################################################################"
qui { // G
	qui { // G1 - apply quality-control to binaries (rounds 2 through $rounds )
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
			global sub_input  ${sub_}-${round1}
			global sub_output ${sub_}-${round2}
			qui { // calculate metrics
				noi di as text""
				noi di as text"# > genotypeqc .......................................... calculate quality control metrics - round `round'"
				!$plink  --bfile ${sub_input} --maf 0.05 --het --out ${sub_input}
				!$plink  --bfile ${sub_input} --hardy          --out ${sub_input}
				}
			qui { // plotting metrics
				noi di as text"# > genotypeqc .......................................... plotting quality control metrics - round `round'"
				graphplinkhet, het(${sub_input}) sd(${hetsd})
				graphplinkhwe, hwe(${sub_input}) threshold(${hwep}) 
				}
			qui { // apply quality-control to binaries
				noi di as text"# > genotypeqc .......................................... applying quality control - round `round' "
				global sub_input  ${sub_}-${round1}
				global sub_output ${sub_}-${round1}-01
				qui { // G2 - het
					noi di as text"# > genotypeqc ................................. (round1) "as result "het"
					clear
					set obs 1
					gen os = "`c(os)'"
					if os == "Unix" { 
						!wc -l tmpHET.indlist  > ${sub_input}.het-count
						import delim using ${sub_input}.het-count, clear varnames(nonames)
							erase ${sub_input}.het-count
							split v1,p(" ")
							destring v11, replace
							sum v11
							if `r(N)' > 0 { 
								!$plink --bfile ${sub_input} --remove tmpHET.indlist --set-hh-missing --make-bed --out ${sub_output}
								!rm tmpHET.indlist
								foreach file in bim bed fam log nosex {
									!rm "${sub_input}.`file'"
									}
								}
							else {
								foreach file in bim bed fam {
								!rm "${sub_output}.`file'"
								!mv "${sub_input}.`file'" "${sub_output}.`file'"
								}
							}
							}
					else if os == "Windows" { 	
							import delim using  tmpHET.indlist, clear varnames(nonames)
							count
							if `r(N)' > 0 { 
								!$plink --bfile ${sub_input} --remove tmpHET.indlist --set-hh-missing --make-bed --out ${sub_output}
								!erase tmpHET.indlist
								foreach file in bim bed fam log nosex {
									!erase "${sub_input}.`file'"
									}
								}
							else {
								foreach file in bim bed fam {
									!del "${sub_output}.`file'"
									!rename "${sub_input}.`file'" "${sub_output}.`file'"
									}
								}
							}
						}
				global sub_input  ${sub_}-${round1}-01
				global sub_output ${sub_}-${round1}-02
				qui { // G3 - hwe
					noi di as text"# > genotypeqc ................................. (round1) "as result "hwe"
					clear
					set obs 1
					gen os = "`c(os)'"
					if os == "Unix" { 
						!wc -l tmpHWE.snplist > ${sub_input}.hwe-count
						import delim using ${sub_input}.hwe-count, clear varnames(nonames)
						erase ${sub_input}.hwe-count
						split v1,p(" ")
						destring v11, replace
						sum v11	
						if `r(N)' > 0 {
							!$plink --bfile ${sub_input} --exclude  tmpHWE.snplist --make-bed --out ${sub_output}
							!rm tmpHWE.snplist
							foreach file in bim bed fam log nosex {
								!rm "${sub_input}.`file'"
								}
							}
						else {
							foreach file in bim bed fam {
								!rm "${sub_output}.`file'"
								!mv "${sub_input}.`file'" "${sub_output}.`file'"
								}
							}

						}
					else if os == "Windows" { 	
						import delim using  tmpHWE.snplist, clear varnames(nonames)
						count
						if `r(N)' > 0 {
							!$plink --bfile ${sub_input} --exclude  tmpHWE.snplist --make-bed --out ${sub_output}
							!del tmpHWE.snplist
							foreach file in bim bed fam log nosex {
								!del "${sub_input}.`file'"
								}
							}
						else {
							foreach file in bim bed fam {
								!del "${sub_output}.`file'"
								!rename "${sub_input}.`file'" "${sub_output}.`file'"
								}
							}
						}		
					
					}
				global sub_input  ${sub_}-${round1}-02
				global sub_output ${sub_}-${round1}-03
				qui { // G4 - imiss
					noi di as text"# > genotypeqc ................................. (round1) "as result "imiss"
					!$plink --bfile ${sub_input} --mind ${mind}  --make-bed --out ${sub_output}
					clear
					set obs 1
					gen os = "`c(os)'"
					if os == "Unix" { 
						foreach file in bim bed fam log nosex {
							!rm "${sub_input}.`file'"
							}
						}
					else if os == "Windows" { 
						foreach file in bim bed fam log nosex {
							!del "${sub_input}.`file'"
							}	
						}
					}
				global sub_input  ${sub_}-${round1}-03
				global sub_output ${sub_}-${round2}
				qui { // G5 - lmiss
					noi di as text"# > genotypeqc ................................. (round1) "as result "lmiss (2)"
					!$plink --bfile ${sub_input} --geno ${geno2} --make-bed --out ${sub_output}
					clear
					set obs 1
					gen os = "`c(os)'"
					if os == "Unix" { 
						foreach file in bim bed fam log nosex {
							!rm "${sub_input}.`file'"
							}
						}
					else if os == "Windows" { 
						foreach file in bim bed fam log nosex {
							!del "${sub_input}.`file'"
							}	
						}
					}
				files2dta, dir(`c(pwd)')
				gen keep = .
				replace keep = 1 if file == "${sub_}-${round2}.bim"
				replace keep = 1 if file == "${sub_}-${round2}.bed"
				replace keep = 1 if file == "${sub_}-${round2}.fam"
				gen a = "erase " + file
				outsheet a if keep == . using tmp.do, non noq replace
				do tmp.do 
				erase tmp.do
				noi di as text"#########################################################################"
				}
			}
		noi di as text""
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - H: move files to output folder"
noi di as text"#########################################################################"
qui { // H
	qui { // H1 - move quality control data to output_folder
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			foreach file in bim bed fam  {
				!cp   "${sub_}-${round2}.`file'"         "${path2file_folder}-qc-${version}/${path2file_file}-qc-${version}.`file'"
				}
			}
		else if os == "Windows" { 
			foreach file in bim bed fam  {
				!copy   "${sub_}-${round2}.`file'"         "${path2file_folder}-qc-${version}/${path2file_file}-qc-${version}.`file'"
				}
			}
		noi di as text""	
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - I: calculate post-quality control metrics "
noi di as text"#########################################################################"
qui { // I
	qui { // I1 - calculate post-qc metrics
		noi di as text"# > genotypeqc .......................................... calculate post-quality control metrics"
		global sub_input ${sub_}-${round2}
		!$plink  --bfile ${sub_input} --freq counts    --out ${sub_input}
		!$plink  --bfile ${sub_input} --maf 0.05 --het --out ${sub_input}
		!$plink  --bfile ${sub_input} --hardy          --out ${sub_input}
		!$plink  --bfile ${sub_input} --missing        --out ${sub_input}
		bim2ld_subset, bim(${sub_input})
		!$plink2 --bfile ${sub_input} --extract bim2ld_subset50000.extract --make-king-table --king-table-filter .0221 --out ${sub_input}
		}
	qui { // I2 - plot metrics
		noi di as text"# > genotypeqc .......................................... plotting post-quality control metrics"
		graphplinkfrq, frq(${sub_input}) 
		graphplinkhet, het(${sub_input}) sd(${hetsd})
		graphplinkhwe, hwe(${sub_input}) threshold(${hwep})
		graphplinkimiss, imiss(${sub_input}) mind(${mind})
		graphplinklmiss, lmiss(${sub_input}) geno(${geno2})	
		graphplinkkin0, kin0(${sub_input}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
		}
	qui { // I3 - move graphs
		foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
			clear
			set obs 1
			gen os = "`c(os)'"
			if os == "Unix" { 
				!cp tmp`graph'.gph ${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}_`graph'.gph
				}
			else if os == "Windows" { 
				!copy tmp`graph'.gph ${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}_`graph'.gph
				}
			}
		}
	qui { // I4 - move relpairs
		insheet using tmpKIN0.relPairs, clear
		for var fid1-rel: tostring X, replace
		renvars, upper
		outsheet using ${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}.relPairs, noq replace
		}	
	noi di as text"#########################################################################"
	noi di as text""	
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - J: define ancesty covariates "
noi di as text"#########################################################################"
qui { // J
	qui { // J1 - define ancestry
		noi di as text"# > genotypeqc .......................................... define ancestry"
		noi bim2hapmap, bim(${sub_input}) like(CEU TSI) hapmap(${bim2hapmap_hapmap}) aims(${bim2hapmap_aims})
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 	
			!cp  "bim2hapmap_${like}-like.keep"     "${path2file_folder}-qc-${version}/${path2file_file}-qc-${version}-${like}-like.keep"
			!cp  "bim2hapmap_pca.gph"               "${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}-pca.gph"
			!cp  "bim2hapmap_pca-${like}-like.gph"  "${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}-${like}-like.gph"
			}
		else if os == "Windows" { 
			!copy  "bim2hapmap_${like}-like.keep"     "${path2file_folder}-qc-${version}/${path2file_file}-qc-${version}-${like}-like.keep"
			!copy  "bim2hapmap_pca.gph"               "${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}-pca.gph"
			!copy  "bim2hapmap_pca-${like}-like.gph"  "${path2file_folder}-qc-${version}/genotypeqc_data/${path2file_file}-qc-${version}-${like}-like.gph"
			}
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - K: create *.genotypeqc-meta.log"
noi di as text"#########################################################################"
qui { // K
	qui { // K1 - write meta-log
		file open myfile using "${path2file_folder}-qc-${version}/${path2file_file}-qc-${version}.genotypeqc-meta.log", write replace
		file write myfile `"#########################################################################"' _n
		file write myfile `"# genotypeqc"' _n
		file write myfile `"#########################################################################"' _n
		file write myfile `"# Started:             $S_DATE $S_TIME "' _n
		file write myfile `"# Username:            `c(username)'"' _n
		file write myfile `"# Operating System:    `c(os)'"' _n
		file write myfile `"#########################################################################"' _n
		file write myfile `"# > genotypeqc ............................. input folder ${path2file_folder}"' _n 
		file write myfile `"# > genotypeqc ........................... input binaries ${path2file_file}"' _n
		file write myfile `"# > genotypeqc .......................... output binaries ${path2file_file}-qc-${version}"' _n
		file write myfile `"#########################################################################"' _n
		file write myfile `"# > genotypeqc .................................. version $version"' _n
		file write myfile `"# > genotypeqc ................ rounds of quality control ${rounds}"' _n
		file write myfile `"# > bim2refid .......... reference genotypes (for naming) ${ref}"' _n
		file write myfile `"# > genotypeqc ........................ --mac (threshold) 5"' _n
		file write myfile `"# > genotypeqc ....................... --geno (threshold) ${geno1};${geno2}"' _n
		file write myfile `"# > genotypeqc ....................... --mind (threshold) ${mind}"' _n
		file write myfile `"# > genotypeqc ...................... --hardy (threshold) 1e-${hwep}"' _n
		file write myfile `"# > genotypeqc ....... std dev heterozygosity (threshold) ${hetsd}"' _n
		file write myfile `"# > genotypeqc .... kinship (dup;1st;2nd;3rd) (threshold) ${kin_d};${kin_f};${kin_s};${kin_t}"' _n
		file write myfile `"#########################################################################"' _n
		file write myfile `"# > bim2array ............................... input array ${bim2array_array}; jaccard = ${bim2array_jaccard}"' _n
		file write myfile `"# > bim2build ............................... input build $input_bim2build"' _n
		bim2count, bim(${home_folder}/${path2file_file}/${path2file_file})
		file write myfile `"# > bim2count .............. markers in the input dataset ${bim2count_snp}"' _n
		file write myfile `"# > bim2count .......... individuals in the input dataset ${bim2count_ind}"' _n
		file write myfile `"#########################################################################"' _n
		file write myfile `"# > bim2build .............................. output build hg19+1"' _n
		bim2count, bim(${sub_input})
		file write myfile `"# > bim2count ............. markers in the output dataset ${bim2count_snp}"' _n
		file write myfile `"# > bim2count ......... individuals in the output dataset ${bim2count_ind}"' _n
		file write myfile `"#########################################################################"' _n
		file write myfile `"# > bim2hapmap ......................... ancestry mapping ${like}"' _n
		file write myfile `"# > bim2hapmap ........... individuals mapped to ancestry ${bim2hapmap_nlike}"' _n
		file write myfile `"#########################################################################"' _n
		file close myfile	
		}
	}
noi di as text"#########################################################################"
noi di as text"# SECTION - L: clean up temp folder"
noi di as text"#########################################################################"
qui { // L
	qui { // L1 - remove and clean
		clear
		set obs 1
		gen os = "`c(os)'"
		if os == "Unix" { 
			cd ${home_folder}
			!rm -r  "${path2file_file}"		
			!rm -r  "${path2file_file}-qc-${version}"		
			}
		else if os == "Windows" { 
			cd ${home_folder}
			!rmdir "${path2file_file}" /s /q
			!rmdir "${path2file_file}-qc-${version}" /s /q
			}
		noi di as text""	
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
