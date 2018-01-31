program checktabbed
syntax 

qui {
	clear
	set obs 1
	gen a = "global checktabbed_file ${tabbed}"
	replace a = subinstr(a,"perl ","",.)
	outsheet a using _x.do, non noq replace
	do _x.do
	erase _x.do
	noi checkfile, file(${checktabbed_file})
	replace a = "a b c d"
	outsheet a using test_pl.txt, noq replace
	!$tabbed test_pl.txt
	qui di as text"# > active perl should be downloaded/installed on your computer https://www.activestate.com/activeperl/downloads"
	qui di as text"# > check that test_pl.txt.tabbed has been created"
	capture confirm file "test_pl.txt.tabbed"
	if _rc==0 {
		noi di as text"# > checktabbed ......................................... " as result"tabbed.pl is set up correctly and working"
		}
	else {
		noi di as text"# > checktabbed ......................................... " as error"tabbed.pl is not set up correctly"
		noi di as error"# > active perl should be downloaded/installed on your computer (https://www.activestate.com/activeperl/downloads)"
		}
	erase test_pl.txt
	erase test_pl.txt.tabbed
	clear
	}

end;
	
