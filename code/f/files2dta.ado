/*
*program*
 files2dta

*description* 
 a command to create a file listing all the files within a directory

*syntax*
files2dta , dir(-dir-) 

 -dir-    root directory to list directories from
*/

program files2dta
syntax , dir(string asis) 

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# files2dta"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > files2dta ....................... saving folders from " as result "`dir'"
	noi di as text"# > files2dta ........................................ to " as result "_files2dta.dta"
	}
qui { // 2 - determine files
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
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
