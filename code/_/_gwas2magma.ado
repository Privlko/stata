program _gwas2magma
syntax , out(string asis)
keep  snp chr bp p
renvars, upper
outsheet using "`out'.pval", noq replace
!$gzip  -f "`out'.pval"
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;



		
		