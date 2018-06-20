/*
*program*
 summaryqc

*description* 
perform basic quality control on summary gwas statistics
*/

program summaryqc
syntax ,  ref(string asis) input(string asis) out(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# summaryqc               "
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	
	noi di as text"# > summaryqc ................................ input data "as result "`input'"
	count
	global summaryqc_Nin `r(N)'
	noi di as text"# > summaryqc .............. markers in the input dataset "as result ${summaryqc_Nin}
	}
qui { // 2 - perform quality control
	qui { // drop if p out-of-bounds
		count 
		global summaryqc_runningtotal `r(N)'
		drop if p > 1
		drop if p < 0
		drop if p == .
		count
		gen a = ${summaryqc_runningtotal} - `r(N)'
		sum a
		global summaryqc_oobSNP `r(max)'
		drop a
		noi di as text"# > summaryqc ....... markers with p-values out-of-bounds "as result ${summaryqc_oobSNP} 
		}
	qui { // duplicates drop
		count 
		global summaryqc_runningtotal `r(N)'
		duplicates drop 
		duplicates drop snp, force
		count
		gen a = ${summaryqc_runningtotal} - `r(N)'
		sum a
		global summaryqc_dupSNP `r(max)'
		drop a
		noi di as text"# > summaryqc ................................ duplicates "as result ${summaryqc_dupSNP} 
		}
	qui { // qc-by-info score
		capture confirm numeric var info
		if !_rc {
			count 
			global summaryqc_runningtotal `r(N)'
			drop if info == .
			drop if info > 2 & info ! = .
			drop if info < .8
			drop info
			count
			gen a = ${summaryqc_runningtotal} - `r(N)'
			sum a
			global summaryqc_infoSNP `r(max)'
			drop a
			noi di as text"# > summaryqc .......... info score out-of-bounds or < .8 "as result ${summaryqc_infoSNP} 
			}
		else {
			global summaryqc_infoSNP "info score not present"
			noi di as text"# > summaryqc .......... info score out-of-bounds or < .8 "as result "${summaryqc_infoSNP}"
			}
		}
	qui { // qc-by-direction
		capture confirm string var direction
		if !_rc {
			count 
			global summaryqc_runningtotal `r(N)'
			replace direction = subinstr(direction, "-", "",.)
			replace direction = subinstr(direction, "+", "",.)
			gen count = length(direction)
			drop if count > 2
			drop direction count
			count
			gen a = ${summaryqc_runningtotal} - `r(N)'
			sum a
			global summaryqc_directionSNP `r(max)'
			drop a
			noi di as text"# > summaryqc ... data missing from > 2 study (direction) "as result ${summaryqc_directionSNP} 
			}
		else {
			global summaryqc_directionSNP "direction variable not present"
			noi di as text"# > summaryqc ... data missing from > 2 study (direction) "as result "${summaryqc_directionSNP}"
			}
		}	
	}
qui { // 3 - plot manhattan
		gen logp = round(-log10(p),1) + 2
		sum logp
		graphmanhattan, chr(chr) bp(bp) p(p) max(`r(max)')
		drop logp
		graph use tmpManhattan.gph
		noi di as text"# > summaryqc .............. exporting manhattan graph to "as result "`out'-summaryqc-manhattan.eps"
		graph export summaryqc-manhattan.eps, replace
		!convert     -density 1000 summaryqc-manhattan.eps -resize 2000x1000! `out'-summaryqc-manhattan.png
		window manage close graph
		erase tmpManhattan.gph
		erase summaryqc-manhattan.eps
		}
qui { // 4 - log and save as
	count
	global summaryqc_Nout `r(N)'
	noi di as text"# > summaryqc .................. markers in final dataset "as result ${summaryqc_Nout}
	noi di as text"# > summaryqc ............................ saving data to "as result "`out'-summaryqc.dta"
	order chr bp snp a1 a2 beta se z or l95 u95 p
	sort  chr bp
	noi di as text"#########################################################################"
	noi di as text"# Completed: $S_DATE $S_TIME"
	noi di as text"#########################################################################"
	
	file open myfile using "`out'-summaryqc.log", write replace
	file write myfile "#########################################################################" _n 
	file write myfile "# summaryqc - log" _n 
	file write myfile "#########################################################################" _n 
	file write myfile "# This log file was generated as part of the -summaryqc- program. " _n 	
	file write myfile "# please note - some pre-processing may have been performed to get these " _n
	file write myfile "# data into the correct format for -summaryqc- " _n 
	file write myfile "#########################################################################" _n 
	file write myfile "# > ................................ input data `input'" _n
	file write myfile "# > .............. markers in the input dataset ${summaryqc_Nin}" _n 
	file write myfile "# > ....... markers with p-values out-of-bounds ${summaryqc_oobSNP}" _n 
	file write myfile "# > ................................ duplicates ${summaryqc_dupSNP}" _n
	file write myfile "# > .......... info score out-of-bounds or < .8 ${summaryqc_infoSNP}" _n
	file write myfile "# > ... data missing from > 2 study (direction) ${summaryqc_directionSNP}" _n
	file write myfile "# > .................. markers in final dataset ${summaryqc_Nout}" _n
	file write myfile "#########################################################################" _n 
	sum chr
	file write myfile "# > ........................... chromosome range `r(min)' , `r(max)'" _n
	sum p
	file write myfile "# > .................................. minimum p `r(min)' " _n
	count if p < 5e-8
	file write myfile "# > .. genomewide significany (p < 5e-8) markers `r(N)' " _n
	sum n
	file write myfile "# > .......................... sample size range `r(min)' , `r(max)'" _n
	file write myfile "#########################################################################" _n
	file write myfile "# Completed: $S_DATE $S_TIME" _n
	file write myfile "#########################################################################" _n
	file close myfile
	for var chr bp: tostring X, replace	
	save `out'-summaryqc.dta, replace
	}
end;

	
