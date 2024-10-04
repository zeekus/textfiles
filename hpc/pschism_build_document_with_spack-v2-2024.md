# PSCHISM install guide for AWS pcluster
- Last edit: 10/3/24
- Author: Theodore Knab aka Zeekus on github
- Quality: Document has not been tested. 
- Version: v2.0
- Licence: MIT license

- Software used in build: 
   - pcluster 3.10.1 https://github.com/aws/aws-parallelcluster/blob/develop/CHANGELOG.md
   - spack  v0.22.0 https://github.com/spack/spack
   - pschism (develop git hash edd85269) https://github.com/schism-dev/schism
   - Intel + GCC MPI from Spack  
   - Intel + GCC Compiler from Spack 
   - Rocky Linux release 8.10 (Green Obsidian)
- Hardware: 
   - Head-node    : 1 AWS - c4.8xlarge   
   - Compute-nodes: 8 AWS - c4.8xlarge 
- Model Run time: ref - params.nml in the data directory to change the default run times from 365 days. 
    ~~10 day test 33 mins with 96 cpus in sbatch.( possible issues with MPI chatter. )~~
    ~~10 day test 30 mins with 72 cpus in sbatch.~~
    ~~1  day test 5 minutes with 72 cpus in sbatch.~~   

## Executive Summary
This document provides a comprehensive guide for installing Spack and setting up the Pschism software stack, including HDF5, NetCDF-C, NetCDF-Fortran, and configuring MPI with both GCC and Intel compilers. Action items are indicated by a checkbox format:
   - [ ] [example action item] in the text. 
Note: This document does not cover how to set up a cluster using PCluster or Azure.
## Software Stack Requirements

## Intel-Specific Requirements
  - Intel Compiler: intel-oneapi-compilers-classic@2021.10.0%gcc@12.2.0 (classic version)
  - Intel MPI: intel-oneapi-mpi@2021.12.1 (depends on Libfabric)
  - HDF5: hdf5@1.14.0
  - NetCDF-C: netcdf-c@4.9.2
  - NetCDF-Fortran: netcdf-fortran@4.6.0
  - Libfabric: libfabric@1.21.0 (note: this is frequently updated)
  - NCO: nco@5.1.9 (post-processing)

## GCC 12.0.2 Specific Requirements

For building the Pschism software stack using GCC compilers, the following components are required:
  - GCC Compiler: gcc@12.2.0 (classic version)
  - MPI: openmpi@5.0.2 (depends on Libfabric)
  - HDF5: hdf5@1.14.0
  - NetCDF-C: netcdf-c@4.9.2
  - NetCDF-Fortran: netcdf-fortran@4.6.0
  - NCO: nco@5.1.9 (post-processing)

## Overview of Covered Topics
This documentation includes the following key topics:
1.  Define snafus. This is intentially put at top to save the reader some time. 
2.  Step-by-Step Guide: Detailed instructions for installing and running Pschism, including setups for Intel MPI and GCC OpenMPI 5.
3. Spack Installation: Instructions for installing Spack from Git.
4. Spack Configuration: Guidance on configuring Spack to recognize current system packages, compilers, and modules.

Modify the following configuration files:

    * packages.yaml
    * compilers.yaml
    * config.yaml
    * modules.yaml

    Explanation of how to inform Spack about external Libfabric and Intel MPI.

  5. Using Spack Environments: Instructions for creating compartmentalized environments using Spack recipes.
  6. Loading Environment Variables: How to use Spack load commands effectively.
  7. Testing MPI: Instructions for conducting an MPI "Hello World" test in C, including an SBATCH script.
  8. Pschism Setup:
    - Building Pschism with CMake.
    - Obtaining test datasets for Pschism from Subversion.
    - Running Pschism tests with an accompanying SBATCH script.




  ## Extra Information: Know snafus

  Please be aware that occasional snafus may arise, impacting the expected outcome. We encourage you to review the details to ensure preparedness for any potential disruptions.
 
  1. To ensure hardware compatibility and avoid unexpected errors when running compiled binaries, it's crucial to verify that the hardware matches on both the head nodes and compute nodes. Spack automatically adds CFLAGS to the compiled packages, which can lead to issues if the binaries are executed on hardware expecting different CFLAGS.

  2. If you are using EFA: To ensure proper functionality of MPI with EFA, it is important to verify EFA setup with IntelMPI.

  To verify EFA, use the command `fi_info -p efa` on the compute nodes. A return value of -61 indicates a potential issue that may affect MPI functionality. It's important to note that this error may occur on the head nodes, as they are primarily used as the launch pad.

  3. Compiling the Pschism Binary: A custom CMake file that does not exist can cause CMake to fail without providing an error message.

  4. Pschism Modules: For the ICM test with the Pschism binary, we need four modules enabled in the SCHISM.local.build.
     Note ParMETRIS is referenced as off to build ParMETIS and subpart.
     ```bash
     set(NO_PARMETIS OFF CACHE BOOLEAN "Turn off ParMETIS")
     set (OLDIO ON CACHE BOOLEAN "Old nc output (each rank dumps its own data)")
     set (PREC_EVAP ON CACHE BOOLEAN "Include precipitation and evaporation calculation")
     set( USE_ICM ON CACHE BOOLEAN "Use ICM module")
     ```

  5. Compilers and Slurm's libpmi Library: To resolve issues with Spack v20 and above, modify the compilers.yaml to point to the intel64 variants for successful compilation.
   ```yaml
  environment:
   prepend_path:
    #found by using cd $(spack -i location intel-oneapi-compilers-classic@2021.10.0)/compiler/lib/intel64_lin
    LD_LIBRARY_PATH: '/modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/intel-oneapi-compilers-classic-2021.10.0-qc4l6vaafkhnrzdcdvse2t2ve4c4v4hk/compiler/lib/intel64_lin'
   set:
    I_MPI_PMI_LIBRARY: '/opt/slurm/lib/libpmi.so'
   ```

  5. Compiler Info and Flags: This document covers specific versions of Intel and GCC compilers tested with Pschism.
  
  6. Libfabric Updates: Libfabric seems to be updated frequently; ensure your Spack packages.yaml is updated accordingly.    

  
