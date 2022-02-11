<#
- Restart VSS Writers
- Revision: 1.0

Cycles through all common VSS writers to stop and then start the services.
#>

#Restart VSS Writers
Stop-Service NtFrs -Force -ErrorAction SilentlyContinue
Start-Service NtFrs -ErrorAction SilentlyContinue
Stop-Service CryptSvc -Force -ErrorAction SilentlyContinue
Start-Service CryptSvc -ErrorAction SilentlyContinue
Stop-Service VSS -Force -ErrorAction SilentlyContinue
Start-Service VSS -ErrorAction SilentlyContinue
Stop-Service SQLWriter -Force -ErrorAction SilentlyContinue
Start-Service SQLWriter -ErrorAction SilentlyContinue
Stop-Service AppHostSvc -Force -ErrorAction SilentlyContinue
Start-Service AppHostSvc -ErrorAction SilentlyContinue
Stop-Service CertSvc -Force -ErrorAction SilentlyContinue
Start-Service CertSvc -ErrorAction SilentlyContinue
Stop-Service NTDS -Force -ErrorAction SilentlyContinue
Start-Service NTDS -ErrorAction SilentlyContinue
Stop-Service IISADMIN -Force -ErrorAction SilentlyContinue
Start-Service IISADMIN -ErrorAction SilentlyContinue
Stop-Service WSearch -Force -ErrorAction SilentlyContinue
Start-Service WSearch -ErrorAction SilentlyContinue
Stop-Service Winmgmt -Force -ErrorAction SilentlyContinue
Start-Service Winmgmt -ErrorAction SilentlyContinue
Stop-Service DHCPServer -Force -ErrorAction SilentlyContinue
Start-Service DHCPServer -ErrorAction SilentlyContinue
Stop-Service EventSystem -Force -ErrorAction SilentlyContinue
Start-Service EventSystem -ErrorAction SilentlyContinue
Start-Service MMS -ErrorAction SilentlyContinue
exit
