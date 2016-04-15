#Requires -Module Timezone

Describe 'Get-Timezone' {
    Context 'UTC' {
        It 'Returns a UTC Timezone object' {
            (Get-Timezone).TimeZone | Should Be 'GMT Standard Time'
            (Get-Timezone).UTCOffset | Should Be '+00:00'
            (Get-Timezone).ExampleLocation | Should Be '(UTC) Dublin, Edinburgh, Lisbon, London'
        }
    }
    Context 'Singapore' {
        It 'Returns a Singapore (UTC+08:00) Timezone object' {
            (Get-Timezone -Timezone 'Singapore Standard Time').Timezone | Should Be 'Singapore Standard Time'
            (Get-Timezone -Timezone 'Singapore Standard Time').UTCOffset | Should Be '+08:00'
            (Get-Timezone -Timezone 'Singapore Standard Time').ExampleLocation | Should Be '(UTC+08:00) Kuala Lumpur, Singapore'
        }
    }
}

Describe 'Get-TimezoneFromOffset' {
    Context 'UTC' {
        It 'Returns the UTC timezone offset' {
            (Get-TimezoneFromOffset -UTCOffset '+00:00').Offset | Should Be '+00:00'
        }

        It 'Returns the UTC timezone' {
            (Get-TimezoneFromOffset -UTCOffset '+00:00').Timezone | Select -First 1 | Should Not Be $null
            (Get-TimezoneFromOffset -UTCOffset '+00:00').Offset | Select -First 1 | Should Be '+00:00'
            (Get-TimezoneFromOffset -UTCOffset '+00:00').ExampleLocation | Select -First 1 | Should Not Be $null
        }
    }

    Context 'Arabian Timezone' {
        It 'Returns the Arabian timezone offset' {
            (Get-TimezoneFromOffset -UTCOffset '+04:00').Offset | Should Be '+04:00'
        }

        It 'Return the Arabian timezone' {
            (Get-TimezoneFromOffset -UTCOffset '+04:00').Timezone | Select -First 1 | Should Not Be $null
            (Get-TimezoneFromOffset -UTCOffset '+04:00').Offset  | Select -First 1 | Should Be '+04:00'
            (Get-TimezoneFromOffset -UTCOffset '+04:00').ExampleLocation | Select -First 1 | Should Not Be $null
        }
    }
}

Describe 'Set-Timezone-UTC' {
    It 'Sets the timezone to UTC' {
        Set-Timezone -Timezone "UTC" -WhatIf | Should Be $null
    }
}
