# Installation of WRF model using Intel compilers as a module

- [Installation of WRF model using Intel compilers as a module](#installation-of-wrf-model-using-intel-compilers-as-a-module)
  - [Dependencies](#dependencies)
  - [WRF \& WPS Installation](#wrf--wps-installation)
    - [WRF Installation](#wrf-installation)
    - [WPS Installation](#wps-installation)
  - [Creating Modulefile](#creating-modulefile)
    - [WRF as module](#wrf-as-module)
    - [WPS as module](#wps-as-module)
  - [Others](#others)

First, thanks to @ KlemensBarfus & @lenamueller for their help and the rich discussion :smile:.

The poem by @lenamueller in the README.md file has contributed to the WRF model installation :smile:.


In this document, the steps to install the Weather Research & Forecasting Model (WRF) model on The HPC cluster of TU Dresden (Taurus) is listed. The document is organized as follows:

1. Dependencies including variables & path. 
2. WRF & WPS Installation
3. Creating Module file for WRF & WPS

Installation Summary:

| Model/Variable | Version/Value|
| ----------- | ----------- |
| WRF | 4.3.1 |
| WPS | 4.3   | 
| Compiler | Intel(R) 64, Version 18.0.1.163 | 
| System    | Red Hat Enterprise Linux Server|
| System Version | 7.9 (Maipo)  | 

## Dependencies

To successfully, install the WRF model, the right modules and environment variables should be set up. However, first start an interactive job to install the model. e.g.:

```bash
srun --pty --nodes=1 --partition=interactive --cpus-per-task=8 --time=6:00:00 --mem-per-cpu=2000 bash -l
```

After starting the interactive job, change to your project directory and make directory for WRF model. In this folder, many versions of WRF module and WPS can be installed.

```bash
cd /projects/p_your_project 
mkdir WRF 
cd WRF/ 
```

A small bash source script should be created and sourced for WRF installation. Name the file `.bashrc_WRF` and placed in the `WRF/` directory.

```bash
module purge

module load modenv/scs5
module load PnetCDF/1.9.0-intel-2018a
module load netCDF-Fortran/4.4.4-intel-2018a

export PROJECT_DIR=/projects/p_your_project 
export PATH=$PATH:$PROJECT_DIR/WRF/netcdf_mine/bin
export WRF_DIR=$PROJECT_DIR/WRF/WRF-4.3.1

export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export NETCDF4=1
export OMP_STACKSIZE="2G"
export HDF5=$EBROOTHDF5 
export PHDF5=$EBROOTHDF5
export PNETCDF=$EBROOTPNETCDF
export NETCDF=$PROJECT_DIR/WRF/netcdf_mine
export NETCDFF=$EBROOTNETCDFMINFORTRAN
export JASPERLIB=$EBROOTJASPER/lib64  
export JASPERINC=$EBROOTJASPER/include  

```

Source the bash script by using:

```bash
source .bashrc_WRF
```

To link the required libraries to your WRF model, copy the `netcdf_mine` folder to the `WRF/` directory. Consequently, you need to run the link script in each subdirectory to have required WRF dependencies, as follows:

```bash
pwd 
#the result should be: /projects/p_your_project/WRF

cd netcdf_mine/bin 
chmod a+u link_script && ./ link_script

cd ../lib
chmod a+u link_script && ./ link_script

cd ../include
chmod a+u link_script && ./ link_script

cd ../../ 
pwd 
#the result should be: /projects/p_your_project/WRF
```

It is okay if the commands above produce permission denied error. You can again source the `.bashrc_WRF` again, just to be sure. 

## WRF & WPS Installation

### WRF Installation

After setting up the environment variables and getting the right libraries. You can get the WRF model & and start installing:

```bash
wget https://github.com/wrf-model/WRF/archive/v4.3.1.tar.gz
tar xvf v4.3.1.tar.gz
cd WRF-4.3.1/
./configure 
```

For `./configure` command, enter 20 (i.e. dmpar with INTEL (ifort/icc): Xeon (SNB with AVX mods)).

"DMPar" means "Distributed-memory Parallelism," which means MPI will be used in the build. The resulting binary will run within and across multiple nodes of a distributed-memory system (or cluster). [Ref](https://forum.mmm.ucar.edu/threads/what-are-the-differences-between-serial-smpar-and-dmpar-compiles-of-wrf.65/)

Afterwards, choose the type of the nesting you want which in our case is basic nesting, i.e. `1`


Now you can compile the WRF model using:

```bash
./compile -j 4 em_real 2>&1 | tee compile.log
```

`-j 4` means compile the model in parallel. The number refers to the number of the parallel processes. This step can take up to one hour (with the default `-j 2`).

If everything went right, this should be the final output from compilation process:

```bash
--->                  Executables successfully built                  <---
 
-rwxr-xr-x 1 user 1111111 82526016  4. Nov 10:11 main/ndown.exe
-rwxr-xr-x 1 user 1111111 82319936  4. Nov 10:11 main/real.exe
-rwxr-xr-x 1 user 1111111 80584544  4. Nov 10:11 main/tc.exe
-rwxr-xr-x 1 user 1111111 94257672  4. Nov 10:08 main/wrf.exe
 
==========================================================================
```

### WPS Installation

First, you need to get WPS from GitHub:

```bash
cd .. 
wget https://github.com/wrf-model/WPS/archive/v4.2.tar.gz
tar xvf v4.2.tar.gz
```

You might want to implement the modification introduced by @KlemensBarfus on his Github repository.
#https://github.com/KlemensBarfus/WRF_opt_output_from_ungrib_path

```bash

```

This is a bash script to get the routines & copy the files to their respective location in WPS directory:

```bash
# get routines 
git clone https://github.com/KlemensBarfus/WRF_opt_output_from_ungrib_path.git

# copy 
cp WRF_opt_output_from_ungrib_path/geogrid_gridinfo_module.F  WPS-4.2/geogrid/src/gridinfo_module.F
cp WRF_opt_output_from_ungrib_path/process_domain_module.F    WPS-4.2/metgrid/src/process_domain_module.F

cp WRF_opt_output_from_ungrib_path/metgrid:gridinfo_module.F  WPS-4.2/metgrid/src/gridinfo_module.F 
cp WRF_opt_output_from_ungrib_path/datint.F                   WPS-4.2/ungrib/src/datint.F
cp WRF_opt_output_from_ungrib_path/file_delete.F              WPS-4.2/ungrib/src/file_delete.F
cp WRF_opt_output_from_ungrib_path/read_namelist.F            WPS-4.2/ungrib/src/read_namelist.F 
cp WRF_opt_output_from_ungrib_path/rrpr.F                     WPS-4.2/ungrib/src/rrpr.F
cp WRF_opt_output_from_ungrib_path/output.F                   WPS-4.2/ungrib/src/output.F 

cp WRF_opt_output_from_ungrib_path/ungrib.F                   WPS-4.2/util/src/ungrib.F
cp WRF_opt_output_from_ungrib_path/avg_tsfc.F                 WPS-4.2/util/src/avg_tsfc.F 
cp WRF_opt_output_from_ungrib_path/util_gridinfo_module.F     WPS-4.2/util/src/gridinfo_module.F  # symlink
cp WRF_opt_output_from_ungrib_path/calc_ecmwf_p.F             WPS-4.2/util/src/calc_ecmwf_p.F
```

## Creating Modulefile

### WRF as module

Create a `lua` file (i.e. `4.3.1-intel-2018a-dmpar.lua`) with the version of WRF model and placed it in `/projects/p_your_project/WRF/WRF-4.3.1`. For more information about lua or lmod files, please check [writing Modulefiles](https://lmod.readthedocs.io/en/latest/015_writing_modules.html)

```lua
help([[

Description
===========
WRF Model is a state of the art mesoscale numerical weather prediction system designed for both atmospheric research and operational forecasting applications.

More Information
================
For detailed instructions, go to:
   https://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/v4.3/contents.html

]])

whatis("Version: 4.3.1")
whatis([==[Description: The Weather Research and Forecasting (WRF) Model is a next-generation mesoscale numerical weather prediction system designed to serve both operational forecasting and atmospheric research needs.]==])
whatis([==[Homepage: http://www.wrf-model.org]==])
whatis("Keywords: Climate Modelling, Numerical weather Prediction, Mesoscale Modelling")

conflict("WRF")

depends_on("intel/2018a")
depends_on("JasPer/2.0.14-GCCcore-6.4.0")
depends_on("HDF5/1.10.1-intel-2018a")
depends_on("netCDF/4.6.0-intel-2018a")
depends_on("PnetCDF/1.9.0-intel-2018a")
depends_on("netCDF-Fortran/4.4.4-intel-2018a")
depends_on("ecCodes/2.8.2-intel-2018a")

local root = "/projects/p_your_project/WRF/WRF-4.3.1"
prepend_path( "PATH",            pathJoin(root, "main"))
prepend_path( "LD_LIBRARY_PATH", pathJoin(root, "main"))

setenv("PROJECT_DIR", "/projects/p_your_project")
setenv("WRF_DIR", "$PROJECT_DIR/WRF/WRF-4.3.1")

setenv("WRFIO_NCD_LARGE_FILE_SUPPORT" , 1)
setenv("NETCDF4"                      , 1)
setenv("OMP_STACKSIZE"                , "2G")
setenv("HDF5"                         , "/sw/installed/HDF5/1.10.1-intel-2018a")
setenv("PHDF5"                        , "/sw/installed/HDF5/1.10.1-intel-2018a")
setenv("PNETCDF"                      , "/sw/installed/PnetCDF/1.9.0-intel-2018a")
setenv("NETCDF"                       , "$PROJECT_DIR/WRF/netcdf_mine")
setenv("NETCDFF"                      , "/sw/installed/netCDF-Fortran/4.4.4-intel-2018a")
setenv("JASPERLIB"                    , "/sw/installed/JasPer/2.0.14-GCCcore-6.4.0/lib64")  
setenv("JASPERINC"                    , "/sw/installed/JasPer/2.0.14-GCCcore-6.4.0/include") 

```

After placing the `4.3.1.lua` in WRF directory, now you need to you need to expand the module search path. This is done by invoking the command:

```bash
module use /projects/p_your_project/WRF/WRF-4.3.1 
# or 
module use $WRF_DIR # if you still have it as environment variable.

```

The command above can fire an error due to the existence of this file `hydro/.version`. It can be solved by:

```bash
#show the file 
cat $WRF_DIR/hydro/.version
# rename it 
mv $WRF_DIR/hydro/.version $WRF_DIR/hydro/backup-version
#then expand the path for the module 
module use $WRF_DIR # if you still have it as environment variable.
```

If you are the admin of the project, you will need to make the file accesabile for your project member, therfore use:

```bash
chmod -R 777 /projects/p_your_project/WRF/WRF-4.3.1
```

### WPS as module

**to be continued**

## Others

If you would like to remove some unnecessary paths in `PATH` variable after installation, you can use:

```bash
PATH=$(REMOVE_PART="Path/to/be/removed" sh -c 'echo ":$PATH:" | sed "s@:$REMOVE_PART:@:@g;s@^:\(.*\):\$@\1@"')
```
