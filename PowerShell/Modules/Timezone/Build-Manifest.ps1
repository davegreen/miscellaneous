<#
    Name  : Build-Manifest (Timezone)
    Author: David Green

    http://www.tookitaway.co.uk/
    https://github.com/davegreen/miscellaneous.git
	
#>

New-ModuleManifest -Path "$PSScriptRoot\Timezone.psd1" -Description 'A PowerShell script module designed to get and set the timezone, using tzutil.' -RootModule 'Timezone.psm1' -Author 'David Green' -CompanyName 'David Green' -Copyright '(c) 2015 David Green' -PowerShellVersion '3.0' -ModuleVersion '1.0' -FileList @('Timezone.psd1', 'Timezone.psm1')