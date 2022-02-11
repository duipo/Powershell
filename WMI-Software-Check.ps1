<#
- WMI Software Checker
- Revision: 1.0

Finds software version and reports if installed
#>

Write-host "Checking Software Version"

$software = Get-WmiObject Win32_Product -Filter "Name LIKE '%Microsoft Visual C++ 2019 X86 Additional Runtime%'"
$version = $software.version

If ($Version -ne "14.24.2817")
{
  Write-host "$version is NOT installed. Please check C++ version for Sage200"
  Start-Sleep -Seconds 5
  Exit
}
else
{
  Write-host "$version is installed"
  Exit
}
