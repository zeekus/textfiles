# PSCHISM install guide for AWS pcluster
--------------------
- Last edit: 12/5/23
- Author: Theodore Knab aka Zeekus on github
- Quality: Document was tested as functional by a third party. 
- Version: v1.0
- Licence: This program [document] is free software; 
           you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation
- Software used in build: 
   - pcluster 3.9.0 https://github.com/aws/aws-parallelcluster/blob/develop/CHANGELOG.md
   - spack  v0.21.0 https://github.com/spack/spack
   - pschism (develop git hash 1b4188b) https://github.com/schism-dev/schism
   - Intel MPI from AWS   
   - Intel Compiler from Spack 
   - CentOS Linux release 7.9.2009 (Core)
- Hardware: 
   - Head-node: 1 AWS     - hpc6a48x - OHIO with EFA  - 96 cores AMD. 
   - Compute-nodes: 3 AWS - hpc6a48x - OHIO with EFA  - 96 cores AMD.
- Model Run time: ref - params.nml in the data directory to change the default run times from 365 days. 
    10 day test 33 mins with 96 cpus in sbatch.( possible issues with MPI chatter. )
    10 day test 30 mins with 72 cpus in sbatch.
    1  day test 5 minutes with 72 cpus in sbatch.   

## Executive Summary

- Install spack and setup HDF5, netcdf-c, and netcdf-fortan with Intel MPI (AWS specific)
- Build pschism with software stack with a step-by-step guide. Note action items are identified by a - [ ] in the text. 
- What this does not cover. How setup a cluster using pcluster or Azure.

## Software Stack Requirements (Intel specific)
----------------------------------------------
- Pschism software stack build:
  - Intel compiler intel-oneapi-compilers@2022.1.0 (classic version)
  - Intel MPI intel-oneapi-mpi@2021.9. - depends on Libfabric 
  - HDF5 - hdf5@1.12.2
  - NetCDF-C - netcdf-c@4.9.0
  - NetCDF-Fortran - netcdf-fortran@4.6.0

## Details on What we cover.
-----------------------------------
- Define snafus. This is intentially put at top to save the reader some time. 
- Provide a step-by-step guide for installing and running Pschism - a hydro model with Intel MPI. 
- Install spack from git.
- Configure spack so that it is aware of the current system packages, compilers, modules, and how to run compiles. 
  1. We explain how to modify the packages.yaml, compilers.yaml, config.yaml, modules.yaml and their relevance. 
  2. We explain how to tell spack about libfabric [external], intelmpi [external].
- Use Spack to install Intel compilers.
- Configure Intel-MPI wrappers to point to Intel compiler (dependancies on compilers.yaml)
  Configure MPII (Intel MPI) point to the proper Intel compilers.
  *MPIIFORT* -  'spack location ifort'
  *MPIICC*   -  'spack location cc'
  *MPIICX*   -  'spack location icpc'
- Test MPI  - We explain how to test MPI - hello world test in c included with sbatch script.
- Install hdf5, netfortran-c, and netfortran - with spack.
- Pschism setup
   1. We explain how to build pschism with cmake
   2. We explain how to get the test datasets for pschism from subversions
   3. We explain how run pschism tests and provide sbatch script. 
   

  ## Extra Information: Know snafus
  --------------

  1. Hardware Compatiblity - To ensure hardware compatibility and avoid unexpected errors when running compiled binaries, it's crucial to verify that the hardware matches on both the head nodes and compute nodes. Spack automatically adds CFLAGS to the compiled packages, which can lead to issues if the binaries are executed on hardware expecting different CFLAGS. To address this, it's essential to confirm hardware consistency across all nodes.

  2. EFA - To ensure proper functionality of MPI with EFA, it is important to verify EFA setup with IntelMPI. Failure to set up EFA with IntelMPI can result in   non-functional or significantly slow MPI performance. Checking EFA for network connection errors is crucial, as any issues can lead to MPI failure.
  Note only some of the AWS hardware has EFA enabled. So, you will need to build a cluster with EFA if you want a high preformance network interface.

 To verify EFA, use the command fi_info -p efa on the compute nodes. A return value of -61 indicates a potential issue that may affect MPI functionality. It's important to note that this error may occur on the head nodes, as they are primarily used as the launch pad.

  For further details and troubleshooting, you can refer to the Intel community and documentation.

  Citations:
  [1] https://community.intel.com/t5/Intel-HPC-Toolkit/Installing-wrappers-for-using-Intel-MPI-with-the-PGI-compilers/td-p/1020565



  3.  When compilng the pshism binary, a custom CMake file that does not exist can cause CMake to fail without providing an error message. It is essential to   verify the existence of the custom CMake file to prevent potential issues.

  4. *Pshism modules* For the ICM test with the Pschism binary we need 4 modules enabled in the SCHISM.local.build.
     Note ParMETRIS is referenced as off to build ParMETIS and subpart.
     ```bash
     set(NO_PARMETIS OFF CACHE BOOLEAN "Turn off ParMETIS")
     set (OLDIO ON CACHE BOOLEAN "Old nc output (each rank dumps its own data)")
     set (PREC_EVAP ON CACHE BOOLEAN "Include precipitation and evaporation calculation")
     set( USE_ICM ON CACHE BOOLEAN "Use ICM module")
     ```

  5. Software stack dependancies. - Use diffutils@3.8 instead of diffutils@3.9, as diffutils3.9 is part of the bundle and is not compatible with hdf5@1.14.1-2. If compilation issues persist, include diffutils@3.8 by adding '^diffutils@3.8' to your install command.

  6. Compilers and Slurm's libpmi library - To resolve issues with Spack v.20 and above, modify the compilers.yaml to point to the intel64 variants for successful compilation. Additionally, include the following change, which may be required:
   ```yaml
  environment:
   prepend_path:
    LD_LIBRARY_PATH: '/modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-or3ebystfoy624o55d3sedgvwwxelhx7/compiler/2022.1.0/linux/compiler/lib/intel64_lin'
   set:
    I_MPI_PMI_LIBRARY: '/opt/slurm/lib/libpmi.so'
   ```

  7. *Compiler info and flags* 
    *I only tested intel@2021.6 0 (aka classic-oneapi-compiler) with pschism. This version comes from intel-oneapi-compilers@2022.1.0.

    - Compiler Flags needed none. 
    - Be careful with compiler flags. The first install, you may want to compile everything without flags.
    - If everything works, you may want to revisit and introduce some compiler flags. This will require a recompile. 
  
  Examples of some compiler flags you can feed to spack. 
  cflags="-O3,-shared,-static,-pthread" 
 
  
   source: *gcc* man page 

   ```
       -pthread
           Adds support for multithreading with the pthreads library.  This option sets flags for both the preprocessor and
           linker.

      -shared
           Produce a shared object which can then be linked with other objects to form an executable.  Not all systems support this option.  For predictable results, you must also specify the same set of

       -non-static
           Link an RTP executable against shared libraries rather than static libraries.  The options -static and -shared can
           also be used for RTPs; -static is the default.
   ```

  8. *Pametris* - external binary for MPI needing elevated privileges.  
      It seems schism relies on this binary. On Centos7, ldconfig seems to want to place the compiled libaries into the system area.

```bash
    [100%] Built target pschism
    Install the project...
    -- Install configuration: "Release"
    -- Up-to-date: /usr/local/include/parmetis.h
    -- Installing: /usr/local/lib/libparmetis.a
    CMake Error at ParMetis-4.0.3/libparmetis/cmake_install.cmake:46 (file):
    file INSTALL cannot copy file
    "/modeling/pschism/schism/src/build/lib/libparmetis.a" to
    "/usr/local/lib/libparmetis.a": Permission denied.
    Call Stack (most recent call first):
    ParMetis-4.0.3/cmake_install.cmake:49 (include)
     cmake_install.cmake:47 (include)
```
 *Simplest: work around for parmetris*
