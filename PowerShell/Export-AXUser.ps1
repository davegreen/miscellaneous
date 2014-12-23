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
