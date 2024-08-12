
# Simple Re-install/Reconfiguration of Spack and install the Intel compiler 

This document provides a step-by-step guide to re-install and reconfigure Spack, assuming an existing but outdated version of Spack is present.

## Uninstall Everything

To uninstall all packages, use the following command:

```bash
spack uninstall --all
```

# Configure Spack to Use Externals
Set the Spack system configuration path and find external packages:

```bash
export SPACK_SYSTEM_CONFIG_PATH=$SPACK_ROOT/etc/spack
spack external find --scope site --exclude cmake
spack external find --scope site texlive 
spack external find --scope site perl 
spack external find --scope site python 
spack external find --scope site libfabric 
spack external find --scope site slurm 
```

# Optional: Configure Spack to Use Temporary Directories

Modify the configuration to use temporary directories for builds and caches:

```text
config:
  install_tree: $spack/opt/spack
  build_stage:
    - $tempdir/$user/spack-stage
    - ~/.spack/stage
  build_jobs: 48
  build_stage: /tmp/spack-stack/cache/build_stage
  test_stage: /tmp/spack-stack/cache/test_stage
  source_cache: /tmp/spack-stack/cache/source_cache
  misc_cache: /tmp/spack-stack/cache/misc_cache
```



# Add Initial Compiler to Spack  

```bash
spack compiler list
spack compiler find --scope site 
```

#  Compile the Base GCC Compiler

Install the GCC compiler:

```bash
spack install -j8 gcc@9.2.0+binutils cflags="-O3"
```

# Register the New Compiler
Add the new GCC compiler to Spack:

```bash 
spack compiler add --scope site $(spack location -i gcc@9.2.0)
```

# Install the Latest Intel Compiler
Install Intel OneAPI compilers:

```bash
spack install -j8 intel-oneapi-compilers@2022.1.0%gcc@9.2.0 cflags="-O3"
```

# Register the Intel Compiler
Remove the old Intel compiler and add the new one:


```bash 
spack compiler rm intel@2021.6.0
spack compiler add --scope site $(spack location -i intel-oneapi-compilers)/compiler/latest/linux/bin/intel64
```

# Verify Compiler Information
Check the compiler paths and versions:

```bash
spack compiler info intel
```

Example output. 

```bash
 spack compiler info intel
intel@2021.6.0: 
        paths:
                cc = /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-q7cww3c3t7kladvhpkanmrdzeywrfmlk/compiler/latest/linux/bin/intel64/icc
                cxx = /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-q7cww3c3t7kladvhpkanmrdzeywrfmlk/compiler/latest/linux/bin/intel64/icpc
                f77 = /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-q7cww3c3t7kladvhpkanmrdzeywrfmlk/compiler/latest/linux/bin/intel64/ifort
                fc = /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-q7cww3c3t7kladvhpkanmrdzeywrfmlk/compiler/latest/linux/bin/intel64/ifort
        modules  = []
        operating system  = rocky8
```

# Get the Path to the Intel64_lin Area
List the installation path:

```bash
ls $(spack location -i intel-oneapi-compilers@2022.1.0)
```

# Modify the Site Compiler.yaml 
Update the compiler.yaml to configure environment variables:

```text
    environment:
      prepend_path:
        LD_LIBRARY_PATH: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-q7cww3c3t7kladvhpkanmrdzeywrfmlk/compiler/2022.1.0/linux/compiler/lib/intel64_lin
      set:
        I_MPI_PMI_LIBRARY: /opt/slurm/lib/libpmi.so
```


# Add Secondary Libraries
Install additional libraries:

```bash
spack install -j8 --reuse netcdf-fortran@4.6.0%intel@2021.6.0 ^hdf5+fortran+hl%intel@2021.6.0 ^netcdf-c@4.9.0%intel@2021.6.0 ^hdf5@1.12.2%intel@2021.6.0 ^intel-oneapi-mpi@2021.9.0%in
tel@2021.6.0+external-libfabric cflags="-O3,-shared,-static"
```

# Verify Intel OneAPI MPI Compilation
Check dependencies:

```bash
 spack dependencies --installed intel-oneapi-mpi
```

Example output.
```text
==> Dependencies of intel-oneapi-mpi@2021.9.0%intel@=2021.6.0/rmok342
-- linux-rocky8-haswell / intel@2021.6.0 ------------------------
ys4i3ss glibc@2.28  7hg3o3x libfabric@1.21.0
```

# Configure MPI Paths
Edit the MPI compiler scripts to reference Intel compilers:

```bash
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2022.1.0)/mpi/2021.9.0/bin/mpiifort
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2022.1.0)/mpi/2021.9.0/bin/mpifc
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2022.1.0)/mpi/2021.9.0/bin/mpiicpc
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2022.1.0)/mpi/2021.9.0/bin/mpiicc
```

# Rebuild the Modules
Refresh the module trees:

```bash
spack module lmod refresh --delete-tree
spack module tcl refresh --delete-tree
```

# Load Modules
Example of loading modules:

``` bash
module load intel-oneapi-compilers/2022.1.0-gcc-9.2.0-q7cww3c
module load intel-oneapi-mpi/2021.9.0-intel-2021.6.0-5doytwi
module load netcdf-c/4.9.0-intel-2021.6.0-alg7zge 
module load netcdf-fortran/4.6.0-intel-2021.6.0-zq4tfol 
module load hdf5/1.12.2-intel-2021.6.0-pviyrk7
```


# Spack Environment Creation
Create and activate a new environment:

``` bash 
spack create env ifort-rocky
```

Activate the environment
```bash
spack activate env ifort-rocky
```

Spack Environment Creation
Create new environment:

``` bash 
spack add intel-oneapi-compilers@2022.1.0
spack add libfabric@1.21.0
spack add intel-oneapi-mpi@2021.9.0 
spack add netcdf-c@4.9.0  
spack add netcdf-fortran@4.6.0
spack add hdf5@1.12.2
spack install --reuse 
```

### Links to Spack Commands

- [Spack Uninstall](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-uninstall)
- [Spack External Find](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-external-find)
- [Spack Install](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-install)
- [Spack Compiler Add](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-compiler-add)
- [Spack Dependencies](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-dependencies)
- [Spack Module](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-module)
- [Spack Create Env](https://spack.readthedocs.io/en/latest/basic_usage.html#spack-environment)