/*
#########################################################################
# bim2ld_subset
# a command to use *.bim files (plink-format marker files) to generate a 
# subset of ld independent snps (_subset#.extract)
#
# command: bim2ld_subset, bim(<FILENAME>) n(number of snps to keep)
# notes: the filename does not require the .bim to be added
# dependencies: bim2ldexclude
#               plink
#
# the default n = 50000
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program bim2ld_subset
syntax , bim(string asis) [n(real 50000)]

qui di as text"#########################################################################"
qui di as text"# bim2ld_subset - version 0.1a 05dec2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command to use *.bim files (plink-format marker files) to generate a  "
qui di as text"# subset of ld independent snps (_subset#.extract)                                                        " 
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
noi checkfile, file(`bim'.bim)
noi checkfile, file(${plink})

qui di as text"# > define ldexcluded snp list"
qui {
	noi bim2ldexclude, bim(`bim')
	}
qui di as text"# > parse genotype - removing ld-exclude"
qui {
	!$plink  --bfile `bim' --maf 0.05 --exclude long-range-ld.exclude --make-bed --out _x_
	}
qui di as text"# > ld-prune genotypes"
qui {
	!$plink  --bfile _x_ --indep-pairwise 1000 5 0.2 --out _x_
	}
qui di as text"# > importing prune.in and selecting "as result `n' as text" snps"	
qui { 
	import delim using _x_.prune.in, clear
	gen x = uniform()
	sort x
	drop if _n > `n'
	outsheet v1 using _subset`n'.extract, non noq replace
	noi di as text"# > "as input"bim2ld_subset"as text" - exporting "as result `n' as text" randomly selected ld-independent snps to"as result" _subset`n'.extract"
	}
qui di as text"# > clean"
qui {
	!del _x_.* _y_.* long-range-ld.exclude
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
