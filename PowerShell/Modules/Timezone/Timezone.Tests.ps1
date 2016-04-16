Import-Module "$PSScriptRoot\Timezone.psm1"

Describe 'Get-Timezone' {
    Context 'UTC' {
        It 'Returns the current Timezone object' {
            $timezone = Get-Timezone
            $timezone.Timezone | Should Not Be $null
            $timezone.UTCOffset | Should Not Be $null
            $timezone.ExampleLocation | Should Not Be $null
        }
    }
    
    Context 'Ahead of GMT timezone' {
        It 'Returns a Singapore (UTC+08:00) Timezone object' {
            $timezone = (Get-Timezone -Timezone 'Singapore Standard Time')
            $timezone.Timezone | Should Be 'Singapore Standard Time'
            $timezone.UTCOffset | Should Be '+08:00'
            $timezone.ExampleLocation | Should Be '(UTC+08:00) Kuala Lumpur, Singapore'
        }
    }
    
    Context 'Behind GMT timezone' {
        It 'Returns a Central America (UTC-06:00) Timezone object' {
            $timezone = (Get-Timezone -Timezone 'Central America Standard Time')
            $timezone.Timezone | Should Be 'Central America Standard Time'
            $timezone.UTCOffset | Should Be '-06:00'
            $timezone.ExampleLocation | Should Be '(UTC-06:00) Central America'
        }
    }
}

Describe 'Get-TimezoneFromOffset' {
    Context 'Current' {
        It 'Returns the current timezone offset' {
            $currentTz = Get-Timezone
            $timezone = Get-TimezoneFromOffset
            $timezone.Timezone -contains $currentTz.Timezone | Should Be $true
            $timezone.UTCOffset -eq $currentTz.UTCOffset | Should Be $true
            $timezone.ExampleLocation -contains $currentTz.ExampleLocation | Should Be $true
        }
    }

    Context 'All' {
        foreach ($timezone in Get-Timezone -All) {
            $tzo = Get-TimezoneFromOffset -UTCOffset $timezone.UTCOffset
            $tzo.Timezone -contains $timezone.Timezone | Should Be $true
            $tzo.UTCOffset -eq $timezone.UTCOffset | Should Be $true
            $tzo.ExampleLocation -contains $timezone.ExampleLocation | Should Be $true
        }
    }
}

Describe 'Set-Timezone-UTC' {
    It 'Sets the timezone to UTC' {
        Set-Timezone -Timezone "UTC" -WhatIf | Should Be $null
    }
}