## Extra Information: Spack Area - Cheat Sheet of Commands

*This area gives a cheat sheet of spack commands.*

# Listing Compilers    
 - Command: `spack compilers` 
   Description: Lists the compilers registered with Spack from the 'compiler.yaml' file. 
```bash
spack compilers
==> Available compilers
-- gcc rocky8-x86_64 --------------------------------------------
gcc@8.5.0
```

# Listing Installed Packages
 - Command: `spack find`
   Description: Displays the packages that Spack is aware of, including some external packages.  
```bash
spack find
-- linux-centos7-x86_64_v3 / gcc@4.8.5 --------------------------
autoconf@2.69  automake@1.13.4  binutils@2.27.44  diffutils@3.3  gawk@4.0.2  gcc@9.2.0  gmake@3.82  gmp@6.2.1  libtool@2.4.7  m4@1.4.16  mpc@1.1.0  mpfr@3.1.6  perl@5.16.3  texinfo@5.1  zlib-ng@2.1.4
```

# Listing Files by Callpaths
 - Command: `spack find -dl`
   Description: Lists installed packages by their callpaths, useful when multiple copies of the same software package are installed. 

# Rebuilding Modules in Spack
 - Command: `spack module tcl refresh --delete-tree`
   Description: Rebuilds the modules in Spack after installation; a new bash instance may be required to see the modules (logging out and back in works). The modules.yaml file controls how these are generated.

# Writing Spack Configurations to Disk: 
 - Command: `spack config --scope site update config`
   Description: Writes changes to Spack configuration files to disk after manual modifications.

# Uninstalling All Packages in a Group
 - Command: `spack uninstall --all %intel@2021.10.0`
  Description: Uninstalls all Spack packages associated with a specific compiler version.

# Inspecting Depedencies on a Package

 - By Hash Command: `spack dependencies --installed /hash` 
   Description: Inspects dependencies for a package referenced by its hash.

 - By Common Name Command: `spack dependencies --installed intel-oneapi-mpi@2021.9.0`
   Description: Inspects dependencies for a package referenced by its common name.



## The main area: Step by Step setup of Spack, MPI, and Pschism

*Reader notes* 
Please be aware the following notion tells the reader they need to take some action. 
- [ ] Action item. This may keep you/me on task. 

- use a non-root user for your intall. On rocky8 this may be your *rocky* user. 

### Step 1: *Hardware Checks*
------

- After building your HPC cluster, ensure hardware consistency between the compute nodes and head nodes. Spack applies CFLAGS based on the node's hardware during installation; mismatched hardware can lead to software stack issues.

- [ ] Check CPU information on the controller/compute node:
   ```bash
   cat /proc/cpuinfo  | grep -i model\ name | head -1
   ``` 

### Step 2:  Download Spack from Git


Preperation 
------
1. Define the Spack Storage Location: Choose a volume accessible to both head nodes and compute nodes. For this example, we will use a shared IO2 volume called /modeling.

2.  [ ] Set the SPACK_ROOT environment variable:
```bash 
export SPACK_ROOT=/modeling/spack
```

Installation
------
1. [ ]  Create the Spack directory and set permissions:
```bash
sudo mkdir -p $SPACK_ROOT
sudo chown rocky:rocky $SPACK_ROOT -R 
```

