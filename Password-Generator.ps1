<#
- Password Generator
- Revision: 1.0

Uses the old format, needs to be updated to match xk.
Commented out the export parts.
#>

$lower = [Char[]]"bcdfghjklmnpqrstvwxyz"
$upper = [Char[]]"BCDFGHJKLMNPQRSTVWXYZ"
$vowels = [Char[]]"aeiou"
$nums = [Char[]]"0123456789"
$special = [Char[]]"!$%&*()-_+@?[]"
$a = 0
#$csv = Import-Csv "C:\update_pass.csv" -Delimiter ","

#ForEach ($line in $csv) {
$1 = $upper | Get-Random -Count 1
$2 = $vowels | Get-Random -Count 1
$3 = $lower | Get-Random -Count 1
$set1 = ($1 + $2 + $3) -join ""

$4 = $lower | Get-Random -Count 1
$5 = $vowels | Get-Random -Count 1
$6 = $lower | Get-Random -Count 1
$set2 = ($4 + $5 + $6) -join ""

$set3 = ($nums | Get-Random -Count 2) -join ""

$7 = $special | Get-Random -Count 1



$pass = (Get-Random -InputObject $set1, $set2, $set3 -Count 3) -join ""
$pass = $pass, $7 -join ""
$wshell = New-Object -ComObject WScript.Shell
$wshell.Popup($pass + " Has been copied to your clipboard")
$pass | clip.exe

#$csv += $line | Add-Member -name "Password" -Value $pass -MemberType NoteProperty -Force

#}

#$csv | Export-Csv "C:\update_pass.csv" -NoTypeInformation

#Do
#{
#$a++
#} Until ($a -eq 20)
Exit
