[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)


## graphmanhattan

**description**
* a command to create a publication quality manhattan plot from gwas 

**syntax**

```graphmanhattan , chr(-chr-) bp(-bp-) p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]```
 
* ```-chr-``` the varname containing the numeric chromosome data
* ```-bp-``` the varname containing the numeric base-pair position data
* ```-p-```	the varname containing p-value
* ```-max- ``` the maximum observed -log10 p-values to plot (all others limited to `max'; default = 10)
* ```-min- ``` the minimum observed -log10 p-values to plot (default = 2)
* ```-gws- ``` the -log10 p-value corresponding to genome-wide significance (default = 7.3)
* ```-str- ``` the -log10 p-value corresponding to "strong" significance (default = 6)


**notes**

![](../images/tmpManhattan.png)

**installation**

```net install graphmanhattan, from(https://raw.github.com/ricanney/stata/master/code/g/) replace```

**dependencies**

```net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)```

