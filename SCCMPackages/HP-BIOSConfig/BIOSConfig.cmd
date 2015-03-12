pushd %~dp0

if %1.==. GOTO NoParams

set _bcu=BiosConfigUtility.exe

if /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" set _bcu=BiosConfigUtility64.exe

"%_bcu%" /nspwdfile:"%~dp0BIOSPW.bin" /set:"%~dp0%1"

if %ERRORLEVEL% NEQ 0 "%_bcu%" /cspwdfile:"%~dp0BIOSPW.bin" /set:"%~dp0%1"

:NoParams
set ERRORLEVEL=1

popd
