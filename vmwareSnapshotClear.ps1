# Clear out Snapshots (odd hour)
# Author: Elliot Bath (Tekkers IT Solutions)
# Version: 1.0
# Changelog:
#  07/09/17 - Created script and tested

param ([string]$server)

# Connect to vCenter Server
Import-Module vmware.powercli
Connect-VIServer -Server $server

# Create VM array
$VMs = Get-VM

# Check each VM, remove orphaned snapshots
ForEach($vm in $VMs)
{
    Get-VM $vm | Get-Snapshot | Remove-Snapshot -Confirm:$false
}

Exit