2. [ ] Clone the Spack Git repository:
```bash
git clone -c feature.manyFiles=true https://github.com/spack/spack $SPACK_ROOT
```

### Step 3: Spack Configuration - Switch to Last Stable Release
------
- [ ] Checkout the version 22 release of spack or the latest stable branch.  

```bash
cd $SPACK_ROOT
git branch -r -v
git checkout  origin/releases/v0.22 #9/23
```

Notes:

  * The Git repository includes multiple versions; use git branch -r -v to view available versions.
  * After checkout, you will be in a 'detached HEAD' state, which is normal.


### Step 4: Set Up the SPACK Environment

- [ ] Setup the spack environment.

```bash
source $SPACK_ROOT/share/spack/setup-env.sh
echo "export SPACK_ROOT=$SPACK_ROOT" >> $HOME/.bashrc
echo "source $SPACK_ROOT/share/spack/setup-env.sh" >> $HOME/.bashrc
spack install libelf #snufu for spack
```

Notes:

  * This loads the Spack environment from the command line and adds it to .bashrc, ensuring it loads every time Bash is initiated.
  * On AWS, home directories are shared, allowing changes on the head node to propagate to compute nodes. Azure does not have this feature.

For further details and troubleshooting, refer to the Spack documentation and community forums for best practices and specific use cases.

For further details and troubleshooting, refer to the Spack documentation and community forums for best practices and specific use cases.
Citations:
[1] https://github.com/spack/spack/issues/10267
[2] https://docs.nersc.gov/applications/e4s/spack/
[3] https://github.com/spack/spack/issues/30547
[4] https://aws.amazon.com/blogs/hpc/install-optimized-software-with-spack-configs-for-aws-parallelcluster/
[5] https://chtc.cs.wisc.edu/uw-research-computing/hpc-spack-setup

## Installing the Compilers

- For AWS with Rocky8, we have an older version of GCC (8.5.0).

### Step 5: Setup Compilers for Intel Compiler Compilation
------

Find and Add Default Compiler

- [ ] Add Rocky's default gcc 8.5.0 compiler to Spack's catalog:

```bash
spack compiler find --scope site
```

Expected Output: 
```text
==> Added 1 new compiler to /modeling/spack/etc/spack/compilers.yaml
    gcc@8.5.0
```

Verify site Compiler Configuration:
The /modeling/spack/etc/spack/compilers.yaml file should look like this:

```yaml
compilers:
- compiler:
    spec: gcc@=8.5.0
    paths:
      cc: /usr/bin/gcc
      cxx: /usr/bin/g++
      f77: /usr/bin/gfortran
      fc: /usr/bin/gfortran
    flags: {}
    operating_system: centos7
    target: x86_64
    modules: []
    environment: {}
    extra_rpaths: []
```

- [ ] Configure External Packages - Tell spack of about our pre-installed packages. 

```bash
export SPACK_SYSTEM_CONFIG_PATH=$SPACK_ROOT/etc/spack
spack external find --scope site --exclude cmake
spack external find --scope site texlive 
spack external find --scope site perl 
spack external find --scope site python 
spack external find --scope site libfabric 
spack external find --scope site slurm 
```

- [ ] Install a newer GCC Compiler 

```bash
spack install -j8 gcc@12.2.0+binutils cflags="-O3"
```

- [ ] Add the new compiler to your site config. 
```bash
spack compiler find --scope site $(spack location -i gcc@12.2.0)/bin 
```

### Step 6: Review and Familiarize Yourself with Spack Configuration
------

Spack manages its behavior through several configuration files, including config.yaml, modules.yaml, packages.yaml, and compilers.yaml. These files can exist in different locations, leading to potential confusion:


    - *Default configurations* are stored in $SPACK_ROOT/etc/spack/default.
    - *Site-level overrides* are in $SPACK_ROOT/etc/spack.
    - *User-specific configurations*  are found in ~/.spack.

To avoid conflicts and ensure consistent configurations:
    - To avoid conflicts and ensure consistent configurations:
    - Be aware of the search order: home directory, then $SPACK_ROOT/etc/spack/, and finally $SPACK_ROOT/etc/spack/default/.
    - Document and communicate the locations and purposes of your Spack configurations.

Key Configuration Files:

1. **config.yaml**
  - Stores global configuration settings for Spack, such as install tree and build stage.

2. **modules.yaml**
   - Used to generate module files that set up the environment for software packages.

3. **packages.yaml**
   - Configures Spack to use externally-installed packages rather than building its own versions.

4. **compiler.yaml**
   - Defines and configures compilers in Spack, specifying paths, flags, and settings.

