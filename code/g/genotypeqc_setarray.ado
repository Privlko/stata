	program genotypeqc_setarray
	
	syntax, name(string asis) array_ref(string asis), bim(string asis)
	
	!rmdir `array_ref'\\`name' /S /Q
	!mkdir `array_ref'\\`name'
	noi checkfile, file(`bim'.bim)
	
	import delim using `bim'.bim, clear
	keep v1 v2 v4
	for var v1 - v4 : tostring X, replace
	rename (v1 v2 v4) (chr rsid bp)
	save `array_ref'\\`name'\\`name'.dta, replace
	
	end;	
	