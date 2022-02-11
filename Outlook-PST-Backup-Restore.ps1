<#
- PST Backup and Restore
- Revision: 1.0

Backups Outlook PST and Restores with shell commands.
#>

# Get current Windows version
$WinVer = (Get-CimInstance Win32_OperatingSystem).version
$pos = $WinVer.IndexOf(".")
$Ver = $WinVer.Substring(0, $pos)

# Create user and share variables
$user = $env:UserName
$dest = "D:\Shared\$user"

# Create popup window object
$wshell = New-Object -ComObject Wscript.Shell

# Warn and close Outlook
$wshell.Popup("Outlook will close when you press OK",0,"Outlook",0x0)
If(Get-Process -Name "outlook" -ea SilentlyContinue)
{
    Stop-Process -Name "outlook"
}

# Log files
$log1 = "$dest\copy1.log"

If(Test-Path $log1)
{
    Remove-Item $log1
}
Else
{
    New-Item $log1 -ItemType file
}

$log2 = "$dest\copy2.log"

If(Test-Path $log2)
{
    Remove-Item $log2
}
Else
{
    New-Item $log2 -ItemType file
}

$datetime = Get-Date -Format g

# Switch command for each OS version
Switch($Ver)
{
    "6"
    {
        # Warns users of Outlook backup
        $wshell.Popup("Outlook PSTs are now being backed up, please do not open Outlook until the next message appears",0,"Outlook",0x0)

        # Creates username share on D drive
        If((Test-Path $dest) -eq $False)
        {
            New-Item -ItemType directory -Path $dest
        }

        Add-Content -Path $log -Value $datetime

        # Searches C drive for PST files, copies and creates log
        $type = "*.pst"
        Get-ChildItem -Path C:\ -Include *.pst -Recurse -ea SilentlyContinue | Foreach-Object{
            $name = $_.name
            $size = $_.length
            $size = $size /1Gb
            $file = "$dest\$name"
            If(Test-Path $file)
            {
                $i = 0
                While (Test-Path $file)
                {
                    $i += 1
                    $file = $file -Replace ".pst$","($i).pst"
                }
                Copy-Item -Path $_ -Destination $file -Recurse -ea SilentlyContinue
                $newFile = Get-ChildItem -Path $file -ea Silently Continue
                $newFilename = $newFile.name
                Add-Content -Path $log1 -Value "`r` $name $_ $size Y $newFilename"
            }
            Else
            {
                Copy-Item -Path $_ -Destination $file -Recurse -ea SilentlyContinue
                Add-Content -Path $log1 -Value "`r` $name $_ $size N"
            }
        }

        $wshell.Popup("Your files have been copied. Please do not archive anything at the .PST",0,"Outlook",0x0)


    }

    "10"
    {
        $answer = $wshell.Popup("Do you want to restore .PST files?",0,"Outlook",4)
        If ($answer -eq 6)
        {
            $wshell.Popup("Copy in progress, please wait",0,"Outlook",0x0)

            $newDest = "C:\PST"
            If((Test-Path $newDest) -eq $False)
            {
                New-Item -ItemType directory -Path $newDest
            }

            Get-ChildItem -Path $dest -Include *.pst -Recurse -ea SilentlyContinue | Foreach-Object{
                $name = $_.name
                $size = $_.length
                $size = $size /1Gb
                $file = "$newDest\$name"

                If(Test-Path $file)
                {
                    $i = 0
                    While (Test-Path $file)
                    {
                        $i += 1
                        $file = $file -Replace ".pst$","($i).pst"
                    }
                    Copy-Item -Path $_ -Destination $file -Recurse -ea SilentlyContinue
                    $newFile = Get-ChildItem -Path $file -ea Silently Continue
                    $newFilename = $newFile.name
                    Add-Content -Path $log2 -Value "`r` $name $_ $size Y $newFilename"
                }
                Else
                {
                    Copy-Item -Path $_ -Destination $file -Recurse -ea SilentlyContinue
                    Add-Content -Path $log2 -Value "`r` $name $_ $size N"
                }
            }

            $wshell.Popup("Your .PST files are restored to C:\PST. Please follow this URL: http://intranet regarding archiving policy and usage of archive mailboxes",0,"Outlook",0x0
        }
    }
}
