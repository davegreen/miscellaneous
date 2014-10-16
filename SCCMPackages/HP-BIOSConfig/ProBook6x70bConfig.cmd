pushd %~dp0

set _bcu=BiosConfigUtility.exe
if /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" set _bcu=BiosConfigUtility64.exe

"%_bcu%" /nspwdfile:"%~dp0BIOSPW.bin" /set:"%~dp0ProBook6470bConfig.cfg"

IF %ERRORLEVEL% NEQ 0 "%_bcu%" /cspwdfile:"%~dp0BIOSPW.bin" /set:"%~dp0ProBook6470bConfig.cfg"

popd
