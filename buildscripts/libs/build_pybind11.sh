#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# This is a project to generate C++/Python bindings.
# Library is header-only, so there is no need to link to Python here.

set -ex

name="pybind11"
version=$1

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=pybind11
branch=v$(echo $version)
[[ -d $software ]] || git clone https://github.com/pybind/$software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch
git checkout $branch
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try_load cmake
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix="/usr/local"
fi

[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DPYBIND11_TEST=OFF -DCMAKE_VERBOSE_MAKEFILE=1 ..
VERBOSE=$MAKE_VERBOSE $SUDO make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
