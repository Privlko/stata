/*
script to get and process the Homo_sapiens.GRCh37.87.gtf.gz gene/exon location file from ftp://ftp.ensembl.org/pub/grch37/release-90/gtf/homo_sapiens/Homo_sapiens.GRCh37.87.gtf.gz
# check for latest release
*/
qui { // set root
	global root E:\data\other\ftp-ensembl\data
	cd ${root}
	}
qui { // get *.gtf file
	!${wget}   ftp://ftp.ensembl.org/pub/grch37/release-90/gtf/homo_sapiens/Homo_sapiens.GRCh37.87.gtf.gz
	}
	
qui { // collect gene information 
	!${gunzip} Homo_sapiens.GRCh37.87.gtf.gz
	import delim using Homo_sapiens.GRCh37.87.gtf, clear varnames(noname) rowrange(6:)
	keep if v3 == "gene"
	rename v1 chr
	rename v4 start
	rename v5 end
	keep chr start end v9
	replace chr = "23" if chr == "X"
	replace chr = "24" if chr == "Y"
	replace chr = "25" if chr == "XY"
	replace chr = "26" if chr == "MT"
	destring chr, replace force
	drop if chr == .
	split v9,p("; ")
	drop v9
	gen ensembl_geneID = subinstr(v91, "gene_id ", "",.) 
	gen symbol         = subinstr(v93, "gene_name ", "",.)
	gen biotype        = subinstr(v95, "gene_biotype ", "",.)
	foreach i in ensembl symbol biotype { 
		replace `i' = subinstr(`i', `"""',"",.)
		replace `i' = subinstr(`i', ";","",.)
		}
	keep  ensembl_geneID chr start end symbol biotype
	order ensembl_geneID chr start end symbol biotype
	sort ensembl_geneID
	save Homo_sapiens.GRCh37.87.gtf.dta, replace
	}
qui { // collect exon information
	import delim using Homo_sapiens.GRCh37.87.gtf, clear varnames(noname) rowrange(6:)
	keep if v3 == "exon"
	rename v1 chr
	rename v4 txstart
	rename v5 txend
	keep chr txstart txend v9
	replace chr = "23" if chr == "X"
	replace chr = "24" if chr == "Y"
	replace chr = "25" if chr == "XY"
	replace chr = "26" if chr == "MT"
	destring chr, replace force
	drop if chr == .
	split v9,p("; ")
	drop v9
	keep txs txe v91 v93 v95 v99
	gen ensembl_geneID  = subinstr(v91, "gene_id ", "",.) 
	gen ensembl_txID    = subinstr(v93, "transcript_id ", "",.) 
	gen exonCount       = subinstr(v95, "exon_number ", "",.)
	gen ensembl_geneID2 = subinstr(v99, "transcript_name ", "",.)
	foreach i in ensembl_geneID ensembl_txID ensembl_geneID2 exonCount { 
		replace `i' = subinstr(`i', `"""',"",.)
		replace `i' = subinstr(`i', ";","",.)
		}
	keep  ensembl_geneID ensembl_geneID2 ensembl_txID exonCount txstart txend
	order ensembl_geneID ensembl_geneID2 ensembl_txID exonCount txstart txend
	sort ensembl_geneID
	merge m:m ensembl_geneID using Homo_sapiens.GRCh37.87.gtf.dta 
	keep  ensembl_geneID ensembl_txID exonCount chr start end txstart txend  symbol ensembl_geneID2 biotype
	order ensembl_geneID ensembl_txID exonCount chr start end txstart txend  symbol ensembl_geneID2 biotype
	sort  ensembl_geneID ensembl_geneID2 exonCount 
	save Homo_sapiens.GRCh37.87.gtf_exon.dta, replace
	}
!${gzip} Homo_sapiens.GRCh37.87.gtf
