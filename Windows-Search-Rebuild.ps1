<#
- Windows Search Cache Rebuild
- Revision: 1.0

Clears the Windows Search Cache and starts the service for indexing.
#>

# Clear Windows Search DB Cache

Stop-Service -Name "wsearch"
Remove-Item "%ProgramData%\Microsoft\Search\data\applications\Windows\Windows.edb.bak" -Force
Move-Item -Path "%ProgramData%\Microsoft\Search\data\applications\Windows\Windows.edb" -Destination "%ProgramData%\Microsoft\Search\data\applications\Windows\Windows.edb.bak"
Start-Service -Name "wsearch"

Exit