By customizing these configuration files, users can control various aspects of Spack, such as package management, module file generation, and compiler configuration.

For this guide, most of the example files are copied from NOAA's git hub site and have been tested as valid on AWS running Centos7.
source - https://github.com/JCSDA/spack-stack/tree/develop/configs/sites/aws-pcluster (Ubuntu specific )

### Step 7: Customize Your Spack Configuration for Proper Builds

Site Files to Edit:
- /modeling/spack/etc/spack/packages.yaml
- /modeling/spack/etc/spack/compilers.yaml

- [ ] Determine the PMIX version and location.

```bash
/opt/pmix/bin/pmix_info | grep -i pmix
```

[ ] Add PMIX information to $SPACK_ROOT/etc/spack/packages.yaml:

```yaml
  pmix:
    externals:
    - spec: pmix@4.2.8%8.5.0
      prefix: /opt/amazon/pmix
    buildable: false
```

[ ] Run ```spack find``` to verify no errors were introduced into the config file. 
   * Note: A typo in the YAML will generate an error.

- [ ] Determine the system installed OpenMPI versions and their locations.

```
find /opt/amazon -iname 'openmp*' 2>/dev/null -maxdepth 1
```

- [ ] Edit your `package.yaml`  if they are missing libfabric, slurm, openmpi, or pmix.
      Here is an example of important entries:

```yaml
packages:
  libfabric:
    externals:
    - spec: libfabric@1.21.0 fabrics=shm,sockets,tcp,udp
      prefix: /opt/amazon/efa
  slurm:
    externals:
    - spec: slurm@23.11.7
      prefix: /opt/slurm
  openmpi:
    externals:
    - spec: openmpi@4.1.6%gcc@=8.5.0+atomics~cuda~cxx~cxx_exceptions~java~memchecker+pmi~static~wrapper-rpath
        fabrics=ofi schedulers=slurm
      prefix: /opt/amazon/openmpi
    - spec: openmpi@5.0.2%gcc@=8.5.0+atomics~cuda~cxx~cxx_exceptions~java~memchecker+pmi~static~wrapper-rpath
        fabrics=ofi schedulers=slurm
    buildable: false
  pmix:
    externals:
    - spec: pmix@4.2.8%8.5.0
      prefix: /opt/amazon/pmix
    buildable: false
```

- [ ] Verify no errors were introduced by running the following command to check for errors in packages.yaml:
```bash
spack external find --help
```

### Create Two Environments for Spack.

- [ ] Create an *Intel-Schism* Environment:
```bash
spack env create intel-schism
```

- [ ] use this build recipe to define the environment.
      *Note* alter `/modeling/spack` to your `$SPACK_ROOT`

```bash 
cat > $SPACK_ROOT/var/spack/environments/intel-schism/spack.yaml  <<EOF
```

- [ ] copy and paste the text from spack to EOF in the YAML. 

```yaml
spack:
  #intel-schism environment
  concretizer:
    unify: true
  modules:
    default:
      enable:
      - tcl
      - lmod
  view: false
  specs:
  - intel-oneapi-compilers-classic@2021.10.0%gcc@12.2.0
  - intel-oneapi-mpi@2021.12.1
  - netcdf-fortran@4.6.0 ^intel-oneapi-mpi@2021.12.1+external-libfabric
  - hdf5@1.14.0 +hl +mpi ~tools ~szip +shared
  - netcdf-c@4.9.2 +mpi ~dap ~szip +shared
  - perl@5.26.3
  - nco
  packages:
    all:
      providers:
        mpi: [intel-oneapi-mpi@2021.12.1]
      require:
      - any_of: ['%intel-oneapi-compilers-classic@2021.10.0', '%intel@2021.10.0',
          '%gcc', '%gcc@12.2.0']
      - any_of: [build_type=Release, '@:']
      - any_of: [~shared, '@:']
      - any_of: [+pic, '@:']
      - any_of: [cmake@3.27.9%gcc@12.2.0]
    libxml2:
      require: +shared
    gettext:
      require: +shared
    netcdf-c:
      require: build_system=autotools
    netcdf-fortran:
      require: build_system=autotools
      #intel-oneapi-compilers-classic@2021.10.0:
      #require: '%gcc-12.2.0'
    perl:
      require: '@5.26.3'
      externals:
      - spec: perl@5.26.3~cpanm+opcode+open+shared+threads
        prefix: /usr
    cmake:
      externals:
      - spec: cmake@3.27.9%gcc@12.2.0
        prefix: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/cmake-3.27.9-hc7lzzkr4awwrcdxzxl5ju2iua3f6h2s
    intel-oneapi-compilers-classic:
      externals:
      - spec: intel-oneapi-compilers-classic@2021.10.0%gcc@12.2.0
        #- spack location -i intel-oneapi-compilers-classic@2021.10.0%gcc@12.2.0
        prefix: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/intel-oneapi-compilers-classic-2021.10.0-qc4l6vaafkhnrzdcdvse2t2ve4c4v4hk
    intel-oneapi-compilers:
      version: [2023.2.4]
    intel-oneapi-mpi:
      version: [2021.12.1]
    libfabric:
      externals:
      - spec: libfabric@1.21.0 fabrics=shm,sockets,tcp,udp
        prefix: /opt/amazon/efa
  compilers:
  - compiler:
      spec: intel@=2021.10.0
      paths:
        cc: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/intel-oneapi-compilers-2023.2.4-msxrrje56bvmx5ikswkpvo72ph5nuikb/compiler/2023.2.4/linux/bin/intel64/icc
        cxx: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/intel-oneapi-compilers-2023.2.4-msxrrje56bvmx5ikswkpvo72ph5nuikb/compiler/2023.2.4/linux/bin/intel64/icpc
        f77: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/intel-oneapi-compilers-2023.2.4-msxrrje56bvmx5ikswkpvo72ph5nuikb/compiler/2023.2.4/linux/bin/intel64/ifort
        fc: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-12.2.0/intel-oneapi-compilers-2023.2.4-msxrrje56bvmx5ikswkpvo72ph5nuikb/compiler/2023.2.4/linux/bin/intel64/ifort
      flags: {}
      operating_system: rocky8
      target: x86_64
      modules: []
      environment:
        set:
          I_MPI_PMI_LIBRARY: /opt/slurm/lib/libpmi.so
      extra_rpaths: []
EOF
```

