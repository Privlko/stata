/*
*program*
 bim2michigan

*description* 
 a command to convert bim file to michigan imputation server ready

*syntax*
 bim2michigan, bim(-filename-) ref(-reference-)
 
 -filename- does not require the .bim filetype to be included - this is assumed
 -reference- download bim2build.dta from github.com/ricanney
 
*/

program bim2michigan
syntax , bim(string asis) ref(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2michigan"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > bim2michigan ................ checking build of (bim) "as result"`bim'.bim"
	noi checkfile, file(`bim'.bim)
	noi di as text"# > bim2michigan ........... checking build against (ref) "as result"`ref'"
	noi checkfile, file(`ref')
	}
qui { // 2 - convert to michigan
	qui { // import bim file and remove ambiguous snps
		noi di as text"# > bim2michigan ................................. import "as result"`bim'.bim"
		bim2dta, bim(`bim')
		erase `bim'_bim.dta
		drop if gt == "W" | gt == "S"
		keep loc_name snp a1 a2
		for var snp a1 a2: rename X bim_X
		}
	qui { // merge with hrc 1.1 reference
		noi di as text"# > bim2michigan ........................... merging with "as result"`ref'"
		merge 1:1 loc_name using `ref'
		keep if _m == 3
		for var snp a1 a2: rename X michigan_X
		}
	qui { // select snps
		noi di as text"# > bim2michigan ........................................ extracting overlapping snps"
		outsheet bim_snp using bim2michigan.extract, non noq replace
		!$plink --bfile `bim' --extract bim2michigan.extract --make-bed --out tempfile-bim2michigan-1
		erase bim2michigan.extract
		}
	qui { // flip strand
		noi di as text"# > bim2michigan ........................................ flipping strands"
		recodestrand , ref_a1(michigan_a1) ref_a2(michigan_a2) alt_a1(bim_a1) alt_a2(bim_a2) 
		outsheet bim_snp using bim2michigan.flip if _tmpflip == 1, non noq replace
		!$plink --bfile tempfile-bim2michigan-1 --flip bim2michigan.flip --make-bed --out tempfile-bim2michigan-2
		!del tempfile-bim2michigan-1*
		erase bim2michigan.flip
		}
	qui { // rename bim_snps to michigan_snps
		noi di as text"# > bim2michigan ........................................ renaming snps"
		outsheet bim_snp michigan_snp if bim_snp != michigan_snp using bim2michigan.update-name, non noq replace
		!$plink --bfile tempfile-bim2michigan-2 --update-name bim2michigan.update-name --make-bed --out tempfile-bim2michigan-3
		!del tempfile-bim2michigan-2*
		erase bim2michigan.update-name

		}
	qui { // set reference allele
		noi di as text"# > bim2michigan ........................................ setting reference allele"
		outsheet michigan_snp michigan_a2 using bim2michigan.a2-allele, non noq replace
		!$plink --bfile tempfile-bim2michigan-3 --a2-allele bim2michigan.a2-allele --make-bed --out tempfile-bim2michigan-4
		!del tempfile-bim2michigan-3*
		erase bim2michigan.a2-allele
		}
	qui { // convert to michigan vcf
		clear
		set obs 1
		gen a = "`bim'"
		split a, p("\")
		drop a
		sxpose, clear
		gen x = _n
		gsort -x
		keep in 1
		gen a = "global bim2michigan_out "
		outsheet a _v using bim2michigan.do, non noq replace
		do bim2michigan.do
		erase bim2michigan.do
		noi di as text"# > bim2michigan ........................................ converting to vcf"
		foreach num of num 1/22 { 
			!${plink} --bfile tempfile-bim2michigan-4 --keep-allele-order -chr `num' --recode vcf --out ${bim2michigan_out}-chrom`num'_hg19_1
			}
		!${plink} --bfile tempfile-bim2michigan-4 --keep-allele-order -chr 23 --recode vcf --out ${bim2michigan_out}-chrom23_hg19_1
		!${cat} ${bim2michigan_out}-chrom23_hg19_1.vcf | ${sed} -e "s/^23/X/"  > ${bim2michigan_out}-chromX_hg19_1.vcf
		!del tempfile-bim2michigan-4* *.hh ${bim2michigan_out}-chrom23_hg19_1.vcf
		}
	qui { // prepare for bgzip on rock
		noi di as text"# > bim2michigan ........................................ archiving vcf bundle"
		!bash -c "tar -zcvf ${bim2michigan_out}.tar.gz *.vcf"
		clear
		set obs 23
		gen N = _n
		tostring N, replace
		replace N = "X" in 23
		gen a = ""
		replace a = "/share/apps/bgzip ${bim2michigan_out}-chrom" + N + "_hg19_1.vcf & "
		outsheet a using bim2michigan.sh, non noq replace
		!$dos2unix bim2michigan.sh
		!del *.vcf *.log
		}
	}
qui { // 3 - post-script
	clear
	noi di as text"#"
	noi di as text"# the tar.gz bundle should be transferred to rocks to convert to bgzip "
	noi di as result"> tar -zxvf ${bim2michigan_out}.tar.gz"
	noi di as result"> bash bim2michigan.sh"
	noi di as text"# the *.vcf.gz files are now ready to submit to the michigan imputation "
	noi di as text"# server at https://imputationserver.sph.umich.edu"
	noi di as text"# > michigan imputation server (options) ................ "as result"unphased"
	noi di as text"# > michigan imputation server (options) ................ "as result"hrc.r1.1.2016"
	noi di as text"# > michigan imputation server (options) ................ "as result"shapeit"
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;	
