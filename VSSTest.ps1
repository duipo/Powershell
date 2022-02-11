# Not Currently in use and created by Adam Bacon.

Function New-MatrixLog {
Param(
[Parameter(Mandatory=$true)]
[ValidateSet("Application", "System")]
[string] $LogName = "System",
[Parameter(Mandatory=$true)]
[ValidateSet("Matrix IT Alert")]
[string] $Source,
[Parameter(Mandatory=$true)]
[ValidateSet("Critical", "Error","Warning","Information")]
[string] $EntryType,
[string] $EventID,
[string] $Message
)
if (-not([System.Diagnostics.EventLog]::SourceExists($Source))){
New-EventLog -LogName $LogName -Source $Source
}
Write-EventLog -LogName $LogName -Source $Source -EntryType $EntryType -EventID $EventID -Message $Message
}
New-Alias log Write-Host
log "Creating an event log in the system event log event id 8808 under the source Matrix IT Alert"

New-MatrixLog -LogName 'System' -Source 'Matrix IT Alert' -EntryType 'Warning' -EventID 8808 -Message 'VSSadmin list writers has indicated one or more problems with the VSS services running on this machine which is preventing a successful backup, a script will now be run to automatically fix this.'

log "This has now been logged to the event log"
log "Checking to see if the VSS service is running"
if ((get-service VSS).status -ne "Running"){Start-service VSS -PassThru}
log "Listing VSS providers on this machine"
Invoke-Command -ScriptBlock {Vssadmin list providers}
log "Gathering all VSS writers on this machine and the current state"
$VssWriters = Invoke-Command -ScriptBlock {Vssadmin list writers}
$VSSOutput = $VssWriters | Select-String  -Pattern 'Writer name:*.*','State:*.*'
$totalCount = $VSSOutput.Count
log "About to auto fix anyt VSS writers in a failed state"
$objCount = 0
Do {
     Write-Host "Processing $($VSSOutput[$objCount])"
     if ($VSSOutput[$objCount+1] | Select-String "Failed")
     {
     $VSSname = $VSSOutput[$objCount].Matches.value -replace 'Writer name:',''
     Write-Host "Restarting services for $VSSname" 
if ($VSSname -match 'System Writer')
{Stop-Service CryptSvc -Force -PassThru; Start-Service CryptSvc -PassThru}
elseif($VSSname -match 'Task Scheduler Writer'){Stop-Service Schedule -Force -PassThru; Start-Service Schedule -PassThru}
elseif($VSSname -match 'VSS Metadata Store Writer'){Stop-Service VSS -Force -PassThru; Start-Service VSS -PassThru}
elseif($VSSname -match 'Performance Counters Writer'){"Please manually Restart this service"}
elseif($VSSname -match 'SqlServerWriter'){Stop-Service SQLWriter -Force -PassThru; Start-Service SQLWriter -PassThru}
elseif($VSSname -match 'WIDWriter'){Stop-Service WIDWriter -Force -PassThru; Start-Service WIDWriter -PassThru}
elseif($VSSname -match 'FSRM Writer'){Stop-Service srmsvc -Force -PassThru; Start-Service srmsvc -PassThru}
elseif($VSSname -match 'Shadow Copy Optimization Writer'){Stop-Service VSS -Force -PassThru; Start-Service VSS -PassThru}
elseif($VSSname -match 'Dhcp Jet Writer'){Stop-Service DHCPServer -Force -PassThru; Start-Service DHCPServer -PassThru}
elseif($VSSname -match 'IIS Config Writer'){Stop-Service AppHostSvc -Force -PassThru; Start-Service AppHostSvc -PassThru}
elseif($VSSname -match 'ASR Writer'){Stop-Service VSS -Force -PassThru; Start-Service VSS -PassThru}
elseif($VSSname -match 'NPS VSS Writer'){Stop-Service EventSystem -Force -PassThru; Start-Service EventSystem -PassThru}
elseif($VSSname -match 'MSSearch Service Writer'){Stop-Service WSearch -Force -PassThru; Start-Service WSearch -PassThru}
elseif($VSSname -match 'Windows Server Storage VSS Writer'){Stop-Service WseStorageSvc -Force -PassThru; Start-Service WseStorageSvc -PassThru}
elseif($VSSname -match 'COM+ REGDB Writer'){Stop-Service VSS -Force -PassThru; Start-Service VSS -PassThru}
elseif($VSSname -match 'BITS Writer'){Stop-Service BITS -Force -PassThru; Start-Service BITS}
elseif($VSSname -match 'DFS Replication service writer'){Stop-Service DFSR -Force -PassThru; Start-Service DFSR -PassThru}
elseif($VSSname -match 'Registry Writer'){Stop-Service VSS -Force -PassThru; Start-Service VSS -PassThru}
elseif($VSSname -match 'WMI Writer'){Stop-Service Winmgmt -Force -PassThru; Start-Service Winmgmt -PassThru}
elseif($VSSname -match 'Certificate Authority'){Stop-Service certsvc -Force -PassThru; Start-Service certsvc -PassThru}
elseif($VSSname -match 'TS Gateway Writer'){Stop-Service TSGateway -Force -PassThru; Start-Service TSGateway -PassThru}
elseif($VSSname -match 'NTDS'){Stop-Service NTDS -Force -PassThru; Start-Service NTDS -PassThru}
elseif($VSSname -match'IIS Metabase Writer') {Stop-Service IISAdmin -Force -PassThru; Start-Service IISAdmin -PassThru}
elseif($VSSname -match 'MSMQ Writer'){Stop-Service MSMQ -Force -PassThru; Start-Service MSMQ -PassThru}
elseif($VSSname -match 'WDS VSS Writer'){Stop-Service WDSServer -Force -PassThru; Start-Service WDSServer -PassThru}
elseif($VSSname -match 'Microsoft Dynamics CRM'){Stop-Service MSCRMVssWriterService -Force -PassThru; Start-Service MSCRMVssWriterService -PassThru}
     }else{
     $VSSname = $VSSOutput[$objCount].Matches.value -replace 'Writer name:',''
     $OK = $VSSOutput[$objCount+1].Matches.value -replace 'State: \[[0-9]\]',''
      "$VSSname service is $OK"
     }
      $objCount+= 2
} Until ($objCount -eq $totalCount)

log "########################################################################"

log "########Make sure below that all VSS writers are now in a STABLE state###########"
$VssWriters2 = Invoke-Command -ScriptBlock {Vssadmin list writers}
$VSSOutput2 = $VssWriters2 | Select-String  -Pattern 'Writer name:*.*','State:*.*'
$VSSOutput2

log "########################################################################


Write-Host "#############Checking the event log for any VSS warnings or errors###########"
$logs = Get-EventLog -LogName Application -Source VSS | ? {($_.EntryType -eq "Warning") -or ($_.EntryType -eq "Error")} | select -first 20
$num = 1
foreach ($log in $logs){
Write-Host "############# Processing log $($num) #################"
$log
$num++
}