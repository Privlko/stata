/*
#########################################################################
# create_temp_dir
# to create a random named temporary directory in the current directory
#
# command: create_temp_dir
# dependencies: ralpha
# https://ideas.repec.org/c/boc/bocode/s457277.html
#
#########################################################################

#########################################################################
# Author:    Richard Anney
# Institute: Cardiff University
# E-mail:    AnneyR@cardiff.ac.uk
# Date:      29nov2017
#########################################################################
*/

program create_temp_dir
syntax 

di as text"#########################################################################"
di as text"# create_temp_dir                                                       "
di as text"# version:       0.1                                                     "
di as text"# Creation Date: 29nov2017                                               "
di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di as text"#########################################################################"
di as text"# Started: $S_DATE $S_TIME                                               "
di as text"#########################################################################"
di as text"# > creating a temporary folder within current directory"
di as input "# >> current directory is : " as result `"`c(pwd)'""'
clear
set obs 1
ralpha folderRandom, range(A/z) l(10)
replace folderRandom  = "`c(pwd)'" + "\" + folderRandom
gen a = "global temp_dir  " + folderRandom
outsheet a using _x.do, non noq replace
do _x.do
erase _x.do
di as text"# >> creating random folder"
!mkdir ${temp_dir}
qui cd ${temp_dir}
di as input"# >> new temporary directory is : `c(pwd)'"
di as input"# >> folder name stored as \${temp_dir}"
di as text"#########################################################################"
di as text"# Completed: $S_DATE $S_TIME"
di as text"#########################################################################"
end;
	