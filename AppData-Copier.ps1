<#
- AppData Copier
- Revision: 1.0

Copies AppData based on hostname and user
#>

# Keeps script running
$running = $True
while ($running -eq $True)
{
  $hostname = Read-Host -Prompt "Enter hostname of PC"
  $username = Get-WmiObject -Class win32_computersystem -ComputerName $hostname | select username | Out-String
  $split = $username.split("\")
  $user = $split[1]
  $user = $user.Trim()
  "User for $hostname is $user"
  ""
  "Copying Horizon AppData"
  $source = "\\$hostname\C$\Users\$user\AppData\Roaming\HorizonIntegrator"
  $dest = "\\V-MERC-DATA\Backup\$user\HorizonIntegrator"
  Copy-Item -Recurse -Path $source -Destination $dest -Verbose -Force
  ""
  ""
  "Copying Google Bookmarks"
  $source = "\\$hostname\C$\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
  $dest = "\\V-MERC-DATA\Backup\$user\Bookmarks"
  Copy-Item -Recurse -Path $source -Destination $dest -Verbose -Force
  ""

  $option = Read-Host -Prompt "Do you want to run again? (Y/N)"
  Switch($option)
  {
    Y {$running = $True; break}
    y {$running = $True; break}
    N {$running = $False; break}
    n {$running = $False; break}
    Default
    {
      ""
      "Invalid input"; break
    }
  }
}
Exit
