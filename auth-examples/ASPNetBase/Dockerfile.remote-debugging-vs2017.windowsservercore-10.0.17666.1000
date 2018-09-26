# escape=`
FROM myplooploops/aspnet:4.7.2-windowsservercore-insider-10.0.17666.1000

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY .\start.ps1 .

#add remote debugging
EXPOSE 4022 4023 
RUN Invoke-WebRequest -OutFile c:\rtools_setup_x64.exe -Uri https://aka.ms/vs/15/release/RemoteTools.amd64ret.enu.exe; `
    c:\rtools_setup_x64.exe /install /quiet; `
    $path = 'C:\\Program Files\\Microsoft Visual Studio 15.0\\Common7\\IDE\\Remote Debugger\\x64'; `
    while(!(Test-Path $path)){ Start-Sleep -Seconds 2 };

RUN .\start.ps1