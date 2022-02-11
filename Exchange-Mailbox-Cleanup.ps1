<#
- Mailbox Folder Cleanup
- Revision: 1.0

Removes items older than x days
#>

$limit = (Get-Date).AddDays(-7)
$mailboxes = "C:\mailboxes.txt"
$ConfirmPreference = 'None'

Get-Content $mailboxes | Export-Mailbox -IncludeFolders "\Inbox\Processed" -StartDate "01/01/2007" -EndDate $limit -DeleteContent

Exit
