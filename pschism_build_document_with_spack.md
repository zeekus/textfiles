# PSCHISM install guide for AWS pcluster
--------------------
- Last edit: 12/4/23
- Quality: Draft
- Version: Pre-production
- Software used in build: 
   - pcluster 3.9.0 https://github.com/aws/aws-parallelcluster/blob/develop/CHANGELOG.md
   - spack  v0.21.0 https://github.com/spack/spack
   - pschism (develop git hash 1b4188b) https://github.com/schism-dev/schism
   - Intel MPI from AWS   
   - Intel Compiler from Spack 
   - CentOS Linux release 7.9.2009 (Core)
- Hardware: 
   - Head-node: AWS     - hpc6a48x - OHIO with EFA  - 96 cores AMD. 
   - Compute-nodes: AWS - hpc6a48x - OHIO with EFA  - 96 cores AMD.
- Model Run time: ref - params.nml in the data directory to change the defaults of 365 days. 
    10 day test 33 mins with 96 cpus in sbatch.( possible issues with MPI chatter. )
    10 day test 30 mins with 72 cpus in sbatch.
    1  day test 5 minutes with 72 cpus in sbatch.   

## Executive Summary

- Install spack and setup HDF5, netcdf-c, and netcdf-fortan with Intel MPI (AWS specific)
- Build pschism with software stack with a step-by-step guide. 
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
- Provide a step-by-step guide for installing and running Pschism - a hydro model. 
- Install spack from git.
- Configure spack so that it is aware of the current system packages, compilers, modules, and how to run compiles. 
  1. We explain how to modify the packages.yaml, compilers.yaml, config.yaml, modules.yaml
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
   

  ## Know snafus
  --------------

  1. Hardware Compatiblity - To ensure hardware compatibility and avoid unexpected errors when running compiled binaries, it's crucial to verify that the hardware matches on both the head nodes and compute nodes. Spack automatically adds CFLAGS to the compiled packages, which can lead to issues if the binaries are executed on hardware expecting different CFLAGS. To address this, it's essential to confirm hardware consistency across all nodes.

  2. EFA - To ensure proper functionality of MPI with EFA, it is important to verify EFA setup with IntelMPI. Failure to set up EFA with IntelMPI can result in   non-functional or significantly slow MPI performance. Checking EFA for network connection errors is crucial, as any issues can lead to MPI failure.

  For EFA verification, the command `fi_info -p efa` can be used. A return value of `-61` indicates a potential issue that may impact MPI functionality.

  For further details and troubleshooting, you can refer to the Intel community and documentation.

  Citations:
  [1] https://community.intel.com/t5/Intel-HPC-Toolkit/Installing-wrappers-for-using-Intel-MPI-with-the-PGI-compilers/td-p/1020565



  3.  When compilng the pshism binary, a custom CMake file that does not exist can cause CMake to fail without providing an error message. It is essential to   verify the existence of the custom CMake file to prevent potential issues.

  4. *Pshism modules* For the ICM test we need 4 modules enabled in the SCHISM.local.build.
     Note ParMETRIS is referenced as off to build ParMETIS and subpart.
```
set(NO_PARMETIS OFF CACHE BOOLEAN "Turn off ParMETIS")
set (OLDIO ON CACHE BOOLEAN "Old nc output (each rank dumps its own data)")
set (PREC_EVAP ON CACHE BOOLEAN "Include precipitation and evaporation calculation")
set( USE_ICM ON CACHE BOOLEAN "Use ICM module")
```

  5. Use diffutils@3.8 instead of diffutils@3.9, as diffutils3.9 is part of the bundle and is not compatible with hdf5@1.14.1-2. If compilation issues persist, include diffutils@3.8 by adding '^diffutils@3.8' to your install command.

  6. To resolve issues with Spack v.20 and above, modify the compilers.yaml to point to the intel64 variants for successful compilation. Additionally, include the following change, which may be required:

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

  9. *Pametris* - external binary for MPI needing elevated privileges.  
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

  
## Spack area - Spack - Cheat Sheet of commands
----------------------------------------------- 

*This area gives a cheat sheet of spack commands.*
    
- list compilers : *spack compilers*
```bash
[myhost Test_ICM_ChesBay]$ spack compilers
==> Available compilers
-- gcc centos7-x86_64 -------------------------------------------
gcc@9.2.0  gcc@4.8.5

-- intel centos7-x86_64 -----------------------------------------
intel@2021.6.0
```

