<#
- Remove RD Client Profile
- Revision: 1.0

Used for removing exiting profiles within remote desktop app.
#>

If(Test-Path -Path $env:localappdata\rdclientwpf)
{
  Remove-Item -Path $env:localappdata\rdclientwpf -Recurse
}
Else
{
  Exit
}
