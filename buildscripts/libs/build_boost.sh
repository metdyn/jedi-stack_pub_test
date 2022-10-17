#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -x

name="boost"
version=$1
[[ $# -lt 2 ]] && level="full" || level=$2

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
software=$name\_$(echo $version | sed 's/\./_/g')
url="https://boostorg.jfrog.io/artifactory/main/release/$version/source/$software.tar.gz"
[[ -d $software ]] || ( rm -f $software.tar.gz; $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

########################################################################
# The headers-only option

if [[ $level = "headers-only" ]]; then

    $MODULES && prefix="${PREFIX:-"/opt/modules"}/core/$name/$version" \
             || prefix=${BOOST_ROOT:-"/usr/local"}
    $SUDO mkdir -p $prefix $prefix/include
    $SUDO cp -R boost $prefix/include

    # generate modulefile from template
    $MODULES && update_modules core "boost-headers" $version \
             || echo "boost-headers" $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

    exit 0
fi

########################################################################

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

debug="--debug-configuration"

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    [[ -z $mpi ]] || module load jedi-$JEDI_MPI
    module list
    set -x
    prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${BOOST_ROOT:-"/usr/local"}
fi

BoostRoot=$(pwd)
BoostBuild=$BoostRoot/BoostBuild
build_boost=$BoostRoot/build_boost
[[ -d $BoostBuild ]] && rm -rf $BoostBuild
[[ -d $build_boost ]] && rm -rf $build_boost

cd $BoostRoot/tools/build

# Configure with MPI
compName=$(echo $compiler | cut -d- -f1)
case "$compName" in
    gnu   ) MPICC=$(which mpicc)  ; toolset=gcc ;;
    intel ) MPICC=$(which mpiicc) ; toolset=intel ;;
    clang ) MPICC=$(which mpiicc) ; toolset=clang ;;
    *     ) echo "Unknown compiler = $compName, ABORT!"; exit 1 ;;
esac

cp $BoostRoot/tools/build/example/user-config.jam ./user-config.jam
cat >> ./user-config.jam << EOF

# ------------------
# MPI configuration.
# ------------------
using mpi : $MPICC ;
EOF

rm -f $HOME/user-config.jam
[[ -z $mpi ]] && rm -f ./user-config.jam || mv -f ./user-config.jam $HOME

./bootstrap.sh --with-toolset=$toolset --with-python=`which python3`
./b2 install $debug --prefix=$BoostBuild

export PATH="$BoostBuild/bin:$PATH"

cd $BoostRoot
b2 $debug --build-dir=$build_boost address-model=64 toolset=$toolset stage
$SUDO mkdir -p $prefix $prefix/include
$SUDO cp -R boost $prefix/include
$SUDO mv stage/lib $prefix

rm -f $HOME/user-config.jam

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
