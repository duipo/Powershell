<#
- Mailbox Copy Items By Category
- Revision: 1.0

Looks for categories and copys items to the target folder.
#>

$csv = Import-Csv "C:\users.csv"

ForEach ($line in $csv)
{
  Write-Host "Copying items for" $line.User "to OrangeCat\" $line.User
  $user = $line.User

  #New-MailboxExportRequest -Mailbox $csv.User -ContentFilter {(Category -like "*Orange*") -And (Received -gt '02/18/2015') -And (Received -lt '06/01/2015')} -FilePath \\v-herr-mail\PSTExport\$User.pst
  Get-Mailbox $line.User | Search-Mailbox -TargetMailbox AdminTekkers -TargetFolder "OrangeCat\$user" -SearchQuery {(Category -like "*Orange*") -And (Received -ge '05/18/2015') -And (Received -lt '06/01/2015')} -SearchDumpster
}
