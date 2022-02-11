[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 
Connect-MsolService
 
$headers = @{
    "User-Agent"  = "$((Get-MsolCompanyInformation).DisplayName) Customer Account Check"
    "api-version" = 2
}
$baseUri = "https://haveibeenpwned.com/api"
$customers = Get-MsolPartnerContract -All
 
foreach ($customer in $customers) {
    $users = Get-msoluser -TenantId $customer.TenantId -All
 
    foreach ($user in $users) {
        $emails = $user.proxyaddresses | Where-Object {$_ -match "smtp:" -and $_ -notmatch ".onmicrosoft.com"}
        $emails | ForEach-Object {
            $email = ($_ -split ":")[1]
            $uriEncodeEmail = [uri]::EscapeDataString($email)
            $uri = "$baseUri/breachedaccount/$uriEncodeEmail"
            $breachResult = $null
            try {
                [array]$breachResult = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction SilentlyContinue
            }
            catch {
                if ($error[0].Exception.response.StatusCode -match "NotFound") {
                    Write-Host "No Breach detected for $email" -ForegroundColor Green
                }
                else {
                    Write-Host "Cannot retrieve results due to rate limiting or suspect IP. You may need to try a different computer"
                }
            }
            if ($breachResult) {
                foreach ($breach in $breachResult) {
 
                    $breachObject = [ordered]@{
                        CustomerName       = $customer.Name
                        TenantId           = $customer.TenantId
                        Email              = $email
                        UserPrincipalName  = $user.UserPrincipalName
                        LastPasswordChange = $user.LastPasswordChangeTimestamp
                        BreachName         = $breach.Name
                        BreachTitle        = $breach.Title
                        BreachDate         = $breach.BreachDate
                        BreachAdded        = $breach.AddedDate
                        BreachDescription  = $breach.Description
                        BreachDataClasses  = ($breach.dataclasses -join ", ")
                        IsVerified         = $breach.IsVerified
                        IsFabricated       = $breach.IsFabricated
                        IsActive           = $breach.IsActive
                        IsRetired          = $breach.IsRetired
                        IsSpamList         = $breach.IsSpamList
                    }
                    $breachObject = New-Object PSobject -Property $breachObject
                    $breachObject | Export-csv C:\temp\BreachedAccounts.csv -NoTypeInformation -Append
                    Write-Host "Breach detected for $email - $($breach.name)" -ForegroundColor Yellow
                    Write-Host $breach.description -ForegroundColor DarkYellow
                }
            }
            Start-sleep -Milliseconds 2000
        }
    }
}