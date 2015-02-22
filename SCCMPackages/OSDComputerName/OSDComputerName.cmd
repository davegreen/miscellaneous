set _sui=ServiceUI.exe
if /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" set _sui=ServiceUI_x64.exe

"%_sui%" -process:TSProgressUI.exe %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File OSDComputerName.ps1