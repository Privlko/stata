[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## graphplinkkin0
**description**
* command to plot distribution from *kin0 plink2 file

**syntax**
 
```graphplinkkin0, kin0(-filename-) [d(-d-) f(-f-) s(-s-) t(-t-) ]```
 
* ```-filename-``` the name of the kin0 file *.kin0 not required
* ``` -d-  ```      the kinship threshold for duplicates (default = 0.3540)
* ``` -f- ```       the kinship threshold for first degree relatives (default = 0.1770)
* ``` -s-  ```      the kinship threshold for second degree relatives (default = 0.0884)
* ``` -t-  ```      the kinship threshold for third degree relatives (default = 0.0442)

**notes**

![](../images/tmpKIN0_1.png)
![](../images/tmpKIN0_2.png)


**installation**

```net install graphplinkkin0, from(https://raw.github.com/ricanney/stata/master/code/g/) replace```




