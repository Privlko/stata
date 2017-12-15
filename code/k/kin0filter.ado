/*
#########################################################################
# kin0filter
# a command that uses *.kin0 files and identifies one of each pair to filter.
# priority exclusion is given to individuals showing relatedness to the 
# most individuals
#
# command: kin0filter, kin0(string asis) filter(string asis)
#
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program kin0filter
syntax , kin0(string asis) filter(string asis) 

qui di as text"#########################################################################"
qui di as text"# kin0filter - version 0.1a 05dec2017 richard anney "
qui di as text"#########################################################################"
qui di as text"# a command that uses *.kin0 files and identifies one of each pair to filter."
qui di as text"# priority exclusion is given to individuals showing relatedness to the "
qui di as text"# most individuals"
qui di as text"#########################################################################"
qui di as text"# kin_started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

noi di as text"# > "as input"kin0filter"as text"........................................... "as result"`kin0'.kin0"
noi di as text"# > "as input"kin0filter"as text" saving individuals to exclude to ......... "as result"`kin0'_filter_`filter'.remove"
noi checkfile, file(`kin0'.kin0)

qui di as text"# > process/import "as result "`kin0'.kin0"
qui {
	import delim using `kin0'.kin0, clear case(lower)
	}
qui di as text"# > process variables"
qui {
	keep fid1-kinship
	for var fid1-id2      : tostring X, replace 
	for var hethet-kinship: destring X, replace force
	}
qui di as text"# > count observations > threshold"
qui {
	drop if fid1 == fid2
	count  
	noi di as text"# > "as input"kin0filter"as text" pairs with kinship > threshold ........... "as result `r(N)'
	if `r(N)' > 0 {
		keep fid1 id1 fid2 id2
		gen pair = _n
		reshape long fid id , i(pair) j(x)
		egen obs_by_id = seq(),by(fid id)
		sum obs_by_id
		gen random = uniform()
		gsort -obs_by_id random
		sum obs_by_id
		if `r(max)' == 1 {
			noi di as text"# >> all individuals in pairs are observed only once"
			count
			noi di as text"# > "as input"kin0filter"as text" saving individuals to exclude to ......... "as result"`kin0'_filter_`filter'.remove"
			noi di as text"# > "as input"kin0filter"as text" individuals saved ........................ "as result `r(N)'
			outsheet fid id using `kin0'_filter_`filter'.remove, non noq replace
			}
		else {
			keep in 1
			noi di as text"# some individuals are in more than 1 pair"
			count
			noi di as text"# > "as input"kin0filter"as text" saving individuals to exclude to ......... "as result"`kin0'_filter_`filter'.remove"
			noi di as text"# > "as input"kin0filter"as text" individuals saved ........................ "as result `r(N)'
			outsheet fid id using `kin0'_filter_`filter'.remove, non noq replace
			}
		}
	else {
		noi di as text"# no (unrelated) pairs observed"
		noi di as text"# > "as input"kin0filter"as text" individuals saved ........................ "as result `r(N)'
		}
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
