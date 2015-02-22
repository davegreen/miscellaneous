[CmdletBinding()]
Param
(
	[Parameter(Mandatory=$false,
	ValueFromPipelineByPropertyName=$true,
	ValueFromPipeline=$true)]
	[Alias('FrontEndServerFqdn')]
	[string]$ServerFqdn = "MYSERVER.contoso.com"
)

Function Get-LyncUsers()
{
    Write-Progress -Activity "Getting user information" -Status "Lync"
    $lyncusers = Get-CsUser | select displayname, sipaddress, lineuri, enterprisevoiceenabled, registrarpool, guid
    Write-Progress -Activity "Getting user information" -Status "Active Directory"
    $adusers = Get-ADUser -LDAPFilter "(&(proxyAddresses=sip:*))" -Properties officephone, mobilephone, ipphone | select name, officephone, mobilephone, ipphone, objectguid
    $users = @()

    foreach ($l in $lyncusers)
    {
        Write-Progress -Activity "Compiling table of user information" -Status ("Processing (" + (($users | measure).count + 1) + " of " + ($lyncusers | measure).count + ")") -PercentComplete (($users | measure).count / ($lyncusers | measure).count * 100 )
        if ($a = $adusers | where {$_.objectguid -eq $l.guid})
        {
            $obj = new-object PSObject
            $obj | Add-Member NoteProperty -Name "Name" -Value $a.name
            $obj | Add-Member NoteProperty -Name "SIP Address" -Value $l.sipaddress
            $obj | Add-Member NoteProperty -Name "Line URI" -Value $l.lineuri
            $obj | Add-Member NoteProperty -Name "Office Phone" -Value $a.officephone
            $obj | Add-Member NoteProperty -Name "IP Phone" -Value $a.ipphone
            $obj | Add-Member NoteProperty -Name "Mobile Phone" -Value $a.mobilephone
            $obj | Add-Member NoteProperty -Name "Enterprise Voice" -Value $l.enterprisevoiceenabled
            $obj | Add-Member NoteProperty -Name "Pool" -Value $l.registrarpool
            $obj | Add-Member NoteProperty -Name "Object GUID" -Value $a.objectguid

            $users += $obj
        }
    }

    Write-Output $users
}

Function Get-LyncUsers-AD()
{
    Write-Progress -Activity "Getting user information" -Status "Active Directory"
    $adusers = Get-ADUser -LDAPFilter "(&(proxyAddresses=sip:*))" -Properties msRTCSIP-Line, msRTCSIP-PrimaryUserAddress, msRTCSIP-UserEnabled, officephone, mobilephone, ipphone | select name, officephone, mobilephone, ipphone, msRTCSIP-Line, msRTCSIP-PrimaryUserAddress, msRTCSIP-UserEnabled, objectguid
    $users = @()

    foreach ($a in $adusers)
    {
        Write-Progress -Activity "Compiling table of user information" -Status ("Processing (" + (($users | measure).count + 1) + " of " + ($adusers | measure).count + ")") -PercentComplete (($users | measure).count / ($adusers | measure).count * 100 )
        if ($a.'msRTCSIP-UserEnabled' -eq $true)
        {
            $obj = new-object PSObject
            $obj | Add-Member NoteProperty -Name "Name" -Value $a.name
            $obj | Add-Member NoteProperty -Name "SIP Address" -Value $a.'msRTCSIP-PrimaryUserAddress'
            $obj | Add-Member NoteProperty -Name "Line URI" -Value $a.'msRTCSIP-Line'
            $obj | Add-Member NoteProperty -Name "Office Phone" -Value $a.officephone
            $obj | Add-Member NoteProperty -Name "IP Phone" -Value $a.ipphone
            $obj | Add-Member NoteProperty -Name "Mobile Phone" -Value $a.mobilephone
            $obj | Add-Member NoteProperty -Name "Object GUID" -Value $a.objectguid

            $users += $obj
        }
    }

    Write-Output $users
}

