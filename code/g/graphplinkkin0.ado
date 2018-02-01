/*
*program*
 graphplinkkin0

*description* 
 command to plot distribution from *kin0 plink2 file

*syntax*
 graphplinkkin0, kin0(-filename-) [d(-d-) f(-f-) s(-s-) t(-t-) ]
 graphplinklmiss, lmiss(-filename-) [geno(-geno-)]
 
 -filename- the name of the kin0 file *.kin0 not required
 -d-        the kinship threshold for duplicates (default = 0.3540)
 -f-        the kinship threshold for first degree relatives (default = 0.1770)
 -s-        the kinship threshold for second degree relatives (default = 0.0884)
 -t-        the kinship threshold for third degree relatives (default = 0.0442)
*/


program graphplinkkin0
syntax , kin0(string asis) [d(real 0.3540) f(real 0.1770) s(real 0.0884) t(real 0.0442)]
noi di as text" "
noi di as text"#########################################################################"
noi di as text"# graphplinkkin0"
noi di as text"#########################################################################"
noi di as text"# Started: $S_DATE $S_TIME"
noi di as text"#########################################################################"
qui { // 1 - introduction
	noi di as text"# > graphplinkkin0 ............................ importing "as result"`kin0'.kin0"
	noi checkfile, file(`kin0'.kin0)
	noi checkfile, file(${plink2})
	checktabbed
	}
qui { // 2 - processing `kin0'.kin0
	import delim using `kin0'.kin0, clear case(lower)
	count
	if `r(N)' > 0 {
		qui di as text"# > non-zero individuals with kinship co-efficients imported - plotting ibs0 by kinship to tmpKIN0_1.gph"
		noi di as text"# > graphplinkkin0 ......... (ibs x kin) plotting data to "as result "tmpKIN0_1.gph"
		for var fid1-id2      : tostring X, replace 
		for var hethet-kinship: destring X, replace force
		replace kin = 0 if kin <0
		global format "msiz(medlarge) msymbol(O) mfc(red) mlc(black) mlabsize(small) mlw(vvthin)"
		global xlabel "0(0.1).5"
		qui { 
			tw scatter ibs kin, $format       ///
				 title("Between-Family Relationships") ///
				 ytitle("Proportion of Zero IBS") ///
				 xlabel($xlabel)          ///
				 xtitle("Estimated Kinship Coefficient") ///
				 xline(0.354, lpattern(dash) lwidth(vthin) lcolor(red))  ///
				 xline(0.177, lpattern(dash) lwidth(vthin) lcolor(red))  ///
				 xline(0.0884, lpattern(dash) lwidth(vthin) lcolor(red)) ///
				 xline(0.0442, lpattern(dash) lwidth(vthin) lcolor(red)) ///
				 nodraw saving(tmpKIN0_1.gph, replace)
			 }
		gen rel = ""
		replace rel = "3rd" if kinship > `t'
		replace rel = "2nd" if kinship > `s'
		replace rel = "1st" if kinship > `f'
		replace rel = "dup" if kinship > `d'
		replace rel = ""    if kinship == .
		foreach rel in dup 1st 2nd 3rd { 
			count if rel == "`rel'"
			global rel`rel' "`r(N)'"
			}
		noi di as text"# > graphplinkkin0 .......... (kin hist) plotting data to "as result "tmpKIN0_2.gph"
		qui { 
			tw hist kinship , width(0.005) freq                          ///
				 xline(0.3540, lpattern(dash) lwidth(vthin) lcolor(red)) ///
				 xline(0.1707, lpattern(dash) lwidth(vthin) lcolor(red)) ///
				 xline(0.0884, lpattern(dash) lwidth(vthin) lcolor(red)) ///
				 xline(0.0442, lpattern(dash) lwidth(vthin) lcolor(red)) ///
				 xlabel($xlabel) legend(off)                             ///
				 caption("Twin/Duplicate Pairs; N = ${reldup}"           ///
								 "1st Degree Relative Pairs ; N = ${rel1st}"     ///
								 "2nd Degree Relative Pairs ; N = ${rel2nd}"     ///
								 "3rd Degree Relative Pairs ; N = ${rel3rd}") nodraw saving(tmpKIN0_2.gph, replace)
				}
		noi di as text"# > graphplinkkin0 ........................... duplicates "as result "${reldup}"
		noi di as text"# > graphplinkkin0 ............... first degree relatives "as result "${rel1st}"
		noi di as text"# > graphplinkkin0 .............. second degree relatives "as result "${rel2nd}"
		noi di as text"# > graphplinkkin0 ............... third degree relatives "as result "${rel3rd}"
		noi di as text"# > graphplinkkin0 ........... exporting related pairs to "as result "tmpKIN0.relPairs"
		outsheet if rel != "" using tmpKIN0.relPairs, noq replace 
		}
	else {
		noi di as text"# > graphplinkkin0 ....... nothing to plot (create blank) "as result "tmpKIN0_1.gph"
		noi di as text"# > graphplinkkin0 ....... nothing to plot (create blank) "as result "tmpKIN0_2.gph"
		twoway scatteri 1 1,            ///
		msymbol(i)                      ///
		ylab("") xlab("")               ///
		yscale(off) xscale(off)         ///
		plotregion(lpattern(blank))     ///
		nodraw saving(tmpKIN0_1.gph, replace)
		twoway scatteri 1 1,            ///
		msymbol(i)                      ///
		ylab("") xlab("")               ///
		yscale(off) xscale(off)         ///
		plotregion(lpattern(blank))     ///
		nodraw saving(tmpKIN0_2.gph, replace)
		}
	}
noi di as text"#########################################################################"
noi di as text"# Completed: $S_DATE $S_TIME"
noi di as text"#########################################################################"
end;
	
