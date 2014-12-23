<# 
    .Synopsis
    Uses AX PowerShell cmdlets to Import AX users from a CSV file.

    .Description
    Uses AX PowerShell cmdlets to Import AX users from a CSV file and works with the corresponding Export-AXUser script.

    .Parameter CsvFile
    The path to the CSV file containing the users to import.

    .Parameter DefaultCompany
    Do not specify the company to add users to (use default).

    .Parameter NoClobber
    Do not override security for existing users.

    .Example
    .\Import-AXUser.ps1 -CsvFile .\Users.csv
    Import users from the CSV file in the current directory.
        
    .Notes
    Name  : Import-AXUser.ps1
    Author: David Green
  
    .Link
    http://www.tookitaway.co.uk
    https://github.com/davegreen/miscellaneous.git
#>

# The Setup-Management and Import-AXModule portaions of theis script are from a script originally by Vishy (http://vgrandhi.wordpress.com).
# (http://vgrandhi.wordpress.com/2014/04/22/ax-2012-powershell-script-to-export-users-and-roles/)

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true,
    ParameterSetName='CSV')]
    [string]$CsvFile = "Users.csv",
    [switch]$DefaultCompany,
    [switch]$NoClobber
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

Function Set-AxSecurity()
{
    Write-Verbose "Setting security roles for $($user.UserName) ($($user.Name))."
    $securityRoles = Get-AXSecurityRole -AxUserID $AXUserId
    $userRoles = @()
        
    foreach ($role in $user.Role.split(","))
    {
        $obj = New-Object PSObject
        $obj | Add-Member NoteProperty -Name "AOTName" -Value $role
        $userRoles += $obj
    }
     
    switch (Compare-Object -ReferenceObject $securityRoles -DifferenceObject $userRoles -property AOTName)
    {
        {$_.SideIndicator -eq "=>"}
        {
            foreach ($aot in $_.AOTName)
            {
                Add-AXSecurityRoleMember -AXUserId $AXUserId -AOTName $aot
                Write-Verbose "Added $($user.UserName) to the role $($aot)."
            }
        }
        
        {$_.SideIndicator -eq "<="}
        {
            #Nothing Native in PowerShell to remove AX security roles from users.
            Write-Verbose "$($user.UserName) has the role $($_.AOTName), but this is not specified in the import data."
        }

        {$_.SideIndicator -eq "=="}
        {
            Write-Verbose "$($user.UserName) already has the role $($_.AOTName)."
        }
    }
}

Setup-Management

$Users = Import-Csv $CsvFile
$UserDomain = $env:userdnsdomain
$AXUsers = Get-AXUser | where {$_.AXUserId -and $_.UserName}
$AXUserId = $null

foreach ($user in $Users)
{
    if ($user.UserName.length -gt 8)
    {
        $AXUserId = ($user.UserName.SubString(0,7) + $user.UserName.substring($user.UserName.length -1))
        Write-Verbose "Altered AXUserId from $($user.UserName) to $AXUserId in order to fit length requirements."
    }

    else
    {
        $AXUserId = $user.UserName
    }

    Write-Verbose "Checking if user $($user.UserName) ($($user.Name)) exists."

    if ($AXUsers.UserName -notcontains $user.UserName)
    {
        if ($DefaultCompany)
        {
            Write-Verbose "Creating User $($user.UserName) ($($user.Name))."
            New-AXUser -AccountType $user.AccountType -AXUserId $AXUserId -UserDomain $UserDomain -UserName $user.UserName
        }

        else
        {
            Write-Verbose "Creating User $($user.UserName) ($($user.Name)) in company $($user.Company)."
            New-AXUser -AccountType $user.AccountType -AXUserId $AXUserId -UserDomain $UserDomain -UserName $user.UserName -Company $user.Company
        }

        Set-AxSecurity
    }

    else
    {
        Write-Verbose "User $($user.UserName) ($($user.Name)) already exists."
    }

    if (!$NoClobber)
    {
        Set-AxSecurity
    }
}
