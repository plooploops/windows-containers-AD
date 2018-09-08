# escape=`
FROM jsturtevant/4.7-windowsservercore-1709-builder:latest as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files
WORKDIR C:\src
COPY windows-auth-impersonate-backend\packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY . C:\src
RUN msbuild windows-auth-impersonate-backend\windows-auth-impersonate-backend.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true 

## final image
FROM microsoft/aspnet:4.7.2-windowsservercore-1803

RUN powershell.exe Add-WindowsFeature Web-Windows-Auth
RUN powershell.exe -NoProfile -Command `
  Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/AnonymousAuthentication -name enabled -value false -PSPath IIS:\ ; `
  Set-WebConfigurationProperty -filter /system.webServer/security/authentication/windowsAuthentication -name enabled -value true -PSPath IIS:\ 
WORKDIR /inetpub/wwwroot
COPY --from=build-agent C:\out\_PublishedWebsites\windows-auth-impersonate-backend .

#Enable Remote IIS administration
RUN Install-WindowsFeature Web-Mgmt-Service; `
     NET USER admin 'pass@word1234' /ADD; `
     NET LOCALGROUP 'Administrators' 'admin' /add; `
     sc.exe config WMSVC start=auto; `
     Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1

#set up remote debug
EXPOSE 4020 4021 
RUN Invoke-WebRequest -OutFile c:\rtools_setup_x64.exe -Uri https://aka.ms/vs/15/release/RemoteTools.amd64ret.enu.exe; `
    c:\rtools_setup_x64.exe /install /quiet