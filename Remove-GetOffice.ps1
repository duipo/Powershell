<#
- Remove "Get Office" App
- Revision: 1.0

Removes the "Get Office" App from Windows
#>

﻿Get-AppxPackage *officehub* | Remove-AppxPackage
Exit
