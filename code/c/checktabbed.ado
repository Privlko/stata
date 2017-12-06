/*
#########################################################################
# checktabbed
# a command to check the presence of tabbed.pl and that it is working correctly
#
# command: checktabbed
#
#########################################################################

#########################################################################
# Author:    Richard Anney
# Institute: Cardiff University
# E-mail:    AnneyR@cardiff.ac.uk
# Date:      29nov2017
#########################################################################
*/

program checktabbed
syntax 
	
qui di as text"#########################################################################"
qui di as text"# checktabbed                                                            "
qui di as text"# version:       0.1                                                     "
qui di as text"# Creation Date: 29nov2017                                               "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME                                               "
qui di as text"#########################################################################"
qui {
	clear
	set obs 1
	gen a = "global checktabbed_file ${tabbed}"
	replace a = subinstr(a,"perl ","",.)
	outsheet a using _x.do, non noq replace
	do _x.do
	erase _x.do
	checkfile, file(${checktabbed_file})
	replace a = "a b c d"
	outsheet a using test_pl.txt, noq replace
	!$tabbed test_pl.txt
	qui di as text"# > active perl should be downloaded/installed on your computer https://www.activestate.com/activeperl/downloads"
	qui di as text"# > check that test_pl.txt.tabbed has been created"
	capture confirm file "test_pl.txt.tabbed"
	if _rc==0 {
		noi di as text"# > "as input"checktabbed "as text"................................. " as result"tabbed.pl is set up correctly and working"
		}
	else {
		noi di as text"# > "as input"checktabbed "as text"................................. " as error"tabbed.pl is not set up correctly"
		noi di as error"# > active perl should be downloaded/installed on your computer (https://www.activestate.com/activeperl/downloads)"
		}
	erase test_pl.txt
	erase test_pl.txt.tabbed
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
