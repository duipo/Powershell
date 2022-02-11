# Retrieves TeamKey for Endpoint
$user = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty username
$domain,$un = $user.Split("\")
$path = "C:\Users\$un\AppData\Local\Autotask Corporation\Common\Status Report - Autotask Endpoint Backup.xml"

[xml]$endpoint = Get-Content $path
$xmlProperties = $endpoint.SelectNodes("/status-report/value")
$key = ($xmlProperties | Where-Object {$_.Name -eq "setup-deployment-key" }).InnerXML

$exe = "C:\Source\Endpoint.exe"
Invoke-WebRequest -Uri https://eu.fileprotection.datto.com/update/aeb/DattoFileProtectionSetup_v8.0.0.274.exe -OutFile $exe

& $exe /install /quiet TeamKey=$key
Exit