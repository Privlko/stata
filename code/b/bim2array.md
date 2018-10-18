## bim2array

**description**

This function determines the overlap between the marker list present in a plink binary marker file ```*.bim``` and a set of reference datasets based on known arrays.

**syntax**

```bim2array, bim(-filename-) dir(-folder-)```
 
 * ```-filename-``` does not require the .bim filetype to be included - this is assumed
 * ```-folder-``` this refers to a folder containing the reference arrays 

** reference arrays **

The reference arrays were derived from data available at http://www.well.ox.ac.uk/~wrayner/strand/

Additional arrays including Perlegen were curated locally or from dbGAP builds. All downloads were limited to the b37 version of strand files.

The working code to convert strand to _array_.dta is available locally in ```/home/mdnra/github/packages/bim2array/code```
The reference arrays are available to MRC CNGG users of ROCKS in ```/neurocluster/databank/3-packages/bim2array/data/original```
For non- MRC CNGG users please contact AnneyR@cardiff.ac.uk for additional information.

**installation**

```net install bim2array,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace```
