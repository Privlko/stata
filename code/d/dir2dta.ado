/*
#########################################################################
# dir2dta
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       16jan2018
# #########################################################################
*/

qui di as text"#########################################################################"
qui di as text"# dir2dta - version 0.1a 16jan2018 richard anney "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

program dir2dta
syntax , dir(string asis) 
noi di as text"# > dir2dta "as text" ................. saving folders from " as result "`dir'"
noi di as text"# > dir2dta "as text" .................................. to " as result "_dir2dta.dta"
qui {
	clear
	set obs 1								
	gen folder = ""							
	save _dir2dta.dta,replace
	
	local myfiles: dir "`dir'" dirs "*" 	, respectcase				
	foreach folder of local myfiles {
		clear								
		set obs 1							
		gen folder = "`folder'" 					
		append using _dir2dta.dta						
		save _dir2dta.dta	,replace						
		}
	drop if folder == ""	
	save _dir2dta.dta	,replace	
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
