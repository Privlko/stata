cd D:\sandbox\graphplinkassoc
fam2dta, fam(example)
keep fid iid
gen pheno = uniform()
replace pheno = 1 if pheno >.5
replace pheno = 2 if pheno <=.5
outsheet using example.pheno, non noq replace
!$plink --bfile example --pheno example.pheno --assoc --ci .95
	import delim using plink.assoc, clear
	replace v1 = subinstr(v1,"  "," ",.)
	replace v1 = subinstr(v1,"  "," ",.)
	replace v1 = subinstr(v1,"  "," ",.)
	replace v1 = subinstr(v1,"  "," ",.)
	replace v1 = subinstr(v1,"  "," ",.)
	split v1,p(" ")
	drop v1
	outsheet using plink.assoc.tabbed, replace non noq
import delim using plink.assoc.tabbed, clear
save plink.assoc.dta, replace

destring p, replace force
noi graphqq,p(p) min(1)
graph use "D:\sandbox\graphplinkassoc\tmpQQ.gph" 
graph export "D:\github\stata\images\example_graphqq.png", as(png) replace 
noi graphmanhattan, chr(chr) bp(bp) p(p) min(1)
graph use "D:\sandbox\graphplinkassoc\tmpManhattan.gph" 
graph export "D:\github\stata\images\example_graphmanhattan.png", as(png) replace height(500) width(1500)
graph combine tmpQQ.gph tmpManhattan.gph, ycommon
graph export "D:\sandbox\graphplinkassoc\example_graphcombined.png", as(png) replace height(500) width(1500)

qui { // clumping and creating table 1
	renvars, upper
	outsheet SNP P using tmp_graphplinkassoc.p, noq replace
	!$plink --bfile example --clump tmp_graphplinkassoc.p --clump-p1 .05 --clump-p2 .05 --clump-kb 1000 --clump-r2 0.2 --out tmp_graphplinkassoc
	import delim using tmp_graphplinkassoc.clumped, clear
		replace v1 = subinstr(v1,"  "," ",.)
		replace v1 = subinstr(v1,"  "," ",.)
		replace v1 = subinstr(v1,"  "," ",.)
		replace v1 = subinstr(v1,"  "," ",.)
		replace v1 = subinstr(v1,"  "," ",.)
		split v1,p(" ")
		drop v1
		outsheet using tmp_graphplinkassoc.clumped.tabbed, replace non noq
	import delim using tmp_graphplinkassoc.clumped.tabbed, clear
	keep chr snp bp p
	for var chr bp p : destring X, replace
	save 	tmp_graphplinkassoc-clumped.dta,replace
	bim2dta, bim(example)
	import delim using tmp_graphplinkassoc.clumped.tabbed, clear
	keep snp sp2 bp
	rename (snp bp) (index bp0)
	split sp2,p(",""NONE""(1)")
	gen sp29999 = ""
	drop sp2
	reshape long sp2, i(index) j(obs)
	rename sp2 snp
	drop if snp == ""
	drop obs
	merge m:1 snp using example_bim.dta	
	keep if _m == 3
	keep index bp0 bp chr
	destring bp0, replace
	destring bp, replace
	order index chr bp
	sort index chr bp
	egen x = seq(),by(index chr )
	reshape wide bp, i(index chr) j(x)
	gen bp9999 = .

	gen min = bp0
	gen max = bp0
	aorder
	for var bp1 - bp9999: replace min = X if X < min
	for var bp1 - bp9999: replace max = X if X > max & X !=.
	keep index bp0 chr min max
	for var min max: tostring X, replace
	gen bed = "chr" + chr + ":" + min + "-" + max
	rename bp0 bp
	tostring bp, replace
	keep index bed
	rename index snp
	merge 1:1 snp using plink.assoc.dta
	keep if _m == 3
	for var or u95 l95 p: destring X,replace force
	sort p
	gen str4 x= string(or,"%03.2f")						
	gen str4 y= string(l95,"%03.2f")					
	gen str4 z= string(u95,"%03.2f")			
	gen _or = x + " (" + y + "-" + z + ")"
	save tmp_graphplinkassoc-clumped.dta, replace	
	
	
	}

	chr	start	stop	gene
5	150273953	150284545	ZNF300
5	150309997	150326146	ZNF300P1
5	150399998	150408554	GPX3
5	150409503	150467221	TNIP1
5	150480266	150537443	ANXA6

use tmp_graphplinkassoc-clumped.dta, clear
gen gene = ""
split bed,p("chr"":""-")
for var bed1-bed4: destring X, replace

-*******-
be-------
b******e-
b*******e
-be------
-b*****e-
-b******e
--be-----
--b****e-
--b*****e

