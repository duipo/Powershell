# This script requires a connection to Azure online and Az Commands.

# Connect to Azure using Global admin credentials.
Connect-AzAccount

# Specify the output path of the generated report.
$FilePath = Read-Host "Please specify a path for the generated report"

# Get Azure Network interfaces and their properties, then export to CSV.

Get-AzNetworkInterface | Select Name, ResourceGroupName, Location,`
 @{Name="VMName";Expression = {$_.VirtualMachine.Id.tostring().substring($_.VirtualMachine.Id.tostring().lastindexof('/')+1)}},`
 @{Name="NSG";Expression = {$_.NetworkSecurityGroup.Id.tostring().substring($_.NetworkSecurityGroup.Id.tostring().lastindexof('/')+1)}},`
 @{Name="SubnetName";Expression = {$_.IpConfigurations.subnet.id.tostring().substring($_.IpConfigurations.subnet.id.tostring().lastindexof('/')+1)}}`
 | Export-Csv "$FilePath\NICs Properties.csv"