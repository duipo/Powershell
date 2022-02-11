<#
- Active Directory Attribute Copier
- Revision: 1.0

Copies data to specific attribute field for an AD user.
#>

# Active Directory Module
import-module ActiveDirectory

#Declare variables
$allusers = Get-ADUser -Filter {Enabled -eq $true} -Properties *

ForEach ($user in $allusers)
{
  Write-Host "Now running on " $user.sAMAccountName
  Set-ADUser -Identity $user -Clear facsimileTelephoneNumber
  $notes = $user.Info
  Set-ADUser -Identity $user -Add @{facsimileTelephoneNumber=$notes}
  Set-ADUser -Identity $user -Clear info
  Write-Host "Copied to Fax field"
  Write-Host ""
}
Exit
