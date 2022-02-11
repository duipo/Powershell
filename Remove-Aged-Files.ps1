<#
- Remove Aged Files
- Revision: 1.0

Script set up to look at files older than 30 days. To amend this, change the value under "Add Days" below.
Path needs to be replaced with SQL .bak file locations.
#>

$Time = (Get-Date).AddDays(-30)
Get-ChildItem -Path C:\Support\Test -Recurse | Where {$_.LastWriteTime -lt $time} | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
