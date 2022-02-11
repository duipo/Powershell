<#
- Random Number Generator
- Revision: 1.0

Creates random number and joins to create a PIN.
#>

$r1 = Get-Random -minimum 0 -maximum 9
$r2 = Get-Random -minimum 0 -maximum 9
$r3 = Get-Random -minimum 0 -maximum 9
$r4 = Get-Random -minimum 0 -maximum 9
$PIN = $r1, $r2, $r3, $r4 -join ""
Write-Host $PIN

Exit