- [ ]  Create a *GCC* Environment:  

```bash
spack env create gcc-schism
```

- [ ] Define the Environment Using the Build Recipe:
      *Note* alter `/modeling/spack` to your `$SPACK_ROOT`

```bash
cat > $SPACK_ROOT/var/spack/environments/gcc-schism/spack.yaml <<EOF
```
- [ ] copy and paste the text from spack to EOF in the YAML. 

```yaml
spack:
  specs:
  - gcc@12.2.0
  - openmpi@5.0.2
  - perl@5.26.3
  - netcdf-fortran@4.6.0 +shared ^openmpi@5.0.2
  - netcdf-c@4.9.2  +mpi ~dap ~szip +shared
  - hdf5@1.14.0 +hl +mpi ~tools ~szip +shared
  - nco
  concretizer:
    unify: true
  modules:
    default:
      enable:
      - tcl
      - lmod
        #lmod:
        #core_compilers:
        #- gcc@=.2.0
  view: true
  packages:
    all:
      providers:
        mpi: [openmpi@5.0.2]
      require:
      - any_of: ['%gcc@12.2.0', '%gcc']
      - any_of: [build_type=Release, '@:']
      - any_of: [~shared, '@:']
      - any_of: [+pic, '@:']
      - any_of: [openmpi@5.0.2]
    libxml2:
      require: +shared
    gettext:
      require: +shared
    perl:
      require: '@5.26.3'
      externals:
      - spec: perl@5.26.3~cpanm+opcode+open+shared+threads
        prefix: /usr
    openmpi:
      externals:
      - spec: openmpi@5.0.2%gcc@=12.2.0 schedulers=slurm
        prefix: /opt/amazon/openmpi5
        extra_attributes:
          environment:
            prepend_path:
              PATH: /opt/amazon/openmpi5/bin:$PATH
              LD_LIBRARY_PATH: /opt/amazon/openmpi5/lib64:$LD_LIBRARY_PATH
      buildable: false
    gcc:
      #prenents gcc@9.2.0 from being installed twice
      externals:
        - spec: gcc@12.2.0
          prefix: /modeling/spack/opt/spack/linux-rocky8-haswell/gcc-8.5.0/gcc-12.2.0-akjd3fbqzyfyg2vvdkkmvwsnmgq3yr6t
          buildable: false  # Prevent Spack from trying to build this compiler
    pkgconf:
      externals:
        - spec: pkgconf@1.4.2%gcc@=8.5.0
          prefix: /usr
        - spec: pkgconf@1.4.2%gcc@=12.2.0
          prefix: /usr
EOF
```
- [ ] Build the intel-schism environment with the Recipe.

```bash
spack env activate intel-schism
concretize
spack install
```

- [ ] Leave the intel-schism Environment
```bash
spack env deactivate
```

- [  ] Build the gcc-schism environment with the Recipe

```bash
spack env activate gcc-schism
concretize
spack install
```

- [ ] Leave the GCC-schism Environment
```bash
spack env deactivate
```

