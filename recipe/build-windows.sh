set -ex

export GCC_ARCH="x86_64-w64-mingw32"
export CPPFLAGS="-DMS_WIN64 -DWIN32"
export PKG_CONFIG_PATH="$(cygpath -u $LIBRARY_LIB/pkgconfig)"
export gsl_CFLAGS="-I$(cygpath -u $LIBRARY_INC) -DGSL_DLL -DGSL_VAR='extern __declspec(dllimport)'"
#export gsl_CFLAGS="-I$(cygpath -u $LIBRARY_INC) -DGSL_DLL"
export gsl_LIBS="-lgsl"
export HDF5_CFLAGS="-I$(cygpath -u $LIBRARY_INC) -DH5_BUILT_AS_DYNAMIC_LIB=1 -D_MSC_VER=1"
#export HDF5_CFLAGS="-I$(cygpath -u $LIBRARY_INC) -DH5_BUILT_AS_DYNAMIC_LIB=1"
export HDF5_LIBS="-lhdf5"

# Create suitable gcc-compatible import library from python dll
gendef ${PREFIX}/python${CONDA_PY}.dll && dlltool -l libpython${CONDA_PY}.a -d python${CONDA_PY}.def -k -A

# Do the same for gsl -> change 25 to an appropriate value when GSL gets updated!
gendef ${LIBRARY_BIN}/gsl-25.dll && dlltool -l libgsl.dll.a -d gsl-25.def --export-all-symbols

# and do the same for hdf5!
gendef ${LIBRARY_BIN}/hdf5.dll && dlltool -l libhdf5.dll.a -d hdf5.def -k -A --export-all-symbols

./configure --disable-static --build=$GCC_ARCH --host=$GCC_ARCH --target=$GCC_ARCH --enable-python-integration --enable-python --prefix=$(cygpath -u $LIBRARY_PREFIX) PYTHON=$(which python) LIBS=-L$PWD
make
make install
rm -rf $PREFIX/Library/tmp
rm $(cygpath -u $LIBRARY_LIB)/libpolycap.la
rm $(cygpath -u $SP_DIR)/*.la

