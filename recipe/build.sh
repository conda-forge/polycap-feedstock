set -e -x

export CI=true

if [[ $(uname) == Darwin ]]; then
  export FCFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FCFLAGS"
  export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config
fi

if [ -z "$MESON_ARGS" ]; then
  # for some reason this is not set on Linux
  MESON_ARGS="--buildtype=release --prefix=${PREFIX} --libdir=lib"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  # Bash scripts with shebang lines calling bash scripts
  # are not supported. Since the python on PATH when cross
  # compiling is a bash script, this breaks calling cython
  # workaround is to change the shebang lie of cython to call
  # python bash script indirectly.
  mv $BUILD_PREFIX/bin/cython $BUILD_PREFIX/bin/cython.bak
  echo '#!/usr/bin/env python' > $BUILD_PREFIX/bin/cython
  cat $BUILD_PREFIX/bin/cython.bak >> $BUILD_PREFIX/bin/cython
  chmod a+x $BUILD_PREFIX/bin/cython

  echo "[binaries]" > "${BUILD_PREFIX}/meson_cross_extra_file.txt"
  echo "h5cc = '${PREFIX}/bin/h5cc'" >> "${BUILD_PREFIX}/meson_cross_extra_file.txt"

  MESON_ARGS+=" --cross-file ${BUILD_PREFIX}/meson_cross_extra_file.txt"
fi

mkdir build
cd build
meson ${MESON_ARGS} \
      --default-library=shared \
      -Dbuild-documentation=false \
      -Dpython=$PYTHON \
      .. || (cat meson-logs/meson-log.txt && exit 1)
ninja
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  ninja test
fi
ninja install
