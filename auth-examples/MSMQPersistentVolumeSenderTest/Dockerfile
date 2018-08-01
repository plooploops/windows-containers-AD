# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files 
WORKDIR C:\src

#testing receiver
COPY . C:\src

RUN msbuild MSMQSenderTest\MSMQSenderTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true

## final image
FROM microsoft/windowsservercore-insider:10.0.17639.1000
# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /Sender
COPY --from=build-agent C:\out\ .

#set up remote debug
EXPOSE 4020 4021 
RUN powershell Invoke-WebRequest -OutFile c:\rtools_setup_x64.exe -Uri https://aka.ms/vs/15/release/RemoteTools.amd64ret.enu.exe; `
    c:\rtools_setup_x64.exe /install /quiet

#ports for MSMQ
#https://support.microsoft.com/en-us/help/178517/tcp-ports-udp-ports-and-rpc-ports-that-are-used-by-message-queuing
EXPOSE 135 389 1801 2101 2103 2105 3527

#RUN Enable-WindowsOptionalFeature -FeatureName ActiveDirectory-Powershell -online -all;


RUN powershell Enable-WindowsOptionalFeature -Online -FeatureName MSMQ -All;
RUN powershell Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Services -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Triggers -All;
RUN powershell Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-ADIntegration -All;
RUN powershell Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-HTTP -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Multicast -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-DCOMProxy -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-RoutingServer -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName WCF-MSMQ-Activation45 -All;

#windows feature install
#RUN Install-WindowsFeature MSMQ;
RUN powershell Install-WindowsFeature MSMQ-Directory;

RUN powershell Set-ItemProperty HKLM:\Software\Microsoft\Msmq\Parameters -Name workgroup -Value 0;

COPY MSMQMonolithTest\monolithtest.ps1 .

RUN $minecraft = Start-Process -FilePath 'pwsh' -Args @('-File C:\minecraft\start.ps1') -RedirectStandardOutput minecraft.out -PassThru; `
    Start-Sleep -Seconds 2; `
    while((Select-String -Pattern 'RCON running' -Path G:\minecraft.out) -eq $null) { Start-Sleep -Seconds 1 }; `
    Wait-Process -InputObject $minecraft; `
    rm eula.txt; `
    rm minecraft.out; `
    rm server.properties; `
    rm -r ./logs; `
    cp -r G:\ C:\default;

# RUN .\monolithtest.ps1

RUN powershell.exe -Command Start-Process MSMQSenderTest.exe