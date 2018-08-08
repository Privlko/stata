program path2file
syntax, path(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# path2file"
noi di as text"#########################################################################"
noi di as text"# Started:             $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // define file, folder, path
	clear
	set obs 1
	gen os = "`c(os)'"
	if os == "Unix" { 
		noi di as text"# Operating System is Unix"
		noi di as text"# > path2file ....................... operating system is "as result "Unix"
		global delimit "/"
		qui { // define path
			global path2file_path `path'
			}
		qui { // define file
			gen path = "${path2file_path}"
			split path, p(${delimit})
			drop os path path1
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
		qui { // define folder
			drop if obs == 0
			keep _v
			rename _ x
			sxpose, clear
			gen _var99 = ""
			gen folder = "${delimit}"
			for var _var1 - _var99: replace folder = folder + X + "${delimit}"
			keep folder
			replace folder = subinstr(folder,"${delimit}${delimit}","${delimit}",.)
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
		}
	else if os == "Windows" { 
		noi di as text"# > path2file ....................... operating system is "as result "Windows"
		global delimit "\"
		qui { // define path
			global path2file_path `path'
			}
		qui { // define file
			gen path = "${path2file_path}"
			split path, p(${delimit})
			drop os path path1
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
		qui { // define folder
			drop if obs == 0
			keep _v
			rename _ x
			sxpose, clear
			gen _var99 = ""
			gen folder = "${delimit}"
			for var _var1 - _var99: replace folder = folder + X + "${delimit}"
			keep folder
			replace folder = subinstr(folder,"${delimit}${delimit}","${delimit}",.)
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
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