- list files installed  - *spack find*
```bash
[myhost Test_ICM_ChesBay]$ spack find
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

## Step by Step setup of Spack, MPI, and Pschism
---

### Step 1: *Hardware Checks*
---------------------------
- After building your HPC cluster, ensure hardware consistency between the compute nodes and head nodes. Spack automatically applies CFLAGS based on the node's hardware during installation. Mismatched hardware may lead to software stack issues, posing challenges for later debugging. 

- Do a cat /proc/cpuinfo on controller/compute node. 
   ```bash
   cat /proc/cpuinfo  | grep -i model\ name | head -1
   ``` 

### Step 2: Spack download - spack from git
--------------------------------------------

The first step is to install spack on your system. To install spack from the github this is how to do it.

- define your SPACK_ROOT
- clone the git repo 

```bash
export SPACK_ROOT=/modeling/spack
git clone -c feature.manyFiles=true https://github.com/spack/spack $SPACK_ROOT
```

### Step 3: Spack configuration: switch to last stable release
---

- The git repo will come with multiple versions. We are going to want one that is stable.
- Use 'git branch -r -v' to view the versions. 
- Use 'git checkout origin/releases/v0.21' to checkout version 21 of spack. 

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

```bash
spack install -j8 gcc@9.2.0+binutils cflags="-O3"
```

- Then we add it the spack complier.yaml file with this processor.
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

- Define your config.yaml 
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

- Define your modules.yaml 
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

- Define your packages.yaml
*packages.yaml* - This file will be written to by the 'spack external find' command. After spack adds the lines, you will need to append some more information.
                  Note, we are putting everything in the "--scope site" just so we know where the file is generated.
          

 - This tells spack to use our system installed vesions of textlive, perl, python and some other libraries. 
  You will need to type these commands in your bash environment. 

-  These commands will generate some basic entries in your packages.yaml file. 
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

- Information that will need to be appended to your package.yaml file. 
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
- This file will be references again later on.
- For spack to compile the spack binaries with MPI support, the compilers.yaml needs to define the environment variables.
- We are skipping the creation of the compilers.yaml for now. 
- This will be touched upon more later since we do not have the intel compiler configured. 



### Step 7: Installing and configuring Intel compilers. 
----


- To install the Intel-oneapi-compilers@2022.1.0 and intel-oneapi-mpi-2021.7.1, use Spack. 
- Once the compiler is installed, configure the compilers.yaml with 'spack compiler add --scope site $(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64'
- Then, set up the compiler.yaml to ensure Spack is aware of which MPI libraries to use. Note that MPI will not work with srun without this configuration, but it will work with mpiexec, albeit at a slower pace. Additionally, compile the Intel compiler in Spack using gcc 9.2.0 and optimization flags. The software stack in this example uses pschism, hdf5, and netcdf-c/fortran, requires the 'classic intel compiler' to compile.

- Base Intel Compiler install is done like this. Adjust the command based on your systems gcc compiler, which may be different.

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

- Classic compiler is referenced by the intel64 path. 
  To tell spack modify the *compiler.yaml*, we run this command: 

```bash
spack compiler add --scope site $(spack location -i /drusa5u)/compiler/latest/linux/bin/intel64
==> Added 1 new compiler to /modeling/spack/etc/spack/compilers.yaml
    intel@2021.6.0
 
==> Compilers are defined in the following files:
    /modeling/spack/etc/spack/compilers.yaml
``` 
- Once the Intel compiler is added to the *compiler.yaml*, it needs to be editted. 
- Modify your compiler.yaml file so that spack can find the MPI libraries used by spack and the compiler libs. 
- Identify where are the slurm MPI libraries are located. Earlier we found that your callpath for the compiler was 'drusa5u'.

```bash
cd $(spack location -i /drusa5u)/compiler/latest/linux/compiler/lib/intel64_lin
echo $PWD
/modeling/spack/opt/spack/linux-centos7-zen2/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-drusa5ufomxfbklm6rbb2xloljxcwgev/compiler/latest/linux/compiler/lib/intel64_lin
```

- Modify the *config.yaml* so that the environment area is defined. 
  The environment area should have the following info.
  
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
- query the compiler by name
```
[myhost ~]$ ls $(spack location -i intel-oneapi-compilers@2022.1.0)/compiler/latest/linux/bin/intel64
codecov  fortcom  fpp  icc  icc.cfg  icpc  icpc.cfg  ifort  ifort.cfg  libcilkrts.so.5  map_opts  mcpcom  profdcg  profmerge  profmergesampling  proforder  tselect  xiar  xiar.cfg  xild  xild.cfg
```

- Test the compiler by displaying the version info. 
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

```
[myhost spack]$ spack install intel-oneapi-mpi@2021.9.0%intel@2021.6.0
==> intel-oneapi-mpi@2021.9.0 : has external module in ['libfabric-aws/1.17.1', 'intelmpi']
[+] /opt/intel (external intel-oneapi-mpi-2021.9.0-ja3rl76w3kwiadg4gcp7vcramorar7es)
```

- Edit the configuration files:
 *Summary: Edit the CC, CXX, IFORT values in your mpi wrappers and reference the compilers.yaml*
 There may be a better way to do this. If you have one, please forward it on.


 *locate* The intel mpi wrapper files - in the bin folder.

```bash
[myhost spack]$ ls $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin
cpuinfo             hydra_nameserver  IMB-MPI1      IMB-MT   IMB-P2P  impi_info  mpicxx   mpiexec.hydra  mpif90  mpigcc  mpiicc   mpiifort  mpitune       tune
hydra_bstrap_proxy  hydra_pmi_proxy   IMB-MPI1-GPU  IMB-NBC  IMB-RMA  mpicc      mpiexec  mpif77         mpifc   mpigxx  mpiicpc  mpirun    mpitune_fast  tune_fast
```

Reference the *compiler yaml* for the intel@2021.6.0
  (aka - intel-classic ) is used to these values. The references in the wrappers need to match up*


- get the compiler info for later reference. 

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

- edit each of wrapper files 

*typically MPII files for MPI-Intel while the MPI files are for gcc*
```bash
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiifort
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpifc
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicpc
 vim $(spack location -i intel-oneapi-mpi@2021.9.0%intel@2021.6.0)/mpi/2021.9.0/bin/mpiicc
