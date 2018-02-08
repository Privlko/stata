[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## graphqq
**description**
* command to create a publication quality qq-plots from gwas summary data

**syntax**

```graphqq , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6) version(real 13.1)]```
 
 * ```-p-```   	the varname containing p-value
 * ```-max-``` 	the maximum observed -log10 p-values to plot (all others limited to `max'; default = 10)
 * ```-min-``` 	the minimum observed -log10 p-values to plot (default = 2)
 * ```-gws-```  the -log10 p-value corresponding to genome-wide significance (default = 7.3)
 * ```-str-```  the -log10 p-value corresponding to "strong" significance (default = 6)
 *  ```-version-``` the version parameter is needed if your stata version is > ```14.1```; in this instance the underlying ```cci``` syntax is altered and needs to be modified (default = 13.1)

**notes**

![](../images/tmpQQ.png)


**installation**

```net install graphqq, from(https://raw.github.com/ricanney/stata/master/code/g/) replace```

**dependencies**

```net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)```


