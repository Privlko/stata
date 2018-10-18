# Title
![loadUnixReplicas](https://github.com/ricanney/stata/blob/master/code/l/loadUnixReplicas.ado) - a program that scans the ```init_unix``` folder for executables and creates a global link to the executable. 
# Installation
```net install loadUnixReplicas                from(https://raw.github.com/ricanney/stata/master/code/l/) replace```
# Syntax
```loadUnixReplicas , folder(<folder_path>)  ```
# Description
This program scans the ```init_unix``` folder for executables and creates a global link to the executable. 

# Examples
```
*download the windows executables to local folder e.g. D:\software\bash\bin
global init_unix  "D:\Software\bash\bin"
loadUnixReplicas , folder(${init_unix})                                        // set global for unix replicas from init_unix folder
* you are now able to run available unix commands from windows stata e.g. gunzip / gzip etc
* examples
!${gunzip} filename.txt.gz
!${gzip}   filename.txt
```

# Dependencies
| Program | Installation Command
| :----- | :------
|```archived executable bundle``` | https://db.tt/FBoh2fPUrK

# Alternatives
Windows 10 includes an underlying “Windows Subsystem for Linux” to run Linux applications.  If you are using windows 10 there is an option to run a linux bash shell that runs directly from command-line. 

This can be installed / activated as described in this blog https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/ . This can be accessed via the bash shell; however, using the ```bash -c``` you can run Linux applications without first launching a Bash window. 

Commands are then called by running the following

```
bash -c "command"
```

Note that this required the command to be contained within quotation marks. Therefore, to run in STATA you would write

```
!bash -c "command"
```

## tips from stack overflow
If you need literal quotes within the command you can backslash escape them

```
$ echo "Here is a \"quoted string\""
Here is a "quoted string"
```

However if you are trying to prevent word splitting of the variable, the outer quotes are usually sufficient I think

```
$ var="quoted string"; echo "Here is a $var"
Here is a quoted string
```