```

- verify each of these point the expected compiler
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
   - mpi %oneapi@2021.7.1 - is external on AWS previously built this. 
   - netcdf-fortran@4.5.4 may needs intel classic compiler
   - depends on hdf5+fortran+hl
   - depends on intel-mpi with external libfabric [ aws specific ]

- compile everything at once 
  netcdf@4.9.0, hdf5@1.12.2, netcdf-fortran@4.6.0, and install external mpi so spack can see it.

- Cmake
  Centos7 snafu /usr/bin/cmake is cmake2 rather than /usr/bin/cmake [version 3].
  It might be better to tell spack to use a seperate version of cmake.
  EFA - network stuff depends on cmake2 on centos7.


- To install the software stack run this:
   Note, the command pulls libfabric info from packages.yaml
   '-j48' is set and comes from the config.yaml.
   '--reuse' tells spack to reuse the libaries rather than install new copies. This may change in the future. 
   -'^' is a dependency in spack. 

```bash
spack install --reuse netcdf-fortran@4.6.0%intel@2021.6.0 ^hdf5+fortran+hl%intel@2021.6.0 ^netcdf-c@4.9.0%intel@2021.6.0 ^hdf5@1.12.2%intel@2021.6.0 ^intel-oneapi-mpi@2021.9.0%intel@2021.6.0 cflags="-O3,-shared,-static"
```

- Sucessful results should look like this. 
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
     Refersh the modules by doing this: 

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

   - update the setup-env.sh to use have the new path.

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
 



- create a simple hello_world.c program.
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


- list the mpi binaries on your system.
```bash
ls $(spack location -i intel-oneapi-mpi@2021.9.0)/mpi/latest/bin
```

- prior to being able to compile mpi code you will need to call the load mpi module
```bash
   module load intelmpi
```

- compile the MPI test code with the intel-mpi compiler from spack
  You created c file so you will be using the mpiicc compiler to compile the code. 
```bash
$(spack location -i intel-oneapi-mpi@2021.9.0)/mpi/latest/bin/mpicc modeling/pschism/mpi_test.c -o /modeling/pschism/hello_out
```

- setup a simple sbatch file to test mpi
  Note, we set the path for the module path in here. This may need updating.

```bash
#!/bin/bash

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

- verify the test by looking the slurm.err and slurm.out files.




## PSCHISM specific information
---

- SNAFU with complier : to Compile the pschism code we need to load all the modules used with pschism first.


### Step 13: Prep verify the modules used for pschism exist in spack and can be accessed. 
---

- list the modules available