```bash
   sudo chown centos /usr/local/include/parmetis.h
   sudo chown centos /usr/local/lib/libparmetis.a
```

 Better Solution: tell cmake to compile parmetis in a different location with "-DCMAKE_INSTALL_PREFIX" like this:
```
  mkdir -p /var/tmp/libparmetis
 -D CMAKE_INSTALL_PREFIX=/var/tmp/libparmetis
```

  
## Extra Information: Spack area - Spack - Cheat Sheet of commands
----------------------------------------------- 

*This area gives a cheat sheet of spack commands.*
    
- list compilers : *spack compilers*
```bash
spack compilers
==> Available compilers
-- gcc centos7-x86_64 -------------------------------------------
gcc@9.2.0  gcc@4.8.5

-- intel centos7-x86_64 -----------------------------------------
intel@2021.6.0
```

- list files installed  - *spack find*
```bash
spack find
-- linux-centos7-x86_64_v3 / gcc@4.8.5 --------------------------
autoconf@2.69  automake@1.13.4  binutils@2.27.44  diffutils@3.3  gawk@4.0.2  gcc@9.2.0  gmake@3.82  gmp@6.2.1  libtool@2.4.7  m4@1.4.16  mpc@1.1.0  mpfr@3.1.6  perl@5.16.3  texinfo@5.1  zlib-ng@2.1.4

-- linux-centos7-zen2 / gcc@9.2.0 -------------------------------
autoconf@2.69    binutils@2.27.44  curl@7.29.0    flex@2.5.37  gmake@3.82                       m4@1.4.16            patchelf@0.17.2  pkg-config@0.27.1  re2c@2.2               tar@1.26
automake@1.13.4  bison@3.0.4       doxygen@1.8.5  gawk@4.0.2   intel-oneapi-compilers@2022.1.0  openssl@1.0.2k-fips  perl@5.16.3      python@3.9.16      rust-bootstrap@1.70.0

-- linux-centos7-zen2 / intel@2021.6.0 --------------------------
bzip2@1.0.8     cmake@3.17.5   gmake@3.82   intel-oneapi-mpi@2021.9.0  lz4@1.9.4       netcdf-fortran@4.6.0  snappy@1.1.10  zstd@1.5.5
c-blosc@1.21.5  diffutils@3.3  hdf5@1.12.2  libaec@1.0.6               netcdf-c@4.9.0  pkgconf@1.9.5         zlib-ng@2.1.4
==> 49 installed packages
```

list the callpaths - Sometimes needed if multiple copies of the same softweare package is installed.
```bash
spack find -dl
```

after getting the modules to install - rebuild the modules in spack
*SNAFU* you will need to start a new bash instance to see the modules. Logging out and in works. 
```bash
spack module tcl refresh --delete-tree
```

write spack configs to disk after modifiying
```bash
spack config --scope site update config
```

uninstall all the spack packages in a group 
```bash
 spack uninstall --all %intel@2021.6.0
```

look at dependancies on a package
```bash
spack dependencies --installed /hash
```
or 
```bash
spack dependencies --installed name
```

## The main area: Step by Step setup of Spack, MPI, and Pschism
---

Reader notes. 
Please be aware the following notion tells the reader they need to take some action. 
- [ ] Action item. This may keep you/me on task. 

### Step 1: *Hardware Checks*
---------------------------
- After building your HPC cluster, ensure hardware consistency between the compute nodes and head nodes. Spack automatically applies CFLAGS based on the node's hardware during installation. Mismatched hardware may lead to software stack issues, posing challenges for later debugging. 

- [ ] Do a cat /proc/cpuinfo on controller/compute node. 
   ```bash
   cat /proc/cpuinfo  | grep -i model\ name | head -1
   ``` 

### Step 2: Spack download - spack from git
--------------------------------------------

The first step is to install spack on your system. To install spack from the github this is how to do it.

- [ ] define your SPACK_ROOT
```bash 
export SPACK_ROOT=/modeling/spack
```
- [ ] clone the git repo 

```bash
git clone -c feature.manyFiles=true https://github.com/spack/spack $SPACK_ROOT
```

### Step 3: Spack configuration: switch to last stable release
---

- The git repo will come with multiple versions. We are going to want one that is stable.
- Use 'git branch -r -v' to view the versions. 
- Use 'git checkout origin/releases/v0.21' to checkout version 21 of spack.

- [ ] Checkout the version 21 release of spack or the latest stable branch.  

```bash
cd /modeling/spack
 git branch -r -v
git checkout  origin/releases/v0.21 #11/30/23

Note: checking out 'origin/releases/v0.21'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name
```

### Step 4: Spack setup: the SPACK environment
---

To load the Spack environment from the command line, use 'source $SPACK_ROOT/share/spack/setup-env.sh'. Additionally, to add the Spack environment call script to .bashrc, use the following commands:

- [ ] Setup the spack environment.

```bash
echo "export SPACK_ROOT=$SPACK_ROOT" >> $HOME/.bashrc
echo "source $SPACK_ROOT/share/spack/setup-env.sh" >> $HOME/.bashrc
```

This ensures that the Spack environment is loaded every time bash is called. Note that on AWS, home directories are shared, allowing changes made on the head node to propagate to the compute area. However, Azure does not have a shared home directory like AWS Pcluster.

For further details and troubleshooting, you can refer to the Spack documentation and community forums for best practices and specific use cases.

Citations:
[1] https://github.com/spack/spack/issues/10267
[2] https://docs.nersc.gov/applications/e4s/spack/
[3] https://github.com/spack/spack/issues/30547
[4] https://aws.amazon.com/blogs/hpc/install-optimized-software-with-spack-configs-for-aws-parallelcluster/
[5] https://chtc.cs.wisc.edu/uw-research-computing/hpc-spack-setup



## Installing the Compilers
--------------

- for AWS with Centos7 we have an old version of GCC. 

### Step 5: Setup the compilers you need to compile the intel compiler. 

To enable Spack to find the local compiler on AWS, use the command 'spack compiler find --scope site'. This command adds the compiler to the compilers.yaml file. For example, it may add 'gcc@4.8.5' to the file. This ensures that Spack is aware of the installed compiler. Note that on AWS, home directories are shared, allowing changes made on the head node to propagate to the compute area. 

- [ ] Tell spack where the Centos7 default gcc4.8.5 compiler is located. This adds it to the spack catalog of compilers.

```bash
spack compiler find --scope site

==> Added 1 new compiler to /home/centos/.spack/linux/compilers.yaml
    gcc@4.8.5 

```
This command adds our compiler to the compiler.yaml. 
Here is what the compilers.yaml file should look like if just gcc-4.8.5 is installed and spack is aware of it.

- /modeling/spack/etc/spack/compilers.yaml
```yaml
compilers:
- compiler:
    spec: gcc@=4.8.5
    paths:
      cc: /usr/bin/gcc
      cxx: /usr/bin/g++
      f77: /usr/bin/gfortran
      fc: /usr/bin/gfortran
    flags: {}
    operating_system: centos7                                                                                                    target: x86_64
    modules: []
    environment: {}
    extra_rpaths: []
```

For AWS, install a newer gcc compiler 9.2.0,  9.4.x, or something newer. 
Centos7 on AWS has gcc4.8.5, but is a bit dated. This is how we may add a newer compiler. 

- To install a newer compiler run this. 

  ```bash
  spack info gcc # to get a list of versions
  ```

