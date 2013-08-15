<# 
  .Synopsis
  Parses the contents of a PFDAVAdmin export

  .Description
  This function parses and outputs the contents of a PFDAVAdmin export.
    
  .Parameter PFDAVAdminFile
  The location of the PFDAVAdmin file to parse.

  .Parameter MaxColumns
  Optional. The maximum amount of columns to parse from the PFDAVAdmin file. Defaults to 40 columns.

  .Example
  .\PFDAVAdminExport.ps1 -PFDAVAdminFile .\pfdavadmin.txt | Export-Csv "output.csv" -NoTypeInformation
  Parse the file 'pfdavadmin.txt' and export it to output.csv

  .Example
  .\PFDAVAdminExport.ps1 -PFDAVAdminFile .\pfdavadmin.txt -MaxColumns 50
  Parse the file 'pfdavadmin.txt' with a 50 column max width.
        
  .Notes
  Name  : PFDAVAdminExport
  Author: David Green
  
  .Link
  http://www.tookitaway.co.uk
#>

[cmdletbinding()]
param(
  [parameter(Mandatory=$true, HelpMessage="The location of the PFDAVAdmin export (Tab delimited text file).")]
    [string]$PFDAVAdminFile,
  [parameter()][int]$MaxColumns = 40
)

Write-Progress -Activity "Loading PFDAVAdmin file and preparing run." -Status ("Loading " + $PFDAVAdminFile) -PercentComplete 0
$a = 1..$MaxColumns
$processed = 0
$PFDAVExport = Import-Csv $PFDAVAdminFile -Delimiter "`t" -Header $a
Write-Progress -Activity "Loading PFDAVAdmin file and preparing run." -Status "Preparing Run" -PercentComplete 99

# Process the raw PFDAVAdmin Export
foreach ($row in $PFDAVExport)
{
  if ($processed -gt 6)
  {
    # Get the mailbox name
    $name = ($row.2).Replace("\Top of Information Store", "")
    Write-Progress -Activity "Parsing data" -Status $name -PercentComplete ($processed / $PFDAVExport.Count * 100)

    foreach ($col in $a)
    {
      # Skip the SETACL and Mailbox name columns and get the permission data.
      if (($col -ne 1) -and ($col -ne 2) -and ($row.$col))
      {
        # Ignore Anonymous, UNKNOWN and NO fields, then grab the user and permission set..
        if (($col % 2 -eq 1) -and ($row.$col -ne "Anonymous") -and ($row.$col -ne "NO") -and ($row.$col -ne "UNKNOWN"))
        {
          $user = (($row.$col).Split("=") | Select-Object -Last 1).Trim()
          
          # Don't include the users permission over their own mailbox.
          if (!($name.Contains($user)) -and (($row.($col + 1)) -ne "None"))
          {
            $htable = @{
              "Name" = $name
              "User" = $user
              "Permissions" = ($row.($col + 1))
            }

            $object = New-Object PSObject -Property $htable
            Write-Output $object
          }
        }
      }
    }
  }

  $processed++
}