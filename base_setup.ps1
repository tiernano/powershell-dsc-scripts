Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
install-module 'AuditPolicyDsc','SecurityPolicyDsc','NetworkingDsc','xPSDesiredStateConfiguration','xNetworking','xWebAdministration',IISAdministration -force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/CSBP_WinServer2019.ps1'))
CSBP_WindowsServer2019
Start-DscConfiguration -Path .\CSBP_WindowsServer2019  -Force -Verbose -Wait
