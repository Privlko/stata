*! 1.0.0 Richard Anney 18oct2018
program renamefiles
syntax , dir(string asis) 

noi di as text" "
noi di as text"#########################################################################"
noi di as text"# renamefiles"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"

qui { // move to working directory
	cd `dir'

	}
qui { // identify files in folders
	noi di as text"# > renamefiles ....................... renaming files in " as result "`dir'"
	files2dta, dir(`dir') 
	noi di as text"# > files2dta ....................... saving folders from " as result "`dir'"
	noi di as text"# > files2dta ........................................ to " as result "_files2dta.dta"
	}
qui { // define newname
	gen new_names = strlower(file)
	}
qui { // remove non-alpha numeric characters
		replace new_names = subinstr(new_names, ".", "-",.) 
		replace new_names = subinstr(new_names, "[", "-",.) 
		replace new_names = subinstr(new_names, "]", "-",.) 
		replace new_names = subinstr(new_names, "(", "-",.) 
		replace new_names = subinstr(new_names, ")", "-",.) 
		replace new_names = subinstr(new_names, " ", "-",.) 
		replace new_names = subinstr(new_names, "_", "-",.) 
		replace new_names = subinstr(new_names, "--", "-",.) 
		replace new_names = subinstr(new_names, "--", "-",.) 
		replace new_names = subinstr(new_names, "--", "-",.) 
		replace new_names = subinstr(new_names, "-.", ".",.) 
		}
qui { // replace full-stop for common filetype extensions
		gen file_extension = ""
		split file, p(".")
		gen file99 = ""
		for var file1 - file99: replace file_ext = X if X !=""
		replace new_names = subinstr(new_names, "-" + file_ext, "." + file_ext,.) 
		replace new_names = subinstr(new_names, "-tar.gz", ".tar.gz",.) 
		}
qui { // generate rename file code
		gen a = "rename " + `"""' + file + `"" ""' + new_names + `"""'
		drop if file == "_files2dta.dta"
		drop if file == ""
		outsheet a using tempfile.bat, non noq replace
		}
qui { // rename files
		!tempfile.bat
		erase tempfile.bat
		erase _files2dta.dta
		}
qui { // identify folders in folders
	noi di as text"# > renamefiles ..................... renaming folders in " as result "`dir'"
	dir2dta, dir(`dir') 
	noi di as text"# > dir2dta  ........................ saving folders from " as result "`dir'"
	noi di as text"# > dir2dta  ......................................... to " as result "_dir2dta.dta"
	}
qui { // define newname
	gen new_names = strlower(folder)
	}
qui { // remove non-alpha numeric characters
		replace new_names = subinstr(new_names, ".", "-",.) 
		replace new_names = subinstr(new_names, "[", "-",.) 
		replace new_names = subinstr(new_names, "]", "-",.) 
		replace new_names = subinstr(new_names, "(", "-",.) 
		replace new_names = subinstr(new_names, ")", "-",.) 
		replace new_names = subinstr(new_names, " ", "-",.) 
		replace new_names = subinstr(new_names, "_", "-",.) 
		replace new_names = subinstr(new_names, "--", "-",.) 
		replace new_names = subinstr(new_names, "--", "-",.) 
		replace new_names = subinstr(new_names, "--", "-",.) 
		replace new_names = subinstr(new_names, "-.", ".",.) 
		}
qui { // generate rename folder code
	gen a = "rename " + folder + " " + new_names
		drop if folder == "_dir2dta.dta"
		drop if folder == ""
		outsheet a using tempfile.bat, non noq replace
		}
qui { // rename folders
	!tempfile.bat
	erase tempfile.bat
	erase _dir2dta.dta
	}	
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

