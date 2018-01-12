[back to opening page](https://github.com/ricanney/stata)

## Getting started 
1. load the stata programs from this site (and a few important dependencies). The downloaded ```get_stata_bundle``` program will  download the programs from this site however, you will also be required to run this program to ensure download additional necessary\useful dependencies not from this site, including ```renvars``` and ```sxpose```

```
net install get_stata_bundle,              from(https://raw.github.com/ricanney/stata/master/code/g/) replace
get_stata_bundle
```

2. setting up your ```profile.do``` to include the location of plink etc. It is important to prepare your ```profile.do``` file with some standard commands and the location of commonly used programs. My ```profile.do``` links to ```plink```, ```plink2```, ```tabbed.pl``` and a range of windows executables that I have collected over the years that mimic ```linux``` commands. The ```profile.do``` file can be found in ```C:\Program Files (x86)\Stata13```.

```
* Example profile.do file
noi di as text"#########################################################################"
noi di as text"# Opening Time: $S_DATE $S_TIME                                          "
noi di as text"#########################################################################"
qui di as text"# > set core parameters"
qui { 
	set maxvar 32767, perm
	set more off, perm
	set mem 1G,perm
	set type double,perm
	macro drop _all
	}
qui di as text"# > set graph scheme - requires blindschemes - download using "
qui di as text"# > ssc install blindschemes, replace all"
qui { 
	set scheme plotplainblind , permanently
	}
qui di as text"# > set location of personal directories"
qui { 
	global init_personal "D:\Software\stata\code\dev-ado"
	global init_root     "D:\Software\stata\data" 
	sysdir set PERSONAL  ${init_personal}
	}
qui di as text"# > set location of common dependent files"
qui { 
	global tabbed 	      perl D:\Software\perl\code\tabbed.pl
	global plink	      "D:\Software\plink\bin\win\plink.exe"
	global plink2	      "D:\Software\plink\bin\win\plink2.exe"
	global Rterm_path     "C:\Program Files\R\R-3.3.1\bin\x64\Rterm.exe"
	global Rterm_options  `"--vanilla"'
	global init_unix      "D:\Software\bash\bin"
	}
qui di as text"# > display to screen"
qui {
	cd ${init_root} 	
	noi di as text"# > ROOT .......... working directory is set to ......... "as result"${init_root}"
	noi di as text"# > PERSONAL .......... ado directory is set to ......... "as result"${init_personal}"
	noi di as text"# > CURRENT ....... working directory is set to ......... "as result"${init_root}"
	noi checkfile, file(${plink})
	noi checkfile, file(${plink2})
	noi checktabbed
	noi checkfile, file($Rterm_path)
	noi loadUnixReplicas , folder(${init_unix})
	noi di as text"#########################################################################"
	}
```
