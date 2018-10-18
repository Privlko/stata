eststo clear
eststo: regress bweight gestwks matage
eststo: regress bweight gestwks
esttab, b(%6.2f) se 
pause
esttab, b(%6.2f) se nodepvar
pause 
esttab, b(%6.2f) se nodepvar mtitles("All" "Excl matage")
pause
esttab, b(%6.2f) se nodepvar mtitles("All" "Excl matage") wide
