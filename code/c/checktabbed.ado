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
	
di as text"#########################################################################"
di as text"# checktabbed                                                              "
di as text"# version:       0.1                                                     "
di as text"# Creation Date: 29nov2017                                               "
di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di as text"#########################################################################"
di as text"# Started: $S_DATE $S_TIME                                               "
di as text"#########################################################################"
clear
set obs 3
gen a = "checkfile, file(" + "${tabbed}" + ")"
replace a = `"di as text"# > check for the presence of " as input "${tabbed} ""' in 1
replace a = `"di as text"# > check that " as input " ${tabbed} " as text "is working""' in 3
replace a = subinstr(a,"perl ","",.)
outsheet a using _x.do, non noq replace
do _x.do
erase _x.do
replace a = "a b c d"
outsheet a using test_pl.txt, noq replace
!$tabbed test_pl.txt
di as text"# > active perl should be downloaded/installed on your computer " as input"https://www.activestate.com/activeperl/downloads"
di as text"# > check that test_pl.txt.tabbed has been created"
checkfile, file(test_pl.txt.tabbed)
erase test_pl.txt
erase test_pl.txt.tabbed
di as text"#########################################################################"
di as text"# Completed: $S_DATE $S_TIME"
di as text"#########################################################################"
end;
	