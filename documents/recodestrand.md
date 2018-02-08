[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## recodestrand

**description** 
* a command to define the markers to flip when compared to reference genotypes

**syntax**

```recodestrand , ref_a1(-allele1_reference-) ref_a2(-allele2_reference-) alt_a1(-allele1_test-) alt_a2(-allele2_test-) ```
 
* ```-ref_a1-```  the varname containing allele 1 of the reference genotypes
* ```-ref_a2-```  the varname containing allele 2 of the reference genotypes
* ```-alt_a1-```  the varname containing allele 1 of the test genotypes
* ```-alt_a2-```  the varname containing allele 2 of the test genotypes

**notes**
* this package creates a ```_tmpflip``` variable and new allele coding ```_tmpb1``` and ```_tmpb2``` for the test alleles to allow recoding and flipping via ```plink```.

**installation**

```net install recodestrand , from(https://raw.github.com/ricanney/stata/master/code/r/) replace```


