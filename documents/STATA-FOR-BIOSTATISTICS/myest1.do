eststo clear
eststo: regress bweight gestwks matage
esttab 
pause
esttab *, se
pause 
esttab *, b(%6.2f) se 
pause
esttab *, b(%6.2f) se nocons
pause
esttab *, b(%6.2f) ci nocons nostar
pause 
esttab *, b(%6.2f) ci nocons wide nostar




