REM Create temp folder for bash
bash -lc "ln -s ${LOCALAPPDATA}/Temp /tmp"

bash -l %RECIPE_DIR%\build-windows.sh

