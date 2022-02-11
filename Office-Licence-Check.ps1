<#
- Office 2013 License Checker
- Revision: 1.0

Checks Office status and exports to file.
#>

$PC = $env:computername
$output = "\\V-PRHO-DATA\Office$\$PC.txt"

cscript "C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS" /dstatus > $output
