## Documentation for Compiling SCHISM on Docker

This document outlines the steps to compile SCHISM using a Docker container configured with Spack. The Docker build information is based on a custom Ubuntu image that sets up a Spack environment with the necessary dependencies.

### Prerequisites

- Ensure you have Docker installed on your machine.
- Access to the internet to download necessary files.

### Building the Docker Container

1. **Clone the Repository**  
   Get the files containing the Docker build scripts:
   ```bash
   wget https://raw.githubusercontent.com/zeekus/textfiles/master/hpc/docker/custom_ubuntu
   wget https://raw.githubusercontent.com/zeekus/textfiles/refs/heads/master/hpc/docker/build_spack_env.bash
   wget https://raw.githubusercontent.com/zeekus/textfiles/refs/heads/master/hpc/docker/pschism_gcc-schism.sh
   ```

2. **Build the Docker Image**  
   Use the following command to build the Docker image:
   ```bash
   docker build -t custom_ubuntu_spack:latest -f custom_ubuntu . > docker-build-custom-ubuntu-orig.log 2> extra_output.log
   ```
   This command builds an image named `custom_ubuntu_spack` using the Dockerfile specified by `custom_ubuntu`.

### Setting Up Spack Environment

3. **The docker script should automatically setup spack for you.**  
   ** take a walk and come back in 30 minutes **
   Inside your Docker container, the script will download the Spack setup script:
   ```bash
   wget https://raw.githubusercontent.com/zeekus/textfiles/refs/heads/master/hpc/docker/build_spack_env.bash
   ```

4. **Connect to your running docker container using **  
  
   ** identify your container id **
   ```bash
   docker ps -a
   ```
   ** output **
   ```text
CONTAINER ID   IMAGE          COMMAND               CREATED        STATUS        PORTS     NAMES
13365cea58aa   208c56762295   "tail -f /dev/null"   17 hours ago   Up 17 hours             goofy_feistel
```

   ** connect to your container **
   ```bash
   docker exec -it 13365cea58aa /bin/bash   
   ```

5. **Activate Spack and Modules**  
   After setting up, activate the necessary environments:
   ```bash
   . /opt/spack/share/spack/setup-env.sh
   . /etc/profile.d/modules.sh
   ```

6. **Check Installed Packages**  
   Verify that the required packages are installed:
   ```bash
   spack env activate gcc-test
   spack find
   ```
   You should see a list of approximately 50 packages, including `gcc`, `hdf5`, `netcdf`, and others.

### Compiling SCHISM

7. **Clone SCHISM Repository**  
   Now, from the docker container, clone the SCHISM repository:
   ```bash
   mkdir /modeling/pschism -p
   cd /modeling/pchism 
   git clone https://github.com/schism-dev/schism.git
   cd schism/
   ```

8. **Checkout Specific Model**  
   Check out the desired model branch:
   ```bash
   git checkout -b remotes/origin/icm_Balg
   ```

9. **Compile SCHISM SRC CODE**  using the custom cmake script 
   Use the provided CMake file to compile SCHISM:
   ```bash
   cd /modeling/pschism 
   wget https://raw.githubusercontent.com/zeekus/textfiles/refs/heads/master/hpc/docker/pschism_gcc-schism.sh
   . pschism_gcc-schism.sh
   ```

10. **Make the binaries and install**
   ```bash
   cd /modeling/pschism/schism/src/build
   make  pschism
   ```

    Note this will generate a binary in bin.

    expected output. 
    ```
root@13365cea58aa:/modeling/pschism/schism/src/build# make pschism
/modeling/pschism/schism/src/Core/gen_version.py
/modeling/pschism/schism/src/Core
/modeling/pschism/schism/src/Core/_version
SCHISM version not available, searching for src/schism_user_version.txt or default
Attempting to get version text manually from first line of
src/Core/schism_version_user.txt if file exists
c399f90d
 SCHISM version:  develop
 GIT commit       c399f90d
[  0%] Built target sversion
Scanning dependencies of target core
[  0%] Building Fortran object Core/CMakeFiles/core.dir/schism_version.F90.o
[  2%] Linking Fortran static library ../lib/libcore.a
[  8%] Built target core
Consolidate compiler generated dependencies of target metis
[ 59%] Built target metis
Consolidate compiler generated dependencies of target parmetis
[ 89%] Built target parmetis
[ 97%] Built target hydro
[ 97%] Linking Fortran executable ../bin/pschism_LEVANTE_GCC_BLD_STANDALONE_TVD-VL
[100%] Built target pschism
root@13365cea58aa:/modeling/pschism/schism/src/build# cd bin
root@13365cea58aa:/modeling/pschism/schism/src/build/bin# ls
pschism_LEVANTE_GCC_BLD_STANDALONE_TVD-VL
```



### Conclusion

This Docker container provides a complete environment for compiling and testing SCHISM with all necessary dependencies managed by Spack. It can be used for code development and testing basic functionality of SCHISM code.

### Note

Ensure that you monitor any output logs for errors during installation and compilation processes for troubleshooting purposes.

