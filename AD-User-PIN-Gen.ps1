<#
- Random PIN Generator in Active Directory
- Revision: 1.0

Looks through extensionAttribute1 and assigns a PIN (if not in use).
#>

#Imports ActiveDirectory modules
import-module activedirectory

$date = Get-Date -format "ddMMyy"
$time = Get-Date -format "HHmm"
$datetime = $date, $time -join "_"
$exportcol = @()

# OU Array - Add OUs here if you want to scan more areas of AD
$OUs =
    "OU=Test,DC=Yourdomain,DC=local"

foreach ($ou in $OUs)
{
# Create array of all users from that OU (and sub OUs)
$users = get-aduser -filter * -SearchBase $ou -Properties extensionAttribute1

foreach ($user in $users)
{
    # Checks if user is disabled
    if([string]$user.properties.useraccountcontrol -band 2)
    {
    }
    else
    {
        # Checks if they have an empty PIN field
	    if ($user.extensionAttribute1 -eq $null)
	    {
            $freePIN = $false
		    while ($freePIN -eq $false)
		    {
                # Creates a random, unique PIN each time
                $r1 = Get-Random -minimum 0 -maximum 9
			    $r2 = Get-Random -minimum 0 -maximum 9
			    $r3 = Get-Random -minimum 0 -maximum 9
			    $r4 = Get-Random -minimum 0 -maximum 9
			    $PIN = $r1, $r2, $r3, $r4 -join ""

                # Checks unique PIN against everyone in AD
                $userPIN = Get-ADUser -Filter {extensionAttribute1 -eq $PIN}
                if ($userPIN -eq $null)
                {
                    # If unique, it will set this variable to quit the 'while' loop
                    $freePIN = $true
                }

		    }

		    if ($freePIN -eq $true)
		    {
                # Sets some variables for exporting to CSV
                # Applies unique PIN to user's account
                $username = $user.samaccountname
			    $user.extensionAttribute1 = $PIN
			    Set-ADUser -instance $user

                # Creates the export object
                # Adds the members
                $export = New-Object PSObject
                Add-Member -InputObject $export -MemberType NoteProperty -Name Username -Value ""
                Add-Member -InputObject $export -MemberType NoteProperty -Name PIN -Value ""

                # Takes the username and PIN, adds to the object
                $export.Username = $username
                $export.PIN = $PIN

                # Adds object to collection
                $exportcol += $export


		    }

	    }
    }
}
}

$exportcol | Export-CSV -Path \\location\PINs_$datetime.csv -NoTypeInformation
$exportcol
