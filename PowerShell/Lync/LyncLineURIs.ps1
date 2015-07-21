#Requires -Modules ActiveDirectory

Function Get-ADLyncUser()
{
    Write-Progress -Activity "Getting user information" -Status "Active Directory"
    $adusers = Get-ADUser -LDAPFilter "(&(msRTCSIP-Line=*))" -Properties msRTCSIP-Line, msRTCSIP-PrivateLine, msRTCSIP-PrimaryUserAddress, msRTCSIP-UserEnabled, officephone, mobilephone, ipphone | Select-Object name, officephone, mobilephone, ipphone, msRTCSIP-Line, msRTCSIP-PrivateLine, msRTCSIP-PrimaryUserAddress, msRTCSIP-UserEnabled, objectguid
    $contacts = Get-ADObject -LDAPFilter "(&(objectClass=contact)(msRTCSIP-Line=*))" -Properties msRTCSIP-Line, msRTCSIP-PrimaryUserAddress, msRTCSIP-UserEnabled, telephonenumber | Select-Object name, msRTCSIP-Line, msRTCSIP-PrimaryUserAddress, msRTCSIP-UserEnabled, objectguid, telephonenumber
    $users = @()

    foreach ($a in $adusers)
    {
        Write-Progress -Activity "Compiling table of user information" -Status ("Processing (" + (($users | Measure-Object).count + 1) + " of " + ($adusers | Measure-Object).count + ")") -PercentComplete (($users | Measure-Object).count / ($adusers | Measure-Object).count * 100 )
        if ($a.'msRTCSIP-UserEnabled' -eq $true)
        {
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "Name" -NotePropertyValue $a.name
            $obj | Add-Member -NotePropertyName "SIP Address" -NotePropertyValue $a.'msRTCSIP-PrimaryUserAddress'
            $obj | Add-Member -NotePropertyName "Line URI" -NotePropertyValue $a.'msRTCSIP-Line'
            $obj | Add-Member -NotePropertyName "Private Line" -NotePropertyValue $a.'msRTCSIP-PrivateLine'
            $obj | Add-Member -NotePropertyName "Office Phone" -NotePropertyValue $a.officephone
            $obj | Add-Member -NotePropertyName "IP Phone" -NotePropertyValue $a.ipphone
            $obj | Add-Member -NotePropertyName "Mobile Phone" -NotePropertyValue $a.mobilephone
            $obj | Add-Member -NotePropertyName "Object GUID" -NotePropertyValue $a.objectguid
            $obj | Add-Member -NotePropertyName "Object Type" -NotePropertyValue "User"

            $users += $obj
        }
    }

    foreach ($c in $contacts)
    {
        Write-Progress -Activity "Compiling Common Area Phones" -Status "Processing" -PercentComplete 90
        if ($c.'msRTCSIP-UserEnabled' -eq $true)
        {
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value $c.name
            $obj | Add-Member -MemberType NoteProperty -Name "SIP Address" -Value $c.'msRTCSIP-PrimaryUserAddress'
            $obj | Add-Member -MemberType NoteProperty -Name "Line URI" -Value $c.'msRTCSIP-Line'
            $obj | Add-Member -MemberType NoteProperty -Name "Office Phone" -Value $c.telephoneNumber
            $obj | Add-Member -MemberType NoteProperty -Name "Object GUID" -Value $c.objectguid
            $obj | Add-Member -MemberType NoteProperty -Name "Object Type" -Value "Contact"

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
    
        $Form = New-Object -TypeName System.Windows.Forms.Form
        $Form.Size = New-Object -TypeName System.Drawing.Size(335,220)
        $Form.StartPosition = "CenterScreen"
        $Form.Text = "Edit Details"
        $Form.Name = "EditDetails"
        $Form.TopMost = $true

        $LBDisplayName = New-Objec -TypeNamet System.Windows.Forms.Label
        $LBDisplayName.Location = New-Object -TypeName System.Drawing.Size(15,20)
        $LBDisplayName.Size = New-Object -TypeName System.Drawing.Size(85,15)
        $LBDisplayName.Text = "Name:"

        $TBDisplayName = New-Object -TypeName System.Windows.Forms.TextBox
        $TBDisplayName.Location = New-Object -TypeName System.Drawing.Size(100,15)
        $TBDisplayName.Size = New-Object -TypeName System.Drawing.Size(200,15)
        $TBDisplayName.Text = $obj.Name
        $TBDisplayName.ReadOnly = $True

        $LBSIPAddress = New-Object -TypeName System.Windows.Forms.Label
        $LBSIPAddress.Location = New-Object -TypeName System.Drawing.Size(15,40)
        $LBSIPAddress.Size = New-Object -TypeName System.Drawing.Size(85,15)
        $LBSIPAddress.Text = "SIP Address:"

        $TBSIPAddress = New-Object -TypeName System.Windows.Forms.TextBox
        $TBSIPAddress.Location = New-Object -TypeName System.Drawing.Size(100,35)
        $TBSIPAddress.Size = New-Objec -TypeNamet System.Drawing.Size(200,15)
        $TBSIPAddress.Text = $obj."SIP Address"
        $TBSIPAddress.ReadOnly = $True

        $LBLineURI = New-Object -TypeName System.Windows.Forms.Label
        $LBLineURI.Location = New-Object -TypeName System.Drawing.Size(15,60)
        $LBLineURI.Size = New-Object -TypeName System.Drawing.Size(85,15)
        $LBLineURI.Text = "Line URI:"

        $TBLineURI = New-Object -TypeName System.Windows.Forms.TextBox
        $TBLineURI.Location = New-Object -TypeName System.Drawing.Size(100,55)
        $TBLineURI.Size = New-Object -TypeName System.Drawing.Size(200,15)
        $TBLineURI.Text = $obj."Line URI"

        $LBOfficePhone = New-Object -TypeName System.Windows.Forms.Label
        $LBOfficePhone.Location = New-Object -TypeName System.Drawing.Size(15,80)
        $LBOfficePhone.Size = New-Object -TypeName System.Drawing.Size(85,15)
        $LBOfficePhone.Text = "Office Phone:"

        $TBOfficePhone = New-Object -TypeName System.Windows.Forms.TextBox
        $TBOfficePhone.Location = New-Object -TypeName System.Drawing.Size(100,75)
        $TBOfficePhone.Size = New-Object -TypeName System.Drawing.Size(200,15)
        $TBOfficePhone.Text = $obj."Office Phone"
        $TBOfficePhone.ReadOnly = $true

        $LBIPPhone = New-Object -TypeName System.Windows.Forms.Label
        $LBIPPhone.Location = New-Object -TypeName System.Drawing.Size(15,100)
        $LBIPPhone.Size = New-Object -TypeName System.Drawing.Size(85,15)
        $LBIPPhone.Text = "IP Phone:"

        $TBIPPhone = New-Object -TypeName System.Windows.Forms.TextBox
        $TBIPPhone.Location = New-Object -TypeName System.Drawing.Size(100,95)
        $TBIPPhone.Size = New-Object -TypeName System.Drawing.Size(200,15)
        $TBIPPhone.Text = $obj."IP Phone"
        $TBIPPhone.ReadOnly = $true

        $LBMobile = New-Object -TypeName System.Windows.Forms.Label
        $LBMobile.Location = New-Object -TypeName System.Drawing.Size(15,120)
        $LBMobile.Size = New-Object -TypeName System.Drawing.Size(85,15)
        $LBMobile.Text = "Mobile Phone:"

        $TBMobile = New-Object -TypeName System.Windows.Forms.TextBox
        $TBMobile.Location = New-Object -TypeName System.Drawing.Size(100,115)
        $TBMobile.Size = New-Object -TypeName System.Drawing.Size(200,15)
        $TBMobile.Text = $obj."Mobile Phone"
 
        $ButtonOK = New-Object -TypeName System.Windows.Forms.Button
        $ButtonOK.Location = New-Object -TypeName System.Drawing.Size(15,140)
        $ButtonOK.Size = New-Object -TypeName System.Drawing.Size(140,25)
        $ButtonOK.Text = "OK"
        $ButtonOK.TabIndex = "2"
        $ButtonOK.Add_Click({Set-LyncUser})

        $ButtonCancel = New-Object -TypeName System.Windows.Forms.Button
        $ButtonCancel.Location = New-Object -TypeName System.Drawing.Size(160,140)
        $ButtonCancel.Size = New-Object -TypeName System.Drawing.Size(140,25)
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
        [void]$Form.Close()
    }
}

Function Set-LyncUser()
{
    if ($obj.'Object Type' -eq "User" -and $obj.'Line URI' -ne $TBLineURI.Text)
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
            Write-Error -Message "Invalid Format. Please try again"
            $obj | Edit-LyncUser
        }
    }

    if ($obj.'Object Type' -eq "User" -and $obj.'Mobile Phone' -ne $TBMobile.Text -and (Check-E164 -number $TBMobile.Text -minlength 12 -maxlength 12))
    {
        Set-ADUser -Identity $obj.'Object GUID' -MobilePhone $TBMobile.Text
    }

    else
    {
        [void]$Form.Close()
        $obj | Edit-LyncUser
    }
}

Function Check-E164($number, $minlength = 4, $maxlength = 12)
{
    if ($number -match "^\+\d{$minlength,$maxlength}$")
    {
        return $true
    }

    else
    {
        Write-Error -Message "Invalid format. Number must be in E.164 format (+1234, +441234567890)."
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
        Write-Error -Message "Invalid URI format. Number must be in Lync URI format with an optional 4 digit extension (tel:+1234, tel:+441234567890;ext:+1234)."
        return $false
    }
}

Get-ADLyncUser | Out-GridView -Title "Lync Users" -PassThru | Edit-LyncUser
