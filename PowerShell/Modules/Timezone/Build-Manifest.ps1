<#
    Name  : Build-Manifest (Timezone)
    Author: David Green

    http://www.tookitaway.co.uk/
    https://github.com/davegreen/miscellaneous.git
	
#>

New-ModuleManifest -Path "$PSScriptRoot\Timezone.psd1" -Description 'A PowerShell script module designed to get and set the timezone, wrapping the tzutil command.' -RootModule 'Timezone.psm1' -Author 'David Green' -CompanyName 'http://tookitaway.co.uk/' -Copyright '(c) 2016 David Green. All rights reserved.' -PowerShellVersion '5.0' -ModuleVersion '1.0.1' -FileList @('Timezone.psd1', 'Timezone.psm1', 'Timezone.Tests.ps1') -FunctionsToExport @('Get-Timezone', 'Get-TimezoneFromOffset', 'Set-Timezone')