- Select the version you want. We use 9.2.0 in this example and use 8 cores to compile it with the "-O3" [oscar 3] compiler flag. Note, '-O2' is the default flag.
  [ Read the man for gcc for more information on the compiler flags available. ]

- [ ] compile and install a new version of your gcc compiler in spack 
```bash
spack install -j8 gcc@9.2.0+binutils cflags="-O3"
```

- [ ] Then we add it the spack complier.yaml file with this processor.
```bash
spack compiler find --scope site $(spack location -i gcc@9.2.0)/bin #AWS specific
```

Alternatively, add the compiler by the callpath. 
You may need this if you have two of same versions of the compiler. Most of the time you will not need it.
But, it is good to know.

The callpath can be found by typing:
```bash
find -dl
```

Example of using a callpath to set the compiler in spack.
```
spack compiler add --scope site  $(spack location -i /6gpygsu)/bin
```

### Step 6: Spack Configuration
----

In this sections we create a `config.yaml`, `modules.yaml`, `packages.yaml`, and `compilers.yaml`. 
These files are created in '/modeling/spack/etc/spack/.' on our test system.  The files need to go in your './spack/etc' folder.
Each of these files in Spack serve different configuration purposes. The following explains how 
they are used by spack. 

1. **config.yaml**:
   - The `config.yaml` file stores global configuration settings for Spack.
   - It allows users to customize settings such as the install tree, build stage, and other Spack configurations.
   - Example:
     ```yaml
     config:
       install_tree: $spack/opt/spack
       build_stage:
         - $tempdir/$user/spack-stage
         - ~/.spack/stage
     ```

2. **modules.yaml**:
   - The `modules.yaml` file is used to generate module files that set up the environment for software packages.
   - It contains settings for generating module files, such as the module root and module type (TCL or Lmod).
   - Example:
     ```yaml
     modules:
       default:
         tcl:
           exclude:
             - '%gcc@11'
       all:
         filter:
           exclude_env_vars:
             - "CC"
             - "CXX"
             - "FC"
             - "F77"
     ```

3. **packages.yaml**:
   - The `packages.yaml` file is where information about external and internal packages is written.
   - External packages exist outside of spack. For example, on Centos7 in AWS Pcluster packages such as pmix, slurm, libfabric, and intelmpi
     might be treated as packages that exist outside of Spack. 
   - Internal packages are installed in spack. For example, when we install hdf5, netcdf-c, and netcdf-fortran via spack. They are internal packages. 
   - The packages.yaml files allows you to configure spack in a way that works for you. 

4. **compilers.yaml**:
   - The `compilers.yaml` file is used to define and configure compilers in Spack.
   - It allows users to specify compiler paths, flags, and other compiler-related settings.
   - Example:
     ```yaml
     compilers:
       - compiler: gcc
         paths:
           cc: /usr/bin/gcc
           cxx: /usr/bin/g++
           f77: /usr/bin/gfortran
           fc: /usr/bin/gfortran
     ```

By customizing these configuration files, users can control various aspects of Spack, such as package management, module file generation, and compiler configuration[1][2][3][4][5].

Citations:
[1] https://github.com/spack/spack/issues/10267
[2] https://spack-tutorial.readthedocs.io/en/latest/tutorial_modules.html
[3] https://spack.readthedocs.io/en/latest/module_file_support.html
[4] https://spack-tutorial.readthedocs.io/en/latest/tutorial_configuration.html
[5] https://spack.readthedocs.io/en/latest/configuration.html


For this howto, most of the example files are copied from NOAA's git hub site and have been tested as valid on AWS running Centos7.
source - https://github.com/JCSDA/spack-stack/tree/develop/configs/sites/aws-pcluster (Ubuntu specific )

In the following section, we will edit and create the following files:
- /modeling/spack/etc/spack/config.yaml  
- /modeling/spack/etc/spack/modules.yaml
- /modeling/spack/etc/spack/packages.yaml
- /modeling/spack/etc/spack/compilers.yaml

- [ ] Define your config.yaml 
File: *config.yaml* - create this if it doesn't exit. This tells spack to use 48 cores when doing a build.
                      It also tells spack to stage the build on local storage. You may want to modify this 
                      place the spack staging info in a different location.

```yaml
config:
  #HPCa6-48 has 48 cpus
  build_jobs: 48

  # Overrides for spack build and staging areas to speed up builds
  #   # by using a local directory instead of the EFS shared filesystem. NOAA 
  #
  build_stage: /tmp/spack-stack/cache/build_stage
  test_stage: /tmp/spack-stack/cache/test_stage
  source_cache: /tmp/spack-stack/cache/source_cache
  misc_cache: /tmp/spack-stack/cache/misc_cache
```

- [ ] Define your modules.yaml 
File: *modules.yaml* - create this if doesn't exit. This tell spack to build modules using these specifications.
                      The file is configuring the Lmod module system. The lmod section which is defined as a default the Python module should be included. 
                      The Ecflow module will be excluded from the generated module files. 

```yaml
modules:
  default:
    enable::
    - lmod
    lmod:
      include:
      - python
      exclude:
      - ecflow
```

- [ ] Define your packages.yaml
*packages.yaml* - This file will be written to by the 'spack external find' command. After spack adds the lines, you will need to append some more information.
                  Note, we are putting everything in the "--scope site" just so we know where the file is generated.
          

 - This tells spack to use our system installed vesions of textlive, perl, python and some other libraries. 
  You will need to type these commands in your bash environment. 

-  [ ] These commands will generate some basic entries in your packages.yaml file. 
```bash
export SPACK_SYSTEM_CONFIG_PATH=/modeling/spack/etc/spack
spack external find --scope system
spack external find --scope system texlive
spack external find --scope system perl
spack external find --scope system python
```

- Now that the *packages.yaml* file is created. You will need to edit it with either emacs, vim, or nano. 
  Append in some information tells spack about the MPI subsystem[intel-onempi, libfabric, pmix, slurm ], and the compilers to use.

File: *packages.yaml*  - base config AWS specific - add this to the top of the configuration or edit it to match.

- [ ] Information that will need to be appended to your package.yaml file. 
```yaml
packages:
  all:
    compiler: [intel@2021.6.0, gcc@9.2.0]
    providers:
      mpi: [intel-oneapi-mpi@2021.9.0, openmpi@4.1.5]

### MPI, Python, MKL
  mpi:
    buildable: false
  intel-oneapi-mpi:
    externals:
    variants: +libfabric
    - spec: intel-oneapi-mpi@2021.9.0%intel@2021.6.0
      prefix: /opt/intel
      modules:
      - libfabric-aws/1.17.1
      - intelmpi
  openmpi:
    externals:
    - spec: openmpi@4.1.5 %gcc@4.8.5
        fabrics=ofi schedulers=slurm
      prefix: /opt/amazon/openmpi
      modules:
      - libfabric-aws/1.17.1
      - openmpi/4.1.5
  libfabric:
        variants: fabrics=efa,tcp,udp,sockets,verbs,shm,mrail,rxd,rxm
        externals:
        - spec: libfabric@1.17.1 fabrics=efa,tcp,udp,sockets,verbs,shm,mrail,rxd,rxm
          prefix: /opt/amazon/efa
        buildable: False
  pmix:
        externals:
          - spec: pmix@4.2.6 ~pmi_backwards_compatibility
            prefix: /opt/pmix
  slurm:
        variants: +pmix sysconfdir=/opt/slurm/etc
        externals:
        - spec: slurm@23.02.6 +pmix sysconfdir=/opt/slurm/etc
          prefix: /opt/slurm
        buildable: False
```

