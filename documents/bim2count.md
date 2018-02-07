[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2count
**description**
* a command to count observations in a plink dataset

**syntax**

```bim2count, bim(-filename-)```

*  ```-filename-``` does not require the .bim filetype to be included - this is assumed

**notes** 
* requires the [```loadunixreplicas```](https://github.com/ricanney/stata/blob/master/documents/loadunixreplicas.md) to be loaded and working on your system, as it requires the ```wc.exe``` executable to be linked via ```${wc}```. 

**installation**

```net install bim2count,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```



