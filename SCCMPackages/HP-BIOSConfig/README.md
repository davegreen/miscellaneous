This package requires the [HP BIOS Configuration Utility](http://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html)

If you are using a BIOS password, you will need the [HP System Software Manager](http://ftp.hp.com/pub/caps-softpaq/cmit/HP_SSM.html)

- Extract the HP System Software Manager download and install it.
- You’ll then have to browse to either `%ProgramFiles(x86)%\Hewlett-Packard\SystemSoftwareManager`, or `%ProgramFiles%\Hewlett-Packard\SystemSoftwareManager` to find `ssm.cab`.
- The BIOS password encryption tool you need is in here (Called `HpqPswd.exe`).

BIOSConfig.cmd can then be used to apply the configuration you want by specifying the configuration filename as a parameter to the batch file:
`BIOSConfig.cmd ProBook6x70b.cfg`