### Step 9: Test All the compilers after Installation
------

```bash
spack env deactivate
spack env activate intel-schism
spack load  intel-oneapi-compilers-classic@2021.10.0 intel-oneapi-mpi@2021.12.1
mpiifort --version; ifort --version
```

- Expected Output

```text
ifort (IFORT) 2021.10.0 20230609
Copyright (C) 1985-2023 Intel Corporation.  All rights reserved.

ifort (IFORT) 2021.10.0 20230609
Copyright (C) 1985-2023 Intel Corporation.  All rights reserved.
```

[ ] run a `spack find` and Review the Environment 
```bash 
spack find
```

[ ] Verify Compiler Variables in our GCC Environment
```bash
spack env deactivate
spack env create gcc-schism
spack load gcc@12.2.0
spack load openmpi@5.0.2
mpifort --version; gcc --version
```

- Expected Output 
```text
GNU Fortran (Spack GCC) 12.2.0
Copyright (C) 2022 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

gcc (Spack GCC) 12.2.0
Copyright (C) 2022 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

[ ] run a `spack find` and review the environment 
```bash 
spack find
```


### Step 10: Spack related: Refresh the modules [ if needed ]
------

  If you encouter issues loading any of the modules, refresh them as follows: 

    
  - [ ] Refresh the modules *If needed* : 

   ```bash
   yes 'y' | spack module tcl refresh --delete-tree
   bash
   module avail
   ```
  
### Step 11: Pre-preperation- Test MPI on the system.
------
* Pschism requires MPI; testing it first ensures functionality for Pschism.
1. Create a Simple MPI Test:

[ ] create a  `hello_world.c` program.

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

[ ] Load the MPI module.

```bash
spack env deactivate 
spack env activate intel-schism
module load $(spack module tcl find libfabric@1.21.0)
module load $(spack module tcl find intel-oneapi-mpi@2021.12.1)
module load $(spack module tcl find intel-oneapi-compilers-classic@2021.10.0)
```

[ ] Compile the MPI Test Code:

```bash
mpicc /modeling/pschism/mpi_test.c -o /modeling/pschism/hello_out
```

- [ ] Set Up a Simple SBATCH File to Test MPI:
  Create a script named my_hello_world_slurm.sh:

```bash
#!/bin/bash
#filename: my_hello_world_slurm.sh

#SBATCH --threads-per-core=1
#SBATCH -N 2
#SBATCH --ntasks-per-node=10
#SBATCH --time=00:10:00  # Adjust the time limit as needed
####SBATCH -p standard96  # Adjust the partition as needed

#load spack environment 
source /modeling/spack/share/spack/setup-env.sh

spack env deactivate
spack env activate intel-schism
module load $(spack module tcl find libfabric@1.21.0)
module load $(spack module tcl find intel-oneapi-mpi@2021.12.1)
module load $(spack module tcl find intel-oneapi-compilers-classic@2021.10.0)


# Print the fully qualified domain name of the host
hostname --fqdn

echo "Loading mpi envi using spack"

spack load --list


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

- [ ] Run your sbatch MPI test.

```bash
sbatch my_hello_world_slurm.sh
```

[ ] Verify the Test Results: Check the `slurm.err` and `slurm.out` files for output.

### Step 12: Get the Latest Pschism Source Code

- [ ] Clone the Latest Source Code:
```bash
cd /modeling/pschism
git clone https://github.com/schism-dev/schism.git
```

- [ ] List Available Branches:
```bash
cd schism/
git branch -a
```

- [  ] Checkout the Desired schism Branch. 
   To switch to the `icm_Balg` branch:
```bash
git checkout -b remotes/origin/icm_Balg
```

### Step 13: Prepare and Build the Source Code for Pschism

* [ ] Clean and Recreate the build folder

```bash
cd /modeling/pschism/schism/src
rm -rf build; mkdir build
```


### Step 14: Compile Pschism with Spack Intel Compiler
------

- [ ] Use This Bash Script to Compile Pschism: Create a script named `pschism_intel_compiler.sh`:

