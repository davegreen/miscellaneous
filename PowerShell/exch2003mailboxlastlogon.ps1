# Modified by Dave Green (david.green@tookitaway.co.uk) from a script by Gary Siepser, Microsoft Premier Field Engineer.
# (http://blogs.technet.com/b/gary/archive/2009/09/16/list-mailbox-sizes-for-both-exchange-2003-and-exchange-2007.aspx)

#Grab the exchange server and output file name from args.
[cmdletbinding()]
param(
  [parameter(Mandatory=$true, Position=1)][string]$ExchServerName,
  [parameter(Mandatory=$true, Position=2)][string]$ADServerName,
  [parameter(Mandatory=$false, Position=3)][string]$OutputFile
)

# Get the WMI objects from both Exchange and AD
# Write progress to the console, to keep the user updated.
Write-Verbose "Getting data from WMI on $ExchServerName (root\MicrosoftExchangeV2\Exchange_mailbox)"
Write-Progress -Activity "Preparing Run" -Status "Getting data from WMI on $ExchServerName (root\MicrosoftExchangeV2\Exchange_mailbox)" -PercentComplete 0
$exchusers = Get-WmiObject -ComputerName $ExchServerName -Namespace root\MicrosoftExchangeV2 -Class Exchange_mailbox | Select-Object LegacyDN, MailboxDisplayName, Size, TotalItems
Write-Verbose "Got Exchange WMI data."
Write-Progress -Activity "Preparing Run" -Status "Getting data from WMI on $ADServerName (root\directory\ldap\ds_user)" -PercentComplete 50
Write-Verbose "Getting data from WMI on $ADServerName (root\directory\ldap\ds_user)"
$adusers = Get-WmiObject -ComputerName $ADServerName -Namespace root\directory\ldap -Class ds_user | Select-Object DS_legacyExchangeDN, DS_proxyAddresses, DS_mail, DS_userAccountControl, DS_extensionAttribute1, DS_CN, DS_LastLogon, DS_accountExpires
Write-Progress -Activity "Preparing Run" -Status "Got WMI Data." -PercentComplete 100
Write-Verbose "Got AD WMI data."
$results = @()

# Create the template object and give it the properties we need to set.
$templateobject = New-Object PSObject
$templateobject = $templateobject | Select-Object Name, CN, HRNo, Disabled, MailboxSizeinMB, Mail, ProxyAddresses, TotalItems, LastLogon, ExpiryDate

foreach ($euser in $exchusers)
{
  # Display the next sectin of the progress, for formatting and matching the data.
  Write-Progress -Activity "Formatting and matching data" -Status ("User: " + $euser.MailboxDisplayName) -PercentComplete ($results.Count / $exchusers.Count * 100)
  $lastlogondate = @()
  
  # Set the template object to the temporary object we wish to populate.
  $object = $templateobject | Select-Object *

  # Grab the first AD object where the DistinguishedName matches between AD and Exchange.
  $aduser = $adusers | Where-Object {$_.DS_legacyExchangeDN -eq $euser.LegacyDN}

  # Make the lastlogon date look nice for the export. 
  if (($aduser.DS_LastLogon -ne $null) -and ($aduser.DS_LastLogon -ne "0"))
  {
    [datetime]$lastlogondate = $aduser.DS_LastLogon
    [string]$lastlogondate = $lastlogondate.AddYears(1600).Date.ToString()
  }

  else
  {
    [string]$lastlogondate = "Never"
  }

  $object.LastLogon = $lastlogondate

  # Same for extensionattribute1, which we use for the users HR number.
  if ($aduser.DS_extensionAttribute1 -ne $null)
  {
    $object.HRNo = $aduser.DS_extensionAttribute1.ToString().PadLeft(5,'0')
  }

  # Again, make the accountexpires date look nice for export.
  if (($aduser.DS_accountExpires -ne $null) -and ($aduser.DS_accountExpires -ne "0") -and ($aduser.DS_accountExpires -ne "9223372036854775807"))
  {
    [datetime]$accountexpiry = $aduser.DS_accountExpires
    [string]$object.ExpiryDate = $accountexpiry.AddYears(1600).Date.ToString()
  }
   
  else
  {
    [string]$object.ExpiryDate = "Never"
  }

  # Set the rest of the object values.
  $object.Name = $euser.MailboxDisplayName
  $object.MailboxSizeinMB = ([math]::Round(($euser.size / 1MB *1KB),2))
  $object.Disabled = [bool](([string]::Format("{0:x}", $aduser.DS_userAccountControl)).EndsWith("2"))
  $object.Mail = $aduser.DS_Mail
  $object.ProxyAddresses = [string]$aduser.DS_proxyAddresses
  $object.TotalItems = $euser.TotalItems
  $object.CN = $aduser.DS_CN
  
  # Display the created object before adding it to the final result set.
  Write-Verbose $object
  $results += $object
}

# Allow output to CSV, or to the pipeline.
if ($OutputFile)
{
  $results | Export-Csv $OutputFile -NoTypeInformation -NoClobber
}

else
{
  Write-Output $results
}