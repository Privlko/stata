/*
#########################################################################
# bim2frq
# a command to create _frq.dta (plink-format marker files) from plink binaries 
#
# command: bim2frq, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# dependencies: tabbed.pl
#               plink
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       21st November 2017
# #########################################################################
*/

program bim2frq
syntax , bim(string asis)

di in white"#########################################################################"
di in white"# bim2frq - version 0.1a 21Nov2017 richard anney "
di in white"#########################################################################"
di in white"# a command to create _frq.dta (plink-format marker files) from plink binaries"
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > check path of plink *.bim file is true"
qui { 
	capture confirm file "`bim'.bim"
	if _rc==0 {
		noi di in green"# >> `bim'.bim found and will be imported"
		}
	else {
		noi di in red"# >> `bim'.bim not found "
		noi di in red"# >> help: do not include .bim in filename  "
		noi di in red"# >> exiting "
		exit
		}
	}
di in white"# > check path of dependencies"
qui { // plink v1.9
	capture confirm file "$plink"
	if _rc==0 {
		noi di in green"# plink v1.9+ exists and is correctly assigned as  $plink"
		}
	else {
		noi di in red"# plink v1.9 does not exists; download executable from https://www.cog-genomics.org/plink2 "
		noi di in red"# set plink v1.9 location using;  "
		noi di in red`"# global plink "folder\file"  "'
		exit
		}
	}
qui { // tabbed
	clear
	set obs 1
	gen a = "$tabbed"
	replace a = subinstr(a,"perl ","capture confirm file ",.)
	outsheet a using _ooo.do, non noq replace
	do _ooo.do
	if _rc==0 {
	noi di in green"# the tabbed.pl script exists and is correctly assigned as  $tabbed"
		noi di in green"# ..... ensuring perl is working on your system and can be called from the command-line"
		clear 
		set obs 10
		gen a = "a b c d"
		outsheet a using test_pl.txt, noq replace
		!$tabbed test_pl.txt
		capture confirm file "test_pl.txt.tabbed"
		if _rc==0 {
			noi di in green"# ..... the tabbed.pl script is working"
			}
		else {
			noi di in red"# ..... the tabbed.pl script did not work"
			noi di in red"# download and install active perl on your computer https://www.activestate.com/activeperl/downloads"
			exit
			}
		!del test_pl.*
		}
	else {
		noi di in red"# tabbed.pl does not exists; download executable from https://github.com/ricanney/perl "
		noi di in red"# set tabbed.pl location using;  "
		noi di in red`"# global tabbed "folder\file"  "'
		exit
		}
	erase _ooo.do
	}
di in white"# > running plink --freq"
qui { 
	!${plink} --bfile `bim' --freq --out tmp-bim2frq
	}
di in white"# > processing file"
qui { 
	!${tabbed} tmp-bim2frq.frq
	}
di in white"# > importing file"
qui { 
	import delim using tmp-bim2frq.frq.tabbed, clear
	}
di in white"# > naming variables"
qui { 
	keep snp a1 maf
	rename (snp maf) (rsid a1_frq)
	}
di in white"# > saving file as `bim'_frq.dta"
qui {
	save `bim'_frq.dta, replace
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;	
