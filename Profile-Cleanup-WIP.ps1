<#
- Profile Cleanup
- Revision: 1.0

Work in progress
#>

﻿Get-WMIObject -class Win32_UserProfile | Where {(!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-90))}
