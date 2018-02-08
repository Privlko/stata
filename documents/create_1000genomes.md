[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## create_temp_dir
**description** 
* create the ```eur-1000g-phase3-chrall-mac5``` plink binaries and reference datasets.  

**notes**
* many of the genomics based applications / packages require a genome reference dataset. for example, to compare allele frequencies in arrays.  for the purposes of our analyses we use the 1000 genomes phase 3 data. depending on the source population we split the full dataset by *super population* - most often using the ```eur-1000g-phase3-chrall-mac5``` european subset.

* to obtain a copy of the reference data you can either;
 - download the plink binaries from [```link-not-active```](```link not active```)
 - access the reference data from the cardiff rocks databank [```local users only```]()
 - build your own 

* below is a tutorial as to how to build your own plink-ready 1000 genome reference using ```Stata```
* note that one of the key components of a *reference* is the ability to map - for some purposes this means limiting the data to non ambiguous genotypes only  i.e. removing ID A C G T W and S - if this is what you need, run ```create_1000genomes_RYKM```.

**syntax**
* download the \*.vcf.gz files for chr1-22 and chrX  from [ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/*](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/*). this can be done manually of via wget, for example;

```
global ftp ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/
foreach i of num 1/22 {
  !bash -c "wget ${ftp}ALL.chr`i'.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz"
  }
!bash -c "wget ${ftp}ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz"
!bash -c "wget ${ftp}integrated_call_samples_v3.20130502.ALL.panel"
```

* once the code has been downloaded you can run the command 

```create_1000genomes ```

or

```create_1000genomes_RYKM ```

**installation**

```net install create_1000genomes,         from(https://raw.github.com/ricanney/stata/master/code/c/) replace```
```net install create_1000genomes_RYKM,         from(https://raw.github.com/ricanney/stata/master/code/c/) replace```