*compilers.yaml*
- For spack to compile the spack binaries with MPI support, the compilers.yaml needs to define the environment variables.
- This will be touched upon more later since we do not have the intel compiler configured. 



### Step 7: Installing and configuring Intel compilers. 
----


- To install the Intel-oneapi-compilers@2022.1.0 and intel-oneapi-mpi-2021.7.1, use Spack. 
- Once the compiler is installed, configure the compilers.yaml with 'spack compiler add --scope site $(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64'
- Then, set up the compiler.yaml to ensure Spack is aware of which MPI libraries to use. Note that MPI will not work with srun without this configuration, but it will work with mpiexec, albeit at a slower pace. Additionally, compile the Intel compiler in Spack using gcc 9.2.0 and optimization flags. The software stack in this example uses pschism, hdf5, and netcdf-c/fortran, requires the 'classic intel compiler' to compile.

- [ ] Base Intel Compiler install is done like this. Adjust the command based on your system's gcc compiler, which may be different.

```bash
 spack install -j8 intel-oneapi-compilers@2022.1.0%gcc@9.2.0 cflags="-O3" #generic 

-- linux-centos7-skylake_avx512 / gcc@9.2.0 ---------------------
intel-oneapi-compilers@2022.1.0  patchelf@0.17.2
```

Pro Tip: If we wanted to find the package names and their callpaths use 'spack find -dl'.


```bash
spack find -dl
```

- Tell Spack about the compiler using the site flag. This will make the compiler available to all nodes that have access to the spack environment.

*IMPORTANT* DO NOT ADD THE oneapi compilers spack gets confused later on. 

- Important/Required Add the classic compiler to spack compiler.yaml file. 
```bash
spack find -dl intel-oneapi-compilers@2022.1.0
-- linux-centos7-zen2 / gcc@9.2.0 -------------------------------
drusa5u intel-oneapi-compilers@2022.1.0
52wa22r     patchelf@0.17.2
xdflvpm         gmake@3.82
```

- [ ] Classic compiler is referenced by the intel64 path.
  Note, we are using the package 'callapath' to refernece the compiler location.  
  To tell spack modify the *compiler.yaml*, we run this command: 

```bash
spack compiler add --scope site $(spack location -i /drusa5u)/compiler/latest/linux/bin/intel64
==> Added 1 new compiler to /modeling/spack/etc/spack/compilers.yaml
    intel@2021.6.0
 
==> Compilers are defined in the following files:
    /modeling/spack/etc/spack/compilers.yaml
``` 
- Once the Intel compiler is added to the *compiler.yaml*, it needs to be manually edited. 
- Modify your compiler.yaml file so that spack can find the MPI libraries used by spack and the compiler libs. 
- Identify where are the slurm MPI libraries are located. Earlier we found that your callpath for the compiler was 'drusa5u'.

```bash
cd $(spack location -i /drusa5u)/compiler/latest/linux/compiler/lib/intel64_lin
echo $PWD
/modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/compiler/lib/intel64_lin
```

- [ ] Modify the *config.yaml* so that the environment area is defined. 
  The environment area should have the following info.
  Defining the environment area in your compiler.yaml tells spack where to get the MPI libraries that Slurm, the scheduler provides.
  
*The LD PATH for the compilerneeds to be set. -source NOAA *
*The I_MPI_PMI_LIBRARY needs to be set        -source NOAA* 

```yaml
    environment:
      prepend_path:
        LD_LIBRARY_PATH: '/modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/compiler/lib/intel64_lin'
      set:
        I_MPI_PMI_LIBRARY: '/opt/slurm/lib/libpmi.so'
```


*classic compiler setup doesn't display the library for some reason*
```bash
spack compiler info intel@2021.6.0
intel@2021.6.0:
        paths:
                cc = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/icc
                cxx = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/icpc
                f77 = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/ifort
                fc = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/ifort
        environment:
            set:
                I_MPI_PMI_LIBRARY = /opt/slurm/lib/libpmi.so
        modules  = []
        operating system  = centos7
```

*Note* We should be using the classic compiler to compile everything. So, the compiler info should look like this:

- from the *config.yaml*
```yaml
intel@2021.6.0:
        paths:
                cc = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-ciiufncrbeqb5lzjm7qzauonhoohyygk/compiler/2021.2.0/linux/bin/intel64/icc
                cxx = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-ciiufncrbeqb5lzjm7qzauonhoohyygk/compiler/2021.2.0/linux/bin/intel64/icpc
                f77 = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-ciiufncrbeqb5lzjm7qzauonhoohyygk/compiler/2021.2.0/linux/bin/intel64/ifort
                fc = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-ciiufncrbeqb5lzjm7qzauonhoohyygk/compiler/2021.2.0/linux/bin/intel64/ifort
        environment:
          prepend_path:
            LD_LIBRARY_PATH: '/modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-or3ebystfoy624o55d3sedgvwwxelhx7/compiler/2022.1.0/linux/compiler/lib/intel64_lin'
          set:
            I_MPI_PMI_LIBRARY: '/opt/slurm/lib/libpmi.so'
        modules  = []
        operating system  = centos7
```


### Step 8: Test ALL Intel compilers after installing - outputs should look similar to this for all the versions 
----

- This step is just a basic santity check. If your tests display the versions, you know the compiler should work.
- [ ] query the compiler by name
```bash
ls $(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64
codecov  fortcom  fpp  icc  icc.cfg  icpc  icpc.cfg  ifort  ifort.cfg  libcilkrts.so.5  map_opts  mcpcom  profdcg  profmerge  profmergesampling  proforder  tselect  xiar  xiar.cfg  xild  xild.cfg
```

- [ ] Test the compiler by displaying the version info. 
- You could go further an do a hello world if you wanted to be 100% certain things are working. 

```bash
$(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64/icc --version
icc (ICC) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.

$(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64/ifort --version
ifort (IFORT) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.

$(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64/icpc --version
icpc (ICC) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.
```


## MPI WRAPPER SETUP
----

### Step 9 - configure the MPI components, so the Intel(r) compilers a properly referenced. 

The Intel MPI Library provides a set of compiler wrapper scripts with the `mpi` prefix for all supported compilers. These wrapper scripts are designed to simplify the process of compiling and linking MPI programs with the appropriate compiler and settings. The wrapper scripts are available for different languages and compilers, and they ensure that the necessary MPI settings and libraries are used during the compilation and linking process.

For example, the Intel MPI compiler wrapper scripts include:
- `mpiicc`: Compiler wrapper for the C language
- `mpiicpc`: Compiler wrapper for the C++ language
- `mpiifort`: Compiler wrapper for the Fortran language

These wrapper scripts allow users to compile and link MPI programs without having to manually specify all the required settings, and they ensure that the programs are built with the correct MPI configurations for optimal performance and compatibility with the Intel MPI Library[1][2][4][5].

Citations:
[1] https://hpc-wiki.info/hpc/How_to_Use_MPI
[2] https://www.intel.com/content/www/us/en/docs/mpi-library/developer-guide-windows/2021-6/compiling-an-mpi-program.html
[3] https://community.intel.com/t5/Intel-HPC-Toolkit/Installing-wrappers-for-using-Intel-MPI-with-the-PGI-compilers/td-p/1020565
[4] https://cdrdv2-public.intel.com/773548/mpi-library_developer-guide-windows_2021.9-768730-773548.pdf
[5] https://kb.ndsu.edu/page.php?id=107847


- Since we have intelmpi pre-installed from AWS Pcluster on Centos, we just tell spack about it. 
  Note spack, replies back that it linking it with libfabric an external module. This gets linked due to the package.yaml dependancy we created earlier.

