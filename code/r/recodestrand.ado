/*
#########################################################################
# recodestrand
# a command to plot distribution from *frq plink file
#
# command: recodestrand, ref_a1(string asis) ref_a2(string asis) alt_a1(string asis) alt_a2(string asis) 
# options: 
#
# dependencies: 
#
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 10th September 2015
#########################################################################
*/

program recodestrand
syntax , ref_a1(string asis) ref_a2(string asis) alt_a1(string asis) alt_a2(string asis) 

di in white"#########################################################################"
di in white"recodestrand - version 0.1a - 05May2017 richard anney "
di in white"#########################################################################"
di in white"# allele 1 for the reference strand is     `ref_a1'"
di in white"# allele 2 for the reference strand is     `ref_a2'"
di in white"# allele 1 for the data to be converted is `alt_a1'"
di in white"# allele 2 for the data to be converted is `alt_a2'"
di in white"#########################################################################"
di in white"# - this script flags all indel, ambiguous, missing, monomorphic markers"
di in white"#   in the variable _tmpflag (1 = error)"
di in white"# - this script creates new allele codes for the data (_tmpb1 and _tmpb2)"
di in white"# - this script creates flip code for all markers that were flipped (_tmpflip)"
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > generating genotype variable for reference alleles"
qui {
	recodegenotype, a1(`ref_a1') a2(`ref_a2')
	rename _gt temp_ref_gt
	}
di in white"# > generating genotype variable for test alleles"
qui {	
	recodegenotype, a1(`alt_a1') a2(`alt_a2')
	rename _gt temp_alt_gt
	}
di in white"# > checking for incompatible genotypes"
qui {
	noi di in white"# >> tabulating genotypes"
	noi ta temp_ref_gt temp_alt_gt
	noi di in white"# >> dropping non- R Y M K genotypes"
	foreach xx in A C G T ID DI W S {
		drop if temp_ref_gt == "`xx'"
		drop if temp_alt_gt == "`xx'"
		}
	noi di in white"# >> tabulating R Y M K genotypes (clean #1)"
	noi ta temp_ref_gt temp_alt_gt
	noi di in white"# >> dropping non-compatible genotypes (K!=M and R!=Y)"
	drop if temp_ref_gt == "K" & ( temp_alt_gt == "R" |  temp_alt_gt == "Y")
	drop if temp_ref_gt == "M" & ( temp_alt_gt == "R" |  temp_alt_gt == "Y")
	drop if temp_ref_gt == "R" & ( temp_alt_gt == "M" |  temp_alt_gt == "K")
	drop if temp_ref_gt == "Y" & ( temp_alt_gt == "M" |  temp_alt_gt == "K")
	noi di in white"# >> tabulating genotypes (clean #2)"
	noi ta temp_ref_gt temp_alt_gt
	}
di in white"# > checking for strand flips"
qui {
	gen _tmpflip = 0
	replace _tmpflip = 1 if temp_ref_gt != temp_alt_gt
	}
di in white"# >> creating new variable for genotypes needing to be flipped"
qui {
	gen _tmpb1 = `alt_a1'
	gen _tmpb2 = `alt_a2'
	replace _tmpb1 = "A" if `alt_a1' == "T" & _tmpflip == 1
	replace _tmpb1 = "C" if `alt_a1' == "G" & _tmpflip == 1
	replace _tmpb1 = "G" if `alt_a1' == "C" & _tmpflip == 1
	replace _tmpb1 = "T" if `alt_a1' == "A" & _tmpflip == 1
	replace _tmpb2 = "A" if `alt_a2' == "T" & _tmpflip == 1
	replace _tmpb2 = "C" if `alt_a2' == "G" & _tmpflip == 1
	replace _tmpb2 = "G" if `alt_a2' == "C" & _tmpflip == 1
	replace _tmpb2 = "T" if `alt_a2' == "A" & _tmpflip == 1
	}
di in white"# >> creating alternative genotype from new alleles"
qui {
	recodegenotype, a1(_tmpb1) a2(_tmpb2)
	}
di in white"# > tabulating genotypes (clean #3)"
qui {
	noi ta temp_ref_gt _gt
	drop _gt temp_ref_gt temp_alt_gt
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;

