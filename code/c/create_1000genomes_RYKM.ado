/*
#########################################################################
# create_1000genomes
# command: create_1000genomes
#########################################################################

#########################################################################
# Author:    Richard Anney
# Institute: Cardiff University
# E-mail:    AnneyR@cardiff.ac.uk
# Date:      19jan2018
#########################################################################
*/

program create_1000genomes
syntax 
qui { // checkfile
	foreach chromosome in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22  {
		noi checkfile, file(ALL.chr`chromosome'.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz)
		}
	noi checkfile, file(ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz)
	noi checkfile, file(ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz)
	noi checkfile, file(integrated_call_samples_v3.20130502.ALL.panel)
	}
qui { // convert vcf to plink (mac5)
	foreach chromosome in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 {
		!$plink --vcf ALL.chr`chromosome'.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz --mac 5 --make-bed --out tmp-chr`chromosome'
		}
	!$plink --vcf ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz                   --mac 5 --make-bed --out tmp-chrMT
	!$plink --vcf ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz --mac 5 --make-bed --out tmp-chrX
	}
qui { // update marker name to single rs# / esv# / ss# or dummy - remove duplicates
	foreach chromosome in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X MT {
		import delim using tmp-chr`chromosome'.bim, clear varnames(nonames)
		qui { // create loc_name
			for var v1 v2 v4: tostring X, replace
			gen a1 = v5 
			gen a2 = v6
			recodegenotype, a1(a1) a2(a2)
			replace _gt = "R"  if _gt == "Y"
			replace _gt = "M"  if _gt == "K" 
			gen loc_name = "chr" + v1 + ":" + v4 + "-" + _gt 
			}
		qui { // replace v2 = single rs#
			split v2,p(";")
			replace v2 = ""
			compress
			gen rs1 = ""
			foreach i in 21 22 23 24 25 26 27 28 29 {
				capture confirm variable v`i'
				if !_rc {
					replace rs1 = substr(v`i',1,2)
					replace v2 = v`i' if rs1 == "rs" & v2 == ""
					}
				}
			}
		qui { // replace v2 = single esv#
			gen esv1 = ""
			foreach i in 21 22 23 24 25 26 27 28 29 {
				capture confirm variable v`i'
				if !_rc {
					replace esv1 = substr(v`i',1,3)
					replace v2 = v`i' if esv1 == "esv" & v2 == ""
					}
				}
			}
		qui { // replace v2 = single ss#
			gen ss1 = ""
			foreach i in 21 22 23 24 25 26 27 28 29 {
				capture confirm variable v`i'
				if !_rc {
					replace ss1 = substr(v`i',1,2)
					replace v2 = v`i' if ss1 == "ss" & v2 == ""
					}
				}
			}
		qui { // replace v2 = loc_name if v2 == ""
				replace v2 = loc_name if v2 == ""
			}
		qui { // identify snps to drop
			gen drop = .
			qui { // tag duplicates to drop
				egen     dup = seq(), by(loc_name)
				replace  dup = dup - 1
				tostring dup, replace 
				replace  dup = "_dup" + dup
				replace  dup = ""     if dup == "_dup0"
				replace  v2 = v2 + dup
				replace drop = 1 if dup != ""
				}
		qui { // drop ambiguous markers
			foreach gt in A C G T W S ID {
				replace drop = 1 if _gt == "`gt'"
				}
			}
		qui { // drop snps with known duplicate locations
			foreach snp in rs111307503 rs111577982 rs5988705 rs113189289 rs75766429 rs56110824 rs111664647 rs11952502 rs12334732 rs113937023 rs79245793 rs112702727 rs76545203 rs75240632 rs113853039 {
				replace drop = 1  if v2 =="`snp'"
				}
			}
		qui { // drop snps with multiple locations
			duplicates tag v2 drop, gen(dup2)
			replace drop = 1 if dup2 != 0 & drop == .
			}
		}
		qui { // export processed files
			outsheet v1 v2 v3 v4 v5 v6 using  tmp-chr`chromosome'_update.bim, non noq replace
			keep if drop == 1
			keep v2
			duplicates drop
			outsheet v2                using  tmp-chr`chromosome'.exclude, non noq replace
			}
		!$plink --bed tmp-chr`chromosome'.bed --bim tmp-chr`chromosome'_update.bim --fam tmp-chr`chromosome'.fam --exclude tmp-chr`chromosome'.exclude --make-bed --out tmp-chr`chromosome'-processed
		}	
	}
qui { // merge binaries
	clear
	set obs 24
	gen a = _n
	tostring a, replace
	replace a = "X"  if a == "23"
	replace a = "MT" if a == "24"
	gen b = "tmp-chr" + a + "-processed.bed tmp-chr" + a + "-processed.bim tmp-chr" + a + "-processed.fam"
	drop in 1
	outsheet b using all.merge-list, non noq replace
	!$plink --bfile tmp-chr1-processed --merge-list all.merge-list --make-bed --out all-1000g-phase3-chrall-RYMKonly-mac5
	} 
qui { // split by super-populations
	import delim using integrated_call_samples_v3.20130502.ALL.panel, clear varnames(1)
	gen fid = sample
	gen iid = sample
	dropmiss, force
	for var super pop: replace X = strlower(X)
	save all-1000g-populations.dta, replace
	foreach population in afr amr eas eur sas {
		use all-1000g-populations.dta, clear
		outsheet fid iid if sup == "`population'" using `population'.keep, non noq replace
		!$plink --bfile all-1000g-phase3-chrall-RYMKonly-mac5 --keep `population'.keep --mac 5 --make-bed --out `population'-1000g-phase3-chrall-RYMKonly-mac5
		bim2count, bim(`population'-1000g-phase3-chrall-RYMKonly-mac5)
		}
	}
qui { // create reference datasets (european)
	noi bim2frq, bim(eur-1000g-phase3-chrall-RYMKonly-mac5)
	noi bim2dta, bim(eur-1000g-phase3-chrall-RYMKonly-mac5)
	}
qui { // clean-up
	foreach chromosome in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22  {
		erase ALL.chr`chromosome'.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
		}
	erase ALL.chrMT.phase3_callmom-v0_4.20130502.genotypes.vcf.gz
	erase ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz
	erase integrated_call_samples_v3.20130502.ALL.panel
	foreach chromosome in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X MT {
		!del tmp-chr`chromosome'*	
		}
	!del all.merge* *.exclude *.nosex *.keep 
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
