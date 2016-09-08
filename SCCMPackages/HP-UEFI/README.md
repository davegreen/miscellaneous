This package requires the [HP BIOS Configuration Utility](http://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html)

If you are using a UEFI/BIOS password, you will need the [HP System Software Manager](http://ftp.hp.com/pub/caps-softpaq/cmit/HP_SSM.html). 

- Extract the HP System Software Manager download and install it.
- You’ll then have to browse to `%ProgramFiles(x86)%\Hewlett-Packard\System Software Manager`
or `%ProgramFiles%\Hewlett-Packard\SystemSoftwareManager` to find `ssm.cab`.
- The BIOS/UEFI password encryption tool you need is in this cabinet file (Called `HpqPswd.exe`).
- This package also contains `HPqflash.exe` and `HPBIOSUPDREC.exe` for deploying updated UEFI images.

ConfigureUEFI.cmd can then be used to apply the configuration (and the password you want if it's not set) by specifying the configuration filename as a parameter to the batch file:
`ConfigureUEFI.cmd EliteBook8x0G3-Win10.cfg`

UpdateUEFI.cmd can be used to apply an updated UEFI image, with the firmware file as a parameter:
`UpdateUEFI.cmd BiosFile.bin`