```bash
module avail
--------------------------------- /modeling/spack/share/spack/modules/linux-centos7-zen2 ----------------------------------
berkeley-db/18.1.40-oneapi-2021.2.0-uevpnh                libfabric/1.18.2-oneapi-2021.2.0-nfoyn4
bzip2/1.0.8-oneapi-2021.2.0-2zpaqr                        libiconv/1.17-oneapi-2021.2.0-wv7fh3
ca-certificates-mozilla/2023-05-30-oneapi-2021.2.0-rr23yt lz4/1.9.4-oneapi-2021.2.0-om4aan
c-blosc/1.21.5-oneapi-2021.2.0-jhwqel                     ncurses/6.4-oneapi-2021.2.0-b6j3se
cmake/3.27.7-oneapi-2021.2.0-ejhvyr                       netcdf-c/4.9.2-oneapi-2021.2.0-g2kwkj
cpio/2.13-oneapi-2021.2.0-6djeie                          netcdf-fortran/4.5.4-oneapi-2021.2.0-zr4nek
curl/8.4.0-oneapi-2021.2.0-nvaxip                         nghttp2/1.57.0-oneapi-2021.2.0-noyvzc
diffutils/3.8-oneapi-2021.2.0-4e7ate                      openssl/3.1.3-oneapi-2021.2.0-ym4a5g
gdbm/1.23-oneapi-2021.2.0-2ybwu6                          patchelf/0.17.2-gcc-9.2.0-jrn2ni
gmake/4.4.1-gcc-9.2.0-mrqghh                              pkgconf/1.9.5-oneapi-2021.2.0-ownafr
gmake/4.4.1-oneapi-2021.2.0-3dqaev                        pmix/4.2.6-oneapi-2021.2.0-ypyayb
hdf5/1.14.3-oneapi-2021.2.0-ici6jg                        readline/8.2-oneapi-2021.2.0-i4n2zg
intel-mpi/2019.10.317-oneapi-2021.2.0-5uvyw3              slurm/23.02.6-oneapi-2021.2.0-2enehb
intel-oneapi-compilers/2021.1.2-gcc-9.2.0-g462ti          snappy/1.1.10-oneapi-2021.2.0-4ne2lt
intel-oneapi-compilers/2021.2.0-gcc-9.2.0-4pjd5d          zlib-ng/2.1.4-oneapi-2021.2.0-kxurjk
intel-oneapi-compilers-classic/2021.1.2-gcc-9.2.0-cj3gte  zstd/1.5.5-oneapi-2021.2.0-gei5ma
libaec/1.0.6-oneapi-2021.2.0-knwa6h
```

- load the modules needed to compile and run pschism 
```bash
module load libfabric/1.18.2-oneapi-2021.2.0-nfoyn4
module load intel-mpi/2019.10.317-oneapi-2021.2.0-5uvyw3
module load hdf5/1.14.3-oneapi-2021.2.0-ici6jg
module load netcdf-c/4.9.2-oneapi-2021.2.0-g2kwkj
module load netcdf-fortran/4.5.4-oneapi-2021.2.0-zr4nek
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

- list modules from the os. Are they loaded ? 
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


- get the [latest] source code
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

- list the branches. In this example,  we want to use icm_Balg.
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

- Snafu - checkout Balg version: Check with Nicole to see if this will work before testing.
```bash
git checkout -b remotes/origin/icm_Balg
Switched to a new branch 'remotes/origin/icm_Balg'
```

### Step 15: Pschism: Prep and build the Source code.
---

- We remove build folder and recreate each build.
```bash
cd /modeling/pschism/schism/src
rm -fr build; mkdir build
```

### Step 16: Pschism: Prep and build create a bash script to do the compiling for you.
---

- check all these paths before attempting to run.
- type 'modules av' to get your modules. 


```bash
vim /modeling/pschism/Test_ICM_ChesBay/load_modules_aws_intel.sh
```

- update the modules so they match your system. 
- type 'modules av' to get your modules. 

```bash
#!/usr/bin/bash
# updated: 11/30/23 
# filename: /modeling/pschism/Test_ICM_ChesBay/load_modules_aws_intel.sh
# holds a list of the moduels to load. Changes each time we rebuild the software stack.

yes 'y'| module clear
module load cmake/3.27.7-oneapi-2021.2.0-n4bs4n
module load libfabric/1.18.2-oneapi-2021.2.0-nfoyn4
module load intel-mpi/2019.10.317-oneapi-2021.2.0-5uvyw3
module load hdf5/1.14.3-oneapi-2021.2.0-dkbvrl
module load netcdf-c/4.9.2-oneapi-2021.2.0-lga6xt
module load netcdf-fortran/4.5.4-oneapi-2021.2.0-eys2rz
```

- This will run the cmake stuff needed to compile the source code. 
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
source $(spack location -i intel-mpi@2019.10.317)/compilers_and_libraries_2020.4.317/linux/mpi/intel64/bin/mpivars.sh

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
  
/modeling/pschism/SCHISM.local.cmake.bluefish.skylake

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

###  Step 17: Prep and build the source Code - Compile using bash script or some other method.
---
```bash
bash compile_pschism_aws_intel-mpi.sh
```

### Step 18: Compile schism from the build directory using make. 
---
```bash
cd /modeling/pschism/schism/src/build
make -j8 pschism
```

### Step 19: - refresh the data.
---
- Data Setup
  1. Each directory needs and outputs folder. This is omitted in the data.
  2. The param.nml file is the configuration file.
      change rnday from 'rnday = 365'  to 'rnday = 1' to reduce cost
       a one day run on ChesBay test should take about 5 mins on AWS.
   
- Get Test Data - for basic tests
```bash
svn co https://columbia.vims.edu/schism/schism_verification_tests/Test_CORIE
mkdir Test_CORE/outputs #create missing outputs directory
```

- Get ICM Test data - source chesapeake bay

```bash
 svn co https://columbia.vims.edu/schism/schism_verification_tests/Test_ICM_ChesBay
 mkdir Test_ICM_ChesBay/outputs # create missing outputs directory
 ```

*IMPORTANT the runs must occur in the target data directory*
```bash
cd .Test_ICM_ChesBay
mkdir outputs
touch sbatch_file_goes_here
```


### Step 20 - Final Step - Running the code.
---
- to run the code you will need a sbatch file

Note, the sbatch file needs to be run from the directory holding the data.
For example, we have the data in a folder called: 

Data dir: /modeling/pschism/Test_ICM_ChesBay

#ref files in cmake_info for latest copies. 
```bash
#!/usr/bin/bash
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

