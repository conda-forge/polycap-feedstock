setlocal EnableDelayedExpansion
@ECHO ON

@REM pkg-config setup
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"

:: meson options
set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --default-library=shared ^
  --buildtype=release ^
  --backend=ninja ^
  -Dpython="%PYTHON%" ^
  -Dpython.platlibdir="%SP_DIR%" ^
  -Dpython.purelibdir="%SP_DIR%" ^
  -Dbuild-documentation=false ^
 ^"

:: configure build using meson
meson setup builddir !MESON_OPTIONS!
if errorlevel 1 exit 1

:: print results of build configuration
meson configure builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\bin\*.pdb

@REM For some reason conda-build decides that the meson files in Scripts are new?
del %PREFIX%\Scripts\meson* %PREFIX%\Scripts\wraptool*
