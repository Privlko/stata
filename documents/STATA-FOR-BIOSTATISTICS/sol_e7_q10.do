    foreach var of varlist matage gestwks bweight {
.           summarize `var'
.           generate log`var'=log(`var') 
.           summarize log`var'
.     }
