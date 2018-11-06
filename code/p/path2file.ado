*! 1.0.0 Richard Anney 05nov2018
program path2file
syntax, path(string asis) 

qui { // print bioler plate to screen
	noi di as text" "
	noi di as text"#########################################################################"
	noi di as text"# path2file"
	noi di as text"#########################################################################"
	noi di as text"# Started:             $S_DATE $S_TIME"
	noi di as text"#########################################################################"
	}
qui { // soft-code path2file_path
	global path2file_path `path'
	clear
	set obs 1
	}
qui { // soft-code path2file_file
	gen path = "${path2file_path}"
	split path, p(/)
	drop path path1
	sxpose, clear
	gen obs = _n
	gsort -obs
	replace obs = 0 in 1
	gsort obs
	gen a = "global path2file_file " + _v
	outsheet a if obs == 0 using temp-do.do, non noq replace
	do temp-do.do
	erase temp-do.do
	}
qui { // soft-code path2file_folder
	drop if obs == 0
	keep _v
	rename _ x
	sxpose, clear
	gen _var99 = ""
	gen folder = "/"
	for var _var1 - _var99: replace folder = folder + X + "/"
	keep folder
	replace folder = subinstr(folder,"//","/",.)
	replace folder = substr(folder,1,length(folder)-1)
	gen a = "global path2file_folder " + folder
	outsheet a using temp-do.do, non noq replace
	do temp-do.do
	erase temp-do.do
	}
qui { // report to screen
	noi di as text"# > \$path2file_path ................................ path "as result"${path2file_path}"
	noi di as text"# > \$path2file_folder ............................ folder "as result"${path2file_folder}"
	noi di as text"# > \$path2file_file ................................ file "as result"${path2file_file}"
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
