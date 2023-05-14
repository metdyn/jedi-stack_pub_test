#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

# Minimal JEDI Stack
export      STACK_BUILD_CMAKE=Y  # otherwise, ncview, netcdf, h5 needs brew uninstall
export     STACK_BUILD_GITLFS=N
export       STACK_BUILD_SZIP=Y
export    STACK_BUILD_UDUNITS=Y
export       STACK_BUILD_ZLIB=Y
export     STACK_BUILD_LAPACK=Y
export STACK_BUILD_BOOST_HDRS=Y
export       STACK_BUILD_BUFR=Y
export     STACK_BUILD_EIGEN3=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
export    STACK_BUILD_ECBUILD=Y
export      STACK_BUILD_ECKIT=Y
export      STACK_BUILD_FCKIT=Y
export      STACK_BUILD_ATLAS=Y
export   STACK_BUILD_GSL_LITE=Y
export   STACK_BUILD_PYBIND11=Y

# Optional Additions
export       STACK_BUILD_ECCODES=Y
export           STACK_BUILD_ODC=Y
export           STACK_BUILD_PIO=Y
export          STACK_BUILD_GPTL=N
export           STACK_BUILD_NCO=Y
export        STACK_BUILD_PYJEDI=Y
export      STACK_BUILD_NCEPLIBS=Y
export          STACK_BUILD_JPEG=Y
export           STACK_BUILD_PNG=Y
export        STACK_BUILD_JASPER=Y
export        STACK_BUILD_XERCES=Y
export        STACK_BUILD_TKDIFF=Y
export    STACK_BUILD_BOOST_FULL=Y
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N
export     STACK_BUILD_PDTOOLKIT=N
export          STACK_BUILD_TAU2=N
export          STACK_BUILD_CGAL=Y
export          STACK_BUILD_GEOS=N
export        STACK_BUILD_SQLITE=Y
export          STACK_BUILD_PROJ=N
export           STACK_BUILD_FMS=Y
export          STACK_BUILD_JSON=Y
export STACK_BUILD_JSON_SCHEMA_VALIDATOR=Y
export        STACK_BUILD_ECFLOW=Y
