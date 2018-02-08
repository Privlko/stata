[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2build
**description**
* a command to check genome build from plink binaries

**syntax**

```bim2build, bim(-filename-) ref(-reference-)```
 
 * ```-filename-``` does not require the .bim filetype to be included - this is assumed
 * ```-reference-``` this refers to a reference file containing the snp/build, ```bim2build.dta``` can be downloaded from ```github.com/ricanney```

**installation**

```net install bim2build,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```