#list_of_modules="intel-oneapi-mpi-2021.7.0-oneapi-2022.2.0-45mbj73 netcdf-c-4.9.0-oneapi-2022.2.0-juhegyh netcdf-fortran-4.6.0-oneapi-2022.2.0-rw2prah hdf5-1.12.2-oneapi-2022.2.0-w64yiqf pmix-4.1.2-gcc-12.2.0-2vc6gpb"

#echo "#!/usr/bin/env bash" > /var/tmp/module_load.sh

#for module_name in $list_of_modules
#   do
#    echo "module load $module_name" >> /var/tmp/module_load.sh
#   done

#source /var/tmp/module_load.sh

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

### End of Step by Step guide

### Trouble shooting tips and snafus
---

- verify that EFA works in the compute node area. If you see, this from the compute nodes EFA may not be working.

```bash
fi_info -p efa
fi_getinfo: -61
```

A successful setup of EFA will look like this:

Could you possibly do a short on checks that are required for getting an AWS cluster setup so MPI works ?
This may be a rudimentary request. But to get MPI working with  models on AWS HPC clusters, normally MPI needs to be functioning. 
Currently, our HPC head cluster in Ohio outputs this when I do a check: 

fi_info -p efa
fi_getinfo: -61

To test EFA, I think I need to be on a compute node. 

```bash
[centos@queue-1-dy-queue-1-cr-1-2 ~]$ fi_info -p efa -t FI_EP_RDM
provider: efa
    fabric: efa
    domain: rdmap0s6-rdm
    version: 118.20
    type: FI_EP_RDM
    protocol: FI_PROTO_EFA
```

*cmake is very picky and doesn't display errors if you don't have your custom files*

- I-MPI tells you what flags are loaded.

```bash
$(spack location -i intel-mpi@2019.10.317)/compilers_and_libraries_2020.4.317/linux/mpi/intel64/bin/impi_info
```

```
 | NAME                                           | DEFAULT VALUE | DATA TYPE |
 ==============================================================================
 |I_MPI_PIN                                       | on            | MPI_CHAR  |
 |I_MPI_PIN_SHOW_REAL_MASK                        | on            | MPI_INT   |
 |I_MPI_PIN_CELL                                  | unit          | MPI_CHAR  |
 |I_MPI_PIN_RESPECT_CPUSET                        | on            | MPI_CHAR  |
 |I_MPI_PIN_RESPECT_HCA                           | on            | MPI_CHAR  |
 |I_MPI_PIN_DOMAIN                                | auto:compact  | MPI_CHAR  |
 |I_MPI_PIN_ORDER                                 | compact       | MPI_CHAR  |
 |I_MPI_OFFLOAD                                   | 0             | MPI_INT   |
 |I_MPI_EXTRA_FILESYSTEM                          | off           | MPI_INT   |
 |I_MPI_FABRICS                                   | shm:ofi       | MPI_CHAR  |
 |I_MPI_MALLOC                                    | 1             | MPI_INT   |
 |I_MPI_SHM_HEAP                                  | -1            | MPI_INT   |
 |I_MPI_SHM_HEAP_OPT                              | -1            | MPI_CHAR  |
 |I_MPI_SHM_HEAP_VSIZE                            | -1            | MPI_INT   |
```


### List of Snafus
------ 

### 1. diffutils on hdf5 
---

Orginally was not able to get hdf5 to compile on the oneapi-compilers with spack version 0.20.3 until hte dependancy of ^diffutils@3.8 was added.
You can either tell packages.yaml about the dependancies. 

```bash
spack install netcdf-fortran%oneapi@2022.1.0
  ^hdf5+fortran+hl%oneapi@2022.1.0
  ^intel-oneapi-mpi%oneapi@2022.1.0
 +external-libfabric ^diffutils@3.8 cflags="-O3,-fPIC"
```

### 2. compiler.yaml fun. 
----

Seems the compiler.yaml for oneapi on spack got modifed. 
Had to modify the compiler.yaml to point to the intel64 versions of the intel compilers to get hdf5 to compile.


