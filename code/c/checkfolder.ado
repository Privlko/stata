/*
#########################################################################
# checkfolder
# a command to check the presence of a folder
#
# command: checkfolder, folder(<location>)
#
#########################################################################

#########################################################################
# Author:    Richard Anney
# Institute: Cardiff University
# E-mail:    AnneyR@cardiff.ac.uk
# Date:      29nov2017
#########################################################################
*/

program checkfolder
syntax , folder(string asis) 
	
qui di as text"#########################################################################"
qui di as text"# checkfolder                                                              "
qui di as text"# version:       0.1                                                     "
qui di as text"# Creation Date: 29nov2017                                               "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME                                               "
qui di as text"#########################################################################"
capture confirm folder "`folder'"
if _rc==0 {
	noi di as text"# > "as input"checkfolder "as text"................................. located" as result" `folder'"
	}
else {
	noi di as text"# > "as input"checkfolder "as text"........................... " as error "cannot locate" as result" `folder'"
	exit
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
