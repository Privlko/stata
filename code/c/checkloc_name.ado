program checkloc_name
syntax 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# checkloc_name               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui {
	capture confirm string var loc_name
	if !_rc {
		noi di as text"# > checkloc_name ....................................... "as result "loc_name present"
		}
	else {
		noi di as text"# > checkloc_name ....................................... "as result "loc_name absent"
		foreach varname in chr bp {
			capture confirm string var `varname'
			if !_rc {
				noi di as text"# > checkloc_name ....................................... "as result "`varname' present"
				}
			else {				
				capture confirm numeric var `varname'
				if !_rc {
					noi di as text"# > checkloc_name ....................................... "as result "`varname' present (numeric - convert to string)"
					tostring `varname', replace
					}
				else {
					noi di as text"# > checkloc_name ....................................... "as result "`varname' absent"
					exit
					}
				}
			}
		capture confirm string var gt
		if !_rc {
			noi di as text"# > checkloc_name ....................................... "as result "gt present"
			gen _gt = gt
			replace _gt = "R" if gt == "Y"
			replace _gt = "M" if gt == "K"
			gen loc_name = "chr" + chr + ":" + bp + "-" + _gt
			drop _gt
			}
		else {				
			capture confirm string var a1
			if !_rc {
				capture confirm string var a2
				if !_rc {
					recodegenotype , a1(a1) a2(a2)
					gen gt = _gt
					replace _gt = "R" if gt == "Y"
					replace _gt = "M" if gt == "K"
					gen loc_name = "chr" + chr + ":" + bp + "-" + _gt
					drop _gt gt					
					}
				else {
					noi di as text"# > checkloc_name ....................................... "as result "a2 absent"
					exit
					}
				}
			else {
				noi di as text"# > checkloc_name ....................................... "as result "a1 absent"
				exit
				}
			}
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
