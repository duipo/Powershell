<#
- ProxyAddress Cleanup
- Revision: 1.0

Looks for a certain domain and removes it from users' ProxAddresses
#>

import-module activedirectory

$pa = '*domain.com'

$allusers = Get-ADUser -Filter {Enabled -eq $true} -Properties *
ForEach ($user in $allusers)
{
    Write-Host "Now running on " $user.sAMAccountName
    ForEach ($proxyAddress in $user.ProxyAddresses)
    {
        If ($proxyAddress -like $pa)
        {
            Write-Host "Deleting " $proxyAddress " from user"
            Set-ADUser -Identity $user -Remove @{proxyaddresses="$proxyAddress"}
        }
    }
}
Exit
