# powershell-dsc-scripts

Random PowerShell DSC Scripts for building Windows Servers

# Base Install

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/base_setup.ps1'))

# .NET 4.8 and IIS install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/IIS_NET48.ps1'))

More coming soon...