- [ ] Tell spack to install the IntelMPI library. Note, we are using an external, so this just creates a refernce in the spack catalog.
      If we end up with duplicates when running 'spack find' later we may need to delete one of these.

```bash
spack install intel-oneapi-mpi@2021.9.0%intel@2021.6.0
==> intel-oneapi-mpi@2021.9.0 : has external module in ['libfabric-aws/1.17.1', 'intelmpi']
[+] /opt/intel (external intel-oneapi-mpi-2021.9.0-ja3rl76w3kwiadg4gcp7vcramorar7es)
```

- Edit the configuration files:
 *Summary: Edit the CC, CXX, IFORT values in your mpi wrappers and reference the compilers.yaml*
 There may be a better way to do this. If you have one, please forward it on.


 - [ ] *locate* The intel mpi wrapper files - in the bin folder.

```bash
[myhost spack]$ ls $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin
cpuinfo             hydra_nameserver  IMB-MPI1      IMB-MT   IMB-P2P  impi_info  mpicxx   mpiexec.hydra  mpif90  mpigcc  mpiicc   mpiifort  mpitune       tune
hydra_bstrap_proxy  hydra_pmi_proxy   IMB-MPI1-GPU  IMB-NBC  IMB-RMA  mpicc      mpiexec  mpif77         mpifc   mpigxx  mpiicpc  mpirun    mpitune_fast  tune_fast
```

Reference the *compiler yaml* for the intel@2021.6.0
  (aka - intel-classic ) is used to these values. The references in the wrappers need to match up*


- [ ] get the compiler info for reference. 

```bash
spack compiler info intel@2021.6.0
intel@2021.6.0:
        paths:
                cc = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/icc
                cxx = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/icpc
                f77 = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/ifort
                fc = /modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/ifort
        environment:
            set:
                I_MPI_PMI_LIBRARY = /opt/slurm/lib/libpmi.so
        modules  = []
        operating system  = centos7
```

- [ ] edit each of MPII wrapper files, so they point to the desired compiler. 

The locations to the CC in mpiicc will need updating. The FC location in mpiifort will need updating. 
Additionally, the location to CXX in the mpiicpc file will need updating. 
For example, The FC for mpiifort should point to our Fortran compiler listed above.

```
FC="/modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/bin/intel64/ifort"
```  

*typically MPII files for MPI-Intel while the MPI files are for gcc*
```bash
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiifort
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpifc
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicpc
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicc
```

- [ ] verify each of these point the expected compiler
```bash
$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiifort --version
$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpifc --version
$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicpc --version
$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicc --version
```

- The results should reference the desired compiler.  
```bash
$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicpc --version
icpc (ICC) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.

$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicc --version
icc (ICC) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.

$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpifc --version
ifort (IFORT) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.

$(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiifort --version
ifort (IFORT) 2021.6.0 20220226
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.
```

### Step 10: Spack related: Build the software stack that is required to run pschism. 
---
   - This covers how to build the software stack that spack installs.
   - Software 
     1. mpi %oneapi@2021.7.1 - is external on AWS previously built this.
     2. hdf5
     3. netcdf-c 
     4. netcdf-fortran@4.5.4 - depends on hdf5+fortran+hl   

- Cmake Snafu with centos7 
  Centos7 snafu /usr/bin/cmake is cmake2 rather than /usr/bin/cmake [version 3].
  It might be better to tell spack to use a seperate version of cmake.
  EFA - network stuff depends on cmake2 on centos7.

- To install the software stack run this:
   Note, the command pulls libfabric info from packages.yaml
   '-j48' is set and comes from the config.yaml.
   '--reuse' tells spack to reuse the libaries rather than install new copies. This may change in the future. 
   -'^' is a dependency in spack. 

- [ ] Build the main software stack for Pschism to run. 
      *Note* this command is likely to fail in new versions of spack.
      If '--reuse' doesn't work, try '--reuse-deps'.  
       

```bash
spack install --reuse netcdf-fortran@4.6.0%intel@2021.6.0 ^hdf5+fortran+hl%intel@2021.6.0 ^netcdf-c@4.9.0%intel@2021.6.0 ^hdf5@1.12.2%intel@2021.6.0 ^intel-oneapi-mpi@2021.9.0%intel@2021.6.0 cflags="-O3,-shared,-static"
```

- A Successful run should look like this. 
```
[myhost]$ spack find
-- linux-centos7-x86_64_v3 / gcc@4.8.5 --------------------------
autoconf@2.69  automake@1.13.4  binutils@2.27.44  diffutils@3.3  gawk@4.0.2  gcc@9.2.0  gmake@3.82  gmp@6.2.1  libtool@2.4.7  m4@1.4.16  mpc@1.1.0  mpfr@3.1.6  perl@5.16.3  texinfo@5.1  zlib-ng@2.1.4

-- linux-centos7-zen2 / gcc@9.2.0 -------------------------------
autoconf@2.69    binutils@2.27.44  curl@7.29.0    flex@2.5.37  gmake@3.82                       m4@1.4.16            patchelf@0.17.2  pkg-config@0.27.1  re2c@2.2               tar@1.26
automake@1.13.4  bison@3.0.4       doxygen@1.8.5  gawk@4.0.2   intel-oneapi-compilers@2022.1.0  openssl@1.0.2k-fips  perl@5.16.3      python@3.9.16      rust-bootstrap@1.70.0

-- linux-centos7-zen2 / intel@2021.6.0 --------------------------
bzip2@1.0.8     cmake@3.17.5   gmake@3.82   intel-oneapi-mpi@2021.9.0  lz4@1.9.4       netcdf-fortran@4.6.0  snappy@1.1.10  zstd@1.5.5
c-blosc@1.21.5  diffutils@3.3  hdf5@1.12.2  libaec@1.0.6               netcdf-c@4.9.0  pkgconf@1.9.5         zlib-ng@2.1.4
```

### Step 11: Spack related: Refresh the modules
---
  - From spack version 19 and on we are required to refresh the module tree to get access to the modules. 
    
  - [ ] Refresh the modules by doing this: 

   ```bash
   yes 'y' | spack module tcl refresh --delete-tree
   bash
   module avail
   ```
   - After the modules install properly, update the spack environment to set the path. Before we know the path, we need to rebuild the modules.

   - Find the path
   ```
   module avail #lists the paths
   ```

   - append the path in ~/.bashrc
   ``` 
   export MODULEPATH=/usr/share/Modules/modulefiles:/opt/intel/mpi/2021.9.0/modulefiles:/modeling/spack/share/spack/modules/linux-centos7-zen2
   ```

   - [ ]  update the setup-env.sh to use have the new path. (Optional)

   ```
   echo "export MODULEPATH=/usr/share/Modules/modulefiles:/opt/intel/mpi/2021.9.0/modulefiles:/modeling/spack/share/spack/modules/linux-centos7-zen2" >> $SPACK_ROOT/share/spack/setup-env.sh  
   ```

  - Snafu - Once the module tree is refeshed a new session needs to be created.
     For example, we can log out and log back in or open a bash session. 


## Test MPI
---

### Step 12: Pre-preperation- test MPI on the system.
---
 - pschism uses/requires mpi, we should test this is working first. 
 - If Mpi works, this is a good indication MPI should work for pchism.

  1. create a simple mpi test
  2. load the mpi module 'module load intelmpi'
  3. create a sbatch script and test your hello_world.o binary with sbatch.
  4. verify the results. 
 



- [ ] create a simple hello_world.c program.
  Here is the source code for simple MPI hello_world.c program.


```c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    printf("Hello from process %d of %d\n", rank, size);

    MPI_Finalize();
    return 0;
}
```


