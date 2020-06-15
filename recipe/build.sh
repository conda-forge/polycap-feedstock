set -e -x

if [[ "$target_platform" == win* ]]; then
	export CFLAGS+=" -Wno-error=unused-function "
	export GCC_ARCH=x86_64-w64-mingw32
	export EXTRA_FLAGS=-DMS_WIN64

	curl -L -O https://patch-diff.githubusercontent.com/raw/PieterTack/polycap/pull/52.diff
	patch -p1 < 52.diff || true
	sed -i.bak "s/-Wl,-subsystem,windows//g" configure.ac
	export PKG_CONFIG_PATH="$(cygpath -u $LIBRARY_LIB)\pkgconfig"
	autoreconf -fi
	./configure \
		--disable-static \
		--build=$GCC_ARCH --host=$GCC_ARCH --target=$GCC_ARCH \
		--enable-python-integration \
		--enable-python \
		--prefix=`cygpath -u $PREFIX` \
		--bindir=`cygpath -u $LIBRARY_BIN` \
		--libdir=`cygpath -u $LIBRARY_LIB` \
		PYTHON=`which python` \
		CPPFLAGS="$CPPFLAGS $EXTRA_FLAGS" \
		LIBS="$LIBS -L`cygpath -u $PREFIX`/../libs -llegacy_stdio_definitions" \
		|| (cat config.log && exit 1)
	patch_libtool
	make
	make install
	rm -rf $PREFIX/Library/tmp
	rm `cygpath -u $LIBRARY_LIB`/libpolycap.la
	#mv `cygpath -u $LIBRARY_LIB`/xrl.dll.lib `cygpath -u $LIBRARY_LIB`/xrl.lib
	rm `cygpath -u $SP_DIR`/*.la
	rm `cygpath -u $SP_DIR`/*.lib
else
	./configure --enable-python --prefix=$PREFIX
	make
	make install
fi
