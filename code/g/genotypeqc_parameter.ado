	program genotypeqc_parameter
	syntax
	cd ${data_folder}	
	file open myfile using ${data_input}.parameters, write replace
	file write myfile "global data_folder	${data_folder}" _n
	file write myfile "global data_input	${data_input}" _n
	file write myfile "global array_ref		E:\data\methods\genotype-array\data" _n
	file write myfile "global build_ref		E:\data\methods\genome-build\data\rsid-hapmap-genome-location.dta" _n
	file write myfile "global kg_ref_frq	E:\data\genotypes\ref\1000-genomes\phase3\data\hg19\eur_1000g_phase3_chrall_impute_macgt5_qcfrq.dta" _n
	file write myfile "global hapmap_data	E:\data\genotypes\ref\hapmap\data\all\hg19-1\hapmap3-all-hg19-1" _n
	file write myfile "global aims	        E:\data\genotypes\ref\hapmap\data\all\hg19-1\hapmap3-all-hg19-1-aims.snp-list" _n
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
	noi di as text"# > genotypeqc_parameter"as text" ........ parameter file created "as result"${data_input}.parameters"

	end;	