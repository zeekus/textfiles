## Cheat Sheet for Spack - For Modellers


# List Environments

```bash
spack env list
```

# Example output 

```text
==> 3 environments
    ifort-rocky  openmpi4  r-env
```

# Load an Environment (Example: ifort-rocky)

```bash
spack env activate ifort-rocky
```

# View Environment Variables Set by Spack

```
env | grep SPACK
```

# List spack packages in your environment
```bash
spack find
```

# List spack packages from the intel@2021.10.0  complier in your envirornment

```bash
spack find %intel@2021.10.0 
```

# Deactivate the Environment

```bash
spack env deactivate
```

# Check Your Environment Status

```bash
spack env status
```

# List Available Modules

```bash
module avail
```

or 

```bash
module av
```

# Load a Module

```
module load <module-name>
```

# Load a Module with Spack for a Specific Compiler

```bash
module load $(spack module tcl find intel-oneapi-mpi%intel@2021.10.0 )
```

# Use Legacy Modules

```bash
module use /module/tools/modulefiles
```


# Slurm Example for ifort.

```
#!/usr/bin/bash
#SBATCH --job-name=mpi-test     # create a short name for your job
#SBATCH --nodes=2               # node count
#SBATCH --ntasks=2              # total number of tasks across all nodes
#SBATCH --cpus-per-task=4       # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G        # memory per cpu-core (4G per cpu-core is default)
#SBATCH --time=00:15:00         # total run time limit (HH:MM:SS)
#SBATCH --error=mpitest%J.err
#SBATCH --output=mpitest%J.out

source /modeling/spack/share/spack/setup-env.sh
spack env activate ifort-rocky
module purge
# Note: In the environment, you don't need to specify the compiler version.
module load $(spack module tcl find intel-oneapi-compilers)
module load $(spack module tcl find intel-oneapi-mpi)
module load $(spack module tcl find netcdf-c)
module load $(spack module tcl find netcdf-fortran)
module load $(spack module tcl find hdf5)
module load $(spack module tcl find nco)
module list

srun --mpi=pmi2 /home/tknab/slurm_tests/hello_world_mpi
```

# Slurm Example for R

```
#!/usr/bin/bash
#SBATCH --job-name=R-serial      # create a short name for your job
#SBATCH --nodes=2                # node count
#SBATCH --ntasks=2              # total number of tasks across all nodes
#SBATCH --cpus-per-task=4       # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G per cpu-core is default)
#SBATCH --time=00:15:00          # total run time limit (HH:MM:SS)
#SBATCH --error=rtest%J.err
#SBATCH --output=rtest%J.out

module purge
echo "$?: purged modules"

spack env activate r-env
module load $(spack module tcl find r)


echo "$?: loaded modules"
$(spack location -i r)/bin/R --vanilla <  /home/u/tknab/slurm_tests/r_test_script.r
echo "$?: run script"
```

# Slurm Example for OpenMPI4 with GCC

```
#!/usr/bin/bash
#SBATCH --job-name=openmpi-test     # create a short name for your job
#SBATCH --nodes=2               # node count
#SBATCH --ntasks=2              # total number of tasks across all nodes
#SBATCH --cpus-per-task=4       # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G        # memory per cpu-core (4G per cpu-core is default)
#SBATCH --time=00:15:00         # total run time limit (HH:MM:SS)
#SBATCH --error=openmpitest%J.err
#SBATCH --output=openmpitest%J.out

#export PATH=$(spack location -i openmpi)/bin:$PATH
#export LD_LIBRARY_PATH=$(spack location -i openmpi)/lib:$LD_LIBRARY_PATH

# Set Open MPI specific environment variables
export OMPI_MCA_mpi_warn_on_fork=0
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
SECONDS=0

# Set ulimits
export OMP_STACKSIZE=500m

#export LD_LIBRARY_PATH=/opt/amazon/openmpi/lib64:$LD_LIBRARY_PATH

source /modeling/spack/share/spack/setup-env.sh

spack env activate openmpi4

module purge

module load libfabric-aws/1.21.0amzn1.0 #external
module load openmpi/4.1.6  #external 
module load $(spack module tcl find netcdf-c)
module load $(spack module tcl find netcdf-fortran)
module load $(spack module tcl find hdf5)
module load $(spack module tcl find nco)

echo "listing modules"
module list
if [[ $? != 0 ]];then
   echo "we got an error exiting"
   exit
else
   srun --mpi=pmix_v5 /home/tknab/slurm_tests/openmpi4/hello_world_mpi
fi
```

# Slurm Example for OpenMPI5 with GCC

```
#!/usr/bin/bash
#SBATCH --job-name=openmpi-test     # create a short name for your job
#SBATCH --nodes=2               # node count
#SBATCH --ntasks=2              # total number of tasks across all nodes
#SBATCH --cpus-per-task=4       # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G        # memory per cpu-core (4G per cpu-core is default)
#SBATCH --time=00:15:00         # total run time limit (HH:MM:SS)
#SBATCH --error=openmpitest%J.err
#SBATCH --output=openmpitest%J.out

#export PATH=$(spack location -i openmpi)/bin:$PATH
#export LD_LIBRARY_PATH=$(spack location -i openmpi)/lib:$LD_LIBRARY_PATH

# Set Open MPI specific environment variables
export OMPI_MCA_mpi_warn_on_fork=0
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
SECONDS=0

# Set ulimits
export OMP_STACKSIZE=500m


#export LD_LIBRARY_PATH=/opt/amazon/openmpi/lib64:$LD_LIBRARY_PATH

source /modeling/spack/share/spack/setup-env.sh
spack env activate openmpi5
module purge
module load libfabric-aws/1.21.0amzn1.0 #external
module load openmpi5/5.0.2 #external
module load $(spack module tcl find netcdf-c)
module load $(spack module tcl find netcdf-fortran)
module load $(spack module tcl find hdf5)
module load $(spack module tcl find nco)

echo "listing modules"
module list
if [[ $? != 0 ]];then
   echo "we got an error exiting"
   exit
else
   srun --mpi=pmix_v5 /home/tknab/slurm_tests/openmpi5/hello_world_mpi
fi
```