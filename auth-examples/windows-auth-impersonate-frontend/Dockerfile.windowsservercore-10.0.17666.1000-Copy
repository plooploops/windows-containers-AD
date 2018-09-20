# escape=`

## final image
FROM myplooploops/aspnet:4.7.2-windowsservercore-insider-10.0.17666.1000

RUN powershell.exe Add-WindowsFeature Web-Windows-Auth
RUN powershell.exe -NoProfile -Command `
  Set-WebConfigurationProperty -filter /system.WebServer/security/authentication/AnonymousAuthentication -name enabled -value false -PSPath IIS:\ ; `
  Set-WebConfigurationProperty -filter /system.webServer/security/authentication/windowsAuthentication -name enabled -value true -PSPath IIS:\ 
WORKDIR /inetpub/wwwroot
COPY windows-auth-impersonate-frontend .

