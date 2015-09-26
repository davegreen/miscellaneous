Function Get-TimezoneFromOffset()
{
    <#
      .Synopsis
      A function that gets the timezones that match a particular offset from UTC

      .Parameter UTCOffset
      A string containing offset time you require. This must match the form +NN:NN or -NN:NN.

      .Example
      Get-TimezoneFromOffset -UTCOffset '+08:00'
      
      Get timezones that match the offset of UTC+08:00 (China, North Asia, Singapore, etc.

      .Notes
      Author: David Green
    #>
    [CmdletBinding()]
    param([parameter(Position=1,ValueFromPipelineByPropertyName=$True,ValueFromPipeline=$True,HelpMessage='Specify the timezone offset.')]
          [ValidateScript({$_ -match '([\+\-])?[0-1][0-9]:[0,1,3,4][0,5]'})][string]$UTCOffset = '+00:00'
    )

    $tz = (tzutil /l)
    $timezones = @()
    
    if (!($UTCOffset.StartsWith('+') -or $UTCOffset.StartsWith('-')))
    {
        $UTCOffset = '+' + $UTCOffset
    }

    foreach ($t in $tz)
    {
        if (($tz.IndexOf($t) -1) % 3 -eq 0)
        {
            $ValidUTCOffset = ((($tz[$tz.IndexOf($t) - 1]).Trim() | 
            Select-String -Pattern "UTC[+-][0-1][0-9]:[0,1,3,4][0,5]|UTC" | 
            Select-Object -First 1 -ExpandProperty Matches).Value).SubString(3)
            
            if (!$ValidUTCOffset)
            {
                $ValidUTCOffset = '+00:00'
            }

            if ($UTCOffset -eq $ValidUTCOffset)
            {
                $timezone = New-Object -TypeName PSObject
                $timezone | Add-Member -MemberType NoteProperty -Name Timezone -Value $t.Trim()
                $timezone | Add-Member -MemberType NoteProperty -Name UTCOffset -Value $ValidUTCOffset
                $timezone | Add-Member –MemberType NoteProperty –Name ExampleLocation –Value ($tz[$tz.IndexOf($t) - 1]).Trim()
                $timezone
                break
            }
        }
    }
}

Function Get-Timezone()
{
    <#
      .Synopsis
      A function that retrieves valid computer timezones.

      .Example
      Get-Timezone
      
      Gets the current computer timezone

      .Example
      Get-Timezone -Timezone 'Singapore Standard Time'
      
      Get the timezone for Singapore standard time (UTC+08:00).

      .Example
      Get-Timezone -All
      
      Returns all valid computer timezones.

      .Notes
      Author: David Green
    #>

    [CmdletBinding(DefaultParametersetName='Specific')]
    Param([parameter(Position=1,ParameterSetName='Specific',ValueFromPipelineByPropertyName=$True,ValueFromPipeline=$True,HelpMessage='Specify the timezone to set (from "tzutil /l").')]
          [ValidateScript(
          {
              $tz = (tzutil /l)
              $validoptions = foreach ($t in $tz)
              { 
                  if (($tz.IndexOf($t) -1) % 3 -eq 0)
                  {
                      $t.Trim()
                  }
              }

              $validoptions -contains $_
          })][string]$Timezone = (tzutil /g),
          [parameter(Position=2,ParameterSetName='All',HelpMessage='Show all timezones.')][switch]$All
    )

    Begin
    {
        $timezones = tzutil /l
    }

    Process
    {
        if ($All)
        {
            foreach ($t in $timezones)
            { 
                if (($timezones.IndexOf($t) -1) % 3 -eq 0)
                {
                    $race = New-Object –TypeName PSObject
                    $race | Add-Member –MemberType NoteProperty –Name Timezone –Value $t

                    if (($timezones[$timezones.IndexOf($t) - 1]).StartsWith('(UTC)'))
                    {
                        $race | Add-Member –MemberType NoteProperty –Name UTCOffset –Value '+00:00'
                    }

                    elseif (($timezones[$timezones.IndexOf($t) - 1]).Length -gt 10)
                    {
                        $race | Add-Member –MemberType NoteProperty -Name UTCOffset –Value ($timezones[$timezones.IndexOf($t) - 1]).SubString(4, 6)
                    }

                    $race | Add-Member –MemberType NoteProperty –Name ExampleLocation –Value ($timezones[$timezones.IndexOf($t) - 1]).Trim()
                    $race
                }
            } 
        }

        else
        {
            foreach ($t in $timezones)
            { 
                if ($t -match "^$Timezone$")
                {
                    $race = New-Object –TypeName PSObject
                    $race | Add-Member –MemberType NoteProperty –Name Timezone –Value $t

                    if (($timezones[$timezones.IndexOf($t) - 1]).StartsWith('(UTC)'))
                    {
                        $race | Add-Member –MemberType NoteProperty –Name UTCOffset –Value '+00:00'
                    }

                    elseif (($timezones[$timezones.IndexOf($t) - 1]).Length -gt 10)
                    {
                        $race | Add-Member –MemberType NoteProperty -Name UTCOffset –Value ($timezones[$timezones.IndexOf($t) - 1]).SubString(4, 6)
                    }

                    $race | Add-Member –MemberType NoteProperty –Name ExampleLocation –Value ($timezones[$timezones.IndexOf($t) - 1]).Trim()
                    $race
                }
            }
        }
    }
}

Function Set-Timezone()
{
    <#
      .Synopsis
      A function that sets the computer timezone.

      .Parameter Timezone
      A string containing the display name of the timezone you require. Only valid timezones (from 'tzutil /l') are supported.

      .Example
      Set-Timezone -Timezone 'Singapore Standard Time'
      
      Set the timezone to Singapore standard time (UTC+08:00).

      .Notes
      Author: David Green
    #>

    [CmdletBinding()]
    param([parameter(Mandatory=$True,Position=1,ValueFromPipelineByPropertyName=$True,HelpMessage='Specify the timezone to set (from "Get-Timezone -All").')]
          [ValidateScript({if (Get-Timezone -Timezone $_){$true}})][string]$Timezone
    )
    
    Write-Verbose "Setting Timezone to $Timezone"
    tzutil.exe /s $Timezone
}