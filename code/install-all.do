net install _sub_genotypeqc_meta,   from(https://raw.github.com/ricanney/stata/master/code/_/) replace
net install _sub_genotypeqc_report, from(https://raw.github.com/ricanney/stata/master/code/_/) replace
net install bim2dta,                from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2eigenvec,           from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2frq     ,           from(https://raw.github.com/ricanney/stata/master/code/b/) replace
net install bim2ldexclude,          from(https://raw.github.com/ricanney/stata/master/code/b/) replace
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
net install loadUnixReplicas,       from(https://raw.github.com/ricanney/stata/master/code/l/) replace
net install profilescore,           from(https://raw.github.com/ricanney/stata/master/code/p/) replace
net install recodegenotype,         from(https://raw.github.com/ricanney/stata/master/code/r/) replace
net install recodestrand,           from(https://raw.github.com/ricanney/stata/master/code/r/) replace
net install symbol2ensembl,         from(https://raw.github.com/ricanney/stata/master/code/s/) replace

* external dependencies
net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/) replace
net install dm88_1.pkg,  from(http://www.stata-journal.com/software/sj5-4/) replace

* set graph to colorblind - this is cosmetic for the graphing elements of the report
ssc install blindschemes, replace all
set scheme plotplainblind , permanently
net install ralpha, from(http://fmwww.bc.edu/RePEc/bocode/r) replace
net install filei, from(http://fmwww.bc.edu/RePEc/bocode/f) replace


