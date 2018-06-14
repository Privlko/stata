program get_stata_bundle
syntax

noi di as text"#########################################################################"
noi di as text"# > get stata bundle .................................... " as result "installing packages from https://github.com/ricanney/stata"
noi di as text"#########################################################################"
noi di as text" "

foreach b in bim2array bim2build bim2count bim2cryptic bim2dta bim2eigenvec bim2frq bim2frq_compare bim2hapmap bim2ld_subset bim2ldexclude bim2merge bim2michigan bim2refid bim2unrelated {
	net install `b' ,  from(https://raw.github.com/ricanney/stata/master/code/b/) replace
	}
foreach c in checkfile checkfolder checkloc_name checktabbed colorscheme create_1000genomes create_1000genomes_RYKM create_temp_dir {
	net install `c',              from(https://raw.github.com/ricanney/stata/master/code/c/) replace
	}
foreach d in datestamp dir2dta {
	net install `d',              from(https://raw.github.com/ricanney/stata/master/code/d/) replace
	}
foreach f in fam2dta files2dta {
	net install `f',              from(https://raw.github.com/ricanney/stata/master/code/f/) replace
	}
foreach g in genotypeqc genotypeqc_parameter genotypeqc_setarray graphgene graphlocus graphmanhattan graphmiami graphplinkfrq graphplinkhet graphplinkhwe graphplinkimiss graphplinkkin0 graphplinklmiss graphqq {
	net install `g',              from(https://raw.github.com/ricanney/stata/master/code/g/) replace
	}
foreach k in kin0filter {
	net install `k',              from(https://raw.github.com/ricanney/stata/master/code/k/) replace
	}
foreach l in loadunixreplicas {
	net install `l',              from(https://raw.github.com/ricanney/stata/master/code/l/) replace
	}
foreach m in mapfrq {
	net install `m',              from(https://raw.github.com/ricanney/stata/master/code/m/) replace
	}
foreach p in profilescore_beta {
	net install `p',              from(https://raw.github.com/ricanney/stata/master/code/p/) replace
	}
foreach r in recodegenotype recodestrand {
	net install `r',              from(https://raw.github.com/ricanney/stata/master/code/r/) replace
	}
foreach s in snp2build snp2refbuild snp2refid summaryqc summaryqc2prePRS summaryqc2sumstats sumstats2h2 sumstats2rg {
	net install `s',              from(https://raw.github.com/ricanney/stata/master/code/s/) replace
	}

noi di as text"# > install external dependencies"
net install dm88_1,      from(http://www.stata-journal.com/software/sj5-4/) replace
net install ralpha,      from(http://fmwww.bc.edu/RePEc/bocode/r) replace
net install filei,       from(http://fmwww.bc.edu/RePEc/bocode/f) replace
net install sxpose,      from(http://fmwww.bc.edu/RePEc/bocode/s) replace

end;


