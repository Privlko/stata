program _sub_genotypeqc_meta
syntax  
end
	
clear
input strL v1
`"#########################################################################"'
`"# Genotyping Array Quality Control Report from STATA command genotypeqc"'                                                                
`"# available from https://github.com/ricanney"'                                                                
`"# ======================================================================="'
`"# Author:     Richard Anney"'
`"# Institute:  Cardiff University"'
`"# E-mail:     AnneyR@cardiff.ac.uk"'
`"# Date:       12th July 2017"'
`"#########################################################################"'
`""'
`"#########################################################################"'
`"# Run Information"'                                                                
`"# ======================================================================="'
`"# Date ...................................................... "'
`"# ======================================================================="'
`"# Input File ................................................ "'
`"# Input Array (Approximated) ................................ "'
`"# Input Total Markers ....................................... "'
`"# Input Total Individuals ................................... "'
`"# ======================================================================="'
`"# Output File ............................................... "'
`"# Output Genome Build ....................................... "'
`"# Output Total Markers ...................................... "'
`"# Output Total Individuals .................................. "'
`"# ======================================================================="'
`"# THRESHOLD - maximum missing by individual ................. "'
`"# THRESHOLD - missing by marker ............................. "'
`"# THRESHOLD - minimum minor allele frequency ................ "'
`"# THRESHOLD - maximum hardy-weinberg deviation (-log10(p)) .. "'
`"# THRESHOLD - maximum heterozygosity deviation (std.dev) .... "'
`"# THRESHOLD - rounds of QC .................................. "'
`"# THRESHOLD - europeans ..................................... "'
`"#########################################################################"'
end
gen v2 = ""
replace v2 = "$S_DATE $S_TIME"     in 14 
replace v2 = "$data_input"         in 16
replace v2 = "$bim2array"          in 17 
replace v2 = "$count_markers_1"    in 18
replace v2 = "$count_individ_1"    in 19
replace v2 = "${data_input}-qc-${version}" in 21
replace v2 = "$bim2build"          in 22
replace v2 = "$count_markers_3"    in 23 
replace v2 = "$count_individ_3"    in 24 
replace v2 = "$mind"               in 26
replace v2 = "$geno2"              in 27 
replace v2 = "mac 5"               in 28 
replace v2 = "10e-$hwep"           in 29 
replace v2 = "$hetsd"              in 30 
replace v2 = "$rounds"             in 31
replace v2 = "$count_European"     in 32
outsheet using ${sub_mod_post}.meta-log, delim(" ") non noq replace
