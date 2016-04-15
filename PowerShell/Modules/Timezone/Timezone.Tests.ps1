#Requires -Module Timezone

Describe 'Get-Timezone' {
    Context 'UTC' {
        It 'Returns a UTC Timezone object' {
            (Get-Timezone).TimeZone | Should Not Be $null
            (Get-Timezone).UTCOffset | Should Be '+00:00'
            (Get-Timezone).ExampleLocation | Should Not Be $null
        }
    }
    
    Context 'Singapore' {
        It 'Returns a Singapore (UTC+08:00) Timezone object' {
            (Get-Timezone -Timezone 'Singapore Standard Time').Timezone | Should Not Be $null
            (Get-Timezone -Timezone 'Singapore Standard Time').UTCOffset | Should Be '+08:00'
            (Get-Timezone -Timezone 'Singapore Standard Time').ExampleLocation | Should Not Be $null
        }
    }
    
    Context 'Central America' {
        It 'Returns a Central America (UTC-06:00) Timezone object' {
            (Get-Timezone -Timezone 'Central America Standard Time').Timezone | Should Not Be $null
            (Get-Timezone -Timezone 'Central America Standard Time').UTCOffset | Should Be '-06:00'
            (Get-Timezone -Timezone 'Central America Standard Time').ExampleLocation | Should Not Be $null
        }
    }
}

Describe 'Get-TimezoneFromOffset' {
    Context 'UTC' {
        It 'Returns the UTC timezone offset' {
            (Get-TimezoneFromOffset -UTCOffset '+00:00').Timezone | Select -First 1 | Should Not Be $null
            (Get-TimezoneFromOffset -UTCOffset '+00:00').Offset | Select -First 1 | Should Be '+00:00'
            (Get-TimezoneFromOffset -UTCOffset '+00:00').ExampleLocation | Select -First 1 | Should Not Be $null
        }
    }

    Context 'Arabian Timezone' {
        It 'Returns the Arabian timezone offset' {
            (Get-TimezoneFromOffset -UTCOffset '+04:00').Timezone | Select -First 1 | Should Not Be $null
            (Get-TimezoneFromOffset -UTCOffset '+04:00').Offset  | Select -First 1 | Should Be '+04:00'
            (Get-TimezoneFromOffset -UTCOffset '+04:00').ExampleLocation | Select -First 1 | Should Not Be $null
        }
    }

    Context 'Venezuela Timezone' {
        It 'Returns the Venezuela timezone offset' {
            (Get-TimezoneFromOffset -UTCOffset '-04:30').Timezone | Select -First 1 | Should Not Be $null
            (Get-TimezoneFromOffset -UTCOffset '-04:30').Offset  | Select -First 1 | Should Be '-04:30'
            (Get-TimezoneFromOffset -UTCOffset '-04:30').ExampleLocation | Select -First 1 | Should Not Be $null
        }
    }

    Context 'Samoa Standard Time' {
        It 'Returns the Samoa timezone offset' {
            (Get-TimezoneFromOffset -UTCOffset '+13:00').Timezone | Select -First 1 | Should Not Be $null
            (Get-TimezoneFromOffset -UTCOffset '+13:00').Offset  | Select -First 1 | Should Be '+13:00'
            (Get-TimezoneFromOffset -UTCOffset '+13:00').ExampleLocation | Select -First 1 | Should Not Be $null
        }
    }
}

Describe 'Set-Timezone-UTC' {
    It 'Sets the timezone to UTC' {
        Set-Timezone -Timezone "UTC" -WhatIf | Should Be $null
    }
}
