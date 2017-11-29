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

qui di as text"#########################################################################"
qui di as text"# create_temp_dir                                                       "
qui di as text"# version:       0.1                                                     "
qui di as text"# Creation Date: 29nov2017                                               "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME                                               "
qui di as text"#########################################################################"
qui di as text"# > creating a temporary folder within current directory"
qui di as text"# >> current directory is : " as result `"`c(pwd)'""'
clear
set obs 1
ralpha folderRandom, range(A/z) l(10)
replace folderRandom  = "`c(pwd)'" + "\" + folderRandom
gen a = "global temp_dir  " + folderRandom
outsheet a using _x.do, non noq replace
do _x.do
erase _x.do
qui di as text"# >> creating random folder"
!mkdir ${temp_dir}
qui cd ${temp_dir}
di as text"# >> new temporary directory is : " as result `"`c(pwd)'"'
qui di as text"# >> folder name stored as \${temp_dir}"
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	