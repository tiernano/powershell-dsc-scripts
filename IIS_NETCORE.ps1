configuration IIS_NETCORE
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DSCResource -ModuleName xWebAdministration
    Import-DSCResource -ModuleName cChoco

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

        xFirewall AllowHttps443tcp {
            Name = "HTTPS port 443 TCP"
            DisplayName = "HTTP port 443"
            Ensure = "Present"
            Protocol = "TCP"
            Enabled = "True"
            Direction = "InBound"
            LocalPort = 443
        }

        xFirewall AllowHttps443udp {
            Name = "HTTPS port 443 UDP"
            DisplayName = "HTTPS port 443 UDP"
            Ensure = "Present"
            Protocol = "UDP"
            Enabled = "True"
            Direction = "InBound"
            LocalPort = 443
        }

        cChocoInstaller installChoco
        {
          InstallDir = "c:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller installNetCoreHosting
        {
           Name = "dotnet-windowshosting"
           DependsOn = "[cChocoInstaller]installChoco"
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
Start-DscConfiguration -Path .\IIS_NETCORE  -Force -Verbose -Wait
