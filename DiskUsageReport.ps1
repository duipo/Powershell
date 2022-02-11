param (
    [string] $drive = '"C:"'
)

# Disk analyser tool
# Author: Elliot Bath
# Version: 1.0

# Variables
$url = "https://antibody-software.com/files/wiztree_3_29_portable.zip"
$file = "C:\Support\wiztree_3_29_portable.zip"
$source = "C:\Support"
$wtfolder = "C:\Support\wiztree"
$wt64 = $wtfolder+"\wiztree64.exe"
$wt = $wtfolder+"\wiztree.exe"
$csv = "C:\Support\disk_report.csv"
$params = $drive + ' /export="C:\source\diskreport.csv" /admin=1 /exportfolders=1 /exportfiles=0 /sortby=1'
$cmdname = "Start-BitsTransfer"
$cmdname2 = "Expand-Archive"


# Downloads WizTree
If(!(Test-Path $source)) {
    New-Item -ItemType Directory -Force -Path $source
}

If(!(Test-Path $wtfolder)) {
    New-Item -ItemType Directory -Force -Path $wtfolder
}

If (Get-Command $cmdname -errorAction SilentlyContinue) {
    Start-BitsTransfer -Source $url -Destination $file
}else{
    (New-Object Net.WebClient).DownloadFile($url, $file)
}


# Expands archive
function Expand-ZIPFile($file, $destination) {
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item)
    }
}

If (Get-Command $cmdname2 -errorAction SilentlyContinue) {
    Expand-Archive -Path $file -DestinationPath $wtfolder
}else{
    Expand-ZIPFile $file -Destination $wtfolder
}

Remove-Item $file


# Runs WizTree with command options
$osarch = ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture)

If ($osarch -eq "64-bit") {
    Start-Process -FilePath $wt64 -ArgumentList $params -Wait
}else{
    Start-Process -FilePath $wt -ArgumentList $params -Wait
}

# Deletes WizTree
Remove-Item $wtfolder -Recurse -Force


# Completion/cleanup/misc