# Disabled users profile cleanup
# Created: 14/06/2020
# Version: 1.0

# Set up variables
$staffProfiles = "C:\staffprofiles\"
$csv = "C:\profiles\disabledusers.csv"
$log = "C:\profiles\profile_cleanup.log"

# Import CSV 
Import-Csv $csv | ForEach-Object {
    $path = -join ($staffProfiles, $_.SAMAccountName)
    Add-Content -Path $log -Value ("$path has been deleted")
    Remove-Item -Path $path -ErrorAction SilentlyContinue
}

Exit