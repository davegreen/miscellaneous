Function Get-TimezoneFromOffset {
    <#
      .Synopsis
      A function that gets the timezones that match a particular offset from UTC

      .Parameter UTCOffset
      A string containing offset time you require. This must match the form +NN:NN, NN:NN or -NN:NN.

      .Example
      Get-TimezoneFromOffset
      
      Get timezones that match the offset of the current timezone.

      .Example
      Get-TimezoneFromOffset -UTCOffset '+08:00'
      
      Get timezones that match the offset of UTC+08:00 (China, North Asia, Singapore, etc.

      .Notes
      Author: David Green (http://tookitaway.co.uk/)
    #>

    [CmdletBinding()]

    Param(
        [parameter(
            Position=1,
            ValueFromPipelineByPropertyName=$True,
            ValueFromPipeline=$True,
            HelpMessage='Specify the timezone offset.'
        )]
        [ValidateScript({
            $_ -match '^[+-]?[0-9]{2}:[0-9]{2}$'
        })]
        [string]$UTCOffset = (Get-Timezone).UTCOffset
    )

    $tz = (tzutil /l)

    $timezones = foreach ($t in $tz) {
        if (($tz.IndexOf($t) -1) % 3 -eq 0) {
            $tzProperties = @{
                Timezone = $t.Trim()
                UTCOffset = $UTCOffset
                ExampleLocation = ($tz[$tz.IndexOf($t) - 1]).Trim()
            }
            
            $TimezoneObj = New-Object -TypeName PSObject -Property $tzProperties
            Write-Output $TimezoneObj
        }
    }

    switch ($UTCOffset) {
        { $_ -match '^[0-1]' } {
            $Offset = ('(UTC+' + $UTCOffset)
            $UTCOffset = '+' + $UTCOffset
            
        }
    
        { $_ -match '^[+-]?00:00' } {
            $Offset = '(UTC)'
            $UTCOffset = '+00:00'
            break
        }

        { $_ -match '^-' } {
            $Offset = '(UTC' + $UTCOffset
        }

        default {
            $Offset = $UTCOffset
        }
    }
    
    $matchedtz = $timezones | Where-Object ExampleLocation -match "$([regex]::Escape($Offset))"

    foreach ($tz in $matchedtz) {
        $TimezoneProperties = @{
            Timezone = $tz.Timezone
            UTCOffset = $UTCOffset
            ExampleLocation = $tz.ExampleLocation
        }

        $TimezoneObj = New-Object -TypeName PSObject -Property $TimezoneProperties
        Write-Output $TimezoneObj
    }
}

Function Get-Timezone {
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
      Author: David Green (http://tookitaway.co.uk/)
    #>

    [CmdletBinding(
        DefaultParametersetName='Specific'
    )]
    
    Param(
        [parameter(
            Position=1,
            ParameterSetName='Specific',
            ValueFromPipelineByPropertyName=$True,
            ValueFromPipeline=$True,
            HelpMessage='Specify the timezone to set (from "tzutil /l").'
        )]
        [ValidateScript( {
            $tz = (tzutil /l)
            $validoptions = foreach ($t in $tz) { 
                if (($tz.IndexOf($t) -1) % 3 -eq 0) {
                    $t.Trim()
                }
            }

            $validoptions -contains $_
        })]
        [string]$Timezone = (tzutil /g),
        
        [parameter(
            Position=2,
            ParameterSetName='All',
            HelpMessage='Show all timezones.')]
        [switch]$All
    )

    Begin {
        $timezones = tzutil /l
    }

    Process {
        if ($All) {
            foreach ($t in $timezones) { 
                if (($timezones.IndexOf($t) -1) % 3 -eq 0) {
                    $TimezoneProperties = @{
                        Timezone = $t
                        UTCOffset = $null
                        ExampleLocation = ($timezones[$timezones.IndexOf($t) - 1]).Trim()
                    }

                    if (($timezones[$timezones.IndexOf($t) - 1]).StartsWith('(UTC)')) {
                        $TimezoneProperties.UTCOffset = '+00:00'
                    }

                    elseif (($timezones[$timezones.IndexOf($t) - 1]).Length -gt 10) {
                        $TimezoneProperties.UTCOffset = ($timezones[$timezones.IndexOf($t) - 1]).SubString(4, 6)
                    }

                    $TimezoneObj = New-Object -TypeName PSObject -Property $TimezoneProperties
                    Write-Output $TimezoneObj
                }
            }
        }

        else {
            foreach ($t in $timezones) { 
                if ($t -match ('^' + [regex]::Escape($Timezone) + '$')) {
                    $TimezoneProperties = @{
                        Timezone = $t
                        UTCOffset = $null
                        ExampleLocation = ($timezones[$timezones.IndexOf($t) - 1]).Trim()
                    }

                    if (($timezones[$timezones.IndexOf($t) - 1]).StartsWith('(UTC)')) {
                        $TimezoneProperties.UTCOffset = '+00:00'
                    }

                    elseif (($timezones[$timezones.IndexOf($t) - 1]).Length -gt 10) {
                        $TimezoneProperties.UTCOffset = ($timezones[$timezones.IndexOf($t) - 1]).SubString(4, 6)
                    }

                    $TimezoneObj = New-Object -TypeName PSObject -Property $TimezoneProperties
                    Write-Output $TimezoneObj
                }
            }
        }
    }
}

Function Set-Timezone {
    <#
      .Synopsis
      A function that sets the computer timezone.

      .Parameter Timezone
      A string containing the display name of the timezone you require. Only valid timezones (from 'tzutil /l') are supported.

      .Example
      Set-Timezone -Timezone 'Singapore Standard Time'
      
      Set the timezone to Singapore standard time (UTC+08:00).

      .Notes
      Author: David Green (http://tookitaway.co.uk/)
    #>

    [CmdletBinding(
        SupportsShouldProcess=$True
    )]

    Param(
        [parameter(
            Mandatory=$True,
            Position=1,
            ValueFromPipelineByPropertyName=$True,
            ValueFromPipeline=$True,
            HelpMessage='Specify the timezone to set (from "Get-Timezone -All").'
        )]
        [ValidateScript({ 
            if (Get-Timezone -Timezone $_) {
                $True
            }
        })]
        [string]$Timezone
    )
    
    if ($PSCmdlet.ShouldProcess($Timezone))
    {
        Write-Verbose "Setting Timezone to $Timezone"
        tzutil.exe /s $Timezone
    }
}

Register-ArgumentCompleter -CommandName Get-Timezone, Set-Timezone -ParameterName Timezone -ScriptBlock {
    <#
      This is the argument completer to return available timezone parameters for use with getting and setting the timezone.

      Provided parameters:
        Parameter commandName
            The command calling this arguement completer.
        Parameter parameterName
            The parameter currently active for the argument completer.
        Parameter currentContent
            The current data in the prompt for the parameter specified above.
        Parameter commandAst
            The full AST for the current command.
        Parameter  fakeBoundParameters
            A hashtable of the current parameters on the prompt.
    #>

    Param(
        $commandName,
        $parameterName,
        $currentContent,
        $commandAst,
        $fakeBoundParameters
    )

    $tz = (tzutil /l)
    $validoptions = foreach ($t in $tz) { 
        if (($tz.IndexOf($t) -1) % 3 -eq 0) {
            $t.Trim()
        }
    }
    
    $validoptions | Where-Object { $_ -like "$($currentContent)*" } | ForEach-Object {
        $CompletionText = $_
        if ($_ -match '\s') { 
            $CompletionText = "'$_'" 
        }
        
        New-Object System.Management.Automation.CompletionResult (
            $CompletionText,  #Completion text that will show up on the command line.
            $_,               #List item text that will show up in intellisense.
            'ParameterValue', #The type of the completion result.
            "$_ (Timezone)"   #The tooltip info that will show up additionally in intellisense.
        )
    }
}
