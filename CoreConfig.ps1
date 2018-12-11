# This is an example of a firewall build for securing a Server

# This is where we open the GPO we're going to be adding the firewall rules into
$gposession = Open-NetGPO -PolicyStore contoso.com\DNSfirewall

# Here is where we declare the IPs for the management servers or jump servers to connect to the DNS server.
$managementIPs = [IPADDRESS] "192.168.178.150","192.168.178.254","192.168.178.8","192.168.178.9"

# Here we declare a list of other DNS servers
$dnsIPs = [IPADDRESS] "192.168.178.1","192.168.178.8","192.168.178.9"

# Here we make a variable that combines both items
$manANDdnsIPs = $managementIPs + $dnsIPs

# Turn on all profiles and allow outbound
Set-NetFirewallProfile -All -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow -AllowLocalFirewallRules False -LogMaxSizeKilobytes 32767 -LogAllowed True -LogBlocked True -AllowLocalIPsecRules False -GPOSession $gposession 

# Core IP services
New-NetFirewallRule -DisplayName "Core-IPv6-ICMP" -GPOSession $gposession -Protocol 58 -IcmpType 2 -Program System
New-NetFirewallRule -DisplayName "Core-ICMPv4-Destination Unreachable Fragmentation Needed" -GPOSession $gposession -Protocol 1 -IcmpType 3 -Program System
New-NetFirewallRule -DisplayName "Core-DHCP-In" -GPOSession $gposession -Protocol 17 -LocalPort 68 -RemotePort 67 -Service DHCP -Program %SystemRoot%\system32\svchost.exe
New-NetFirewallRule -DisplayName "Core-DHCPv6-In" -GPOSession $gposession -Protocol 17 -LocalPort 546 -RemotePort 547 -Service DHCP -Program %SystemRoot%\system32\svchost.exe
New-NetFirewallRule -DisplayName "Core-ICMPv6-PacketTooBig" -GPOSession $gposession -Protocol 58 -IcmpType 2 
New-NetFirewallRule -DisplayName "Core-ICMPv6-ParameterProblem" -GPOSession $gposession -Protocol 58 -IcmpType 4 -Program System
New-NetFirewallRule -DisplayName "Core-ICMPv6-RouterAdvertisement" -GPOSession $gposession -Protocol 58 -IcmpType 134 -Program System
New-NetFirewallRule -DisplayName "Core-ICMPv6-RouterSolicitation" -GPOSession $gposession -Protocol 58 -IcmpType 133 -Program System
New-NetFirewallRule -DisplayName "Core-ICMPv6-TimeExceeded" -GPOSession $gposession -Protocol 58 -IcmpType 3 -Program System

# Standard Windows Control Ports and Services
New-NetFirewallRule -DisplayName "RemoteDesktopTCP" -GPOSession $gposession -LocalPort 3389 -Protocol TCP -Name "Remote Desktop TCP" | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "RemoteDesktopUDP" -GPOSession $gposession -LocalPort 3389 -Protocol UDP -Name "Remote Desktop UDP" | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "RemoteEventLogMgmt" -GPOSession $gposession -LocalPort 445 -Protocol TCP -Program System -Name "Remote Event Log Management" | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "RemoteEventLogMgmtRPC" -GPOSession $gposession -LocalPort RPC -Protocol TCP -Service Eventlog -Program %SystemRoot%\system32\svchost.exe -Name "Remote Event Log Management RPC" | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "RemoteEventLogMgmtRPCepmap" -GPOSession $gposession -LocalPort RPCepmap -Protocol TCP -Service RPCSS -Program %SystemRoot%\system32\svchost.exe -Name "Remote Event Log Management RPCEPmap" | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "WMI"  -GPOSession $gposession -Protocol TCP -Name "Windows Management Instrumentation" -Program %systemroot%\system32\wbem\unsecapp.exe | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "WMIDCOM" -GPOSession $gposession -LocalPort 135 -Protocol TCP -Name "Windows Remote Management DCOM" -Service RPCSS -Program %SystemRoot%\system32\svchost.exe | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "WMIin" -GPOSession $gposession -Protocol TCP -Name "Windows Remote Management In" -Service winmgmt -Program %SystemRoot%\system32\svchost.exe | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "WinRMHTTP" -GPOSession $gposession -LocalPort 5985 -Protocol TCP -Program System  | Set-NetFirewallRule -RemoteAddress $managementIPs
New-NetFirewallRule -DisplayName "WinRMHTTPS" -GPOSession $gposession -LocalPort 5986 -Protocol TCP -Program System  | Set-NetFirewallRule -RemoteAddress $managementIPs



Save-NetGPO -GPOSession $gposession
