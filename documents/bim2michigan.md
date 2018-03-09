[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2michigan
**description**
* converts plink binaries to vcf for upload to michigan imputation server. the program bundles into archive for processing on ```ROCKS``` using ```bgzip```.

**syntax**

 ```bim2michigan , bim(-filename1-)  ref(-reference-) ```

 * ```-filenames-``` 	does not require the .bim filetype to be included - this is assumed. where multiple -filenames- are included these must be comma delimited
 * ```-reference-```	this is the ```all-hrc-1.1-chrall-mac5_bim.dta``` 

**notes** 

* the resultant \*.tar.gz bundle should be transferred to rocks to convert to bgzip 

```tar -zxvf ${bim2michigan_out}.tar.gz```
```bash bim2michigan.sh```

* the resulting *.vcf.gz files are now ready to submit to the michigan imputation server at ```https://imputationserver.sph.umich.edu```
* as part of the imputation routine the following parameters are used 
	* unphased
	* hrc.r1.1.2016
	* shapeit



**installation**

```net install bim2michigan ,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```





