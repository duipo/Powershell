<#
- Password Tester
- Revision: 1.0

Takes username and password input and tests against the domain to confirm if correct.
#>

$cred = Get-Credential
$username = $cred.username
$password = $cred.GetNetworkCredential().password

# Get current domain using logged-on user's credentials
$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

if ($domain.name -eq $null)
{
  write-host "Authentication failed - please verify your username and password."
}
else
{
  write-host "Successfully authenticated with domain $domain.name"
}
