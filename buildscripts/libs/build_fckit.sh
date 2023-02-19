#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="fckit"
# source should be either ecmwf or jcsda (fork)
source=$1
version=$2

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

software=fckit
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch --tags
git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module load jedi-$JEDI_MPI
    module try_load ncarcompilers
    module try_load cmake
    module try_load ecbuild
    module try_load eckit
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$source-$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${FCKIT_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

# ygyu  python flag


# set install prefix and CMAKE_INSTALL_LIBDIR to make sure it installs as lib, not lib64
ecbuild --build=release -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_LIBDIR=lib ..

# fail
#ecbuild --build=release -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_LIBDIR=lib \
#    -DPYTHON_INCLUDE_DIR=$(python3.11 -c "import sysconfig; print(sysconfig.get_path('include'))")  \
#    -DPYTHON_LIBRARY=$(python3.11 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))") ..

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $source-$version \
         || echo $name $source-$version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