```bash
spack compiler info oneapi@2022.1.0
 
oneapi@2022.1.0
 :
        paths:
                cc = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-4pjd5dcymlvje6f7yohtwl7wsm6foy5k/compiler/2021.2.0/linux/bin/intel64/icc
                cxx = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-4pjd5dcymlvje6f7yohtwl7wsm6foy5k/compiler/2021.2.0/linux/bin/intel64/icpc
                f77 = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-4pjd5dcymlvje6f7yohtwl7wsm6foy5k/compiler/2021.2.0/linux/bin/intel64/ifort
                fc = /modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-4pjd5dcymlvje6f7yohtwl7wsm6foy5k/compiler/2021.2.0/linux/bin/intel64/ifort
        environment:
            set:
                I_MPI_PMI_LIBRARY = /opt/slurm/lib/libpmi.so
        modules  = []
        operating system  = centos7
```

### 3. Azure specific issues: Libfabric is missing. 
---

####################################
#Azure: LibFabric issues. Azure doesn't get the libfabic hooks unless they are installed at the OS level.
####################################

```bash
yum install libfabric.x86_64
...
Dependencies Resolved

==================================================================================================================================
 Package                      Arch                 Version                                     Repository                    Size
==================================================================================================================================
Installing:
 libfabric                    x86_64               1.7.2-1.el7                                 base-openlogic               536 k
Installing for dependencies:
 infinipath-psm               x86_64               3.3-26_g604758e_open.2.el7                  base-openlogic               186 k
 libpsm2                      x86_64               11.2.78-1.el7                               base-openlogic               189 k

Transaction Summary
==================================================================================================================================
Install  1 Package (+2 Dependent packages)

Total download size: 910 k
Installed size: 2.4 M
```

### 4. Spack sets the following environment variables when the modules are called.
---

Here is a list of values that Spack setups up when the modules are loaded. 

```
NETCDF_C_ROOT
NETCDF_FORTRAN_ROOT
HDF5_ROOT
HDF5_PLUGIN_PATH
MPICC
MPIFC
INTEL_MPI_ROOT
MPIF77
MPIF90
MPICXX
I_MPI_ROOT
LIBFABRIC_ROOT
LD_LIBRARY_PATH
PATH
CMAKE_PREFIX_PATH
```

### 5. CMAKE doesn't seem link the HDF5 and NETCDF libraries properly. 
---
We see this error in the slurm output file. 


```bash
cat pschism_job_beefy.24.err

Are you sure you want to clear all loaded modules!? [n] Currently Loaded Modulefiles:
  1) libfabric/1.18.2-oneapi-2021.2.0-nfoyn4
  2) intel-mpi/2019.10.317-oneapi-2021.2.0-5uvyw3
  3) pkgconf/1.9.5-oneapi-2021.2.0-ownafr
  4) zlib-ng/2.1.4-oneapi-2021.2.0-kxurjk
  5) hdf5/1.14.3-oneapi-2021.2.0-ici6jg
  6) bzip2/1.0.8-oneapi-2021.2.0-2zpaqr
  7) lz4/1.9.4-oneapi-2021.2.0-om4aan
  8) snappy/1.1.10-oneapi-2021.2.0-4ne2lt
  9) zstd/1.5.5-oneapi-2021.2.0-gei5ma
 10) c-blosc/1.21.5-oneapi-2021.2.0-jhwqel
 11) libaec/1.0.6-oneapi-2021.2.0-knwa6h
 12) netcdf-c/4.9.2-oneapi-2021.2.0-g2kwkj
 13) netcdf-fortran/4.5.4-oneapi-2021.2.0-zr4nek
forrtl: severe (168): Program Exception - illegal instruction
Image              PC                Routine            Line        Source
pschism_AWS_SKYLA  000000000072DF5B  for__signal_handl     Unknown  Unknown
libpthread-2.17.s  00002B27FE7BB630  Unknown               Unknown  Unknown
libhdf5.so.310.3.  00002B27FF560563  H5T__init_native_     Unknown  Unknown
libhdf5.so.310.3.  00002B27FF4C67D8  H5T_init              Unknown  Unknown
libhdf5.so.310.3.  00002B27FF584960  H5VL_init_phase2      Unknown  Unknown
libhdf5.so.310.3.  00002B27FF216290  H5_init_library       Unknown  Unknown
libhdf5.so.310.3.  00002B27FF2E5385  H5Eset_auto2          Unknown  Unknown
libnetcdf.so.19.2  00002B27FBF6110C  nc4_hdf5_initiali     Unknown  Unknown
libnetcdf.so.19.2  00002B27FBF6A50C  NC_HDF5_initializ     Unknown  Unknown
libnetcdf.so.19.2  00002B27FBECF808  nc_initialize         Unknown  Unknown
libnetcdf.so.19.2  00002B27FBED4D7A  NC_open               Unknown  Unknown
libnetcdf.so.19.2  00002B27FBED4A87  nc_open               Unknown  Unknown
libnetcdff.so.7.1  00002B27FC0D5442  nf_open_              Unknown  Unknown
libnetcdff.so.7.1  00002B27FC118E39  netcdf_mp_nf90_op     Unknown  Unknown
pschism_AWS_SKYLA  000000000049D3E6  Unknown               Unknown  Unknown
pschism_AWS_SKYLA  0000000000410052  Unknown               Unknown  Unknown
pschism_AWS_SKYLA  000000000040FF92  Unknown               Unknown  Unknown
libc-2.17.so       00002B27FEBEE555  __libc_start_main     Unknown  Unknown
pschism_AWS_SKYLA  000000000040FEA9  Unknown               Unknown  Unknown
srun: error: compute2-dy-slurmworkers-1: task 0: Exited with exit code 168
```

