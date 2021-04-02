
# SPACK install guide.

Spack is a package manager for supercomputers. Unlike other package managers Spack does not use binaries.
Spack can be used to download and resolve software dependancies using raw source code. For a HPC environment,
this can in theory speed up the computing speed. 

## Pre-requistives to running spack

Documentation: Docs: https://spack.readthedocs.io/en/latest/

Base libraries: Centos7 

https://linuxize.com/post/how-to-install-gcc-compiler-on-centos-7/

```
yum install gcc-c++ libstdc++ -y
yum  install openmpi
yum groupinstall "Development Tools" "Development Libraries" -y
yum install gcc-objc++
yum compat-gcc-44-c++.x86_64
yum install haxe-stdlib
yum install libstdc++-static
compat-libstdc++-33

```



## using gcc7

```
yum install devtoolset-7
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install gcc* #gets everything.
yum install git
```

## Enable the newer gcc7 compiler

```
scl enable devtoolset-7 bash
```
source: https://linuxize.com/post/how-to-install-gcc-compiler-on-centos-7/


# How to use spack

## 1. get the git repo


```
cd /opt
git clone https://github.com/spack/spack.git
```

## 2. setup the environment with 'source'

```
cd /opt
source ./spack/share/spack/setup-env.sh
```

## 3. start installing.

```
spack install zlib
```

# Good [English] sources of info:

## Youtube:

https://www.youtube.com/watch?v=Qok-nXfIWfg

https://www.youtube.com/watch?v=edpgwyOD79E


# Other good sources of info

A Scientist's Guide to Cloud-HPC: example with AWS parallelcluster, slurm, spack and WRF. 
https://jiaweizhuang.github.io/blog/aws-hpc-guide/