replace gene = gene + " ZNF300" if (bed2 == 5 & bed3 <= start & bed4  > start))
replace gene = gene + " ZNF300" if (bed2 == 5 & bed3 >= start & bed4  < end))
replace gene = gene + " ZNF300" if (bed2 == 5 & bed3 >= start & bed3 <= end))





bed

chr5:165981949-166113230
chr1:15027217-15054740
chr1:230232917-230254964

	
	qui { // annotate
	import delim using glist-hg19.txt, clear delim(" ") 
	rename (v1-v4) (chr start stop gene)
	replace chr = "23" if chr == "X"
	replace chr = "24" if chr == "Y"
	replace chr = "25" if chr == "XY"
	destring chr, replace
	sort chr start	
	save tmp,replace
	append using tmp.dta
	append using tmp.dta
	egen x = seq(),by(chr start stop gene)
	for var chr start stop : tostring X ,replace
	
	gen a = ""
	replace a = `"replace gene = gene + " "' + gene + `"" if (bed2 == "' + chr + `" & bed3 <= "' + start + " & bed4  >  "  + start + ")" if x == 1
	replace a = `"replace gene = gene + " "' + gene + `"" if (bed2 == "' + chr + `" & bed3 >= "' + start + " & bed4  <  "  + stop  + ")" if x == 2
	replace a = `"replace gene = gene + " "' + gene + `"" if (bed2 == "' + chr + `" & bed3 >= "' + start + " & bed3  <= " + stop  + ")" if x == 3
	outsheet a using _tmp.do, non noq replace
	
use tmp_graphplinkassoc-clumped.dta, clear
gen gene = ""
split bed,p("chr"":""-")
for var bed1-bed4: destring X, replace
qui do _tmp.do
replace gene = subinstr(gene,"  "," ",.)
replace gene = subinstr(gene,"  "," ",.)
replace gene = subinstr(gene,"  "," ",.)
replace gene = subinstr(gene,"  "," ",.)
keep chr bp snp bed a1 f_a f_u a2 chisq p _or gene
split gene, p(" ")
for var chr bp p: tostring X, replace
gen a = chr + "££" + bp + "££" + snp + "££" + bed + "££" + a1 + "££" + f_a + "££" + f_u + "££" + a2 + "££" + chisq + "££" + p + "££" + _or
drop chr bp snp bed a1 f_a f_u a2 chisq p _or gene
reshape long gene, i(a) j(obs)
drop obs
duplicates drop
egen x = seq(),by(a)
reshape wide gene , i(a) j(x)
split a,p("££")
drop a
rename(a1-a11) (chr bp snp bed a1 f_a f_u a2 chisq p or)
gen gene999 = ""
aorder
gen gene = ""
for var gene1-gene999: replace gene = X + " " + gene if X != ""
keep chr bp snp bed a1 f_a f_u a2 chisq p or gene
order chr bp snp bed a1 f_a f_u a2 chisq p or gene
destring p,replace
sort p




	

	
			gen GENES = RANGES
			replace GENES = subinstr(GENES , "[", "",.) 
			replace GENES = subinstr(GENES , "]", "",.) 
			replace GENES = subinstr(GENES , ",", " ",.) 
			drop RANGES
			gen str4 W= string(HETISQT ,"%04.3f")
			gen str4 X= string(HETCHISQ ,"%04.3f")
			gen str1 Y= string(HETDF ,"%4.3f")
			gen str5 Z= string(HETPVA,"%04.3f")
			gen HETEROGENEITY = W + " (CHI2 = " + X + "; DF = " + Y + "; P=" + Z + ")"
			drop W X Y Z
			rename POS LD_RANGE
			keep  SNP POSITION ALLELE OR P INFO DIRECTION HETEROGENEITY LD_RANGE GENES 
			order SNP POSITION ALLELE OR P INFO DIRECTION HETEROGENEITY LD_RANGE GENES 
			lab var SNP "MARKER"
			lab var POSITION "MARKER LOCATION"
			lab var LD_RANGE "ASSOCIATED REGION (CLUMP)"
			lab var GENES "GENES IN REGION"
			lab var ALLELE_AF "ALLELE (GT; FRQ_A:FRQ_U)"
			lab var OR "ODDS RATIO (95%CI)"
			lab var P "P-VALUE"
			lab var INFO "INFO SCORE"
			lab var DIRECTION "DIRECTION OF META"
			lab var HETEROGENEITY "HETEROGENEITY"
			sort P
			save 						summary\\${filename_`i'}.clumped.ranges.dta,replace
			keep if P <= 1e-4
			export excel using 			summary\\${filename_`i'}.clumped.ranges.xls , firstrow(varlabels) sh("Association Findings (P<1e-4)") sheetreplace		
			}
		
		
		
