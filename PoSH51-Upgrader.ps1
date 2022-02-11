<#
- PowerShell 5.1 Upgrader
- Revision: 1.0

Work in progress
#>

# Get OS Version
$OS = (Get-WmiObject win32_operatingsystem).Version

# WMF 3.0 Check
$PSVer = $PSVersionTable.PSVersion.ToString()
$PSVer

# Check .NET Version


## Install latest .NET


# Install WMF 5.1


# Cleanup
