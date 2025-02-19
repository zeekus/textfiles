
## Basic Modellers Cheat sheet for spack. 

## Managing Spack Environments
# List all environments
```
spack env list
```

# Show current environment status
```bash
spack env status
```

# View environment configuration
```bash
spack env show
```

# Deactivate any existing environment
```bash
spack env deactivate
```
## cleaning up things for clean slate

# Activate specific environment
```bash
spack env activate openmpi4
```

# Step 1: Clean slate - deactivate and purge

```bash
spack env deactivate
module purge
```

# Step 2: Activate environment and load external modules
```bash
spack env activate openmpi4
```

```bash
module load libfabric-aws/1.21.0amzn1.0  # external dependency
module load openmpi/4.1.6                # external MPI
```

# Step 3: Load Spack-managed modules the spack way

```bash
module load $(spack module tcl find netcdf-c)
module load $(spack module tcl find netcdf-fortran)
module load $(spack module tcl find hdf5)
module load $(spack module tcl find nco)
```

# Step 4: Verify environment

```bash
spack env status
```

# basic test script for Python Numpy and netCDF4.

```python
# Example dependencies needed for your Python script
import os,sys
import tarfile
from glob import glob
from datetime import date
from numpy import array,unique,arange,zeros
from netCDF4 import Dataset
```

# example run 

```shell
python test.py 
```
