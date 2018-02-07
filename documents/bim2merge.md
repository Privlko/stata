[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2merge
**description**
* command to identify / join multiple *.bim files (plink-format marker files) 

**syntax**
 ```bim2merge , bim(-filename1-,-filename2-,filenameN-)  ref_bim(-reference-) project(-project_name-) [join(-join-)]```

 * ```-filenames-``` 	does not require the .bim filetype to be included - this is assumed. where multiple -filenames- are included these must be comma delimited
 * ```-reference-```	does not require the .bim filetype to be included - this is assumed. this is the bim file that others are strand aligned to
 * ```-project_name-```	this is the name of the project
 * ```-join-```	this can be -yes- and initiates the merge protocol in plink


**notes** 
* this program was written to facilitate the merge of multiple plink binary files; the program includes quality control checks and limits to the overlapping SNPs
* the program includes; 
	* limit to autosome;
	* remove ambiguous markers (W/S);
	* remove incompatible markers;
	* strand flip;
	* limit to intercept over all markers and reference. 
* the resultant binaries are created and named with the tag ```-intercept```.

**installation**
```net install bim2merge ,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```





