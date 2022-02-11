param (
    [Parameter(Mandatory=$true)][string]$key
)

$exe = "C:\Source\Endpoint.exe"
Invoke-WebRequest -Uri https://eu.fileprotection.datto.com/update/aeb/DattoFileProtectionSetup_v8.0.0.274.exe -OutFile $exe

& $exe /install /quiet TeamKey=$key
Exit