Function Edit-LyncUser()
{
    [CmdletBinding()]
    Param
    (
	    [Parameter(	ValueFromPipelineByPropertyName=$true,
	    ValueFromPipeline=$true)]$obj
    )

    Process
    {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    
        $Form = New-Object System.Windows.Forms.Form
        $Form.Size = New-Object System.Drawing.Size(335,220)
        $Form.StartPosition = "CenterScreen"
        $Form.Text = "Edit Details"
        $Form.Name = "EditDetails"
        $Form.TopMost = $true

        $LBDisplayName = New-Object System.Windows.Forms.Label
        $LBDisplayName.Location = New-Object System.Drawing.Size(15,20)
        $LBDisplayName.Size = New-Object System.Drawing.Size(85,15)
        $LBDisplayName.Text = "Name:"

        $TBDisplayName = New-Object System.Windows.Forms.TextBox
        $TBDisplayName.Location = New-Object System.Drawing.Size(100,15)
        $TBDisplayName.Size = New-Object System.Drawing.Size(200,15)
        $TBDisplayName.Text = $obj.Name
        $TBDisplayName.ReadOnly = $True

        $LBSIPAddress = New-Object System.Windows.Forms.Label
        $LBSIPAddress.Location = New-Object System.Drawing.Size(15,40)
        $LBSIPAddress.Size = New-Object System.Drawing.Size(85,15)
        $LBSIPAddress.Text = "SIP Address:"

        $TBSIPAddress = New-Object System.Windows.Forms.TextBox
        $TBSIPAddress.Location = New-Object System.Drawing.Size(100,35)
        $TBSIPAddress.Size = New-Object System.Drawing.Size(200,15)
        $TBSIPAddress.Text = $obj."SIP Address"
        $TBSIPAddress.ReadOnly = $True

        $LBLineURI = New-Object System.Windows.Forms.Label
        $LBLineURI.Location = New-Object System.Drawing.Size(15,60)
        $LBLineURI.Size = New-Object System.Drawing.Size(85,15)
        $LBLineURI.Text = "Line URI:"

        $TBLineURI = New-Object System.Windows.Forms.TextBox
        $TBLineURI.Location = New-Object System.Drawing.Size(100,55)
        $TBLineURI.Size = New-Object System.Drawing.Size(200,15)
        $TBLineURI.Text = $obj."Line URI"

        $LBOfficePhone = New-Object System.Windows.Forms.Label
        $LBOfficePhone.Location = New-Object System.Drawing.Size(15,80)
        $LBOfficePhone.Size = New-Object System.Drawing.Size(85,15)
        $LBOfficePhone.Text = "Office Phone:"

        $TBOfficePhone = New-Object System.Windows.Forms.TextBox
        $TBOfficePhone.Location = New-Object System.Drawing.Size(100,75)
        $TBOfficePhone.Size = New-Object System.Drawing.Size(200,15)
        $TBOfficePhone.Text = $obj."Office Phone"
        $TBOfficePhone.ReadOnly = $true

        $LBIPPhone = New-Object System.Windows.Forms.Label
        $LBIPPhone.Location = New-Object System.Drawing.Size(15,100)
        $LBIPPhone.Size = New-Object System.Drawing.Size(85,15)
        $LBIPPhone.Text = "IP Phone:"

        $TBIPPhone = New-Object System.Windows.Forms.TextBox
        $TBIPPhone.Location = New-Object System.Drawing.Size(100,95)
        $TBIPPhone.Size = New-Object System.Drawing.Size(200,15)
        $TBIPPhone.Text = $obj."IP Phone"
        $TBIPPhone.ReadOnly = $true

        $LBMobile = New-Object System.Windows.Forms.Label
        $LBMobile.Location = New-Object System.Drawing.Size(15,120)
        $LBMobile.Size = New-Object System.Drawing.Size(85,15)
        $LBMobile.Text = "Mobile Phone:"

        $TBMobile = New-Object System.Windows.Forms.TextBox
        $TBMobile.Location = New-Object System.Drawing.Size(100,115)
        $TBMobile.Size = New-Object System.Drawing.Size(200,15)
        $TBMobile.Text = $obj."Mobile Phone"
 
        $ButtonOK = New-Object System.Windows.Forms.Button
        $ButtonOK.Location = New-Object System.Drawing.Size(15,140)
        $ButtonOK.Size = New-Object System.Drawing.Size(140,25)
        $ButtonOK.Text = "OK"
        $ButtonOK.TabIndex = "2"
        $ButtonOK.Add_Click({Set-LyncUser})

        $ButtonCancel = New-Object System.Windows.Forms.Button
        $ButtonCancel.Location = New-Object System.Drawing.Size(160,140)
        $ButtonCancel.Size = New-Object System.Drawing.Size(140,25)
        $ButtonCancel.Text = "Cancel"
        $ButtonCancel.TabIndex = "3"
        $ButtonCancel.Add_Click({[void]$Form.Close()})

        $Form.KeyPreview = $True
        $Form.Add_KeyDown({if ($_.KeyCode -eq "Enter"){Set-LyncUser $obj}})
        $Form.Add_KeyDown({if ($_.KeyCode -eq "Escape"){[void]$Form.Close()}})

        $Form.Controls.Add($LBDisplayName)
        $Form.Controls.Add($TBDisplayName)
        $Form.Controls.Add($LBSIPAddress)
        $Form.Controls.Add($TBSIPAddress)
        $Form.Controls.Add($LBLineURI)
        $Form.Controls.Add($TBLineURI)
        $Form.Controls.Add($LBOfficePhone)
        $Form.Controls.Add($TBOfficePhone)
        $Form.Controls.Add($LBIPPhone)
        $Form.Controls.Add($TBIPPhone)
        $Form.Controls.Add($LBMobile)
        $Form.Controls.Add($TBMobile)
        $Form.Controls.Add($ButtonOK)
        $Form.Controls.Add($ButtonCancel)
        $Form.Add_Shown({$Form.Activate()})
        $Form.ShowDialog()
    }
}