```bash
#!/bin/bash

spack env deactivate
spack env activate intel-schism

schism_root="$HOME/schism-test" 
mpi_library="intel-oneapi-mpi@2021.12.1"
my_compiler="intel@2021.10.0"
mymodules="$mpi_library hdf5@1.14.0 libfabric@1.21.0 nco@5.1.9 netcdf-c@4.9.2 netcdf-fortran@4.6.0"

echo "Clear loaded modules"
module purge

for mymodule in $mymodules; do
    module load $(spack module tcl find $mymodule)
done

echo "Set all compiler variables"
export FC=$(spack location -i $mpi_library)/mpi/latest/bin/mpiifort
export CC=$(spack location -i $mpi_library)/mpi/latest/bin/mpiicc
export CXX=$(spack location -i $mpi_library)/mpi/latest/bin/mpiicpc

# Set additional environment variables as needed...

# Check for required CMake files before proceeding with compilation.
if [[ ! -e "$local_build_for_cmake" || ! -e "$custom_build_for_cmake" ]]; then 
    echo "ERROR: Required CMake files are missing."
    exit 1 
fi

# Run CMake to configure the build.
cmake -C $local_build_for_cmake -C $custom_build_for_cmake \
    -D CC=$CC \
    -D FC=$FC \
    -D CMAKE_Fortran_COMPILER=$CMAKE_Fortran_COMPILER \
    ...

# Compile Pschism.
make pschism 
```

[ ] Compile with source or '.'

```bash
source pschism_intel_compiler.sh
make pschism
```

## Step 15: Compile Pschism with Spack GCC Compiler Using OpenMPI5


[ ] Navigate to Your Staging Directory (one level above your Schism source directory):
  
```bash
cd ~/schism-test
```

[ ] Use This Bash Script to Build Schism with GCC: Create  a script named `pschism_gcc-schism.sh`

```bash
#/bin/bash
#filename: pschism_gcc-schism.sh

spack env deactivate
spack env activate gcc-schism


schism_root="$HOME/schism-test" #your home may differ
mpi_library="openmpi@5"
my_compiler="gcc@12.2.0"
mymodules="$mpi_library hdf5@1.14.0 nco@5.1.9  netcdf-c@4.9.2  netcdf-fortran@4.6.0"

echo "clear loaded modules"
module purge

echo "load environment for gcc 12.2.0"
spack load gcc-runtime@12.2.0
spack load gcc@12.2.0
echo "load cmake environment variables"
spack load cmake@3.27.9%gcc@12.2.0

for mymodule in $mymodules
  do
     module load $(spack module tcl find $mymodule)
  done

#echo "load openmpi source"
#source $(spack location -i $mpi_library)/setvars.sh

spack load gcc@12.2.0

echo "set all compiler variables"
export FC=mpifort
export CC=mpicc
export CXX=mpicxx
#export I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi.so"
#export MPI_ROOT=$I_MPI_ROOT
export CMAKE_Fortran_COMPILER=$FC
export CMAKE_CXX_COMPILER=$CXX
export CMAKE_C_COMPILER=$C
export NETCDF=$(spack location -i netcdf-c)
export NETCDFF=$(spack location -i netcdf-fortran)
export NETCDF_FORTRAN=$(spack location -i netcdf-fortran)
export HDF5_DIR=$(spack location -i hdf5)
export NetCDF_C_DIR=$NETCDF
export NetCDF_FORTRAN_DIR=$NETCDFF
#SNAFU had to hardcode library path as file for this variable
export NetCDF_LIBRARY="$NETCDF/lib"
export NetCDFF_LIBRARY="$NETCDFF/lib"
#export CMAKE_BINARY="$(spack location -i cmake%$my_compiler)/bin/cmake"
export NetCDF_INCLUDE_DIR="$NetCDF/include"
export NetCDF_LIBRARIES=$NetCDF_LIBRARY
export NetCDF_FORTRAN_DIR=$NETCDFF
export NetCDF_FORTRAN_LIBRARIES=$NetCDFF_LIBRARY

#to updated
export local_build_for_cmake=$schism_root/schism/cmake/SCHISM.local.build
export custom_build_for_cmake=$schism_root/schism/cmake/SCHISM.local.levante.gcc

#checks
echo "display essential variables"
echo "cmake version: $(cmake -version)"
echo "locations: to libraries"
echo "NETCDF  (netcdf-c): $NETCDF"
echo "NetCDF_LIBRARY: $NetCDF_LIBRARY"

echo "NETCDFF (netcdf-fortran): $NETCDFF"
echo "NetCDF_FORTRAN_DIR: $NETCDFF"
echo "NetCDF_FORTRAN_LIBRARY: $NetCDFF_LIBRARY"

echo "HDF5_DIR: $HDF5_DIR"

sleep 30


#check to make sure the cmake files for the build are present
#Without these things may still compile but the application may not work as expected.
if [ -e "$local_build_for_cmake" ] && [ -e "$custom_build_for_cmake" ]; then
           echo "both the $local_build_for_cmake and the $custom_build_for_cmake exist"
   else
           echo "ERROR either the $local_build_for_cmake or the $custom_build_for_cmake is missing error"
           exit 1
fi

rm -fr $schism_root/schism/src/build; mkdir -p $schism_root/schism/src/build

#schism may complain that FC,CC,and some other variables are not necessary. This ok.
cmake -C $local_build_for_cmake -C $custom_build_for_cmake \
-D CC=$CC \
-D FC=$FC \
-D CMAKE_Fortran_COMPILER=$CMAKE_Fortran_COMPILER \
-D CMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER \
-D CMAKE_C_COMPILER=$CMAKE_C_COMPILER \
-D NetCDF_C_DIR=$NETCDF \
-D NetCDF_FORTRAN_DIR=$NETCDFF \
-D NetCDF_FORTRAN_LIBRARIES="$NETCDFF/lib" \
-D HDF5_DIR=$HD5_DIR \
-S $schism_root/schism/src -B $schism_root/schism/src/build
```