- [ ] list the mpi binaries on your system.
```bash
ls $(spack location -i intel-oneapi-mpi@2021.9.0)/mpi/latest/bin
```

- [ ] prior to being able to compile mpi hello_world.c code you will need to call the load mpi module
```bash
   module load intelmpi
```

- [ ] To compile the MPI test code with the intel-mpi compiler from spack
  You created c file so you will be using the mpiicc compiler to compile the code. 
```bash
$(spack location -i intel-oneapi-mpi@2021.9.0)/mpi/latest/bin/mpicc modeling/pschism/mpi_test.c -o /modeling/pschism/hello_out
```

- [ ] setup a simple sbatch file to test mpi
  Note, we set the path for the module path in here. This may need updating.

```bash
#!/bin/bash
#filename: my_hello_world_slurm.sh

#SBATCH --threads-per-core=1
#SBATCH -N 2
#SBATCH --ntasks-per-node=10
#SBATCH --time=00:10:00  # Adjust the time limit as needed
####SBATCH -p standard96  # Adjust the partition as needed

#tell shell to reload the module path
export MODULEPATH=/usr/share/Modules/modulefiles:/opt/intel/mpi/2021.9.0/modulefiles:/modeling/spack/share/spack/modules/linux-centos7-zen2

# Print the fully qualified domain name of the host
hostname --fqdn

echo "Loading mpi envi using spack"
source /modeling/spack/share/spack/setup-env.sh
spack load intelmpi
spack load --list

echo "loading modules using module"
module load libfabric-aws/1.17.1
module load intempi 
ls -la $I_MPI_ROOT
echo "$?: did we load the I_MPI_ROOT"
source $I_MPI_ROOT/env/vars.sh
echo "$?: did we load the mpivars.sh"
#echo "set the environment variables to use slurm mpi"
export I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi.so"
export I_MPI_FABRICS="shm:ofi"
export I_MPI_OFI_LIBRARY_INTERNAL=0 #disable default providers in attempt to prevent conflicts
export I_MPI_OFI_PROVIDER=efa #use efa
export MPIR_CVAR_CH4_OFI_ENABLE_RMA=0 #turn off RMA operations per https://github.com/aws/aws-parallelcluster/issues/1988
export I_MPI_DEBUG=30
export I_MPI_HYDRA_BOOTSTRAP=slurm
export I_MPI_HYDRA_IFACE="eth0"
echo "Starting mpi test using slurm and pmi"
srun --mpi=pmi2 /modeling/pschism/hello_out
```

- [ ] run your sbatch file.

   ```bash
   sbatch my_hello_world_slurm.sh
   ```

- [ ] verify the test by looking the slurm.err and slurm.out files.




## PSCHISM specific information
---

- SNAFU with complier : to Compile the pschism code we need to load all the modules used with pschism first.


### Step 13: Prep verify the modules used for pschism exist in spack and can be accessed. 
---

- [ ] list the modules available. Note, if you don't see the new modules, log out and log back in.
      That will refresh the environment or you simply type 'bash' to start a new nested bash session. 
      If one of the modules, you are seeking doesn't

```bash
module av

---------------------------------------------- /usr/share/Modules/modulefiles -----------------------------------------------
dot                  module-git           modules              openmpi/4.1.5
libfabric-aws/1.17.1 module-info          null                 use.own

-------------------------------------------- /opt/intel/mpi/2021.9.0/modulefiles --------------------------------------------
intelmpi

---------------------------------- /modeling/spack/share/spack/modules/linux-centos7-zen2 -----------------------------------
bzip2/1.0.8-intel-2021.6.0-esuoxfm                libaec/1.0.6-intel-2021.6.0-cv2h7bd
c-blosc/1.21.5-intel-2021.6.0-niqotqt             lz4/1.9.4-intel-2021.6.0-hvtwrt2
cmake/3.27.7-intel-2021.6.0-hbyt6ed               ncurses/6.4-intel-2021.6.0-jvmqf7o
curl/7.29.0-intel-2021.6.0-xljlfmh                netcdf-c/4.9.0-intel-2021.6.0-yii5utw
diffutils/3.3-intel-2021.6.0-kbninbp              netcdf-fortran/4.6.0-intel-2021.6.0-vpzbv7s
gmake/3.82-gcc-9.2.0-xdflvpm                      patchelf/0.17.2-gcc-9.2.0-52wa22r
gmake/3.82-intel-2021.6.0-2vg32r4                 pkgconf/1.9.5-intel-2021.6.0-vyeh2zz
hdf5/1.12.2-intel-2021.6.0-uz2e74i                snappy/1.1.10-intel-2021.6.0-riisc5q
intel-oneapi-compilers/2022.1.0-gcc-9.2.0-drusa5u zlib-ng/2.1.4-intel-2021.6.0-v44hor5
intel-oneapi-mpi/2021.9.0-intel-2021.6.0-hul6jpm  zstd/1.5.5-intel-2021.6.0-4dpbqto
```

- [ ] load the modules needed to compile and run pschism *note* your names may differ. 
```bash
module load libfabric-aws/1.17.1 #external libfabric
module load intelmpi #external mpi
module load hdf5/1.12.2-intel-2021.6.0-uz2e74i
module load netcdf-c/4.9.0-intel-2021.6.0-yii5utw
module load netcdf-fortran/4.6.0-intel-2021.6.0-vpzbv7s
```

*note loading these spack modules will create the following environment variables*

MPICC
MPIFC
MPIF77
MPIF90
MPICXX
NETCDF_C_ROOT
NETCDF_FORTRAN_ROOT
HDF5_ROOT
HDF5_PLUGIN_PATH
INTEL_MPI_ROOT
I_MPI_ROOT
LIBFABRIC_ROOT
LD_LIBRARY_PATH
PATH
CMAKE_PREFIX_PATH

- [ ] list modules from the os. Are they loaded ? 
```bash
module list
Currently Loaded Modulefiles:
  1) libfabric/1.18.2-oneapi-2021.2.0-nfoyn4        8) snappy/1.1.10-oneapi-2021.2.0-4ne2lt
  2) intel-mpi/2019.10.317-oneapi-2021.2.0-5uvyw3   9) zstd/1.5.5-oneapi-2021.2.0-gei5ma
  3) pkgconf/1.9.5-oneapi-2021.2.0-ownafr          10) c-blosc/1.21.5-oneapi-2021.2.0-jhwqel
  4) zlib-ng/2.1.4-oneapi-2021.2.0-kxurjk          11) libaec/1.0.6-oneapi-2021.2.0-knwa6h
  5) hdf5/1.14.3-oneapi-2021.2.0-ici6jg            12) netcdf-c/4.9.2-oneapi-2021.2.0-g2kwkj
  6) bzip2/1.0.8-oneapi-2021.2.0-2zpaqr            13) netcdf-fortran/4.5.4-oneapi-2021.2.0-zr4nek
  7) lz4/1.9.4-oneapi-2021.2.0-om4aan
```

### Step 14 Pschism - Get the source code 
---


- [ ] get the [latest] source code
```bash
git clone https://github.com/schism-dev/schism.git
Cloning into 'schism'...
remote: Enumerating objects: 20465, done.
remote: Counting objects: 100% (3396/3396), done.
remote: Compressing objects: 100% (881/881), done.
remote: Total 20465 (delta 2523), reused 3291 (delta 2443), pack-reused 17069
Receiving objects: 100% (20465/20465), 247.86 MiB | 41.81 MiB/s, done.
Resolving deltas: 100% (14501/14501), done.
```

- [ ] list the branches. In this example,  we want to use icm_Balg.
  This is how we would select the branch.
  Note this branch is a dev branch. The master branch should work.

