/*
#########################################################################
# bim2eigenvec
# a command to generate ancestry informative eigenvectors from plink-format 
# files) 
#
# command: bim2eigenvec, bim(<FILENAME>)
# options: 
# 			pc(num) .....number of pcs to calculate - default = 10
# notes: the filename does not require the .bim to be added
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
#########################################################################
*/

program bim2eigenvec
syntax , bim(string asis) [pc(real 10)]

qui di as text"#########################################################################"
qui di as text"# bim2eigenvec               "
qui di as text"# version:  1a              "
qui di as text"# Creation Date: 25may2017            "
qui di as text"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
qui di as text"#########################################################################"
qui di as text"# This is a script to derive from a bim file (and matching bed fam) the "
qui di as text"# ancestry informative eigenvectors. "
qui di as text"# The script removes long-range LD regions as described in; "
qui di as text"# Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes "
qui di as text"# Price, Mike Weale et al., The American Journal of Human Genetics 83, "
qui di as text"# 127 - 147, July 2008              "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : plink_v1.9 via ${plink}         "
qui di as text"# Dependencies : plink_v2   via ${plink2}         "
qui di as text"# Dependencies : tabbed.pl  via ${tabbed}         "
qui di as text"# Dependencies : bim2ldexclude       "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > "as input"bim2eigenvec "as text"........................................ "as result"`bim'.bim"
noi checkfile, file(`bim'.bim)
noi checkfile, file(`bim'.bed)
noi checkfile, file(`bim'.fam)
noi checkfile, file(${plink})
noi checkfile, file(${plink2})
noi checktabbed

qui di as text"# > run bim2ldexclude                           "
qui { 
	noi bim2ldexclude, bim(`bim') 
	}
qui di as text"# > excluding long-distance-ld-ranges using ${plink}"
qui { 	
	!$plink --bfile `bim' --exclude long-range-ld.exclude --indep-pairwise 1000 5 0.2  --out _00000001
	}
qui di as text"# > ld-pruning using ${plink}#"
qui {
	!$plink --bfile `bim' --extract _00000001.prune.in --make-bed                      --out _00000002
	}
qui di as text"# > defining principle component using ${plink2}"
qui {
	!$plink2 --bfile _00000002 --pca `pc' --out _00000003
	}
qui di as text"# > processing eigenvec file to `bim'_eigenvec.dta"
qui {
	!$tabbed _00000003.eigenvec
	import delim using _00000003.eigenvec.tabbed, clear
	keep fid iid pc1 - pc`pc'
	save `bim'_eigenvec.dta,replace
	}
qui di as text"# > processing eigenval file to `bim'_eigenval.dta"
qui {	
	!$tabbed _00000003.eigenval
	import delim using _00000003.eigenval.tabbed, clear
	gen pc = _n
	ren v1 eigenval
	save `bim'_eigenval.dta,replace
	}
qui di as text"# > cleaning temp files"
qui {
	!del *_0000000* long-range-ld.exclude
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;


	