Function Set-LyncUser()
{
    if ($obj.'Line URI' -ne $TBLineURI.Text)
    {
        if (Check-LyncURI($TBLineURI.Text))
        {
            Set-ADUser -Identity $obj.'Object GUID' -Replace @{'msRTC-Line'=$TBLineURI.Text}

            if ($TBLineURI.Text -match "\+\d{4,12}|\d{4}")
            {
                Set-ADUser -Identity $obj.'Object GUID' -OfficePhone $matches[0]
                Set-ADUser -Identity $obj.'Object GUID' -Replace @{ipPhone=("+" + $matches[1])}
            }
        }

        else
        {
            Write-Error "Invalid Format. Please try again"
            $obj | Edit-LyncUser
        }
    }

    if ($obj.'Mobile Phone' -ne $TBMobile.Text -and (Check-E164 -number $TBMobile.Text -minlength 12 -maxlength 12))
    {
        Set-ADUser -Identity $obj.'Object GUID' -MobilePhone $TBMobile.Text
    }

    else
    {
        $obj | Edit-LyncUser
    }

    [void]$Form.Close()
}

Function Check-E164($number, $minlength = 4, $maxlength = 12)
{
    if ($number -match "^\+\d{$minlength,$maxlength}$")
    {
        return $true
    }

    else
    {
        Write-Error Write-Error "Invalid format. Number must be in E.164 format (+1234, +441234567890)."
        return $false
    }
}

Function Check-LyncURI($uri)
{
    if ($uri -match "^tel\:\+\d{4,12}$|^tel\:\+\d{4,12}\;ext=\d{4}$")
    {
        return $true
    }
        
    else
    {
        Write-Error "Invalid URI format. Number must be in Lync URI format with an optional 4 digit extension (tel:+1234, tel:+441234567890;ext:+1234)."
        return $false
    }
}

Function Start-Session()
{
    $credential = Get-Credential
    $session = New-PSSession -ConnectionUri "https://$ServerFqdn/OcsPowershell" -Credential $credential
    Import-PsSession $session -AllowClobber
}

#Measure-Command 
#{
#    Start-Session
#    Get-LyncUsers
#}

#Measure-Command {Get-LyncUsers-AD}

Get-LyncUsers-AD | Out-GridView -Title "Lync Users" -PassThru | Edit-LyncUser
