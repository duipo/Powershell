<#
- Active Directory Export Disabled Users
- Revision: 1.0

Exports disabled users from Active Directory.
#>

# Set up variables
$csv = "C:\disabledusers.csv"

Import-Module ActiveDirectory

Get-ADUser -Filter * -SearchBase "OU=STAFF,OU=USERS,OU=MAYVILLE,DC=MAYVILLE,DC=LOCAL" | Where-Object {$_.Enabled -eq $false} | Select-Object SAMAccountName | Export-CSV -Path $csv -NoTypeInformation
Write-Host "Export complete"
Exit
