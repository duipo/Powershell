<#
- SKU Checker
- Revision: 1.0

Queries Registry and WMI to check the SKU
#>

$skuReg = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS -Name "SystemSKU"
$skuReg.SystemSKU

$skuWMI = Get-WMIObject -Namespace root\wmi -Class MS_SystemInformation
$skuWMI.SystemSKU

$skuWMIa = Get-WMIObject Win32_BIOS | Select-Object SerialNumber
$skuWMIa.SerialNumber
