<#
- Email Finder
- Revision: 1.0

Enter email address to find in Active Directory/ADSI
#>

Import-Module activedirectory

# Keeps script running
$running = $True
while ($running -eq $True)
{
  $address = Read-Host -Prompt "Enter email address to check"
  $result = Get-ADObject -Properties mail, proxyAddresses -Filter {mail -eq $address -or proxyAddresses -eq $address}
  $result | FT

  $response = Read-Host "Press y to continue or anything else to quit"
  if(!$response = "y")
  {
    $running -eq $false
  }
}
