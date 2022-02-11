<#
- HKEY User Cleaner
- Revision: 1.0

Loads the HKU hive and removes specific items.
#>

﻿$ProfileList = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
$UserProfiles = dir $ProfileList | % {Get-ItemProperty $_.pspath} | Select profileImagePath, PSChildName
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
cd HKU:\

ForEach($profile in $UserProfiles)
{
  $hive = $profile.PSChildName
  Remove-Item -Path "HKU:\$hive\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsytem\Profiles" -Recurse
}
Exit
