/*
*program*
 bim2hapmap

*description* 
 command that uses plink-format genotype files to plot against hapmap 
 ancestries. the script also defines individuals with ancestral 
 similarities to a defined hapmap set

*syntax*
bim2hapmap,  bim(-filename-) hapmap(string asis) aims(string asis) like(string asis)
 
 -filename- does not require the .bim filetype to be included - this is assumed
 -aims-     download bim2hapmap.aims from github.com/ricanney
 -hapmap-   download hapmap3-all-hg19+1.bed; hapmap3-all-hg19+1.bim; hapmap3-all-hg19+1.fam; hapmap3-all-hg19+1.population from github.com/ricanney
 -like-     this refers to population codes (ASW LWK MKK YRI CEU TSI MEX GIH CHB CHD JPT); more than one code can be specified (space seperated)
*/

program bim2hapmap
syntax , bim(string asis) like(string asis) hapmap(string asis) aims(string asis)
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# bim2hapmap"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
 noi di as text"# > bim2hapmap ........ defining ancestries vs hapmap for "as result"`bim'"
 noi checkfile, file(`bim'.bim)
 noi checkfile, file(`bim'.bed)
 noi checkfile, file(`bim'.fam)
 noi checkfile, file(`hapmap'.bim)
 noi checkfile, file(`hapmap'.bed)
 noi checkfile, file(`hapmap'.fam)
 noi checkfile, file(`hapmap'.population)
 noi checkfile, file(`aims')
 noi checkfile, file(${plink})
 }
qui { // 2 - limit genotypes to aims and merge
 !$plink --bfile `bim'    --extract `aims' --make-founders --make-bed --out bim2hapmap_test
 !$plink --bfile `hapmap' --extract `aims' --make-founders --make-bed --out bim2hapmap_hapmap
 bim2dta, bim(bim2hapmap_test)
 keep snp a1 a2
 rename (a1 a2) (_test_a1 _test_a2)
 save bim2hapmap_test_bim.dta,replace
 bim2dta, bim(bim2hapmap_hapmap)
 keep snp a1 a2
 rename (a1 a2 ) (_hapmap_a1 _hapmap_a2)
 merge 1:1 snp using bim2hapmap_test_bim.dta
 keep if _m == 3
 keep snp _test_a1 _test_a2  _hapmap_a1 _hapmap_a2 
 recodestrand, ref_a1(_hapmap_a1) ref_a2(_hapmap_a2) alt_a1(_test_a1) alt_a2(_test_a2) 
 outsheet snp using overlap.extract, non noq replace
 keep if _tmpflip == 1
 outsheet snp using _test.flip, non noq replace
 !$plink --bfile bim2hapmap_test   --flip _test.flip --make-founders --extract overlap.extract --make-bed --out bim2hapmap_test_flip_intersect
 !$plink --bfile bim2hapmap_hapmap --make-founders --extract overlap.extract --make-bed --out  bim2hapmap_hapmap_intersect
 !$plink --bfile bim2hapmap_test_flip_intersect --bmerge bim2hapmap_hapmap_intersect.bed bim2hapmap_hapmap_intersect.bim bim2hapmap_hapmap_intersect.fam  --allow-no-sex --make-bed --out bim2hapmap_combined
 }
qui { // 3 - calculate eigenvectors
 bim2eigenvec, bim(bim2hapmap_combined)
 }
qui { // 4 - plot graphs
 use bim2hapmap_combined_eigenval.dta,clear
 twoway scatter eigenval pc, xtitle("Principle Components") connect(l) xlabel(1(1)10) mfc(red) mlc(black) mlw(vthin) ms(O) saving(bim2hapmap_eigenval-scree.gph, replace) nodraw
 clear
 set obs 25
 egen x = seq(),block(5) 
 egen y = seq(),by(x)
 gen POPULATION = ""
 replace POPULATION = "Test (European)"     if x == 1 & y == 5
 replace POPULATION = "Test (non-European)" if x == 3 & y == 5
 replace POPULATION = "ASW"                 if x == 1 & y == 4
 replace POPULATION = "LWK"                 if x == 2 & y == 4
 replace POPULATION = "MKK"                 if x == 3 & y == 4
 replace POPULATION = "YRI"                 if x == 4 & y == 4
 replace POPULATION = "CEU"                 if x == 1 & y == 3
 replace POPULATION = "TSI"                 if x == 2 & y == 3
 replace POPULATION = "MEX"                 if x == 1 & y == 2
 replace POPULATION = "GIH"                 if x == 2 & y == 2
 replace POPULATION = "CHB"                 if x == 1 & y == 1
 replace POPULATION = "CHD"                 if x == 2 & y == 1
 replace POPULATION = "JPT"                 if x == 3 & y == 1
 replace POPULATION = " "                   if x == 5 & y == 5
 global format msiz(medlarge) msymbol(S) mlc(black) mlabel(POP) mlabposition(3) mlabsize(medium) mlw(vvthin)
 colorscheme 8, palette(Blues) 
 global ceu mfcolor("`=r(color8)'")
 global tsi mfcolor("`=r(color4)'")
 colorscheme 8, palette(Oranges) 
 global chb mfcolor("`=r(color8)'")
 global chd mfcolor("`=r(color6)'")
 global jpt mfcolor("`=r(color4)'")
 colorscheme 8, palette(Purples) 
 global mex mfcolor("`=r(color8)'")
 global gih mfcolor("`=r(color6)'")   
 colorscheme 8, palette(Greens) 
 global yri mfcolor("`=r(color8)'")
 global lwk mfcolor("`=r(color7)'")
 global mkk mfcolor("`=r(color6)'")   
 global asw mfcolor("`=r(color5)'")
 global test1 mfcolor(red)
 global test2 mfcolor(gs8) 
 tw scatter y x if POP == "Test (European)" ,     $format $test1  ///
 || scatter y x if POP == "Test (non-European)" , $format $test2  ///  
 || scatter y x if POP == "ASW"                 , $format $asw  ///
 || scatter y x if POP == "LWK"                 , $format $lwk  ///
 || scatter y x if POP == "MKK"                 , $format $mkk  ///
 || scatter y x if POP == "YRI"                 , $format $yri  ///
 || scatter y x if POP == "CEU"                 , $format $ceu  ///
 || scatter y x if POP == "TSI"                 , $format $tsi  ///
 || scatter y x if POP == "MEX"                 , $format $mex  /// 
 || scatter y x if POP == "GIH"                 , $format $gih  ///
 || scatter y x if POP == "CHB"                 , $format $chb  ///
 || scatter y x if POP == "CHD"                 , $format $chd  ///
 || scatter y x if POP == "JPT"                 , $format $jpt  ///
 || scatter y x if POP == " "                   , msymbol(none)                   ///
  legend(off) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank)) 
  graph save legend.gph, replace
  window manage close graph

  import delim using "`hapmap'.population", clear case(lower)
  merge 1:1 fid iid using bim2hapmap_combined_eigenvec.dta
  replace pop = "TEST" if pop == ""
  count if pop == "TEST"
  noi di as text"# > bim2hapmap ............. test individuals in analysis "as result"`r(N)'"  
  gen like = .
  foreach i in `like'  {
   replace like = 1 if pop =="`i'"
   }
  foreach i of num 1/3 {
   gen nr`i' = .
   sum pc`i' if (like == 1)
   gen min = r(mean) - 2*r(sd)
   gen max = r(mean) + 2*r(sd)
   foreach j in min max {
     sum `j'
     global pc`i'`j' `r(mean)'
     di" `j' bounds of pc`i' == ${pc`i'`j'}"
     drop `j'
     }
   replace nr`i' = 1 if  pc`i' < ${pc`i'max} & pc`i' > ${pc`i'min}
   }
  replace pop = "nr" if pop == "TEST" & nr1 == 1 & nr2 == 1 & nr3 == 1
  count if pop == "nr"
  noi di as text"# > bim2hapmap ...................... ancestry definition "as result "`like'"  
  noi di as text"# > bim2hapmap ....  individuals defined as like ancestry "as result`r(N)'  
  gen a = "`like'"
  replace  a = subinstr(a, " ", "_",.)
  replace  a = subinstr(a, " ", "_",.)
  replace  a = subinstr(a, " ", "_",.)
  replace  a = subinstr(a, " ", "_",.)
  replace a = "global like " + a
  outsheet a in 1 using _temp_.do, non noq replace
  do _temp_.do
  erase _temp_.do
  noi di as text"# > bim2hapmap ................................. saved to "as result"bim2hapmap_${like}-like.keep"
  outsheet fid iid if pop == "nr" using bim2hapmap_${like}-like.keep, non noq replace

  global format "msiz(large) msymbol(o) mlc(black) mlw(vvthin)"
  foreach i of num 1/3 { 
   foreach j of num 1/3 { 
    tw scatter pc`j' pc`i' if pop == "ASW" ,  $format $asw ///
    || scatter pc`j' pc`i' if pop == "LWK" ,  $format $lwk ///
    || scatter pc`j' pc`i' if pop == "MKK" ,  $format $mkk ///
    || scatter pc`j' pc`i' if pop == "YRI" ,  $format $yri ///
    || scatter pc`j' pc`i' if pop == "CEU" ,  $format $ceu ///
    || scatter pc`j' pc`i' if pop == "TSI" ,  $format $tsi ///
    || scatter pc`j' pc`i' if pop == "MEX" ,  $format $mex /// 
    || scatter pc`j' pc`i' if pop == "GIH" ,  $format $gih ///
    || scatter pc`j' pc`i' if pop == "CHB" ,  $format $chb ///
    || scatter pc`j' pc`i' if pop == "CHD" ,  $format $chd ///
    || scatter pc`j' pc`i' if pop == "JPT" ,  $format $jpt ///
    || scatter pc`j' pc`i' if pop == "TEST",  $format $test2 ///
    || scatter pc`j' pc`i' if pop == "nr", $format $test1 ///
      legend(off) saving(_cpc`j'pc`i'.gph, replace) ///
      yline(${pc`j'max}, lw(.1) lc(black) lp(solid)) ///
      yline(${pc`j'min}, lw(.1) lc(black) lp(solid)) ///
      xline(${pc`i'max}, lw(.1) lc(black) lp(solid)) ///
      xline(${pc`i'min}, lw(.1) lc(black) lp(solid)) nodraw
     }
    }
  graph combine _combined_eigenval-scree.gph  _cpc1pc2.gph _cpc1pc3.gph _cpc2pc3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
  noi di as text"# > bim2hapmap .......... graph (all ancestries) saved to "as result"bim2hapmap_pca.png"
  graph export  bim2hapmap_pca.png, height(2500) width(8000) replace
  window manage close graph
  
  foreach i of num 1/3{
   sum pc`i' if like == 1 
   drop if pc`i' > (r(mean) + 6*r(sd)) 
   drop if pc`i' < (r(mean) - 6*r(sd))
   }
  foreach i of num 1/3 { 
   foreach j of num 1/3 { 
    tw scatter pc`j' pc`i' if pop == "ASW" ,  $format $asw ///
    || scatter pc`j' pc`i' if pop == "LWK" ,  $format $lwk ///
    || scatter pc`j' pc`i' if pop == "MKK" ,  $format $mkk ///
    || scatter pc`j' pc`i' if pop == "YRI" ,  $format $yri ///
    || scatter pc`j' pc`i' if pop == "CEU" ,  $format $ceu ///
    || scatter pc`j' pc`i' if pop == "TSI" ,  $format $tsi ///
    || scatter pc`j' pc`i' if pop == "MEX" ,  $format $mex /// 
    || scatter pc`j' pc`i' if pop == "GIH" ,  $format $gih ///
    || scatter pc`j' pc`i' if pop == "CHB" ,  $format $chb ///
    || scatter pc`j' pc`i' if pop == "CHD" ,  $format $chd ///
    || scatter pc`j' pc`i' if pop == "JPT" ,  $format $jpt ///
    || scatter pc`j' pc`i' if pop == "TEST",  $format $test2 ///
    || scatter pc`j' pc`i' if pop == "nr", $format $test1 ///
      legend(off) saving(_cpc`j'pc`i'.gph, replace) ///
      yline(${pc`j'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
      yline(${pc`j'min}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
      xline(${pc`i'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
      xline(${pc`i'min}, lsty(refline) lw(.1) lc(black) lp(solid)) nodraw
     }
    }
  graph combine _combined_eigenval-scree.gph  _cpc1pc2.gph _cpc1pc3.gph _cpc2pc3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
  noi di as text"# > bim2hapmap ..... graph (selected ancestries) saved to "as result"bim2hapmap_pca-${like}-like.png"
  graph export  bim2hapmap_pca-${like}-like.png, height(2500) width(8000) replace
  window manage close graph
 } 
qui { // 5 - clean files
 foreach i of num 1/3 {
  foreach j of num 1/3 {
   erase _cpc`i'pc`j'.gph
   }
  }
 !del bim2hapmap_combined*
 !del bim2hapmap_hapmap*
 !del bim2hapmap_test*
 erase legend.gph
 erase overlap.extract
 }
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end; 
