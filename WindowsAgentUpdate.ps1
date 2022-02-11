# Agent Updater Script
# Author: Elliot Bath
# Ver: 1.2

param (
    [Parameter(Mandatory=$true)][string]$newver
)

# This section downloads the Windows Agent from ms.tekkersit.com

New-Item -ItemType Directory -Force -Path C:\Source

$url = "https://ms.tekkersit.com/download/$newver/winnt/N-central/WindowsAgentSetup.exe"
$file = "C:\Source\WindowsAgentSetup.exe"

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $file

$sysvol = "C:\Windows\SYSVOL\domain\scripts\Agent\WindowsAgentSetup.exe"

Copy-Item -Path $file -Destination $sysvol -Force

# Now we need to update the sNewAgent string in InstallAgent.vbs

$script = "C:\Windows\SYSVOL\domain\scripts\Agent\InstallAgent.vbs"
$line = Get-Content $script | Select-String 'sNewAgent =' | Select-Object -ExpandProperty Line

$newver2 = [char]34 + $newver + [char]34

$content = Get-Content $script
$content | ForEach-Object {$_ -replace $line,"sNewAgent = $newver2"} | Set-Content $script

Exit