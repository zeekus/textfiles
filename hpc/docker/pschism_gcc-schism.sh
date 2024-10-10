#/bin/bash
#filename: pschism_gcc-schism.sh

spack env deactivate
spack env activate gcc-test


schism_root="/modeling/pschism" #your home may differ
mpi_library="openmpi@5"
my_compiler="gcc@12.2.0"
mymodules="$mpi_library hdf5@1.14.0 nco@5.1.9  netcdf-c@4.9.2  netcdf-fortran@4.6.0"

echo "clear loaded modules"
module purge

echo "load environment for gcc 11.4.0"
spack load gcc-runtime@11.4.0
spack load gcc@11.4.0
echo "load cmake environment variables"
spack load cmake

for mymodule in $mymodules
  do
     module load $(spack module tcl find $mymodule)
  done

#echo "load openmpi source"
#source $(spack location -i $mpi_library)/setvars.sh

spack load gcc@11.4.0

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
