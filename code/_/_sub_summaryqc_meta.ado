program _sub_summaryqc_meta
syntax
end

clear
	input strL v1
	"#########################################################################"
	"# summaryqc"
	"#########################################################################"
	"# Started: " 
	"#########################################################################"
	"# > summaryqc ................................ input data " 
	"# > summaryqc ............................... output data "
	"# > summaryqc .......... reference genotypes (for naming) "
	"# > summaryqc .............. markers in the input dataset "
	"# > summaryqc ....... markers with p-values out-of-bounds "
	"# > summaryqc ................................ duplicates "
	"# > summaryqc .......... info score out-of-bounds or < .8 "
	"# > summaryqc ... data missing from > 1 study (direction) "
	"# > summaryqc .................. markers in final dataset "
	"# > summaryqc ............................. saved data to "
	"# > summaryqc ................ exported manhattan plot to "
	"#########################################################################"
	end

gen v2 = ""
	gen v3 = .
	replace v2 = "$S_DATE $S_TIME" in 4 
	replace v2 = "`input'" in 6
	replace v2 = "`output'" in 7
	replace v2 = "`ref'" in 8
	replace v2 = "${summaryqc_input}" in 9 
	replace v2 = "${summaryqc_oobSNP}" in 10 
	replace v2 = "${summaryqc_dupSNP}" in 11
	replace v2 = "${summaryqc_infoSNP}" in 12 
	replace v2 = "${summaryqc_directionSNP}" in 13
	replace v2 = "${summaryqc_output}" in 14
	replace v2 = "`out'-summaryqc.dta" in 15
	replace v2 = "`out'-summaryqc-manhattan.png}" in 16
	tostring v3, replace
	replace v2 = v3 if v3 != "."
	drop v3
	outsheet using "`out'-summaryqc.log", delim("") non noq replace
	noi di as text"# > summaryqc .......................... reporting to log "as result "`out'-summaryqc.log"
