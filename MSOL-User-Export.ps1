<#
- MSOL User Export
- Revision: 1.0

Connects to MSOL to export users.
#>

$userCreds = Get-Credential -Message "Enter Office365 administrator details" -UserName "admin@domain"
$remoteSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $userCreds -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue

Import-PSSession $remoteSession -DisableNameChecking -AllowClobber
Connect-MsolService -Credential $userCreds

Get-MsolUser | select UserPrincipalName | Export-CSV D:\Media\Scripts\passwords.csv -NoTypeInformation
Exit
