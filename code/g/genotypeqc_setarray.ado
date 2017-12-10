	program genotypeqc_setarray
	syntax, name(string asis)
	!mkdir ${array_ref}\\`name'
	import delim using ${data_folder}\\${data_input}.bim, clear
	keep v1 v2 v4
	for var v1 - v4 : tostring X, replace
	rename (v1 v2 v4) (chr rsid bp)
	save ${array_ref}\\`name'\\`name'.dta, replace
	end;	