```bash
cd schism/
git branch -a
* master
  remotes/origin/2D_variable_manning
  remotes/origin/GEN_DOX
  remotes/origin/HEAD -> origin/master
  remotes/origin/ICM_v0
  remotes/origin/ICM_v1
  remotes/origin/ICM_v2
  remotes/origin/QSim_output
  remotes/origin/ci
  remotes/origin/cmmb
  remotes/origin/gh-pages
  remotes/origin/ice_BGC
  remotes/origin/icm_Balg
  remotes/origin/master
  remotes/origin/new_horizontal_diffusion
  remotes/origin/platipodium-workflow-cmake
  remotes/origin/procvisit
  remotes/origin/v5.10
  remotes/origin/v5.11
  remotes/origin/v5.8.1
  remotes/origin/v5.9
  remotes/origin/variable_settling
```

- [ ] Snafu - checkout Balg version: Check with Nicole to see if this will work before testing. (Optional )
```bash
git checkout -b remotes/origin/icm_Balg
Switched to a new branch 'remotes/origin/icm_Balg'
```

### Step 15: Pschism: Prep and build the Source code.
---

- [ ] We remove build folder and recreate each build.
```bash
cd /modeling/pschism/schism/src
rm -fr build; mkdir build
```

### Step 16: - refresh the data.
---
- Data Setup
  1. Each directory needs and outputs folder. This is omitted in the data.
  2. The param.nml file is the configuration file.
      change rnday from 'rnday = 365'  to 'rnday = 1' to reduce cost
       a one day run on ChesBay test should take about 5 mins on AWS.
   
- [ ] Get Test Data - for basic tests (Optional)
```bash
svn co https://columbia.vims.edu/schism/schism_verification_tests/Test_CORIE
mkdir Test_CORE/outputs #create missing outputs directory
```

- [ ] Get ICM Test data - source chesapeake bay (Our data)

```bash
 svn co https://columbia.vims.edu/schism/schism_verification_tests/Test_ICM_ChesBay
 mkdir Test_ICM_ChesBay/outputs # create missing outputs directory
 ```

*IMPORTANT the runs must occur in the target data directory*

- [ ] Change into the data directory and create a outputs folder and a sbatch run file. 

```bash
cd Test_ICM_ChesBay
mkdir outputs
touch sbatch_file_goes_here #use what ever naming convention you desire.
```

### Step 17: Pschism: Prep and build create a bash script to do the compiling for you.

This step can be done differently.
---

- [ ] check all these paths before attempting to run your pschism compile. 
  1. - [ ] type 'modules av' to get your modules. 
  2. - [ ] create a file to load your modules with 'source' in your batch script. See example provided. 
```bash
vim /modeling/pschism/Test_ICM_ChesBay/load_modules_aws_intel.sh
```

- [ ] update the modules so they match your system. The format should match the following bash script. 


```bash
#!/usr/bin/bash
# updated: 11/30/23 
# filename: /modeling/pschism/Test_ICM_ChesBay/load_modules_aws_intel.sh
# holds a list of the moduels to load. Changes each time we rebuild the software stack.


yes 'y'| module clear
#note all the modules are loaded on one line and libfabric is external with intelmpi
module load libfabric-aws/1.17.1 intelmpi hdf5/1.12.2-intel-2021.6.0-uz2e74i netcdf-c/4.9.0-intel-2021.6.0-yii5utw netcdf-fortran/4.6.0-intel-2021.6.0-vpzbv7s
```

- [ ] Before attempting to run cmake with the bash script clear your modules and load them manually.
      Here are the steps to clear the module and load all the modules manually.  

```bash
yes 'y'| module clear
module load libfabric-aws/1.17.1 intelmpi hdf5/1.12.2-intel-2021.6.0-uz2e74i netcdf-c/4.9.0-intel-2021.6.0-yii5utw netcdf-fortran/4.6.0-intel-2021.6.0-vpzbv7s
```

- [ ] Create a bash file to build the Cmake pschism parts.
      Here is an example shell script. 

Filename:  /modeling/pschism/Test_ICM_ChesBay/compile_pschism_aws_intel-mpi.sh
#tested 11/16/23

```bash
#!/usr/bin/bash
#filename:  /modeling/pschism/Test_ICM_ChesBay/compile_pschism_aws_intel-mpi.sh
#description: cmake file for compiling pschism with intel-mpi
#updated: 11/30/23

#PSCHISM will not compile if the modules are not loaded first - check the modules
export MODULEPATH=$MODULEPATH:/modeling/spack/share/spack/modules/linux-centos7-zen2
module list -l  2> /var/tmp/modulelist

export module_load_file="/modeling/pschism/Test_ICM_ChesBay/load_modules_aws_intel.sh"
if ! grep -q "No Modulefiles Currently Loaded." /var/tmp/modulelist; then
    echo "Good:The module list is not empty"
else
    echo error: you will need to manually source the $module_load_file if it exists or manually load the desired modules.
    exit 1
fi


#load environment for mpi
source $(spack location -i intel-oneapi-mpi@2021.9.0)/setvars.sh

#Set all the Variables
export FC=/modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-or3ebystfoy624o55d3sedgvwwxelhx7/compiler/2022.1.0/linux/bin/intel64/ifort
export CC=/modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-or3ebystfoy624o55d3sedgvwwxelhx7/compiler/2022.1.0/linux/bin/intel64/icc
export cxx=/modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-or3ebystfoy624o55d3sedgvwwxelhx7/compiler/2022.1.0/linux/bin/intel64/icpc
export I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi.so"
export MPI_ROOT=$I_MPI_ROOT
export CMAKE_Fortran_COMPILER=/opt/intel/mpi/2021.9.0/bin/mpiifort
export CMAKE_CXX_COMPILER=/opt/intel/mpi/2021.9.0/bin/mpiicpc
export CMAKE_C_COMPILER=/opt/intel/mpi/2021.9.0/bin/mpiicc
export NETCDF=$(spack location -i netcdf-c%intel)
export NETCDFF=$(spack location -i netcdf-fortran%intel)
export NETCDF_FORTRAN=$(spack location -i netcdf-fortran%intel)
export HDF5_DIR=$(spack location -i hdf5%intel)
export NetCDF_C_DIR=$NETCDF
export NetCDF_FORTRAN_DIR=$NETCDFF
#SNAFU had to hardcode library path as file for this variable
export NetCDF_LIBRARY="$NETCDF/lib"
export NetCDFF_LIBRARY="$NETCDFF/lib"
export CMAKE_BINARY="$(spack location -i /h4r3val)/bin/cmake"
export NetCDF_INCLUDE_DIR="$NetCDF/include"
export NetCDF_LIBRARIES=$NetCDF_LIBRARY
export NetCDF_FORTRAN_DIR=$NETCDFF
export NetCDF_FORTRAN_LIBRARIES=$NetCDFF_LIBRARY
export local_build_for_cmake=/modeling/pschism/SCHISM.local.build
export custom_build_for_cmake=/modeling/pschism/SCHISM_local.cmake.bluefish.intel


#checks
echo "cmake version: $(cmake -version)"
echo "locations: to libraries"
echo "NETCDF  (netcdf-c): $NETCDF"
echo "NetCDF_LIBRARY: $NetCDF_LIBRARY"

echo "NETCDFF (netcdf-fortran): $NETCDFF"
echo "NetCDF_FORTRAN_DIR: $NETCDFF"
echo "NetCDF_FORTRAN_LIBRARY: $NetCDFF_LIBRARY"

echo "HDF5_DIR: $HDF5_DIR"


#check to make sure the cmake files for the build are present
#Without these things may still compile but the application may not work as expected.
if [ -e "$local_build_for_cmake" ] && [ -e "$custom_build_for_cmake" ]; then
   echo "both the $local_build_for_cmake and the $custom_build_for_cmake exist"
else
   echo "ERROR either the $local_build_for_cmake or the $custom_build_for_cmake is missing error"
   exit 1
fi

#clean up the build folder
rm -fr /modeling/pschism/schism/src/build; mkdir /modeling/pschism/schism/src/build

#schism may complain that FC,CC,and some other variables are not necessary. This ok. 
$CMAKE_BINARY -C $local_build_for_cmake -C $custom_build_for_cmake \
-D CC=$CC \
-D FC=$FC \
-D CMAKE_Fortran_COMPILER=$CMAKE_Fortran_COMPILER \
-D CMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER \
-D CMAKE_C_COMPILER=$CMAKE_C_COMPILER \
-D NetCDF_C_DIR=$NETCDF \
-D NetCDF_FORTRAN_DIR=$NETCDFF \
-D NetCDF_FORTRAN_LIBRARIES="$NETCDFF/lib" \
-D HDF5_DIR=$HD5_DIR \
-S /modeling/pschism/schism/src -B /modeling/pschism/schism/src/build
```

