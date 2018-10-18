## bim2array

**description**

This function determines the overlap of markers within a plink binary ```*.bim``` file with a set of reference datasets. This can be used to predict the most likley array that was used to genotype the study.

**syntax**

```bim2array, bim(-filename-) dir(-folder-)```
 
 * ```-filename-``` does not require the .bim filetype to be included - this is assumed
 * ```-folder-``` this refers to a folder containing the reference arrays - an archive of formatted arrays
 
**creating the reference folder**

under construction

https://github.com/ricanney/stata/blog/how-to-create-bim2array-reference.md 

The working code to create the reference array files can be found in the rocks home directory ```/packages/bim2array/code/```.
This code has been adapted to report arrays using 3x marker identifiers
* _"as is"_
* _"as rsid"_ 
* _"as loc_name"_

For MRC CNGG users the local folder to implement bim2array is ```/databank/3-packages/bim2array/data/original/```
For non- MRC CNGG users please contact AnneyR@cardiff.ac.uk for more details

**installation**

```net install bim2array,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```
