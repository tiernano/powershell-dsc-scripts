Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
install-module 'AuditPolicyDsc','SecurityPolicyDsc','NetworkingDsc','xPSDesiredStateConfiguration','xNetworking','xWebAdministration','IISAdministration','cChoco' -force