*SNAFU* Remember to clean out the src/build before every cmake run. 
*SNAFU* verify the configuration files you are references exist. If they don't exist, the cmake run will fail with no error file.
  
- [ ] create a custom cmake file defining the compiler details - /modeling/pschism/SCHISM.local.cmake.bluefish.skylake

```bash
#Binary name
set (SCHISM_EXE_BASENAME pschism_AWS_SKYLAKE CACHE STRING "Base name (modules and file extension to be added of the executable. If you want a machine name, add it here")

###Relative paths won't work
set(CMAKE_Fortran_COMPILER "ENV{CMAKE_Fortran_COMPILER}" CACHE PATH "Path to serial Fortran compiler")
set(CMAKE_C_COMPILER "$ENV{CMAKE_C_COMPILER}"  CACHE PATH "Path to serial Fortran compiler")
set(NetCDF_FORTRAN_DIR "$ENV{NETCDF_FORTRAN_DIR}"  CACHE PATH "Path to NetCDF Fortran library")
set(NetCDF_C_DIR "$ENV{NetCDF_C_DIR}" CACHE PATH "Path to NetCDF C library")
set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -fPIC -no-prec-sqrt -no-prec-div -align all -assume buffered_io -assume byterecl" CACHE STRING "Fortran flags" FORCE)
```

###  Step 18: Prep and build the source Code - Compile using bash script or some other method.
---

- [ ] compile pschism with your custom cmake file. 
```bash
bash compile_pschism_aws_intel-mpi.sh
```

### Step 19: Compile schism from the build directory using make. 
---

- [ ] build the binary with make 
```bash
cd /modeling/pschism/schism/src/build
make -j8 pschism
```

### Step 20 - Final Step - Running the code.
---
- to run the code you will need a sbatch file
- you may also want to edit the 'params.nml' control file to reduce the number of days of data to simulate. 
- the sbatch file needs to be run from the directory holding the data.

For example, we have the data in a folder called: 

Data dir: /modeling/pschism/Test_ICM_ChesBay

#ref files in cmake_info for latest copies. 

- [ ] Before running the module update the params.nml file. 
      365 should be changed to 1 or 10. 
      A 365 day run will take 24+ hours.
      A 1 day run should take 5 minutes if everything is running properly. 
      A 10 run should take about 30 minutes if everything is running properly. 

- [ ] create a sbatch file and run the model.
      Here is an example sbatch script that was used in the past. 
      Note the outputs/mirror.out sets displays the results.

```bash
#!/usr/bin/bash
#filename: pschism_sbatch_job.sh
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=72
#SBATCH --threads-per-core=1
#SBATCH --sockets-per-node=72
#SBATCH --exclusive
#SBATCH -t 40:00:00
#SBATCH --job-name=pschism_t44h
#SBATCH --error=pschism_job_beefy.%J.err
#SBATCH --output=pschism_job_beefy.%J.out
###SBATCH --mem-per-cpu=2G # memory per cpu-core
##binary run

#shell to relaod path
export MODULEPATH=$MODULEPATH:/modeling/spack/share/spack/modules/linux-centos7-zen2


#load enviornment variables
#load the paths from the INTEL-MPI
echo "load spack environment variables"
export SPACK_ROOT=/modeling/spack
source $SPACK_ROOT/share/spack/setup-env.sh
echo "load spack environment variables $?"

source $(spack location -i intel-oneapi-mpi@2021.9.0)/setvars.sh
echo "we loaded the mpi env and got a $? response"

#load enviornment variables first
#export PSCHISM_BINARY=/modeling/pschism/schism/src/build/bin/pschism_AWS_SKYLAKE_ICM_OLDIO_PREC_EVAP_TVD-VL

export PSCHISM_BINARY=/modeling/pschism/schism/src/build/bin/pschism_AWS_SKYLAKE_ICM_OLDIO_PREC_EVAP_TVD-VL


#export I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi2.so"
export I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi.so"
export I_MPI_MPIRUN="$I_MPI_ROOT/intel64/bin/mpirun"


export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
SECONDS=0

export I_MPI_FABRICS="shm:ofi"
export I_MPI_OFI_LIBRARY_INTERNAL=0 #disable default providers in attempt to prevent conflicts
export I_MPI_OFI_PROVIDER=efa #use efa
export MPIR_CVAR_CH4_OFI_ENABLE_RMA=0 #turn off RMA operations per https://github.com/aws/aws-parallelcluster/issues/1988
export FI_PROVIDER=efa
export FI_LOG_LEVEL=debug #warn, info, debug
export I_MPI_DEBUG=30
export I_MPI_HYDRA_BOOTSTRAP=slurm
export I_MPI_HYDRA_IFACE="eth0"
export UCX_UNIFIED_MODE=y
# specify message size threshold for using the UCX Rendevous Protocol
export UCX_RNDV_THRESH=65536
# use high-performance rc transports where possible
export UCX_TLS=rc
#export UCX_TLS=tcp
# control how much information about the transports is printed to log
export UCX_LOG_LEVEL=info

#set ulimits
export OMP_STACKSIZE=500m
ulimit -l unlimited
ulimit -v unlimited
ulimit -s unlimited

echo "load modules"
source /modeling/pschism/Test_ICM_ChesBay/load_modules_aws_intel.sh
echo "did we get an error $?"


echo "loading the modules $?"
module list
echo "listing the modules $?"

echo "running binary"
srun --mpi=pmi2 $PSCHISM_BINARY # oldIO
#srun --mpi=pmi2 $PSCHISM_BINARY 30 #new io

echo "srun output was $?"

echo "finished with errors: $? "
echo "Finished in $(printf '%02dh:%02dm:%02ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60)))"

```

- [ ] run your batch file. 
      You need to submit sbatch jobs with the 'sbatch' command. 

   ```bash
   sbatch pschism_sbatch_job.sh
   ```

 - [ ] monitor Pschism  outputs/mirror.out this will tell you if the model ran right. 
   ```bash
   TIME STEP=         5760;  TIME=        864000.000000

Run completed successfully at 20231205, 161111.159
   ```

### End of Step by Step guide


### References 
---

- old setup guide https://jiaweizhuang.github.io/blog/aws-hpc-guide/

- spack environments https://hpc.nmsu.edu/discovery/software/spack/environments/

-NOAA has the best documenation  https://github.com/JCSDA/spack-stack/tree/develop/configs/sites/aws-pcluster

END/end










