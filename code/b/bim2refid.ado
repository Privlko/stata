/*
#########################################################################
# bim2refid
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       16jan2018
# #########################################################################
*/

program bim2refid

syntax , bim(string asis) ref(string asis)
qui di as text"#########################################################################"
qui di as text"# bim2refid - version 0.1 29jan2018 richard anney "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
qui { // module 1 - check input files
	noi di as text"# > bim2refid ............... checking plink is mapped as "as result"${plink}"
	noi checkfile, file(${plink})
	noi di as text"# > bim2refid ......... updating bim snpid to refid (bim) "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	noi di as text"# > bim2refid ......... updating bim snpid to refid (ref) "as result"`ref'"
	noi checkfile, file(`ref')
	}
qui { // module 2 - rename according to refid
	qui { // import bim file
		noi di as text"# > bim2refid ................... pre-process metrics for "as result"`bim'.bim"
		noi bim2count, bim(`bim')
		noi di as text"# > bim2refid .................................... import "as result"`bim'.bim"
		noi bim2dta, bim(`bim')
		erase `bim'_bim.dta
		keep loc_name snp
		rename snp oldname
		}
	qui { // merge over loc_name - remove duplicates
		merge m:1 loc_name using `ref'	
		keep if _m == 3
		keep snp oldname
		rename snp newname
		compress
		duplicates tag newname, gen(tag)
		egen keep = seq(),by(newname tag)
		keep if keep == 1
		}
	qui { // export extract and update-name-file
		outsheet oldname using bim2refid.extract, non noq replace
		outsheet oldname newname using bim2refid.update-name, non noq replace
		}
	}
qui { // module 3 - update binaries
	!$plink --bfile `bim'        --extract bim2refid.extract         --make-bed --out bim2refid-01
	!$plink --bfile bim2refid-01 --update-name bim2refid.update-name --make-bed --out `bim'-refid
	!del bim2refid-01.*
	noi di as text"# > bim2refid .................. post-process metrics for "as result"`bim'-refid.bim"
	noi bim2count, bim(`bim'-refid)
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
