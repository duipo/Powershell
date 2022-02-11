######### Secrets/Variables #########
$ApplicationId = '2f73e4cd-e344-40a8-8e4f-c5b6f840aa69'
$ApplicationSecret = 'PMEvk4sDfhj7NzAniViISWnM6RzT+b05GcSBeyTWBuE=' | ConvertTo-SecureString -Force -AsPlainText
$TenantID = '68c4d87a-ce14-435f-add3-e9a6bc3b00e5'
$RefreshToken = '0.ATsAetjEaBTOX0Ot0-mmvDsA5c3kcy9E46hAjk_FtvhAqmk7ACo.AgABAAAAAAD--DLA3VO7QrddgJg7WevrAgDs_wQA9P_dhokLNI9ZstfRC45kLSkFbCfMg3Z68L3tH31-UPVGcqvXJ1sYB2G2DOGgK96MonEmzjle5IRKcQGpXEF7iVxyzdOrmnZDkRwvgv4LDqWjcnPeLqOtJRlMSIxErRWXd-HqspWmm_SsRag6fFKsC_JOk1O45F7u6bFvTxD-8lzEnS2wu7cKGRZWDQOEFvxvpuY4eAH7VdMuhkEmkkH2xS14GsUgbQnoqojJ1ttHhs15d_QzfHIYVBSlEsvQNoYVlPXzLdjhHOCwUcY-WwN8q_FYrz6F1QjW8OXkA3Xr80iH4S5OIMYPQskvJZBZy-DggIuSXJjYCV0_IjZ_jcqvd2xundiA_fwk9awTCEMqqSqRc1u0beX8-qCyOf2mMnT8MNv18TClDVB2EqaL-FtOmXbzOVO88x5Ky-RoihI09Gjbs0_jdj9_7u8QFD0TkDSN-81CEE1mn6cIYk1auxE1e-GIqpIS94m-PSOrmlbRXZKsh1ETGkVULmrvW7CPuHktvBeRe4MR5Sbm5HYRbE6XZGgOe6swzL5j2TrjwEATzNEgJGILBpwvbn-esidi91VVB3a6On78O_AcwSVLzKYIWIWO9NNMlYjaygbJQDsaQWKGdH5pOFrVswnWEp9xAGoz-DRZGhnT4FUbj7TLqEVFr_Au9rwHSfjjEnnh0yq2DRLWPn2-28EG76rkChq0VMwzlOTwB_sud4CwnUD73XQaiQCyLTy1k-AV2qpFK89wnoXTyBP59wiqoVVXG-FDfsqdNONJ-tbr0Ux0c19dBd5tE3PU1M5gmDaQSsbyYU7_Bux5forquIWWMCqEXKmFnB7otCmrZDAfE1cTef6Q9p83Jqy2fuT8HBpflS7CwvPWXh2aLObvWVlMnu_vo9SgI_KsXUaE9SIpvwo9qN3xkkE0B9pJEklzVp-DJi43Q0qP3u5x8kesP_oG0ua-eTpUdfL9m6gMS5GI2-mjVT1BvZwfWZlfOvpt3NG446uOjdN9b7Kuafw8kvU9y-Z4jfkhmmYOD4xOdye_pUshzUBn2DRC-oeubfoqNLsH00soeCmbRzdQ6-cQnfTzWyxnkIGh34cnI1x8XgafeSqTLXIyFkuF7wt7amCPg0hhhDrMBJh8de6TMj7lqyU7YcVIA2oY9eW5TMxVa4yZ8LP7-Dk'
$UPN = "matrix.admin@kingswood-group.com"
$MinimumFreeGB = '50'
$SubscriptionID = '05bf03b1-bbfe-481c-872d-6537536c80a1'
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