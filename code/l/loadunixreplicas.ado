qui di as text"#########################################################################"
qui di as text"# loadunixreplicas - version 0.1a 02oct2015 richard anney "
qui di as text"#########################################################################"
qui di as text"# Creates global link to unix executables "
qui di as text"# as an alternative to unix executable use "as result`"!bash -c "<unix code>""'
qui di as text"#########################################################################"
qui di as text"# Started: $S_DATE $S_TIME"
qui di as text"#########################################################################"
qui di as text"# > scan `folder' for *.exe "

program loadunixreplicas
syntax , folder(string asis) 

qui {
	clear
	set obs 1
	gen unixreplicas = ""
	save _tmpunixreplicas.dta,replace
	local myfiles: dir "`folder'" files "*.exe" 
	foreach file of local myfiles { 
		clear
		set obs 1
		gen unixreplicas = "`file'" 
		append using _tmpunixreplicas.dta
		save _tmpunixreplicas.dta,replace
		} 
	}
qui di as text"# > creating globals for individual *.exe "
qui {
	use  _tmpunixreplicas.dta,replace
	drop if unixreplicas == ""
	split unixreplicas,p(".exe")
	gen a1 = "global "
	gen a2 = " `folder'\"
	egen a = concat(a1 unixreplicas1 a2 unixreplicas)
	outsheet a using _tmpunixreplicas.do, non noq replace
	do _tmpunixreplicas.do
	erase _tmpunixreplicas.dta
	erase _tmpunixreplicas.do
	keep unixreplicas1
	sort unixreplicas1
	egen x = seq(),block(8)
	egen y = seq(),by(x)
	rename un a
	reshape wide a , i(x) j(y)
	egen a = concat(a1 - a8), p(" ")
	noi di as text"# > loadUnixReplicas ............................. loaded " as result a[1]
	count
	global num `r(N)'
	foreach num of num 2 / $num {
		noi di as text"# > ..................................................... " as result a[`num']
		}
	clear
	}
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
qui di as text" "
end;
