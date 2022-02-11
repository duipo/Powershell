<#
- Exchange Online Template
- Revision: 1.0

Used for templates
#>

$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-Host "Now connected to PowerShell Exchange"
