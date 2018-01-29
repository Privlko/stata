program get_stata_bundle
syntax

noi di as text"#########################################################################"
noi di as text"# > command to get stata packages from "as input"https://github.com/ricanney/stata"
noi di as text"# > on first download this program runs an automatically install of the stata"
noi di as text"# > program bundle"
noi di as text"# > this can be reinstalled by running the command get_stata_bundle"
noi di as text"#########################################################################"
noi di as text" "

noi di as text"# > install packages from https://github.com/ricanney/stata"
net install _gwas2magma,            from(https://raw.github.com/ricanney/stata/master/code/_/) replace
net install _gwas2prePRS,           from(https://raw.github.com/ricanney/stata/master/code/_/) replace
net install _gwas2sumstat,          from(https://raw.github.com/ricanney/stata/master/code/_/) replace
net install _sub_genotypeqc_report, from(https://raw.github.com/ricanney/stata/master/code/_/) replace
net install bim2build,              from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2count,              from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2dta,                from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2eigenvec,           from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2frq,                from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2qcfrq,              from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2hapmap,             from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2ld_subset,          from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2ldexclude,          from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2merge,              from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2refid,              from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2unrelated,          from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install checkfile,              from(https://raw.github.com/ricanney/stata/master/code/c/) replace
net install checktabbed,            from(https://raw.github.com/ricanney/stata/master/code/c/) replace
net install create_temp_dir,        from(https://raw.github.com/ricanney/stata/master/code/c/) replace
net install datestamp,              from(https://raw.github.com/ricanney/stata/master/code/d/) replace
net install ensembl2symbol,         from(https://raw.github.com/ricanney/stata/master/code/e/) replace
net install fam2dta,                from(https://raw.github.com/ricanney/stata/master/code/f/) replace
net install genotypeqc,             from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphgene,              from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphmanhattan,         from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphplinkfrq,          from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphplinkhet,          from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphplinkhwe,          from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphplinkimiss,        from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphplinkkin0,         from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphplinklmiss,        from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install graphqq,                from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install gwas2prs,               from(https://raw.github.com/ricanney/stata/master/code/g/) replace
net install kin0filter,             from(https://raw.github.com/ricanney/stata/master/code/k/) replace
net install loadUnixReplicas,       from(https://raw.github.com/ricanney/stata/master/code/l/) replace
net install profilescore,           from(https://raw.github.com/ricanney/stata/master/code/p/) replace
net install recodegenotype,         from(https://raw.github.com/ricanney/stata/master/code/r/) replace
net install recodestrand,           from(https://raw.github.com/ricanney/stata/master/code/r/) replace
net install summary2gwas,           from(https://raw.github.com/ricanney/stata/master/code/s/) replace
net install symbol2ensembl,         from(https://raw.github.com/ricanney/stata/master/code/s/) replace

noi di as text"# > install external dependencies"
net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/) replace
net install dm88_1,      from(http://www.stata-journal.com/software/sj5-4/) replace
net install ralpha,      from(http://fmwww.bc.edu/RePEc/bocode/r) replace
net install filei,       from(http://fmwww.bc.edu/RePEc/bocode/f) replace
net install sxpose,      from(http://fmwww.bc.edu/RePEc/bocode/s) replace

noi di as text"# > installing and setting graphing schemes"
ssc install blindschemes, replace all
set scheme plotplainblind , permanently
end;


