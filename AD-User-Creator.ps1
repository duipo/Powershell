<#
- AD User Creation Tool
- Revision: 1.0

Active Directory script to create users in Active Directory.
This was used for an ex-customer, but can be tweaked as required.
#>

#import-module Microsoft.Exchange.Management.PowerShell.E2010
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionURI http://v-herr-mail/powershell -Authentication kerberos
import-PSSession $session
import-module activedirectory

""
"PowerShell User Creation"
""
"Please enter user details as follows"
$firstName = Read-Host "First Name"
$lastName = Read-Host "Last Name"
$name = $firstName + " " + $lastName
$username = $firstName + "." + $lastName
""

$menu1 = 0
while($menu1 -eq 0)
{
    "Select site"
    "1. Camberley"
    "2. Wokingham"

    $siteC = Read-Host "Site"

    switch($siteC)
    {
        1 {"You have selected Camberley"; $tel = "01276 85"; $office = "Camberley Office";
        $officePhone = "01276 686222"; $site = "Camberley"; $mbd = "Camberley Users"; $street = "Building 9, Riverside Way, Watchmoor Park";
        $city = "Camberley"; $postco = "GU15 3YL"; $state = "Surrey";
        $ou = "OU=Camberley,OU=Users,OU=Herrington & Carmichael,DC=hc,DC=local"; $menu1++}
        2 {"You have selected Wokingham"; $tel = "0118 989"; $office = "Wokingham Office";
        $officePhone = "0118 977 4045"; $site = "Wokingham"; $mbd = "Wokingham Users"; $street = "27 Broad Street";
        $city = "Wokingham"; $postco = "RG40 1AU"; $state = "Berkshire";
        $ou = "OU=Wokingham,OU=Users,OU=Herrington & Carmichael,DC=hc,DC=local"; $menu1++}
        default {"Please enter 1 or 2"; $menu1 = 0}
    }
    ""
}

$dept = Read-Host "Department"
$title = Read-Host "Job Title"
""

#$menu2 = 0
#while($menu2 -eq 0)
#{
#}

$ext = Read-Host "Extension"
""
$menu3 = 0
while($menu3 -eq 0)
{
    "Would you like to copy groups from a user?"
    $copyC = Read-Host "Y or N"

    switch($copyC)
    {
        "Y"
        {
            "User to copy from"
            $copyuser = Read-Host "Username"
            $copyY = $true

            $copyuserCheck = Get-ADUser -Filter {sAMAccountName -eq $copyuser}
            If(!$copyuserCheck)
            {
                "Username does not exist, please try again"
            }else{
                $copyuserAD = Get-ADUser -Identity $copyuser -Properties MemberOf
                $menu3++
            }
        }
        "N" {$copyY = $false; $menu3++}
    }
}
""
$pass = Read-Host "Password"
""
""
"You have selected the following information..."
""
"First Name: " + $firstName
"Last Name: " + $lastName
"Username: " + $username
"Location: " + $site
"Department: " + $dept
"Title: " + $title
If($time = $true)
{
    "Time Record: Yes"
    }else{
    "Time Record: No"
}
$hometel = $tel + " " + $ext
"Extension: " + $hometel
"Copy from: " + $copyuserAD.displayName
"Password: " + $pass
""

$menu4 = 0
while($menu4 -eq 0)
{
    "Would you like to proceed?"

    $confC = Read-Host "Y or N"

    switch($confC)
    {
        "Y" {"Yes, please continue and create this user"; $conf = $true; $menu4++}
        "N" {"No, I'd like to make some changes"; $conf = $false; $menu4++}
        default {"Please enter Y or N"; menu2 = 0}
    }
    ""
}
"User creation will now start, please wait"
$pass_ss = ConvertTo-SecureString -String $pass -AsPlainText -Force
$userPN = $username + "@hc.local"
""
New-ADUser -Name $name -DisplayName $name -GivenName $firstName -Surname $lastName -UserPrincipalName $userPN -AccountPassword $pass_ss -Enabled $true -SAMAccountName $username -CannotChangePassword $false -ChangePasswordAtLogon $false -Path $ou -HomePhone $hometel -Department $dept -Title $title -Office $office -OfficePhone $officePhone -Company "Herrington Carmichael LLP" -StreetAddress $street -City $city -PostalCode $postco -State $state -Country GB
""
"New user has been created"
""
"Mailbox now being created"
$mailcreated = 0
while($mailcreated -eq 0)
{
    $mailbox = $username + "@herrington-carmichael.com"
    ""
    Enable-Mailbox $username -Database $mbd
    $exist = [bool](Get-Mailbox $username -erroraction SilentlyContinue)
    If($exist -eq $true)
    {
        $mailcreated = 1
    }else{
    }
}
"Mailbox created successfully in database: " + $mbd
$newuser = Get-ADUser -Identity $username
If($copyY -eq $true)
{
    "Copying group membership..."
    $copyuserAD.MemberOf | Where{$newuser.MemberOf -notcontains $_} | Add-ADGroupMember -Member $newuser
}else{
    Add-ADGroupMember -Identity AllStaffReview -Member $newuser
}
""
"Press any key to continue..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Exit
