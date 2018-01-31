program checkfile
syntax , file(string asis) 
qui {	
	capture confirm file "`file'"
	if _rc==0 {
		noi di as text"# > checkfile ................................... located" as result" `file'"
		}
	else {
		noi di as text"# > checkfile ............................. " as error "cannot locate" as result" `file'"
		exit
		}
	}
end;
	
