<#
- NIC Reset
- Revision: 1.0

If ping fails, the NIC is reset.
#>

$pingtest = test-connection 192.168.0.1 -count 1 -quiet

if(!$pingtest)
{
  $nic = gwmi win32_networkadapter -filter "NetConnectionID='Ethernet'"
  $nic.disable()
  sleep 5
  $nic.enable()
}
Exit
