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
	
di as text"#########################################################################"
di as text"# checkfile                                                              "
di as text"# version:       0.1                                                     "
di as text"# Creation Date: 29nov2017                                               "
di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di as text"#########################################################################"
di as text"# Started: $S_DATE $S_TIME                                               "
di as text"#########################################################################"
capture confirm file "`file'"
if _rc==0 {
	di as input"# > check for the presence of `file' ........ "as result"located "
	}
else {
	di as input"# > check for the presence of `file' ........ "as error"not found "
	exit
	}
di as text"#########################################################################"
di as text"# Completed: $S_DATE $S_TIME"
di as text"#########################################################################"
end;
	
