<#
- SNMP Enable
- Revision: 1.0

Installs the feature and enables via registry key.
#>

Install-WindowsFeature SNMP-Service -IncludeAllSubFeature -IncludeManagementTools
reg add “HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities” /v "public" /t REG_DWORD /d 4 /f

Exit
