# escape=`
FROM microsoft/windowsservercore:1803 
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

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
# RUN powershell Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-HTTP-Support -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Multicast -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-DCOMProxy -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-RoutingServer -All;
#RUN Enable-WindowsOptionalFeature -Online -FeatureName WCF-MSMQ-Activation45 -All;

#windows feature install
#RUN Install-WindowsFeature MSMQ;
RUN powershell Install-WindowsFeature MSMQ-Directory;
RUN powershell Install-WindowsFeature MSMQ-HTTP-Support;

RUN powershell Set-ItemProperty HKLM:\Software\Microsoft\Msmq\Parameters -Name workgroup -Value 0;
