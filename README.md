# powershell-dsc-scripts

Random PowerShell DSC Scripts for building Windows Servers

You will need to run base setup first then the IIS config you want...

# Base Install

## Server 2019:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/base_setup_2019.ps1'))
```

## Server 2022:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/base_setup_2022.ps1'))
```

## Either Server without the CSBP harding rules:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/base_setup_no_CSBP.ps1'))
```

# .NET 4.8 and IIS install
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/IIS_NET48.ps1'))
```



# .NET CORE and IIS install
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tiernano/powershell-dsc-scripts/main/IIS_NETCORE.ps1'))
```

# Whats the scripts do?

## Base Install (2022 or 2019)

 VM baseline policies for CSBP. Fixes a LOT of issues with the security center in Azure. View the code to see what is in there. Also, installs [Chocolatey](https://chocolatey.org) on the box, along with the required Powershell and DSC modules for the DSC Scripts:

* [AuditPolicyDsc](https://www.powershellgallery.com/packages/AuditPolicyDsc/1.4.0.0)
* [SecurityPolicyDsc](https://www.powershellgallery.com/packages/SecurityPolicyDsc/3.0.0-preview0006)
* [NetworkingDsc](https://www.powershellgallery.com/packages/NetworkingDsc/9.0.0)
* [xPSDesiredStateConfiguration](https://www.powershellgallery.com/packages/xPSDesiredStateConfiguration/9.2.0-preview0007)
* [xNetworking](https://www.powershellgallery.com/packages/xNetworking/5.7.0.0)
* [xWebAdministrationIISAdministration](https://github.com/dsccommunity/WebAdministrationDsc)
* [cChoco](https://www.powershellgallery.com/packages/cChoco/2.5.0.0)

Also removes the Server Manager Scheduled task that opens Server Manager on each login...

## .NET Core

Installs IIS and managment tools, along with ASP.NET. Also opens ports 80 and 443 on the local Windows Firewall (80 on TCP, 443 on both TCP and UDP to allow HTTP2.0). Also installs the [.NET Core Hosting Bundle](https://community.chocolatey.org/packages?q=dotnet-windowshosting).

## .NET 4.8

Same as above, but instead of .NET Core, it installs [.NET 4.8](https://community.chocolatey.org/packages/netfx-4.8). 

# Random Useful snippets...

The scripts above all, by default, remove the default AppPool and Default site from IIS. If you want to add some scripts for doing different tasks, have a look a the following snippets

## Make sure a folder exists. 

```
      File LoggingPath
        {
           
            Type = "Directory"
            DestinationPath = "f:\logs\"
            Ensure = "Present"
        }
```

## Create an IIS App Pool

```
xWebAppPool "API"
        {
            DependsOn='[WindowsFeature]IIS'
            Name = "API"
            Ensure = "Present"
            ManagedPipelineMode = "Integrated"
            managedRuntimeVersion = "V4.0"
            State = "Started"
            IdentityType = "ApplicationPoolIdentity"
            Credential = $(if (($Credentials | Where-Object {$_.Name -eq "API.AppPoolIdentity"}) -ne $null) {($Credentials | Where-Object {$_.Name -eq "API.AppPoolIdentity"}).Credential} else {$null} )
            startMode = "AlwaysRunning"
            maxProcesses = 1
        }
```

## set permissions on a folder to allow an app pool to write to it (app_data)

```
cNTFSPermissionEntry  "APIAppDataSecurity"
        {
            Ensure = "Present"
            Principal = "IIS AppPool\API"
            Path = "f:\apps\API\App_Data"
            DependsOn = '[File]APIAppData'
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = 'Allow'
                    FileSystemRights = 'FullControl'
                    Inheritance = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
        }
```



## Adding websites to IIS using DSC

```
      xWebSite "API"
        {
            DependsOn='[WindowsFeature]IIS'
            Ensure = "Present"
            Name = "API"
            State = "Started"
            PhysicalPath = "f:\apps\api"
            ApplicationPool = "API"
            BindingInfo = @(
                # check for keyword CertificateStoreName
                    MSFT_xWebBindingInformation                    
                    {
                        Protocol              = "HTTP"
                        Port                  = 80
                    }
            )

            # Set logging path
            LogPath = "f:\logs\"

            # Set Authentication mechanisms
            AuthenticationInfo = MSFT_xWebAuthenticationInformation {
                Anonymous = $true
                Basic = $false
                Digest = $false
                Windows = $false
            }
        }
```

More options for the Website are available [here](https://github.com/dsccommunity/WebAdministrationDsc#website)


# Thanks

* Thanks to [Chocolatey](https://chocolatey.org) for making their package manager, and the script above to download and run a powershell script in one go!
* Thanks to [Cloudneeti](https://cloudneeti.github.io/Cloudneeti_SaaS_Docs/remediation/osBaseline/win19QuickWins/) Who built the original CSBP script. 