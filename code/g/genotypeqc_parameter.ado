	program genotypeqc_parameter
	syntax
	cd ${data_folder}	
	file open myfile using ${data_input}.parameters, write replace
	file write myfile "global bim2array_ref		   	E:\data\methods\bim2array\data\all" _n
	file write myfile "global bim2build_ref		    E:\data\methods\bim2build\data\bim2build.dta" _n
	file write myfile "global ref                   E:\data\genotypes\ref\1000-genomes\phase3\data\ftp.1000genomes.ebi.ac.uk\eur-1000g-phase3-chrall-mac5" _n
	file write myfile "global bim2frq_compare_ref	E:\data\genotypes\ref\1000-genomes\phase3\data\ftp.1000genomes.ebi.ac.uk\eur-1000g-phase3-chrall-RYMKonly-mac5" _n
	file write myfile "global bim2hapmap_hapmap     E:\data\methods\bim2hapmap\data\hapmap3-all-hg19+1" _n
	file write myfile "global bim2hapmap_aims       E:\data\methods\bim2hapmap\data\bim2hapmap.aims" _n
	file write myfile "global rounds      4" _n
	file write myfile "global hwep        10" _n
	file write myfile "global hetsd       4" _n
	file write myfile "global maf         0.01" _n
	file write myfile "global mind        0.02" _n
	file write myfile "global geno1       0.05" _n
	file write myfile "global geno2       0.02" _n
	file write myfile "global kin_d       0.3540" _n
	file write myfile "global kin_f       0.1770" _n
	file write myfile "global kin_s       0.0884" _n
	file write myfile "global kin_t       0.0442" _n
	file close myfile
	noi di as text"# > "as input"genotypeqc_parameter"as text" ........ parameter file created "as result"${data_input}.parameters"
	end;	
	
