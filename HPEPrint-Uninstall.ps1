<#
- HPE Print Uninstaller
- Revision: 1.0

Removes the HPE Print app.
#>

$app = Get-WmiObject -Class Win32_Product | Where-Object
{
  $_.Name -match "HP ePrint Windows Driver"
}

$app.Uninstall()
Exit
