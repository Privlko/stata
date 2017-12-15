/*
#########################################################################
# graphplinkkin0
# a command to plot distribution from *imiss plink file
#
# command: graphplinkkin0, kin0(input-file) 
# options: 
#          d(num) ..... threshold for duplicates
#          f(num) ..... threshold for first degree relatives
#          s(num) ..... threshold for second degree relatives
#          t(num) ..... threshold for third degree relatives
#
# dependencies: 
# tabbed.pl must be set to be called via ${tabbed}
#
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 10th September 2015
#########################################################################
*/

program graphplinkkin0
syntax , kin0(string asis) [d(real 0.3540) f(real 0.1770) s(real 0.0884) t(real 0.0442)]

qui di as text"#########################################################################"
qui di as text"# graphplinkkin0                                                         "
qui di as text"# version:       1a                                                      "
qui di as text"# Creation Date: 21April2017                                             "
qui di as text"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
qui di as text"#########################################################################"
qui di as text"# This is a script to plot the output from the  --make-king-table routine"
qui di as text"# in plink2.                                                             " 
qui di as text"# The input data comes in standard format from the kin0 output.          "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Dependencies : tabbed.pl via ${tabbed}                                 "
qui di as text"# -----------------------------------------------------------------------"
qui di as text"# Syntax : graphplinkkin0, kin0(filename)                                "
qui di as text"# for filename, .kin0 is not needed                                      "
qui di as text"#                                                                        "
qui di as text"# We are assuming relationships/ kinship scores are as follows;          "
qui di as text"#    3rd-degree if kinship > `t'"
qui di as text"#    2nd-degree if kinship > `s'"
qui di as text"#    1st-degree if kinship > `f'"
qui di as text"#    duplicate  if kinship > `d'"
qui di as text"#  WARNING : this may not be the case for non-standard arrays e.g. psychchip/ immunochip"
qui di as text"#########################################################################"

noi di as text"# > "as input"graphplinkkin0 "as text"...................................... "as result"`kin0'.kin0"
noi checkfile, file(`kin0'.kin0)
noi checktabbed 

qui di as text"# > processing `kin0'.kin0"
qui { 
	import delim using `kin0'.kin0, clear case(lower)
	count
	if `r(N)' > 0 {
		qui di as text"# > non-zero individuals with kinship co-efficients imported - plotting ibs0 by kinship to tmpKIN0_1.gph"
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
		qui di as text"# > non-zero individuals with kinship co-efficients imported - plotting kinship histogram to tmpKIN0_2.gph"
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
		qui di as text"# > exporting related pairs to tmpKIN0.relPairs"
		outsheet if rel != "" using tmpKIN0.relPairs, noq replace 
		}
	else {
		qui di as text"# > zero individuals with kinship co-efficients imported - generating blank plot to tmpKIN0_1.gph and tmpKIN0_2.gph"
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
qui di as text"#########################################################################"
qui di as text"# Completed: $S_DATE $S_TIME"
qui di as text"#########################################################################"
end;
	
