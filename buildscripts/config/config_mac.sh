#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

# Compiler/MPI combination
export JEDI_COMPILER="clang/14.0.0"  # "clang/14.0.0" ? hwloc inconsistent between clang and gfortran, 13.1.6 old
export FC=gfortran                   # Set the initial fortran compiler to build MPI distribution
export JEDI_MPI="openmpi/4.0.7"
#export JEDI_MPI="mpich/3.3.2"        # 17-Oct-2022 fail mpich/4.0.2
export COMPILER_BUILD="native-pkg"
export MPI_BUILD="from-source"

# Build options
export PREFIX=${JEDI_OPT:-/opt/modules}
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"
#Global compiler flags
export FFLAGS=""
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortrant
# from-source: This is to build from source

##Note this does not work
##Determine number of processors: valid on OS
## note =16 on my mac; but [[ -x systcl ]] fails. 
#if [[ -x sysctl ]]; then
#    NUM_PROCS=$(sysctl -n hw.logicalcpu)    
#else
#    NUM_PROCS=4
#fi
