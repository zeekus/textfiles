#!/bin/bash
#description: install udunits, spack gcc-test environment with system perl, netcdf, openmpi, nco, and hdf5
#filename: build_spack_env.bash
#author Theodore Knab

# Define the name of the environment
ENV_NAME="gcc-test"

# Source the Spack environment
source /opt/spack/share/spack/setup-env.sh

install_spack() {
    # Create the spack.yaml file
    cat <<EOL > spack.yaml
spack:
  specs:
  - gcc@11.4.0
  - perl@5.34.0
  - openmpi@5.0.2
  - netcdf-fortran@4.6.0 +shared ^openmpi@5.0.2
  - netcdf-c@4.9.2 +mpi ~dap ~szip +shared
  - hdf5@1.14.0 +hl +mpi ~tools ~szip +shared
  - nco
  concretizer:
    unify: true
  modules:
    default:
      enable:
      - tcl
      - lmod
      lmod:
        core_compilers:
        - gcc@=11.4.0
  view: true
  compilers:
    - compiler:
        spec: gcc@11.4.0
        paths:
          cc: /usr/bin/gcc
          cxx: /usr/bin/g++
          f77: /usr/bin/gfortran
          fc: /usr/bin/gfortran
        flags: {}
        operating_system: ubuntu22.04
        target: x86_64
        modules: []
        environment: {}
        extra_rpaths: []
  packages:
    all:
      providers:
        mpi: [openmpi@5.0.2]
      require:
      - any_of: ['%gcc@11.4.0', '%gcc']
      - any_of: [build_type=Release, '@:']
      - any_of: [~shared, '@:']
      - any_of: [+pic, '@:']
      - any_of: [openmpi@5.0.2]
    cmake:
      buildable: false
      externals:
      - spec: cmake@3.22.1
        prefix: /usr
    curl:
      buildable: false
      externals:
      - spec: curl@7.81.0+gssapi+ldap+nghttp2
        prefix: /usr
    openssl:
      buildable: false
      externals:
      - spec: openssl@3.0.2
        prefix: /usr
    libxml2:
      require: +shared
    gettext:
      require: +shared
    pkgconf:
      buildable: false
      externals:
      - spec: pkgconf@1.8.0
        prefix: /usr
    findutils:
      externals:
      - spec: findutils@4.8.0
        prefix: /usr
    gawk:
      externals:
      - spec: gawk@5.1.0
        prefix: /usr
    tar:
      externals:
      - spec: tar@1.34
        prefix: /usr
    openssh:
      externals:
      - spec: openssh@8.9p1
        prefix: /usr
    perl:
      buildable: false
      externals:
      - spec: perl@5.34.0~cpanm+opcode+open+shared+threads
        prefix: /usr
    udunits:
      buildable: false  # Prevents Spack from building its own version.
      externals:
      - spec: udunits@2.2.8
        prefix: /opt/spack/local # Replace with the actual prefix where expat is installed

EOL

    # Create the Spack environment using the generated spack.yaml file.
    spack env create "$ENV_NAME" spack.yaml

    echo "Environment '$ENV_NAME' created with specifications from spack.yaml."

    spack env activate "$ENV_NAME"

    echo "Running concretizer..."
    spack concretize -f 

    echo "Installing missing packages..."
    spack install 
}

install_udunits() {
    local version="2.2.28"
    local url="https://downloads.unidata.ucar.edu/udunits/${version}/udunits-${version}.tar.gz"
    local tar_file="udunits-${version}.tar.gz"
    local install_prefix="/opt/spack/local"
    local expat_path="/usr/include"

    # Download the UDUNITS package.
    echo "Downloading UDUNITS version ${version}..."
    wget -q "${url}" -O "${tar_file}" || { echo "Error downloading UDUNITS."; return 1; }

    # Decompress the package.
    echo "Decompressing ${tar_file}..."
    tar xf "${tar_file}" || { echo "Error decompressing ${tar_file}."; return 1; }

    # Navigate into the extracted directory.
    cd "udunits-${version}" || { echo "Error navigating to directory."; return 1; }

    # Configure the build.
    echo "Configuring the build..."
    ./configure --prefix="${install_prefix}" || { echo "Configuration failed."; return 1; }

    # Build the library.
    echo "Building UDUNITS..."
    export CMAKE_PREFIX_PATH="${expat_path}"
    make -j 4 || { echo "Build failed."; return 1; }

    # Install the library.
    echo "Installing UDUNITS..."
    make install || { echo "Installation failed."; return 1; }

    echo "UDUNITS version ${version} installed successfully!"
}

# Check if the Spack environment exists.
if spack env list | grep -q "$ENV_NAME"; then
    echo "Spack environment '$ENV_NAME' already exists. Skipping installation of Spack and UDUnits."
else 
    echo "Installing UDUnits..."
    install_udunits

    echo "Installing Spack..."
    install_spack 
fi




