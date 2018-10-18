eststo clear
eststo: regress bweight gestwks matage
esttab est1 using myfile.rtf, b(%6.2f) se replace
eststo: logit lowbw gestwks matage
esttab est2 using myfile.rtf, b(%6.2f) se eform append