[ ] Compile with source or '.'

```bash
source pschism_gcc-schism.sh
make pschism
```


### Step 16: Refresh the Data
------
- Data Setup
  1. Each directory requries an `outputs` folder. Ensure this is creatred. 
  2. The param.nml file is the configuration file.

   
- [ ] Get Test Data for Basic Tests (Optional): (Optional)
```bash
cd /modeling/pschism
svn co https://columbia.vims.edu/schism/schism_verification_tests/Test_CORIE
mkdir Test_CORE/outputs #create missing outputs directory
```

- [ ] Get ICM Test Data - Source Chesapeake Bay (Our Data):

```bash
 cd /modeling/pschism
 svn co https://columbia.vims.edu/schism/schism_verification_tests/Test_ICM_ChesBay
 mkdir Test_ICM_ChesBay/outputs # create missing outputs directory
 ```

*IMPORTANT*: The runs must occur in the target data directory.

- [ ] Change into the Data Directory and Create an Outputs Folder:

```bash
cd Test_ICM_ChesBay
mkdir outputs
touch sbatch_file_goes_here # Use your preferred naming convention
```

### Step 17 - Final Steps - Running Pschism Code
------
- To run the code, you will need an SBATCH file.
- You may want to edit the `params.nml` control file to reduce the number of days of data to simulate.
- The SBATCH file needs to be run from the directory holding the data.

For example, if your data is in a folder called:
`Data dir: /modeling/pschism/Test_ICM_ChesBay`

- [ ] Before Running Pschism, Update the `params.nml` File:
    * Change `rnday` from 'rnday = 365'  to 'rnday = 1' to reduce cost. 
    Note A 365-day run will take over 24 hours, while a one-day run should take about 5 minutes if everything is running properly. A 10-day run should take about 30 minutes.
    

- [ ] Create an SBATCH File and Run the Model:
      Here is an example SBATCH script that has been used in the past. Note that `outputs/mirror.out` displays the results

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

#load enviornment variables
#load the paths from the INTEL-MPI
echo "load spack environment variables"
export SPACK_ROOT=/modeling/spack
source $SPACK_ROOT/share/spack/setup-env.sh
echo "load spack environment variables $?"

spack env deactivate
spack env activate intel-schism
spack load intel-oneapi-compilers-classic@2021.10.0

mpi_library="intel-oneapi-mpi@2021.12.1"
my_compiler="intel@2021.10.0"
mymodules="$mpi_library hdf5@1.14.0    libfabric@1.21.0  nco@5.1.9  netcdf-c@4.9.2  netcdf-fortran@4.6.0  pkgconf@1.4.2"

echo "clear loaded modules"
module purge

for mymodule in $mymodules
  do
     module load $(spack module tcl find $mymodule%$my_compiler)
  done



source $(spack location -i intel-oneapi-mpi@2021.12.1)/setvars.sh
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

- [ ] Run Your Batch File: Submit SBATCH jobs with the sbatch command:
    

   ```bash
   sbatch pschism_sbatch_job.sh
   ```

 - [ ]  Monitor Pschism Output: Check outputs/mirror.out to verify if the model ran successfully:
   ```bash
   TIME STEP=         5760;  TIME=        864000.000000
   Run completed successfully at 20231205, 161111.159
   ```

------
### End of Step by Step guide
------

### References 
------

- An old setup guide from a grad student. https://jiaweizhuang.github.io/blog/aws-hpc-guide/

- NMSU has some good spack environments https://hpc.nmsu.edu/discovery/software/spack/environments/

- NOAA pcluster/spack setups in github.  https://github.com/JCSDA/spack-stack/tree/develop/configs/sites/aws-pcluster

- Amazon https://aws.amazon.com/blogs/hpc/install-optimized-software-with-spack-configs-for-aws-parallelcluster/

- Wisc.edu https://chtc.cs.wisc.edu/uw-research-computing/hpc-spack-setup

- Spack github site https://github.com/spack/spack/

### Special Thanks
------

- Special thanks to Dave Kintgen for testing this document. 


END/end
