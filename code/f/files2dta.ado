/*
#########################################################################
# files2dta
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       16jan2018
# #########################################################################
*/

qui di as text"#########################################################################"
qui di as text"# files2dta - version 0.1a 16jan2018 richard anney "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"

program files2dta
syntax , dir(string asis) 
noi di as text"# > files2dta "as text" ........................ saving files from" as result" `dir'"
noi di as text"# > files2dta "as text" ....................................... to" as result" _files2dta.dta"
qui {
	clear
	set obs 1								
	gen file = ""							
	save _files2dta.dta,replace
	
	local myfiles: dir "`dir'" files "*" 	, respectcase				
	foreach file of local myfiles {
		clear								
		set obs 1							
		gen file = "`file'" 					
		append using _files2dta.dta						
		save _files2dta.dta	,replace						
		}
	drop if file == ""	
	save _files2dta.dta	,replace	
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;	
