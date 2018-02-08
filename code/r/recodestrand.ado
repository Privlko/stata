/*
*program*
 recodestrand

*description* 
 a command to define the markers to flip when compared to reference genotypes

*syntax*
syntax , ref_a1(-allele1_reference-) ref_a2(-allele2_reference-) alt_a1(-allele1_test-) alt_a2(-allele2_test-) 
 
 -ref_a1-   the varname containing allele 1 of the reference genotypes
 -ref_a2-   the varname containing allele 2 of the reference genotypes
 -alt_a1-   the varname containing allele 1 of the test genotypes
 -alt_a2-   the varname containing allele 2 of the test genotypes
*/
program recodestrand
syntax , ref_a1(string asis) ref_a2(string asis) alt_a1(string asis) alt_a2(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# recodestrand"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > recodestrand ........................................ "as result"checking that alleles are defined correctly"
	capture confirm var `ref_a1'
	if _rc==0 {
		noi di as text"# > recodestrand ......... allele 1 (reference genotypes) "as result"present"
		}
	else {
		noi di as text"# > recodestrand ......... allele 1 (reference genotypes) "as error "absent"
		exit
		}
	capture confirm var `ref_a2'
	if _rc==0 {
		noi di as text"# > recodestrand ......... allele 2 (reference genotypes) "as result"present"
		}
	else {
		noi di as text"# > recodestrand ......... allele 2 (reference genotypes) "as error "absent"
		exit
		}
	capture confirm var `alt_a1'
	if _rc==0 {
		noi di as text"# > recodestrand .............. allele 1 (test genotypes) "as result"present"
		}
	else {
		noi di as text"# > recodestrand .............. allele 1 (test genotypes) "as error "absent"
		exit
		}
	capture confirm var `alt_a2'
	if _rc==0 {
		noi di as text"# > recodestrand .............. allele 2 (test genotypes) "as result"present"
		}
	else {
		noi di as text"# > recodestrand .............. allele 2 (test genotypes) "as error "absent"
		exit
		}
	}
qui { // 2 - define genotypes
	recodegenotype, a1(`ref_a1') a2(`ref_a2')
	rename _gt recodestrand_ref_gt
	recodegenotype, a1(`alt_a1') a2(`alt_a2')
	rename _gt recodestrand_alt_gt
	}
qui { // 3 - dropping incompatible genotypes
	ta recodestrand_ref_gt recodestrand_alt_gt,m
	qui { // dropping non- R Y M K genotypes
		foreach xx in A C G T W S {
			gen drop = .
			replace drop = 1 if recodestrand_ref_gt == "`xx'"
			replace drop = 1 if recodestrand_alt_gt == "`xx'"
			count if drop == 1
			noi di as text"# > recodestrand ................... dropping markers (`xx') "as result "`r(N)'"
			drop if drop == 1
			drop drop
			}
		foreach xx in ID DI {
			gen drop = .
			replace drop = 1 if recodestrand_ref_gt == "`xx'"
			replace drop = 1 if recodestrand_alt_gt == "`xx'"
			count if drop == 1
			noi di as text"# > recodestrand .................. dropping markers (`xx') "as result "`r(N)'"
			drop if drop == 1
			drop drop
			}
		}
	qui { // dropping non-compatible genotypes (K!=M and R!=Y)
		gen drop = .
		replace drop = 1 if recodestrand_ref_gt == "K" & ( recodestrand_alt_gt == "R" |  recodestrand_alt_gt == "Y")
		replace drop = 1 if recodestrand_ref_gt == "M" & ( recodestrand_alt_gt == "R" |  recodestrand_alt_gt == "Y")
		replace drop = 1 if recodestrand_ref_gt == "R" & ( recodestrand_alt_gt == "M" |  recodestrand_alt_gt == "K")
		replace drop = 1 if recodestrand_ref_gt == "Y" & ( recodestrand_alt_gt == "M" |  recodestrand_alt_gt == "K")
		count if drop == 1
		noi di as text"# > recodestrand ..... dropping genotypes (K!=M and R!=Y) "as result "`r(N)'"
		drop if drop == 1
		drop drop
		}
	}
qui { // 4 - identifying strand flips
	gen _tmpflip = 0
	replace _tmpflip = 1 if recodestrand_ref_gt != recodestrand_alt_gt
	qui { // creating new variable for genotypes needing to be flipped
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
	qui { // creating alternative genotype from new alleles"
		recodegenotype, a1(_tmpb1) a2(_tmpb2)
		}
	}
qui { // 5 - clean up
	drop _gt recodestrand_ref_gt recodestrand_alt_gt
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;

