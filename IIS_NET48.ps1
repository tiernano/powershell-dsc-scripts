configuration IIS_NET48
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DSCResource -ModuleName xWebAdministration


    Node $env:COMPUTERNAME
    {        
        WindowsFeature Web-Server {
            Ensure = "Present"
            Name = "Web-Server"
        }
        WindowsFeature IISManagementTools
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Tools"
            DependsOn='[WindowsFeature]Web-Server'
        }

        WindowsFeature ASP 
        { 
            Ensure = "Present"
            Name = "Web-Asp-Net45"
            DependsOn='[WindowsFeature]Web-Server'
        } 

        WindowsFeature WCFHTTP {
            Ensure = "Present"
            Name = "NET-WCF-HTTP-Activation45"
            DependsOn='[WindowsFeature]ASP'
        }

        WindowsFeature DynamicCompression {
            Ensure = "Present"
            Name = "Web-Dyn-Compression"
            DependsOn='[WindowsFeature]Web-Server'
        }

        WindowsFeature WebScriptingTools {
            Ensure = "Present"
            Name = "Web-Scripting-Tools"
            DependsOn='[WindowsFeature]Web-Server'
        }        

        xFirewall AllowHttp80 {
            Name = "HTTP port 80"
            DisplayName = "HTTP port 80"
            Ensure = "Present"
            Protocol = "TCP"
            Enabled = "True"
            Direction = "InBound"
            LocalPort = 80
        }

        Script Install_Net_4.8
        {
            DependsOn='[WindowsFeature]ASP'

            SetScript = {
                $SourceURI = "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe"
                $FileName = $SourceURI.Split('/')[-1]
                $BinPath = Join-Path $env:SystemRoot -ChildPath "Temp\$FileName"

                if (!(Test-Path $BinPath))
                {
                    Invoke-Webrequest -Uri $SourceURI -OutFile $BinPath
                }

                write-verbose "Installing .Net 4.8 from $BinPath"
                write-verbose "Executing $binpath /q /norestart"
                Start-Sleep 5
                Start-Process -FilePath $BinPath -ArgumentList "/q /norestart" -Wait -NoNewWindow            
                Start-Sleep 5
                Write-Verbose "Setting DSCMachineStatus to reboot server after DSC run is completed"
                $global:DSCMachineStatus = 1
            }

            TestScript = {
                [int]$NetBuildVersion = 528049

                if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | %{$_ -match 'Release'})
                {
                    [int]$CurrentRelease = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Release
                    if ($CurrentRelease -lt $NetBuildVersion)
                    {
                        Write-Verbose "Current .Net build version is less than 4.8 ($CurrentRelease)"
                        return $false
                    }
                    else
                    {
                        Write-Verbose "Current .Net build version is the same as or higher than 4.8 ($CurrentRelease)"
                        return $true
                    }
                }
                else
                {
                    Write-Verbose ".Net build version not recognised"
                    return $false
                }
            }

            GetScript = {
                if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | %{$_ -match 'Release'})
                {
                    $NetBuildVersion =  (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Release
                    return $NetBuildVersion
                }
                else
                {
                    Write-Verbose ".Net build version not recognised"
                    return ".Net 4.8 not found"
                }
            }
        }        

        xWebSite DefaultSite
        {
            DependsOn='[WindowsFeature]Web-Server'
            Ensure = "Absent"
            Name = "Default Web Site"
            State = "Stopped"
            PhysicalPath = "c:\inetpub\wwwroot"
        }

        # loop through list of default app pools and stop them
        ForEach($Pool in @(".NET v2.0", `
        ".NET v2.0 Classic", `
        ".NET v4.5", `
        ".NET v4.5 Classic", `
        "Classic .NET AppPool", `
        "DefaultAppPool"))
        {
            xWebAppPool $Pool
            {
                DependsOn='[WindowsFeature]Web-Server'
                Name = $Pool
                State = "Stopped"
                Ensure = "Absent"				 
            }
        }
    }
}
IIS_NET48
Start-DscConfiguration -Path .\IIS_NET48  -Force -Verbose -Wait
