PUSHD %~dp0

SET _upd=hpqFlash.exe
SET bios=%1

IF /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (
	SET _upd=hpqFlash64.exe
)

"%_upd%" -pBIOSPW.bin -f%bios% -s

POPD

IF %ERRORLEVEL% NEQ 282 (
	IF %ERRORLEVEL% NEQ 273 (
		EXIT /B 3010
	)
)