### 6. cmake pulls in configurations that define what modules are loaded.
---

 - cmake:SCHISM.local build needs the following for pschism to run right 
*defines the modules in pshcism to load/compile*

```bash
set(NO_PARMETIS OFF CACHE BOOLEAN "Turn off ParMETIS")
set (OLDIO ON CACHE BOOLEAN "Old nc output (each rank dumps its own data)")
set (PREC_EVAP ON CACHE BOOLEAN "Include precipitation and evaporation calculation")
set( USE_ICM ON CACHE BOOLEAN "Use ICM module")
```
- CMAKE: SCHISM_local.cmake.bluefish.intel

*defines: custom compiling options*

```bash
[myhost schism]$ cat /modeling/pschism/SCHISM_local.cmake.bluefish.intel
###AWS SKYLAKE CLUSTER
#Name the binary
set (SCHISM_EXE_BASENAME pschism_AWS_SKYLAKE CACHE STRING "Base name (modules and file extension to be added of the executable. If you want a machine name, add it here")
###Relative paths won't work
set(CMAKE_Fortran_COMPILER "ENV{CMAKE_Fortran_COMPILER}" CACHE PATH "Path to serial Fortran compiler")
set(CMAKE_C_COMPILER "$ENV{CMAKE_C_COMPILER}"  CACHE PATH "Path to serial Fortran compiler")
set(NetCDF_FORTRAN_DIR "$ENV{NETCDF_FORTRAN}" CACHE PATH "Path to NetCDF Fortran library")
set(NetCDF_C_DIR  "$ENV{NETCDF}"  CACHE PATH "Path to NetCDF C library")
###Compile flags. If USE_WWM, change to -O2
#set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -mtune=skylake -init=zero -align array64byte -finline-functions" CACHE STRING "Fortran flags" FORCE)
#base compiler configuration is simple
set(CMAKE_Fortran_FLAGS_RELEASE "-O2 -debug minimal" CACHE STRING "Fortran flags" FORCE)
```

### 7. How NOAA is running pshchism.
---

 - NOAA run used this info.

Ref: sbatch job ref : export variables 
```bash
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export I_MPI_ROOT=$(spack location -i intel-oneapi-mpi%oneapi@2022.1.0
 )/mpi/2021.7.0
export MPI_PMI_LIBRARY=/opt/slurm/lib/libpmi2.so #when using srun through Slurm
export I_MPI_FABRICS="shm:ofi"
export FI_LOG_LEVEL=debug
export I_MPI_DEBUG=5
```



####################
#REF:noaa - 9/29/22 run 
####################

These are the modules I'm using in our setup for SCHISM:
```bash
module load cmake
module load intel/2021.3.0
module load impi/2021.3.0
module load hdf5/1.10.6
module load netcdf/4.7.0
```

The cluster environment we have uses a custom AMI, but the support team has told me it's similar to centos:centos7.8.2003.
For srun I had to specify pmi2. Actually our environment used to be AWS PCluster before, and back then I had to use --mpi=pmi2; now we moved to a custom cluster setup where  I should directly use mpirun

If you can, I would suggest that you use a combination of compilers and libraries that you know should work for SCHISM in your case; for example something you might have used on another HPC platform before.

This is the compile script I use:
```bash
#for cmake
export  CMAKE_Fortran_COMPILER=mpiifort
export  CMAKE_CXX_COMPILER=mpiicc
export  CMAKE_C_COMPILER=mpiicc
export  FC=ifort
export  MPI_HEADER_PATH='/apps/oneapi/mpi/2021.3.0'

export NETCDF='/apps/netcdf/4.7.0/intel/18.0.5.274'

export  NetCDF_C_DIR=$NETCDF
export  NetCDF_INCLUDE_DIR=$NETCDF"/include"
export  NetCDF_LIBRARIES=$NETCDF"/lib"
export  NetCDF_FORTRAN_DIR=$NETCDF
export  PARMETIS_DIR=${src_dir}/src/ParMetis-*/

#make parmetis seperatly
cd ${PARMETIS_DIR}
make

export  TVD_LIM=VL
cd ${src_dir}

#clean cmake build folder
rm -rf build_mpiifort
mkdir build_mpiifort

#cmake
cd build_mpiifort
cmake ../src \
    -DCMAKE_Fortran_COMPILER=$CMAKE_Fortran_COMPILER \
    -DCMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER \
    -DCMAKE_C_COMPILER=$CMAKE_C_COMPILER \
    -DMPI_HEADER_PATH=$MPI_HEADER_PATH \
    -DNetCDF_C_DIR=$NetCDF_C_DIR \
    -DNetCDF_INCLUDE_DIR=$NetCDF_INCLUDE_DIR \
    -DNetCDF_LIBRARIES=$NetCDF_LIBRARIES \
    -DNetCDF_FORTRAN_DIR=$NetCDF_FORTRAN_DIR \
    -DTVD_LIM=$TVD_LIM \
    -DUSE_PAHM=TRUE

#gnu make
make -j 6
```

