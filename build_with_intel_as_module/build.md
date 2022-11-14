# Installation as project module of WRF model using Intel compilers

- [Installation as project module of WRF model using Intel compilers](#installation-as-project-module-of-wrf-model-using-intel-compilers)
  - [Dependencies](#dependencies)
  - [WRF & WPS Installation](#wrf--wps-installation)
    - [WRF](#wrf)
    - [WPS](#wps)
  - [Creating Modulefile](#creating-modulefile)
    - [WRF as module](#wrf-as-module)
    - [WPS as module](#wps-as-module)

First, thanks to @ KlemensBarfus & @lenamueller for their help and the rich discussion :grinning:.


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

Now, you can change to your project directory. i.e.`/projects/p_your_project`

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

### WRF

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

`-j 4` means compile the model parallel. The number refers to the number of the parallel processes. This step can take up to one hour (with the default `-j 2`).

### WPS

to be continued

## Creating Modulefile

### WRF as module 

```lua
help([[

Description
===========
WRF Model is a state of the art mesoscale numerical weather prediction system designed for both atmospheric research and operational forecasting applications.

More Information
================
For detailed instructions, go to:
   https://www2.mmm.ucar.edu/wrf

]])

whatis("Version: 4.3.1")
whatis([==[Description: The Weather Research and Forecasting (WRF) Model is a next-generation mesoscale numerical weather prediction system designed to serve both operational forecasting and atmospheric research needs.]==])
whatis([==[Homepage: http://www.wrf-model.org]==])

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

setenv("NETCDF", "/projects/p_your_project/WRF/netcdf_mine")
setenv("NETCDFF", "/sw/installed/netCDF-Fortran/4.4.4-intel-2018a")
```
### WPS as module 