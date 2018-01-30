* [packages](#packages)
* [routines](#routines)

# packages
* [```colorbrewer```](#colorbrewer)
* [```discard```](#discard)
* [```encode```](#encode)
* [```inlist```](#inlist) 

# colorbrewer
how to install colorbrewer
from https://github.com/matthieugomez/stata-colorscheme
1. download archive from github 
2. unpack archive
3. then run the following commands;
```
cap ado uninstall colorscheme                         
net install colorscheme, from("folder\stata-colorscheme-master")         
```

# discard
command to discard all ado files from memory
```
discard
```
# encode  
convert strvar to numvar

```
encode
```
or
```
gen  ORDER1 = _n 							
egen ORDER2 = min(ORDER1), by(name) 					
egen ORDER3 = group(ORDER2) 						
labmask order, values(name)
```

# inlist
generate newvar from outcomes of oldvar 

```
gen asean4 = 1 if countryname == “Indonesia” | countryname == “Malaysia” | countryname == “Philippines” | countryname == “Thailand”
gen asean4 = 1 if inlist(countryname, “Indonesia”, “Malaysia”, “Philippines”, “Thailand”)''
gen asean4 = 1 if inlist(countrycode, 360, 458, 608, 764)''

The difference between using numeric and string values is in the number of allowable elements in the list. For numeric values, 254 elements are allowed and for string values, only 9. 
```

# routines
* [add-a-leading-zero-to-number](#add-a-leading-zero-to-number)
* [create-a-blank-graph](#create-a-blank-graph)
* [create-newvar-based-on-line-number](#create-newvar-based-on-line-number)
* [create-newvar-foreach-observations-in-oldvar](#create-newvar-foreach-observations-in-oldvar)
* [create-newvar-listing-nth-observations-in-oldvar](#create-newvar-listing-nth-observations-in-oldvar)
* [create-newvar-odds_ratio-based-on-oldvar-or-l95-u95](#create-newvar-odds_ratio-based-on-oldvar-or-l95-u95)
* [fill-missing-if-previous-observation-is-present](#fill-missing-if-previous-observation-is-present)

# display macro with formatting
```
noi di as text"# > "as input"bim2array "as text" calculating ........ jaccard index = " as result trim("`: display %5.4f r(min)'") as text " for array : " as result "${bim2array`num'}"
```

# create-newvar-based-on-line-number
```
gen  newvar = _n 							
```

# create-newvar-odds_ratio-based-on-oldvar-or-l95-u95
```
keep or l95 u95
gen str4 x= string(or,"%03.2f")						
gen str4 y= string(l95,"%03.2f")					
gen str4 z= string(u95,"%03.2f")			
gen odds_ratio = x + " (" + y + "-" + z + ")"
```

# create-newvar-foreach-observations-in-oldvar
creates a new variable 0/1 for each observation 
```
sysuse auto, clear
tab oldvar, gen(newvar)
```

# create-newvar-listing-nth-observations-in-oldvar
```
egen newvar = seq(), by(oldvar)	
```

#  create-a-blank-graph
```
twoway scatteri 1 1,            ///
msymbol(i)                      ///
ylab("") xlab("")               ///
ytitle("") xtitle("")           ///
yscale(off) xscale(off)         ///
plotregion(lpattern(blank))     ///
name(blank, replace)
```

# add-a-leading-zero-to-number
```
gen str4 stringvar =    string(numvar, "%04.0f")
gen      stringvar = strofreal(numvar, "%04.0f")
```

# fill-missing-if-previous-observation-is-present
```
replace var = var[_n-1] if var == ""
```

# rename files and folders
```
global root "folder"
cd $root
*rename files (lower-case & underscore to -)
clear
set obs 1
gen old_names = ""
save tempfile.dta,replace
local myfiles: dir "${root}" files "*" 
foreach file of local myfiles { 
 clear
 set obs 1
 gen old_names = "`file'" 
 append using tempfile.dta
 save tempfile.dta,replace
 } 
gen     new_names = strlower(old_names)
replace new_names = subinstr(new_names, "_", "-",.) 
gen a = "rename " + old_names + " " + new_names
outsheet a using tempfile.bat, non noq replace
!tempfile.bat
!del tempfile.*
*rename folders (lower-case & underscore to -)
clear
set obs 1
gen old_names = ""
save tempfolder.dta,replace
local myfolders: dir "${root}" dirs "*" 
foreach folder of local myfolders { 
 clear
 set obs 1
 gen old_names = "`folder'" 
 append using tempfolder.dta
 save tempfolder.dta,replace
} 
gen new_names = strlower(old_names)
replace new_names = subinstr(new_names, "_", "-",.) 
gen a = "rename " + old_names + " " + new_names
outsheet a using tempfolder.bat, non noq replace
!tempfolder.bat
!del tempfolder.*
```

# listing contents of a folder
```
global root "<define-folder-location>"		
cd    $root								
clear									
set obs 1								
gen filename = ""							
save tmp.dta,replace							
local myfiles: dir "$root" files "*" 					
foreach file of local myfiles { 					
 clear								
 set obs 1							
 gen filename = "`file'" 					
 append using tmp.dta						
 save tmp.dta,replace						
 }
```

# inrange
replace var1 based on numeric range data in var2
```
generate newvar = 1 if inrange(oldvar,  4000,4099)
replace  oldvar = 1 if inrange(oldvar2, 4000,4099)
```

# length
create newvar based on length of an oldvar
```
generate newvar = length(oldvar)
```

# subinstr
replacing string in var1 based on input from var2
```
generate newvar = subinstr(oldvar, "-OLDCHAR-", "-NEWCHAR",.)
replace  oldvar = subinstr(oldvar, "-OLDCHAR-", "-NEWCHAR",.)
```

# substr
create variable by cropping 
```
generate newvar = substr(oldvar,1,2)	// example: create a variable containing 2 digits from point 1
```
