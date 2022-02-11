# NCentral On Access Scanning WMI Fix
$a = Get-WmiObject -Namespace root\SecurityCenter -Class AntiVirusProduct
$a.onAccessScanningEnabled = $true
$a = $null
Exit