#!/bin/bash

# exit on first error
set -e

source wrf_modules

mkdir $WRF_HOME
mkdir $WRF_DEPENDENCIES

# Compile zlib
echo "Compile Zlib"
cd $WRF_HOME && \
wget https://zlib.net/zlib-1.2.12.tar.gz && \
tar xvf zlib-1.2.12.tar.gz && \
cd zlib-1.2.12/  && \
./configure --prefix=$WRF_DEPENDENCIES  && \
make -j && \
make install  && \
cd .. && \
rm -rf zlib-1.2.12 zlib-1.2.12.tar.gz

# compile hdf5
echo "Compile Hdf5"
cd $WRF_HOME && \
wget https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_12_0/source/hdf5-1.12.0.tar.gz && \
tar xvf hdf5-1.12.0.tar.gz && \
cd hdf5-1.12.0 && \
./configure --prefix=$WRF_DEPENDENCIES --with-zlib=$WRF_DEPENDENCIES --enable-fortran && \
make -j && \
make install && \
cd .. && \
rm -rf hdf5-1.12.0 hdf5-1.12.0.tar.gz

# compile netcdf
echo "Compile netcdf"
cd $WRF_HOME && \
wget https://downloads.unidata.ucar.edu/netcdf-c/4.8.1/netcdf-c-4.8.1.tar.gz && \
tar xvf netcdf-c-4.8.1.tar.gz  && \
cd netcdf-c-4.8.1/ && \
export LD_LIBRARY_PATH=$WRF_DEPENDENCIES/lib && \
export LDFLAGS=-L$WRF_DEPENDENCIES/lib && \
export CPPFLAGS=-I$WRF_DEPENDENCIES/include && \
source ~/wrf_modules &&\
./configure --prefix=$WRF_DEPENDENCIES && \
make -j && \
make install  && \
cd .. && \
rm -rf netcdf-c-4.8.1 netcdf-c-4.8.1.tar.gz

# compile netcdf-fortran
echo "Compile netcdf-fortran"
cd $WRF_HOME && \
wget https://downloads.unidata.ucar.edu/netcdf-fortran/4.5.4/netcdf-fortran-4.5.4.tar.gz && \
tar xvf netcdf-fortran-4.5.4.tar.gz && \
cd netcdf-fortran-4.5.4/ && \
export LD_LIBRARY_PATH=$WRF_DEPENDENCIES/lib && \
export LDFLAGS=-L$WRF_DEPENDENCIES/lib && \
export CPPFLAGS=-I$WRF_DEPENDENCIES/include && \
source ~/wrf_modules &&\
./configure --prefix=$WRF_DEPENDENCIES --with-netcdf=$WRF_DEPENDENCIES && \
make -j && \
make install && \
cd .. && \
rm -rf netcdf-fortran-4.5.4 netcdf-fortran-4.5.4.tar.gz

# compile jasper
echo "Compile jasper"
cd $WRF_HOME && \
wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.29.tar.gz && \
tar xvf jasper-1.900.29.tar.gz && \
cd jasper-1.900.29 && \
sed -i 's/char \*optstr/const char \*optstr/g' src/libjasper/jpg/jpg_dummy.c  && \
./configure --prefix=$WRF_DEPENDENCIES && \
make -j && \
make install && \
cd .. && \
rm -rf jasper-*

# compile wrf
echo "Compile wrf"
cd $WRF_HOME && \
export NETCDF=$WRF_DEPENDENCIES && \
export HDF5=$WRF_DEPENDENCIES && \
wget https://github.com/wrf-model/WRF/archive/refs/tags/v4.3.1.tar.gz && \
tar xvf v4.3.1.tar.gz && \
cd WRF-4.3.1/ && \
./configure && \
./compile 2>&1 | tee compile.log && \
cd .. && \
rm -rf v4.3.1.tar.gz

# compile wps
echo "Compile wps"
wget https://github.com/wrf-model/WPS/archive/refs/tags/v4.3.1.tar.gz && \
tar xvf v4.3.1.tar.gz && \
cd WPS-4.3.1/ && \
export NETCDF=$WRF_DEPENDENCIES && \
export HDF5=$WRF_DEPENDENCIES && \
export WRF_DIR=$WRF_HOME/WRF-4.3.1 && \
export JASPERINC=$WRF_DEPENDENCIES/include && \
export JASPERLIB=$WRF_DEPENDENCIES/lib && \
./configure && \
./compile 2>&1 | tee compile.log &&\
cd .. && \
rm -rf v4.3.1.tar.gz
