/*
*program*
 datestamp

*description* 
 command to create a single data code $DATE

*syntax*
 datestamp

*/

program datestamp
syntax 

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# datestamp"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	clear
	set obs 1
	gen a = "global DATE "
	gen b = "$S_DATE"
	replace b = subinstr(b, " ", "",.)
    replace b = strlower(b)	
	outsheet using datestamp.do, replace non noq
	do  datestamp.do
	erase  datestamp.do
	noi di as text"# > datestamp "as text" ...................... reporting \$DATE as" as result" $DATE"
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
