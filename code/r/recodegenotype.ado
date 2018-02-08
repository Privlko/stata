/*
*program*
 recodegenotype

*description* 
 a command to convert allele codes to genotype codes

*syntax*
syntax , a1(-allele1-) a2(-allele2-)
 
 -a1-   the varname containing allele 1 
 -a2-   the varname containing allele 2 

*/
program recodegenotype
syntax , a1(string asis)  a2(string asis) 
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# recodegenotype"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > recodegenotype ...................................... "as result"checking that alleles are defined correctly"
	capture confirm var `a1'
	if _rc==0 {
		noi di as text"# > recodestrand ......... allele 1 (reference genotypes) "as result"present"
		}
	else {
		noi di as text"# > recodestrand ......... allele 1 (reference genotypes) "as error "absent"
		exit
		}
	capture confirm var `a2'
	if _rc==0 {
		noi di as text"# > recodestrand ......... allele 2 (reference genotypes) "as result"present"
		}
	else {
		noi di as text"# > recodestrand ......... allele 2 (reference genotypes) "as error "absent"
		exit
		}
	}
qui { // 2 - converting complex indels to ID (by length)
	gen counta1 = length(`a1')
	gen counta2 = length(`a2')
	replace `a1' = "I" if counta1 > counta2
	replace `a2' = "I" if counta2 > counta1
	replace `a1' = "D" if `a2' == "I"
	replace `a2' = "D" if `a1' == "I"
	replace `a1' = substr(`a1',1,1)
	replace `a2' = substr(`a2',1,1)
	drop counta1 counta2
	replace `a1' = "" if `a1' == "-"
	replace `a2' = "" if `a2' == "-"
	replace `a1' = "" if `a1' == "0"
	replace `a2' = "" if `a2' == "0"
	compress
	}
qui { // 3 - creating _gt_tmp from `a1' and `a2'
	gen _gt_tmp = ""
	replace _gt_tmp = "A" if  (`a1' =="A" & `a2' =="")
	replace _gt_tmp = "A" if  (`a1' =="A" & `a2' =="A")
	replace _gt_tmp = "A" if  (`a1' ==""  & `a2' =="A")
	
	replace _gt_tmp = "C" if  (`a1' =="C" & `a2' =="")
	replace _gt_tmp = "C" if  (`a1' =="C" & `a2' =="C")
	replace _gt_tmp = "C" if  (`a1' ==""  & `a2' =="C")
	
	replace _gt_tmp = "G" if  (`a1' =="G" & `a2' =="")
	replace _gt_tmp = "G" if  (`a1' =="G" & `a2' =="G")
	replace _gt_tmp = "G" if  (`a1' ==""  & `a2' =="G")
	
	replace _gt_tmp = "T" if  (`a1' =="T" & `a2' =="")
	replace _gt_tmp = "T" if  (`a1' =="T" & `a2' =="T")
	replace _gt_tmp = "T" if  (`a1' ==""  & `a2' =="T")
	
	replace _gt_tmp = "I" if  (`a1' =="I" & `a2' =="")
	replace _gt_tmp = "I" if  (`a1' =="I" & `a2' =="I")
	replace _gt_tmp = "I" if  (`a1' ==""  & `a2' =="I")
	
	replace _gt_tmp = "D" if  (`a1' =="D" & `a2' =="")
	replace _gt_tmp = "D" if  (`a1' =="D" & `a2' =="D")
	replace _gt_tmp = "D" if  (`a1' ==""  & `a2' =="D")

	replace _gt_tmp = "ID" if (`a1' =="D" & `a2' =="I")
	replace _gt_tmp = "ID" if (`a1' =="I" & `a2' =="D")
	
	replace _gt_tmp = "K" if  (`a1' =="G" & `a2' =="T")
	replace _gt_tmp = "K" if  (`a1' =="T" & `a2' =="G")
	
	replace _gt_tmp = "M" if  (`a1' =="A" & `a2' =="C")
	replace _gt_tmp = "M" if  (`a1' =="C" & `a2' =="A")
	
	replace _gt_tmp = "R" if  (`a1' =="A" & `a2' =="G")
	replace _gt_tmp = "R" if  (`a1' =="G" & `a2' =="A")
	
	replace _gt_tmp = "S" if  (`a1' =="C" & `a2' =="G")
	replace _gt_tmp = "S" if  (`a1' =="G" & `a2' =="C")

	replace _gt_tmp = "W" if  (`a1' =="A" & `a2' =="T")
	replace _gt_tmp = "W" if  (`a1' =="T" & `a2' =="A")
	
	replace _gt_tmp = "Y" if  (`a1' =="C" & `a2' =="T")
	replace _gt_tmp = "Y" if  (`a1' =="T" & `a2' =="C")
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
