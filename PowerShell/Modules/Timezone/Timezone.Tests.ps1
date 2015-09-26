Import-Module Timezone

Describe 'Get-Timezone-UTC' {
    It 'Returns a UTC Timezone object' {
        (Get-Timezone).TimeZone | Should Be 'GMT Standard Time'
        (Get-Timezone).UTCOffset | Should Be '+00:00'
        (Get-Timezone).ExampleLocation | Should Be '(UTC) Dublin, Edinburgh, Lisbon, London'
    }
}

Describe 'Get-Timezone-Singapore' {
    It 'Returns a Singapore (UTC+08:00) Timezone object' {
        (Get-Timezone -Timezone 'Singapore Standard Time').Timezone | Should Be 'Singapore Standard Time'
        (Get-Timezone -Timezone 'Singapore Standard Time').UTCOffset | Should Be '+08:00'
        (Get-Timezone -Timezone 'Singapore Standard Time').ExampleLocation | Should Be '(UTC+08:00) Kuala Lumpur, Singapore'
    }
}

Describe 'Get-Timezone-Singapore-PipelineInput' {
    It 'Returns a Singapore (UTC+08:00) Timezone object using pipeline input by property name' {
        Get-Timezone -Timezone 'Singapore Standard Time' | Get-Timezone | Select-Object -ExpandProperty Timezone | Should Be 'Singapore Standard Time'
    }
    It 'Returns a Singapore (UTC+08:00) Timezone object using pipeline input' {
        (Get-Timezone -Timezone 'Singapore Standard Time').Timezone | Get-Timezone | Select-Object -ExpandProperty Timezone | Should Be 'Singapore Standard Time'
    }
}

Describe 'Get-TimezoneFromOffset-UTC' {
    It 'Returns the UTC timezone offset' {
        (Get-TimezoneFromOffset -UTCOffset '+00:00').UTCOffset | Should Be '+00:00'
    }

    It 'Implicitly returns the UTC timezone offset' {
        (Get-TimezoneFromOffset -UTCOffset '00:00').UTCOffset | Should Be '+00:00'
    }

    It 'Return the UTC timezone' {
        (Get-TimezoneFromOffset -UTCOffset '+00:00').Timezone | Select -First 1 | Should Be 'Morocco Standard Time'
        (Get-TimezoneFromOffset -UTCOffset '+00:00').UTCOffset | Select -First 1 | Should Be '+00:00'
        (Get-TimezoneFromOffset -UTCOffset '+00:00').ExampleLocation | Select -First 1 | Should Be '(UTC) Casablanca'
    }
}

Describe 'Get-TimezoneFromOffset-UTC-PipelineInput' {
    It 'Returns the UTC timezone offset using pipeline input by property name' {
        Get-TimezoneFromOffset -UTCOffset '+00:00' | Get-TimezoneFromOffset | Select-Object -ExpandProperty UTCOffset | Should Be '+00:00'
    }
    It 'Returns the UTC timezone offset using pipeline input' {
        (Get-TimezoneFromOffset -UTCOffset '+00:00').UTCOffset | Get-TimezoneFromOffset | Select-Object -ExpandProperty UTCOffset | Should Be '+00:00'
    }
}

Describe 'Get-TimezoneFromOffset-ArabianTz' {
    It 'Returns the Arabian timezone offset' {
        (Get-TimezoneFromOffset -UTCOffset '+04:00').UTCOffset | Should Be '+04:00'
    }

    It 'Implicitly returns the Arabian timezone offset' {
        (Get-TimezoneFromOffset -UTCOffset '04:00').UTCOffset | Should Be '+04:00'
    }

    It 'Return the Arabian timezone' {
        (Get-TimezoneFromOffset -UTCOffset '+04:00').Timezone | Select -First 1 | Should Be 'Arabian Standard Time'
        (Get-TimezoneFromOffset -UTCOffset '+04:00').UTCOffset | Select -First 1 | Should Be '+04:00'
        (Get-TimezoneFromOffset -UTCOffset '+04:00').ExampleLocation | Select -First 1 | Should Be '(UTC+04:00) Abu Dhabi, Muscat'
    }
}

Describe 'Get-TimezoneFromOffset-ArabianTz-PipelineInput' {
    It 'Returns the Arabian timezone offset using pipeline input by property name' {
        Get-TimezoneFromOffset -UTCOffset '+04:00' | Get-TimezoneFromOffset | Select-Object -ExpandProperty UTCOffset | Should Be '+04:00'
    }
    It 'Returns the Arabian timezone offset using pipeline input' {
        (Get-TimezoneFromOffset -UTCOffset '+04:00').UTCOffset | Get-TimezoneFromOffset | Select-Object -ExpandProperty UTCOffset | Should Be '+04:00'
    }
}

Describe 'Set-Timezone-UTC' {
    It 'Sets the timezone to UTC' {
        $current = Get-Timezone
        Set-Timezone -Timezone "UTC" | Should Be $null
        $current | Set-Timezone
    }
}