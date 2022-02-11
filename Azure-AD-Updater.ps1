<#
- Azure AD User Updater
- Revision: 1.0

Takes CSV and sets details against users.
#>

﻿$Username = ""
$Password = ""

$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username $SecurePassword

Import-Module MSOnline

Connect-MsolService -Credential $Credential

Import-Csv "" | % {Set-MsolUser -UserPrincipalName %_.UserPrincipalName -Fax $_.Fax -MobilePhone $_.MobilePhone -Office $_.Office -Title $_.Title}
Exit
