# File upload script
# Author: Elliot Bath @ Tekkers IT Solutions
# Version: 1.0

# Variables
$SrcFolder = "C:\"
$ComFolder = "C:\Completed"
$CurrentDate = Get-Date
$Retention = "-14"
$DeleteFiles = $CurrentDate.AddDays($Retention)
$SecFile = "C:\pass.txt"
$Password = Get-Content $SecFile | ConvertTo-SecureString

# Load WinSCP .NET assembly
Add-Type -Path "WinSCPnet.dll"

# WinSCP Session
$SessionOpts = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "217.40.39.30"
    UserName = "Prospect"
    Password = $Password
    SshHostKeyFingerprint = "ssh-rsa 2048 xx:xx:xx:xx:xx"
}

# WinSCP Object Creation
$Session = New-Object WinSCP.Session

# Connect to WinSCP Session
$Session.Open($SessionOpts)

$TransOpts = New-Object WinSCP.TransferOptions
$TransOpts.TransferMode = [WinSCP.TransferMode]::Binary

# Cycle through folder, upload and move
Get-ChildItem -Path $SrcFolder -Recurse -ea SilentlyContinue | ForEach-Object {
    # Run WinSCP command
    $Session.PutFiles($_, "/home/", $False, $TransOpts)
    Move-Item -Path $_ -Destination $ComFolder
}

# Delete files older than $Retention variable in completed folder
Get-ChildItem -Path $ComFolder -Recures -ea SilentlyContinue | Where-Object { $_.LastWriteTime -lt $DeleteFiles} | Remove-Item

#Close WinSCP session
$Session.Dispose()
exit