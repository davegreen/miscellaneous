This Package requires ServiceUI to run in WinPE. This can be obtained from http://technet.microsoft.com/en-gb/windows/dn475741.aspx

You will also need to perform the following steps to work with SCCM.

Add the ‘WinPE-NetFx’ and ‘WinPE-Powershell’ features to the boot image you will be using. (Boot Images > Boot image > Properties > Optional components)
Download a copy of MDT that matches the boot image architecture you want (x86/x64), then extract the ServiceUI.exe file from it, usually located at "%ProgramFiles%\Microsoft Deployment Toolkit\Templates\Distribution\Tools"
Create an SCCM package containing the script, plus ServiceUI, but don’t create a program for it, as we’ll deal with that bit when adding it to the task sequence.
Add a ‘Run Command Line’ task in your task sequence, then use the package created  in the previous step, along with a command line like:

ServiceUI.exe -process:TSProgressUI.exe %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File MYSCRIPTFILENAME.ps1
