program _gwas2sumstat
syntax , munge(string asis) merge(string asis) out(string asis)
keep snp a1 a2 z p n a1_frq
rename a1_frq maf
renvars, upper
outsheet SNP A1 A2 Z P N MAF using tempfile.txt, noq replace
!python "`munge'" --sumstats tempfile.txt --out `out'_hw3 --merge-alleles "`merge'"
!$gzip -f `out'_hw3.sumstats
!python "`munge'" --sumstats tempfile.txt --out `out' 
!$gzip -f `out'.sumstats
erase tempfile.txt
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;



		
		