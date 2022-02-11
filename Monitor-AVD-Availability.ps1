######### Secrets/Variables #########
$ApplicationId = 
$ApplicationSecret = | ConvertTo-SecureString -Force -AsPlainText
$TenantID =
$RefreshToken = 
$UPN
$MinimumFreeGB =
$SubscriptionID =
######### Secrets/Variables #########
If (Get-Module -ListAvailable -Name Az.DesktopVirtualization) { 
    Import-module Az.DesktopVirtualization
}
Else { 
    Install-PackageProvider NuGet -Force
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module -Name Az.DesktopVirtualization -force
}
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$azureToken = New-PartnerAccessToken -ApplicationId $ApplicationID -Credential $credential -RefreshToken $refreshToken -Scopes 'https://management.azure.com/user_impersonation' -ServicePrincipal -Tenant $TenantId
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationID -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $TenantId
  
Connect-Azaccount -AccessToken $azureToken.AccessToken -GraphAccessToken $graphToken.AccessToken -AccountId $upn -TenantId $tenantID
Set-AzContext -SubscriptionId $SubscriptionID
$Subscriptions = Get-AzSubscription  | Where-Object { $_.State -eq 'Enabled' } | Sort-Object -Unique -Property Id
$SessionHostState = foreach ($Sub in $Subscriptions) {
    $null = $Sub | Set-AzContext
 
    $WVDHostPools = Get-AzResource -ResourceType 'Microsoft.DesktopVirtualization/hostpools'
    if (!$WVDHostpools) {
        write-host "No hostpool found for tenant $($Sub.name)"
        continue
    }
    write-host "Found hostpools. Checking current availibility status"
    foreach ($HostPool in $WVDHostPools) {
        $AllHPState = get-AzWvdsessionhost -hostpoolname $Hostpool.name -resourcegroupname $hostpool.resourcegroupname 
        Foreach ($State in $AllHPState) {
            [PSCustomObject]@{
                HostName         = $State.Name
                Available        = $State.Status
                Heartbeat        = $State.LastHeartBeat
                UpdateState      = $State.UpdateState
                LastUpdate       = $State.LastUpdateTime
                AllowNewSessions = $State.AllowNewSession
                Subscription     = $Sub.Name
             
            }
        }
    }
 
}
 
#Check for WVD Session hosts that have issues updating the agent:
 
if (($SessionHostState | Where-Object { $_.UpdateState -ne 'Succeeded' })) {
    write-host "Unhealthy - Some session hosts have not updated the Agent correctly."
    $SessionHostState | Where-Object { $_.UpdateState -ne 'Succeeded' }
}
else {
    write-host "Healthy - Session hosts all updated."  
}
 
 
#Check for unavailable hosts
if (($SessionHostState | Where-Object { $_.Available -ne 'Available' })) {
    write-host "Unhealthy - Some session hosts are unavailable."
    $SessionHostState | Where-Object { $_.Available -ne 'Available' }
}
else {
    write-host "Healthy - Session hosts all updated."  
}
 
#Check for hosts in drain mode
if (($SessionHostState | Where-Object { $_.AllowNewSessions -eq $false })) {
    write-host "Unhealthy - Some session hosts are in drain mode"
    $SessionHostState | Where-Object { $_.AllowNewSessions -eq $false }
}
else {
    write-host "Healthy - No sessionhosts in drain mode."  
}
