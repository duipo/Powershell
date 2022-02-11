<#
- PC Install Script
- Revision: 1.0

Work in progress.
#>


# Username check
$user = $env:USERNAME

If($user -ne "Administrator")
{
    Write-Host "Please log on and run as Administrator"
    Write-Host "Script will now exit, please press any key to continue..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit
}

Write-Host "Please enter build administrator credentials"
$buildcreds = Get-Credential

# Map Z drive
New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\V-TEKK-DEPLOY\Media" -Credential $buildcreds

# Check for Source folder
$source = Test-Path C:\Source
If($source -eq $false)
{
    New-Item -ItemType directory -Path C:\Source
    New-Item -ItemType directory -Path C:\Source\Software
}

$menu = 0
while($menu -eq 0)
{
    Write-Host "Main Menu"
    Write-Host "[1] - HP Cleanup (Coming Soon)"
    Write-Host "[2] - Software Installs"

    $sel = Read-Host "Selection"
    Write-Host ""

    switch($sel)
    {
        1 {"You have selected HP Cleanup, this is coming soon"}
        2 {"You have selected Software Installs"
            $menu2 = 0
            while($menu2 -eq 0)
            Write-Host ""
            {
                Write-Host "Installing Adobe Flash"
                $af1 = "Z:\Applications\Adobe\install_flash_player_24_active_x.msi"
                $af2 = "Z:\Applications\Adobe\install_flash_player_24_plugin.msi"
                $af3 = "Z:\Applications\Adobe\install_flash_player_24_ppapi.msi"

                & $af1 /qn
                & $af2 /qn
                & $af3 /qn

                "Installing Adobe Air"
                $aa = "C:\Source\Software\AdobeAIRInstaller.exe"

                "Installing Adobe Reader"
            }
        }
    }
}


Exit
