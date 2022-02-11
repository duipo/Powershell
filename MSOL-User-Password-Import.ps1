<#
- MSOL User Password Import
- Revision: 1.0

Description
#>

# Microsoft Office 365 Password Update
# Takes passwords from csv and updates user accounts

# Prompt for Office365 credentials
$userCreds = Get-Credential -Message "Enter Office365 administrator details" -UserName "admin@domain"
$remoteSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCreds -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue

Import-PSSession $remoteSession -DisableNameChecking
Connect-MsolService -Credential $userCreds

Write-Host "Now connected to Office 365 PowerShell"
Write-Host "Importing new passwords"

Import-Csv D:\Media\Scripts\passwords.csv | % {Set-MsolUserPassword -userPrincipalName $_.userPrincipalName -NewPassword $_.Password -ForceChangePassword $False}

Write-Host "Passwords imported and updated"
Exit
