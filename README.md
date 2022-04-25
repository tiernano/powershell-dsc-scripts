# powershell-dsc-scripts

Random PowerShell DSC Scripts for building Windows Servers

You will need to run base setup first then the IIS config you want...

# Base Install

## Server 2019:

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/base_setup_2019.ps1'))`

## Server 2022:

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/base_setup_2019.ps1'))`

# .NET 4.8 and IIS install
`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/IIS_NET48.ps1'))`



# .NET CORE and IIS install
`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/IIS_NETCORE.ps1'))`

# Whats the scripts do?

## Base Install (2022 or 2019)

 VM baseline policies for CSBP. Fixes a LOT of issues with the security center in Azure. View the code to see what is in there. Also, installs [Chocolatey](https://chocolatey.org) on the box, along with the required Powershell and DSC modules for the DSC Scripts:

* AuditPolicyDsc
* SecurityPolicyDsc
* NetworkingDsc
* xPSDesiredStateConfiguration
* xNetworking
* xWebAdministrationIISAdministration
* cChoco

Also removes the Server Manager Scheduled task that opens Server Manager on each login...

## .NET Core

Installs IIS and managment tools, along with ASP.NET. Also opens ports 80 and 443 on the local Windows Firewall (80 on TCP, 443 on both TCP and UDP to allow HTTP2.0). Also installs the [.NET Core Hosting Bundle](https://community.chocolatey.org/packages?q=dotnet-windowshosting).

## .NET 4.8

Same as above, but instead of .NET Core, it installs [.NET 4.8](https://community.chocolatey.org/packages/netfx-4.8). 

# Thanks

* Thanks to [Chocolatey](https://chocolatey.org) for making their package manager, and the script above to download and run a powershell script in one go!
* Thanks to [Cloudneeti](https://cloudneeti.github.io/Cloudneeti_SaaS_Docs/remediation/osBaseline/win19QuickWins/) Who built the original CSBP script. 