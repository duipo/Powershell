<#
- ProxyAddress Updater
- Revision: 1.0

Finds the user and adds the required addresses based on array.
#>


# Imports Active Directory module
import-module activedirectory

# Creates domain array
$domains = @("@boatingbusiness.co.uk","@boatingbusiness.com","@engineeringcapacity.com","@greenport.com","@maritimejournal.com","@mercator.local","@motorship.com","@portstrategy.com","@seawork.com","@seaworkasia.com","@worldfishing.net")
$smtp = "smtp:"

# Keeps script running
$running = $True
while ($running -eq $True)
{

    # Menu for operations
    $menu1 = $True
    while ($menu1 -eq $True)
    {
        ""
        "== Menu =="
        "1. New user"
        "2. Move addresses"
        "3. Quit"
        $option = Read-Host -Prompt "Enter selection"
        If ($option)
        {
            Switch ($option)
            {
                1 {$menu1 = $False; break}
                2 {$menu1 = $False; break}
                3 {$menu1 = $False; $running = $False; break}
                Default
                {
                    ""
                    "Invalid input"; break
                }
            }
        }
    }

    Switch ($option)
    {
        1
        {
            $menu2 = $True
            While ($menu2 -eq $True)
            {
                $user = Read-Host -Prompt 'Input username'
                $aduser = get-aduser -filter {sAMAccountName -eq $user}
                If ($aduser -eq $Null)
                {
                    Write-Host "User does not exist"
                }
                Else
                {
                    Write-Host "You selected $user"

                    ForEach ($domain in $domains) {
                        $address = $smtp, $user, $domain -join ""
                        $aduser.ProxyAddresses.add($address)
                        Write-Host $address
                    }

                    $address2 = "SMTP:", $user, "@mercatormedia.com" -join ""
                    $aduser.ProxyAddresses.add($address2)
                    Write-Host $address2

                    Write-Host "Writing addresses to user"
                    Set-ADUser -Instance $aduser
                    Write-Host "Completed, please check ADSI"

                    $menu2 = $False
                }
            }
        }

        2
        {
            $menu2 = $True
            While ($menu2 -eq $True)
            {
                $old = $True
                While ($old -eq $True)
                {
                    $oldobj = Read-Host -Prompt 'Old username/group'
                    $oldaduser = Get-ADUser -Filter {sAMAccountName -eq $oldobj} -Properties ProxyAddresses
                    If ($oldaduser -eq $Null)
                    {
                        $oldadgroup = Get-ADGroup -Filter {sAMAccountName -eq $oldobj} -Properties ProxyAddresses
                        If ($oldadgroup -eq $Null)
                        {
                            Write-Host "User or group does not exist"
                        }
                        Else
                        {
                            Write-Host "You selected $oldobj"
                            $proxyold = $oldadgroup.ProxyAddresses
                            $isoldgroup = $True
                            $old = $False
                        }
                    }
                    Else
                    {
                        Write-Host "You selected $oldobj"
                        $proxyold = $oldaduser.ProxyAddresses
                        $isoldgroup = $False
                        $old = $False
                    }
                }

                $new = $True
                While ($new -eq $True)
                {
                    $newobj = Read-Host -Prompt 'New username/group'
                    $newaduser = Get-ADUser -Filter {sAMAccountName -eq $newobj} -Properties ProxyAddresses
                    If ($newaduser -eq $Null)
                    {
                        $newadgroup = Get-ADGroup -Filter {sAMAccountName -eq $newobj} -Properties ProxyAddresses
                        If ($newadgroup -eq $Null)
                        {
                            Write-Host "User or group does not exist"
                        }
                        Else
                        {
                            Write-Host "You selected $newobj"
                            $newadobj = $newadgroup
                            $isnewgroup = $True
                            $new = $False
                        }
                    }
                    Else
                    {
                        Write-Host "You selected $newobj"
                        $newadobj = $newaduser
                        $isgroup = $False
                        $new = $False
                    }
                }
                ForEach ($address in $proxyold)
                {
                    $main = $address.Contains("SMTP")
                    If ($main -eq $True)
                    {
                        $1 = $address.Substring(5)
                        $newaddress = $smtp, $1 -join ""
                        $newadobj.ProxyAddresses.add($newaddress)
                    }
                    Else
                    {
                        $newadobj.ProxyAddresses.add($address)
                    }
                }
                If ($isnewgroup -eq $True)
                {
                    Set-ADGroup -Instance $newadobj
                }
                Else
                {
                    Set-ADUser -Instance $newadobj
                }
                If ($isoldgroup -eq $True)
                {
                    Set-ADGroup $oldadgroup -Clear ProxyAddresses
                    Set-ADGroup -Instance $oldadgroup
                }
                Else
                {
                    Set-ADUser $oldaduser -Clear ProxyAddresses
                    Set-ADUser -Instance $oldaduser
                }
                Write-Host "Proxy addresses moved from $oldobj to $newobj"
                $menu2 = $False
            }
        }
    }
}
