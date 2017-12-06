/*
#########################################################################
# checkfile
# a command to check the presence of a file
#
# command: checkfile, file(<location>)
#
#########################################################################

#########################################################################
# Author:    Richard Anney
# Institute: Cardiff University
# E-mail:    AnneyR@cardiff.ac.uk
# Date:      29nov2017
#########################################################################
*/

program checkfile
syntax , file(string asis) 
	
qui di as text"#########################################################################"
qui di as text"# checkfile                                                              "
qui di as text"# version:       0.1                                                     "
qui di as text"# Creation Date: 29nov2017                                               "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME                                               "
qui di as text"#########################################################################"
capture confirm file "`file'"
if _rc==0 {
	noi di as text"# > checkfile .................................... " as result"located"as result" `file'"
	}
else {
	noi di as text"# > checkfile .............................. " as result"cannot locate"as result" `file'"
	exit
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