### 8. Different ways to install the software stack
---

- Intel-oneapi-mpi build with one command
```bash
spack spec netcdf-fortran%oneapi@2022.1.0
  ^hdf5+fortran+hl%oneapi@2022.1.0
  ^intel-oneapi-mpi%oneapi@2022.1.0
 +external-libfabric

spack install --no-cache -j32 netcdf-fortran@4.6.1%oneapi@2022.1.0
  ^hdf5+fortran+hl%oneapi@2022.1.0
  ^intel-oneapi-mpi%oneapi@2022.1.0
 +external-libfabric ^diffutils@3.8 cflags="-O3" #AWS
```

- Optional install the MPI libraries individually

```bash
spack install --no-cache -j32 intel-mpi%oneapi@2022.1.0
 +external-libfabric cflags="-O3,-fpic" #AWS 
```


- Informational Azure specific MPI builds

```bash 
  spack install --no-cache hdf5+fortran+hl%oneapi@2022.1.0
  ^intel-oneapi-mpi%oneapi@2022.1.0
 +external-libfabric ^diffutils@3.8  cflags="-O3,-fPIC"
  spack install netcdf-fortran%oneapi@2022.1.0
  ^hdf5+fortran+hl%oneapi@2022.1.0
  ^intel-oneapi-mpi%oneapi@2022.1.0
 +external-libfabric cflags="-O3,-fPIC"
```

### References 
---

- old setup guide https://jiaweizhuang.github.io/blog/aws-hpc-guide/

- spack environments https://hpc.nmsu.edu/discovery/software/spack/environments/

-NOAA has the best documenation  https://github.com/JCSDA/spack-stack/tree/develop/configs/sites/aws-pcluster

END/end












[Extra stuff to be worked in later will come after this.]
















*Omitted text to be worked in later*

# Azure specific 

### AZURE Specific 
-  Azure comes with gcc9.2.0 pre installed.
-  Just need to add the compiler to spack. This command should add it to the compiler.yaml. 
```
spack compiler find --scope site /opt/gcc-9.2.0/ #AZURE specific
```


  Snafu *MPI on Azure( - Libfabric is not part of the Azure cluster. 
      To use Libfabric on Azure, some post install magic needs to ocurr to install this subsystem on the head and compute nodes.
       The package information needs to be defined in packages.yaml.



File: *packages.yaml*  base config Azure specific - not tested 

```yaml
packages:
 hpcx-mpi:
    buildable: false
    externals:
    - spec: hpcx-mpi@2.8.3
      prefix: /opt/hpcx-v2.8.3-gcc-MLNX_OFED_LINUX-5.2-2.2.3.0-redhat7.9-x86_64/ompi
 libfabric:
   variants: fabrics=tcp,tcp,udp,sockets,verbs,shm,mrail,rxd,rxm schedulers=slurm
   externals:
   - spec: libfabric@1.7.2 fabrics=tcp,tcp,udp,sockets,verbs,shm,mrail,rxd,rxm
   buildable: False
 slurm:
  variants: +pmix sysconfdir=/etc/slurm
  externals:
  - spec: slurm@23.02 +pmix sysconfdir=/etc/slurm
     #prefix: /opt/slurm
     buildable: False
 # mpi:
 # variants: +pmix sysconfdir=/etc/slurm
 # externals:
 # - spec slurm@23.02 +pmix syscnfdir=/etc/slurm
 #    prefix: /opt/intel/oneapi/mpi/2021.2.0
 #    buildable: False
```
- for AZURE things are easy with Centos7


Environment for Intel compiler which is not installed yet:
```yaml
  ...
  environment:
      prepend_path:
        LD_LIBRARY_PATH: '/modeling/spack/opt/spack/linux-centos7-skylake_avx512/gcc-9.2.0/intel-oneapi-compilers-2022.1.0-or3ebystfoy624o55d3sedgvwwxelhx7/compiler/2022.1.0/linux/compiler/lib/intel64_lin'
      set:
        I_MPI_PMI_LIBRARY: '/opt/slurm/lib/libpmi.so'
  ```

