program _gwas2prePRS
syntax , out(string asis)
rename snp rsid
order chr bp rsid a1 a2 a1_f or p
keep  chr bp rsid a1 a2 a1_f or p
outsheet using "`out'-prePRS.tsv", noq replace
!$gzip  -f "`out'-prePRS.tsv"
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;



		
		