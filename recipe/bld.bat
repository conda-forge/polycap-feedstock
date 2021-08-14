setlocal EnableDelayedExpansion
@echo on


set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --default-library=shared ^
  --wrap-mode=nofallback ^
  --buildtype=release ^
  --backend=ninja ^
  -Dpython=%PYTHON% ^
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

@REM Meson doesn't put the Python files in the right place.
cd %LIBRARY_PREFIX%\lib\python*
cd site-packages
move polycap.* %PREFIX%\lib\site-packages\
