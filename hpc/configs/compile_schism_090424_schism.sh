#/bin/bash
#filename: pschism_compiler_test.sh

spack env activate schism

schism_root="$HOME/schism-test"
mpi_library="intel-oneapi-mpi@2021.9.0"
my_compiler="intel@2021.6.0"


mymodules="hdf5@1.14.0 nco@5.1.9  netcdf-c@4.9.2  netcdf-fortran@4.6.0"

echo "clear loaded modules"
module purge

module load libfabric-aws/1.21.0amzn1.0
module load $(spack module tcl find $mpi_library)
spack load intel-oneapi-compilers@2022.1.0 
spack load cmake@3.27.9%gcc@12.2.0 
spack load $mpi_library
for mymodule in $mymodules
  do 
     module load $(spack module tcl find $mymodule)
     sleep 1
  done


#echo "load openmpi source"
#source $(spack location -i $mpi_library)/setvars.sh 

echo "set all compiler variables"
export FC=$(spack location -i $mpi_library)/mpi/latest/bin/mpiifort
export CC=$(spack location -i $mpi_library)/mpi/latest/bin/mpiicc
export CXX=$(spack location -i $mpi_library)/mpi/latest/bin/mpiicpc
export I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi.so"
export MPI_ROOT=$I_MPI_ROOT
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
export NetCDF_INCLUDE_DIR="$NetCDF/include"
export NetCDF_LIBRARIES=$NetCDF_LIBRARY
export NetCDF_FORTRAN_DIR=$NETCDFF
export NetCDF_FORTRAN_LIBRARIES=$NetCDFF_LIBRARY

#to updated
export local_build_for_cmake=$schism_root/schism/cmake/SCHISM.local.build
export custom_build_for_cmake=$schism_root/schism/cmake/SCHISM.local.levante.intel


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
#$CMAKE_BINARY -C $local_build_for_cmake -C $custom_build_for_cmake \
#-D CC=$CC \
#-D FC=$FC \
#-D CMAKE_Fortran_COMPILER=$CMAKE_Fortran_COMPILER \
#-D CMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER \
#-D CMAKE_C_COMPILER=$CMAKE_C_COMPILER \
#-D NetCDF_C_DIR=$NETCDF \
#-D NetCDF_FORTRAN_DIR=$NETCDFF \
#-D NetCDF_FORTRAN_LIBRARIES="$NETCDFF/lib" \
#-D HDF5_DIR=$HD5_DIR \
#-S $schism_root/schism/src -B $schism_root/schism/src/build

cmake -C $local_build_for_cmake \
              -C $custom_build_for_cmake \
              -D CMAKE_Fortran_COMPILER=$CMAKE_Fortran_COMPILER \
              -D CMAKE_CXX_COMPILER=$CMAKE_CXX_COMPILER \
              -D CMAKE_C_COMPILER=$CMAKE_C_COMPILER \
              -D NetCDF_C_DIR=$NETCDF \
              -D NetCDF_FORTRAN_DIR=$NETCDFF \
              -D NetCDF_FORTRAN_LIBRARIES="$NETCDFF/lib" \
              -S $schism_root/schism/src \
              -B $schism_root/schism/src/build

