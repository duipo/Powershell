<#
- Active Directory Import From CSV
- Revision: 1.0

Script can import a CSV and update user attributes using a foreach loop
#>

Import-Module activedirectory
#samaccountname,extensionattribute1
$csv = import-csv "C:\folder\file.csv" -Delimiter ','

# Line properties need to match csv headers
foreach ($line in $csv)
{
$user = Get-ADUser $line.user -Properties extensionattribute1
$user.extensionattribute1 = $line.extensionattribute1
    Set-ADUser -instance $user
}
Exit
