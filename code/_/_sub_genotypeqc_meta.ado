program _sub_genotypeqc_meta
syntax
end
	
clear
input strL v1
"#########################################################################"
"# genotypeqc"
"#########################################################################"
"# Started: " 
"#########################################################################"
"# > genotypeqc .................................. version"
"# > genotypeqc ............................... input data" 
"# > bim2array ............................... input array" 
"# > bim2build ............................... input build" 
"# > bim2count .............. markers in the input dataset"
"# > bim2count .......... individuals in the input dataset"
"# > genotypeqc .............................. output data"
"# > bim2build .............................. output build"
"# > bim2count ............. markers in the output dataset"
"# > bim2count ......... individuals in the output dataset"
"# > bim2hapmap ......................... ancestry mapping"
"# > bim2hapmap ........... individuals mapped to ancestry"
"# > genotypeqc ........... (threshold) minor allele count"
"# > genotypeqc ...... (threshold) missingness by genotype"
"# > genotypeqc .... (threshold) missingness by individual"
"# > genotypeqc  (threshold) max. hardy weinberg deviation"
"# > genotypeqc  (threshold) max. heterozygosity deviation"
"# > genotypeqc ......... (threshold) kinship (duplicates)"
"# > genotypeqc ....... (threshold) kinship (first degree)"
"# > genotypeqc ...... (threshold) kinship (second degree)"
"# > genotypeqc ....... (threshold) kinship (third degree)"
"# > genotypeqc ................ rounds of quality control"
"# > bim2refid .......... reference genotypes (for naming)"
"#########################################################################"
end
gen v2 = ""
replace v2 = "$S_DATE $S_TIME"                                       in 4 
replace v2 = "${version}"                                            in 6
replace v2 = "${input}"                                              in 7
replace v2 = "${bim2array}"                                          in 8
replace v2 = "${bim2build}"                                          in 9
replace v2 = "${input_snp}"                                          in 10
replace v2 = "${input_ind}"                                          in 11
replace v2 = "${output}"                                             in 12
replace v2 = "hg19 +1"                                               in 13
replace v2 = "${output_snp}"                                         in 14
replace v2 = "${output_ind}"                                         in 15
replace v2 = "CEU TSI"                                               in 16
replace v2 = "${ancestry_ind}"                                       in 17
replace v2 = "5"                                                     in 18
replace v2 = "${geno1}; ${geno2}"                                    in 19
replace v2 = "${mind}"                                               in 20
replace v2 = "1e-${hwep}"                                            in 21
replace v2 = "${hetsd}"                                              in 22
replace v2 = "${kin_d}"                                              in 23
replace v2 = "${kin_s}"                                              in 24
replace v2 = "${kin_f}"                                              in 25
replace v2 = "${kin_t}"                                              in 26
replace v2 = "${rounds}"                                             in 27
replace v2 = "${ref}"                                                in 28
outsheet using "${output}-genotypeqc.log", delim(" ") non noq replace
		

		
		
		

