[back to opening page](https://github.com/ricanney/stata)

[back to packages](https://github.com/ricanney/stata/blob/master/documents/packages.md)

## bim2merge
**description** - merge multiple plink binary files (with quality control and limit to overlap). the program includes; limit to autosome; remove ambiguous markers (W/S); remove incompatible markers; strand flip and limit to intercept over all markers and reference. the resultant binaries are created and named with the tag ```-intercept```.

**remarks** 

**examples** - list comma-seperate binaries in bim(). add the reference binary to ref_bim() - this binary will be used to define strand. add a project-name in project() - the log file will be named using this name. if the join(yes) flag is included - the files in the bim() command will be merged into a new plink binary <project>.bim <project>.bed <project>.fam

```
bim2merge , bim(file1,file2,file3) ref_bim(file4) project(project_name) [join(yes)]
```
**installation**

```
net install bim2merge ,         from(https://raw.github.com/ricanney/stata/master/code/b/) replace
```

**auxiliary files**

**dependencies**
[```checkfile```](https://github.com/ricanney/stata/blob/master/documents/checkfile.md)
[```bim2ldexclude```](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md)




