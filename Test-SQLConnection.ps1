<#
.SYNOPSIS
Exported function. Tests a the connection to a single instance and shows the output.

.EXAMPLE
Test-SqlConnection sql01

Sample output:

Local PowerShell Enviornment

Windows : 10.0.10240.0
PowerShell : 5.0.10240.16384
CLR : 4.0.30319.42000
SMO : 13.0.0.0
DomainUser : True
RunAsAdmin : False

SQL Server Connection Information

ServerName : sql01
BaseName : sql01
InstanceName : (Default)
AuthType : Windows Authentication (Trusted)
ConnectingAsUser : ad\dba
ConnectSuccess : True
SqlServerVersion : 12.0.2370
AddlConnectInfo : N/A
RemoteServer : True
IPAddress : 10.0.1.4
NetBIOSname : SQLSERVER2014A
RemotingAccessible : True
Pingable : True
DefaultSQLPortOpen : True
RemotingPortOpen : True
#>    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("ServerInstance", "SqlInstance")]
        [object]$SqlServer,
        [System.Management.Automation.PSCredential]$SqlCredential
    )
    
    import-module sqlps
    $datetime = (Get-Date).ToString('dd/MM/yyyy hh:mm:ss tt')
    Write-Output "Test initiated at $datetime" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8
    
    # Get local enviornment
    Write-Output "Getting local enivornment information" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    $localinfo = @{ } | Select-Object Windows, PowerShell, CLR, SMO, DomainUser, RunAsAdmin
    $localinfo.Windows = [environment]::OSVersion.Version.ToString()
    $localinfo.PowerShell = $PSVersionTable.PSversion.ToString()
    $localinfo.CLR = $PSVersionTable.CLRVersion.ToString()
    $smo = (([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.Fullname -like "Microsoft.SqlServer.SMO,*" }).FullName -Split ", ")[1]
    $localinfo.SMO = $smo.TrimStart("Version=")
    $localinfo.DomainUser = $env:computername -ne $env:USERDOMAIN
    $localinfo.RunAsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    # SQL Server
    if ($SqlServer.GetType() -eq [Microsoft.SqlServer.Management.Smo.Server]) { $SqlServer = $SqlServer.Name.ToString() }
    
    $serverinfo = @{ } | Select-Object ServerName, BaseName, InstanceName, AuthType, ConnectingAsUser, ConnectSuccess, SqlServerVersion, AddlConnectInfo, RemoteServer, IPAddress, NetBIOSname, RemotingAccessible, Pingable, DefaultSQLPortOpen, RemotingPortOpen
    
    $serverinfo.ServerName = $sqlserver
    
    Write-Output "Determining SQL Server base address" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    $baseaddress = $sqlserver.Split("\")[0]
    try { $instance = $sqlserver.Split("\")[1] }
    catch { $instance = "(Default)" }
    if ($instance -eq $null) { $instance = "(Default)" }
    
    if ($baseaddress -eq "." -or $baseaddress -eq $env:COMPUTERNAME)
    {
        $ipaddr = "."
        $hostname = $env:COMPUTERNAME
        $baseaddress = $env:COMPUTERNAME
    }
    
    $serverinfo.BaseName = $baseaddress
    $remote = $baseaddress -ne $env:COMPUTERNAME
    $serverinfo.InstanceName = $instance
    $serverinfo.RemoteServer = $remote
    
    Write-Output "Resolving IP address" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    try
    {
        $hostentry = [System.Net.Dns]::GetHostEntry($baseaddress)
        $ipaddr = ($hostentry.AddressList | Where-Object { $_ -notlike '169.*' } | Select-Object -First 1).IPAddressToString
    }
    catch { $ipaddr = "Unable to resolve" }
    
    $serverinfo.IPAddress = $ipaddr
    
    Write-Output "Resolving NetBIOS name" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    try
    {
        $hostname = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $ipaddr -ErrorAction SilentlyContinue).PSComputerName
        if ($hostname -eq $null) { $hostname = (nbtstat -A $ipaddr | Where-Object { $_ -match '\<00\> UNIQUE' } | ForEach-Object { $_.SubString(4, 14) }).Trim() }
    }
    catch { $hostname = "Unknown" }
    
    $serverinfo.NetBIOSname = $hostname
    
    
    if ($remote -eq $true)
    {
        # Test for WinRM #Test-WinRM neh
        Write-Output "Checking remote acccess" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
        winrm id -r:$hostname 2>$null | Out-Null
        if ($LastExitCode -eq 0) { $remoting = $true }
        else { $remoting = $false }
        
        $serverinfo.RemotingAccessible = $remoting
        
        Write-Output "Testing raw socket connection to PowerShell remoting port" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
        $tcp = New-Object System.Net.Sockets.TcpClient
        try
        {
            $tcp.Connect($baseaddress, 135)
            $tcp.Close()
            $tcp.Dispose()
            $remotingport = $true
        }
        catch { $remotingport = $false }
        
        $serverinfo.RemotingPortOpen = $remotingport
    }
    
    # Test Connection first using Test-Connection which requires ICMP access then failback to tcp if pings are blocked
    Write-Output "Testing ping to $baseaddress" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    $testconnect = Test-Connection -ComputerName $baseaddress -Count 1 -Quiet
    
    $serverinfo.Pingable = $testconnect
    
    # SQL Server connection
    
    if ($instance -eq "(Default)")
    {
        Write-Output "Testing raw socket connection to default SQL port" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
        $tcp = New-Object System.Net.Sockets.TcpClient
        try
        {
            $tcp.Connect($baseaddress, 1433)
            $tcp.Close()
            $tcp.Dispose()
            $sqlport = $true
        }
        catch { $sqlport = $false }
        $serverinfo.DefaultSQLPortOpen = $sqlport
    }
    else { $serverinfo.DefaultSQLPortOpen = "N/A" }
    
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $SqlServer
    
    try
    {
        if ($SqlCredential -ne $null)
        {
            $username = ($SqlCredential.username).TrimStart("\")

            if ($username -like "*\*")
            {
                $username = $username.Split("\")[1]
                $authtype = "Windows Authentication with Credential"
                $server.ConnectionContext.LoginSecure = $true
                $server.ConnectionContext.ConnectAsUser = $true
                $server.ConnectionContext.ConnectAsUserName = $username
                $server.ConnectionContext.ConnectAsUserPassword = ($SqlCredential).GetNetworkCredential().Password
            }
            else
            {
                $authtype = "SQL Authentication"
                $server.ConnectionContext.LoginSecure = $false
                $server.ConnectionContext.set_Login($username)
                $server.ConnectionContext.set_SecurePassword($SqlCredential.Password)
            }
        }
        else
        {
            $authtype = "Windows Authentication (Trusted)"
            $username = "$env:USERDOMAIN\$env:username"
        }
    }
    catch
    {
        Write-Exception $_
        $authtype = "Windows Authentication (Trusted)"
        $username = "$env:USERDOMAIN\$env:username"
    }
    
    $serverinfo.ConnectingAsUser = $username
    $serverinfo.AuthType = $authtype
    
    
    Write-Output "Attempting to connect to $SqlServer as $username " | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    try
    {
        $server.ConnectionContext.ConnectTimeout = 10
        $server.ConnectionContext.Connect()
        $connectSuccess = $true
        $version = $server.Version.ToString()
        $addlinfo = "N/A"
        $server.ConnectionContext.Disconnect()
    }
    catch
    {
        $connectSuccess = $false
        $version = "N/A"
        $addlinfo = $_.Exception
    }
    
    $serverinfo.ConnectSuccess = $connectSuccess
    $serverinfo.SqlServerVersion = $version
    $serverinfo.AddlConnectInfo = $addlinfo
    
    Write-Output "`nLocal PowerShell Enviornment" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    $localinfo | Select-Object Windows, PowerShell, CLR, SMO, DomainUser, RunAsAdmin | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8
    
    Write-Output "SQL Server Connection Information`n" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    $serverinfo | Select-Object ServerName, BaseName, InstanceName, AuthType, ConnectingAsUser, ConnectSuccess, SqlServerVersion, AddlConnectInfo, RemoteServer, IPAddress, NetBIOSname, RemotingAccessible, Pingable, DefaultSQLPortOpen, RemotingPortOpen | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8
    
    Write-Output "----------------------------------------------------" | Out-File -FilePath C:\Support\sqltest.txt -Append -Encoding utf8 
    