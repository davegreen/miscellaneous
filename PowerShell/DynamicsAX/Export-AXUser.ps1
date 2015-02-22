<# 
    .Synopsis
    Uses AX PowerShell cmdlets to Export AX user data.

    .Description
    Uses AX PowerShell cmdlets to Export AX user data. This script works with the corresponding Import-AXUser script.

    .Parameter CsvFile
    The path to the CSV file to export user data to.

    .Example
    .\Export-AXUser.ps1 -CsvFile .\Users.csv
    Export users to a CSV file called Users.csv in the current directory.
        
    .Notes
    Name  : Export-AXUser.ps1
    Author: David Green
  
    .Link
    http://www.tookitaway.co.uk
    https://github.com/davegreen/miscellaneous.git
#>

# The Setup-Management and Import-AXModule portaions of theis script are from a script originally by Vishy (http://vgrandhi.wordpress.com).
# (http://vgrandhi.wordpress.com/2014/04/22/ax-2012-powershell-script-to-export-users-and-roles/)

[CmdletBinding()]
Param
(   [Parameter(Mandatory=$false,
    ParameterSetName='CSV')]
    [string]$CsvFile
)

Function Import-AXModule($axModuleName, $disableNameChecking, $isFile)
{
    Try
    {
        $outputmessage = "Importing " + $axModuleName
        Write-Verbose $outputmessage
 
        if($isFile)
        {
            $dynamicsSetupRegKey = Get-Item "HKLM:\SOFTWARE\Microsoft\Dynamics\6.0\Setup"
            $sourceDir = $dynamicsSetupRegKey.GetValue("InstallDir")
            $axModuleName = "ManagementUtilities\" + $axModuleName + ".dll"
            $axModuleName = Join-Path $sourceDir $axModuleName
        }

        if($disableNameChecking)
        {
            Import-Module $axModuleName -DisableNameChecking
        }

        else
        {
            Import-Module $axModuleName
        }
    }

    Catch
    {
        $outputmessage = "Could not load file " + $axModuleName
        Write-Error $outputmessage
    }
}

Function Setup-Management()
{ 
    $dynamicsSetupRegKey = Get-Item "HKLM:\SOFTWARE\Microsoft\Dynamics\6.0\Setup"
    $sourceDir = $dynamicsSetupRegKey.GetValue("InstallDir")
    $dynamicsAXModulesPath = join-path $sourceDir "ManagementUtilities\Modules"
    $env:PSModulePath = $env:PSModulePath + ";" + $dynamicsAXModulesPath

    Import-AXModule "AxUtilLib" $false $true
    Import-AXModule "AxUtilLib.PowerShell" $true $false
    Import-AXModule "Microsoft.Dynamics.Administration" $false $false
    Import-AXModule "Microsoft.Dynamics.AX.Framework.Management" $false $false
}

Setup-Management
$OutputObj = @()

Write-Verbose "Exporting AX Accounts of type `"WindowsUser`"."

foreach ($user in Get-AxUser | Where-Object {$_.AccountType -eq "WindowsUser"})
{
    if ($user.Name -and $user.UserName)
    {
        Write-Verbose "Exporting User $($user.UserName) ($($user.Name))."
        $AXUser = New-Object PSObject
        $AXUser | Add-Member NoteProperty -Name "Name" -Value $user.Name
        $AXUser | Add-Member NoteProperty -Name "UserName" -Value $User.UserName
        $AXUser | Add-Member NoteProperty -Name "AccountType" -Value $User.AccountType
        $AXUser | Add-Member NoteProperty -Name "Enabled" -Value $user.Enabled
        $AXUser | Add-Member NoteProperty -Name "Company" -Value $user.Company
        $AXUser | Add-Member NoteProperty -Name "Role" -Value ((Get-AXSecurityRole -AxUserId $User.AxUserId | Select-Object -ExpandProperty AOTName) -join ",")
        $OutputObj += $AXUser
    }
}

if ($CsvFile)
{
    Write-Verbose "Writing to CSV."
    $OutputObj | Export-Csv $CsvFile -NoTypeInformation -NoClobber
}

else
{
    Write-Output $OutputObj
}
