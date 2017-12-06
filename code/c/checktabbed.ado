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
	gen a = "noi checkfile, file(" + "${tabbed}" + ")"
	replace a = subinstr(a,"perl ","",.)
	outsheet a using _x.do, non noq replace
	do _x.do
	erase _x.do
	replace a = "a b c d"
	outsheet a using test_pl.txt, noq replace
	!$tabbed test_pl.txt
	qui di as text"# > active perl should be downloaded/installed on your computer https://www.activestate.com/activeperl/downloads"
	qui di as text"# > check that test_pl.txt.tabbed has been created"
	noi checkfile, file(test_pl.txt.tabbed)
	noi di as text"# > checkfile ...." as result "located ........."as text" `file'"
	noi di as text"# > checktabbed .." as result "located ........."as text" tabbed.pl"
	noi di as text"# > checktabbed .." as result "working ........."as text" tabbed.pl and perl are working"
	erase test_pl.txt
	erase test_pl.txt.tabbed
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
