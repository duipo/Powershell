<#
- Exchange Mailbox Folder Deletion
- Revision: 1.0

Finds relevant folder and deletes from mailbox.
Can be tweaked with a for loop against a list.
#>

$mailbox = Get-Mailbox "username@domain"
$folder = "Inbox\Clients\Dude"

# Displays mailbox/folder for verification
$mailbox
$folder

# Delete email/folder
Search-Mailbox -TargetMailbox $mailbox -TargetFolder $folder -DeleteContent -Force
Exit
