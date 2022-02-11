<#
- User Password Reset
- Revision: 1.0

Updates passwords via user csv.
#>

Import-Module ActiveDirectory
$csv = Import-Csv "C:\update_pass.csv" -Delimiter ","

foreach ($line in $csv)
{

  $user = Get-ADUser $line.Name -Properties *
  $newpwd = ConvertTo-SecureString -AsPlainText -Force $line.Password
  Set-ADAccountPassword $user -NewPassword $newpwd -Reset
  Set-ADUser $user -passwordNeverExpires $true
  Set-ADUser $user -CannotChangePassword $true

  Set-ADUser -Instance $user

}
Write-Host "All passwords reset!"
