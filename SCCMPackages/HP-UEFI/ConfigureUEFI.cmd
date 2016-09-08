PUSHD %~dp0

SET _bcu=BiosConfigUtility.exe
SET config=%1

IF /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (
	SET _bcu=BiosConfigUtility64.exe
)

"%_bcu%" /nspwdfile:"%~dp0BIOSPW.bin" /set:"%~dp0%config%" /l

IF %ERRORLEVEL% EQU 10 (
	"%_bcu%" /cspwdfile:"%~dp0BIOSPW.bin" /set:"%~dp0%config%" /l
)

POPD

EXIT /B 3010