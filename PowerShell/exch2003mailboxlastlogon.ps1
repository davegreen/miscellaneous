<# 
  .Synopsis
  Uses WMI to get Exchange and AD data about users and mailboxes.

  .Description
  Gets LegacyDN, MailboxDisplayName, Size, TotalItems for Exchange
  and DS_legacyExchangeDN, DS_proxyAddresses, DS_mail, DS_userAccountControl, 
  DS_extensionAttribute1, DS_CN, DS_LastLogonTimeStamp, DS_accountExpires for AD.
    
  .Parameter ExchServerName
  The hostname of the Exchange server to query.

  .Parameter ADServerName
  The hostname of the AD server to query. If no AD domain controller is specified, use the exchange server hostname.

  .Parameter ListEmpty
  Do not list empty mailboxes, unless -ListEmpty is specified.

  .Parameter ListSystem
  # Do not list system mailboxes, unless -ListSystem is specified.

  .Parameter ListNoEmail
  # Do not list users with no email address, unless -ListNoEmail is specified.

  .Example
  .\exch2003mailboxlastlogon.ps1 -ListEmpty -ListNoEmail
  Get the data from the machine running the script. List both Empty mailboxes and users with no mail address.

  .Example
  .\exch2003mailboxlastlogon.ps1 -ExchServerName Exchange1.contoso.com
  Query the server 'Exchange1.contoso.com'
        
  .Notes
  Name  : exch2003mailboxlastlogon
  Author: David Green
  
  .Link
  http://www.tookitaway.co.uk
#>

# Modified by Dave Green (david.green@tookitaway.co.uk) from a script originally by Gary Siepser, Microsoft Premier Field Engineer.
# (http://blogs.technet.com/b/gary/archive/2009/09/16/list-mailbox-sizes-for-both-exchange-2003-and-exchange-2007.aspx)

[cmdletbinding()]
param(

  # The hostname of the Exchange server. If this is not specified, the current machine hostname will be used.
  [parameter(Mandatory=$false)][string]$ExchServerName = ([System.Net.Dns]::GetHostByName(($env:computerName)).HostName),

  # The hostname of an AD Domain controller in the same domain as the Exchange server. If this is not specified, the Exchange server name will be used.
  [parameter(Mandatory=$false)][string]$ADServerName = $ExchServerName,
  [parameter(Mandatory=$false)][switch]$ListEmpty,
  [parameter(Mandatory=$false)][switch]$ListSystem,
  [parameter(Mandatory=$false)][switch]$ListNoEmail
)

# Returns a date string based on an AD attribute (like lastlogon, or accountexpires).
# Param1: $addate - AD attribute date value.
Function Get-ADDate($addate)
{
  Try
  {
    $formatteddate = [datetime]::FromFileTime($addate).Date.ToString()
  }

  Catch
  {
    $formatteddate = "Never"
  }

  return $formatteddate
}

# Get the WMI objects from both Exchange and AD
# Write progress to the console, to keep the user updated.
Write-Verbose "Getting data from WMI on $ExchServerName (root\MicrosoftExchangeV2\Exchange_mailbox)"
Write-Progress -Activity "Preparing Run" -Status "Getting data from WMI on $ExchServerName" -PercentComplete 0
$exchusers = Get-WmiObject -ComputerName $ExchServerName -Namespace root\MicrosoftExchangeV2 -Class Exchange_mailbox | Select-Object LegacyDN, MailboxDisplayName, Size, TotalItems
Write-Verbose "Got Exchange WMI data."
Write-Progress -Activity "Preparing Run" -Status "Getting data from WMI on $ADServerName" -PercentComplete 50
Write-Verbose "Getting data from WMI on $ADServerName (root\directory\ldap\ds_user)"
$adusers = Get-WmiObject -ComputerName $ADServerName -Namespace root\directory\ldap -Class ds_user | Select-Object DS_legacyExchangeDN, DS_proxyAddresses, DS_mail, DS_userAccountControl, DS_extensionAttribute1, DS_CN, DS_LastLogonTimeStamp, DS_accountExpires
Write-Progress -Activity "Preparing Run" -Status "Got WMI Data." -PercentComplete 100
Write-Verbose "Got AD WMI data."
$processed = 0

foreach ($euser in $exchusers)
{
  # Display the next section of the progress, for formatting and matching the data.
  Write-Progress -Activity "Formatting and matching data" -Status ("User: " + $euser.MailboxDisplayName) -PercentComplete ($processed / $exchusers.Count * 100)
  $lastlogondate = @()
  $accountexpires = @()
  $object = New-Object PSObject

  # Do not list empty mailboxes, unless -ListEmpty is specified.
  if (!$ListEmpty -and ($euser.TotalItems -eq 0))
  {
    continue
  }
  
  # Do not list system mailboxes, unless -ListSystem is specified.
  if (!$ListSystem -and ($euser.MailboxDisplayName -like "SystemMailbox*"))
  {
    continue
  }

  # Grab the AD object where the DistinguishedName matches between AD and Exchange.
  $aduser = $adusers | Where-Object {$_.DS_legacyExchangeDN -eq $euser.LegacyDN}

  # Do not list users with no email address, unless -ListNoEmail is specified.
  if (!$ListNoMail -and !($aduser.DS_mail))
  {
    continue
  }

  # Grab and format the Exchange object values.
  $object | Add-Member -Type NoteProperty -Name Name -Value $euser.MailboxDisplayName
  $object | Add-Member -Type NoteProperty -Name MailboxSizeinMB -Value ([math]::Round(($euser.size / 1MB *1KB),2))
  $object | Add-Member -Type NoteProperty -Name TotalItems -Value $euser.TotalItems

  # Grab and format the AD object values.
  if ($aduser)
  {
    $object | Add-Member -Type NoteProperty -Name Mail -Value $aduser.DS_Mail
    $object | Add-Member -Type NoteProperty -Name ProxyAddresses -Value ([string]($aduser.DS_proxyAddresses))
    $object | Add-Member -Type NoteProperty -Name Disabled -Value ([bool](([string]::Format("{0:x}", $aduser.DS_userAccountControl)).EndsWith("2")))

    # Again, make the accountexpires date look nice for export.
    $object | Add-Member -Type NoteProperty -Name ExpiryDate -Value (Get-ADDate $aduser.DS_accountExpires)

    # Make the lastlogon date look nice for the export. 
    $object | Add-Member -Type NoteProperty -Name LastLogon -Value (Get-ADDate $aduser.DS_LastLogonTimestamp)

    # Same for extensionattribute1, which we use for the users HR number.
    if ($aduser.DS_extensionAttribute1 -ne $null)
    {
      $object | Add-Member -Type NoteProperty -Name HRNo -Value ($aduser.DS_extensionAttribute1.ToString().PadLeft(5,'0'))
    }
  }

  Write-Output $object
  $processed++
}