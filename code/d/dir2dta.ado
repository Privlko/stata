/*
*program*
 dir2dta

*description* 
 a command to create a file listing all the directories within a directory

*syntax*
dir2dta , dir(-dir-) 

 -dir-    root directory to list directories from
*/

program dir2dta
syntax , dir(string asis) 

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# dir2dta"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > dir2dta "as text" ................. saving folders from " as result "`dir'"
	noi di as text"# > dir2dta "as text" .................................. to " as result "_dir2dta.dta"
	}
qui { // 2- define folders
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
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
