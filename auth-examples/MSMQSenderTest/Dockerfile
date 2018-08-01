# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files 
WORKDIR C:\src

#testing Sender
COPY . C:\src
RUN msbuild MSMQSenderTest\MSMQSenderTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true 


## final image
FROM microsoft/windowsservercore-insider:10.0.17639.1000
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /Sender
COPY --from=build-agent C:\out\ .

#set up remote debug
EXPOSE 4020 4021 
RUN Invoke-WebRequest -OutFile c:\rtools_setup_x64.exe -Uri https://aka.ms/vs/15/release/RemoteTools.amd64ret.enu.exe; `
    c:\rtools_setup_x64.exe /install /quiet

#ports for MSMQ
#https://support.microsoft.com/en-us/help/178517/tcp-ports-udp-ports-and-rpc-ports-that-are-used-by-message-queuing
EXPOSE 135 389 1801 2101 2103 2105 3527

#RUN Enable-WindowsOptionalFeature -FeatureName ActiveDirectory-Powershell -online -all;

RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ -All;
RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Services -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Triggers -All;
RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-ADIntegration -All;
RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-HTTP -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Multicast -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-DCOMProxy -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-RoutingServer -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName WCF-MSMQ-Activation45 -All;

#windows feature install
#RUN Install-WindowsFeature MSMQ;
RUN Install-WindowsFeature MSMQ-Directory;

RUN Set-ItemProperty HKLM:\Software\Microsoft\Msmq\Parameters -Name workgroup -Value 0;

#ENTRYPOINT MSMQSenderTest.exe
#ENTRYPOINT .\runnerAsUser.ps1