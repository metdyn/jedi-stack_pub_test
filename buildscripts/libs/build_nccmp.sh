#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="nccmp"
version=$1

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

url="https://gitlab.com/remikz/nccmp/-/archive/$version/${software}.tar.gz"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

[[ -d $software ]] || ( rm -f $software.tar.gz; $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    [[ -z $mpi ]] || module load jedi-$JEDI_MPI
    module try_load ncarcompilers
    module try_load szip
    module load hdf5
    module try_load pnetcdf
    module load netcdf
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${NCCMP_ROOT:-"/usr/local"}
fi

if [[ ! -z $mpi ]]; then
    export FC=$MPI_FC
    export CC=$MPI_CC
    export CXX=$MPI_CXX
else
    export FC=$SERIAL_FC
    export CC=$SERIAL_CC
    export CXX=$SERIAL_CXX
fi

export CFLAGS+=" -fPIC -fcommon"
export LDFLAGS+=" -L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

# Enable header pad comparison, if netcdf-c src directory exists!
[[ -d "netcdf-c-$NETCDF_VERSION" ]] && extra_confs="--with-netcdf=$PWD/netcdf-c-$NETCDF_VERSION" || extra_confs=""

../configure --prefix=$prefix $extra_confs

make V=$MAKE_VERBOSE -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make V=$MAKE_VERBOSE -j${NTHREADS:-4} install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
