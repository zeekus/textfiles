## Documentation for Compiling SCHISM on Docker

This document outlines the steps to compile SCHISM using a Docker container configured with Spack. The Docker build information is based on a custom Ubuntu image that sets up a Spack environment with the necessary dependencies.

### Prerequisites

- Ensure you have Docker installed on your machine.
- Access to the internet to download necessary files.

### Building the Docker Container

1. **Get the Files**  
   Download the files containing the Docker build scripts:
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

3. **Automatic Spack Setup**  
   The Docker script should automatically set up Spack for you. **Take a walk and come back in 30 minutes.**

4. **Connect to Your Running Docker Container**  
   Identify your container ID:
   ```bash
   docker ps -a
   ```
   **Output Example:**
   ```
   CONTAINER ID   IMAGE          COMMAND               CREATED        STATUS        PORTS     NAMES
   13365cea58aa   208c56762295   "tail -f /dev/null"   17 hours ago   Up 17 hours             goofy_feistel
   ```

   Connect to your container:
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

7. **Download SCHISM Repository**  
   From the Docker container, create a directory and clone the SCHISM repository:
   ```bash
   mkdir -p /modeling/pschism 
   cd /modeling/pschism 
   git clone https://github.com/schism-dev/schism.git
   cd schism/
   ```

8. **Checkout Specific Model**  
   Check out the desired model branch:
   ```bash
   git checkout -b remotes/origin/icm_Balg
   ```

9. **Compile SCHISM Source Code Using Custom CMake Script**  
    Use the provided CMake file to compile SCHISM:
    ```bash
    cd /modeling/pschism 
    wget https://raw.githubusercontent.com/zeekus/textfiles/refs/heads/master/hpc/docker/pschism_gcc-schism.sh
    . pschism_gcc-schism.sh
    ```

10. **Make the Binaries and Install**  
    Navigate to the build directory and compile:
    ```bash
    cd /modeling/pschism/schism/src/build
    make pschism
    ```

    *Note: This will generate a binary in `bin`.*

    Example Output:
    ```
    root@13365cea58aa:/modeling/pschism/schism/src/build# make pschism
    ...
    [100%] Built target pschism
    root@13365cea58aa:/modeling/pschism/schism/src/build# cd bin
    root@13365cea58aa:/modeling/pschism/schism/src/build/bin# ls
    pschism_LEVANTE_GCC_BLD_STANDALONE_TVD-VL
    ```

### Conclusion

This Docker container provides a complete environment for compiling and testing SCHISM with all necessary dependencies managed by Spack. It can be used for code development and testing basic functionality of SCHISM code.

### Note

Ensure that you monitor any output logs for errors during installation and compilation processes for troubleshooting purposes.
