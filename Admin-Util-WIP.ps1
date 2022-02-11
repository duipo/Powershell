<#
- PowerShell Admin Utility
- Revision: 1.0

Work in progress, designed to have a whole host of utilities.
#>

$PSVersionTable.PSVersion
""
"PowerShell Admin Utility"
"Author:  Elliot Bath"
"Version: 1.0"
""

$cat = 0
while($cat -eq 0)
{
    "Select Category"
    "1. Active Directory"
    "2. Exchange"
    "3. Windows OS"
    ""

    $cat = Read-Host "Category"

    switch($cat)
    {
        1 {"Active Directory"; $cat = 1}
        2 {"Exchange"; $cat = 2}
        3 {"Windows OS"; $cat = 3}
        default {"Please enter 1-3"; $cat = 0}
    }
    ""
}

$task = 0
while($task -eq 0)
{
    "Select Task"
    "1. List of disabled users"
    "2."

    $task = Read-Host "Task"

    switch($task)
    {
        1 {"Disabled users"; $task = 1}
        2 {""; $task = 2}
    }
}
