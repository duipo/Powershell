

param([string] $subscriptioname, [string] $resourcegroup, [string]$state)
Get-AzureRmSubscription -SubscriptionName $subscriptioname | Select-AzureRmSubscription
Find-AzureRmResource -ResourceGroupNameContains $resourcegroup -ResourceType Microsoft.Logic/workflows | ForEach-Object {Set-AzureRmLogicApp -ResourceGroupName $_.ResourceGroupName -Name $_.Name -State $state -Force}