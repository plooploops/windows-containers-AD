# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files 
WORKDIR C:\src

#testing receiver
COPY . C:\src

RUN msbuild MSMQReceiverTest\MSMQReceiverTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true

## final image
FROM myplooploops/windows-ad:msmq-base-1809 
# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /Receiver
COPY --from=build-agent C:\out\ .
COPY MSMQPersistentVolume\MSMQPersistentVolumeReceiverTest\start.ps1 .

# RUN $msmqreceive = Start-Process MSMQReceiverTest.exe -PassThru; `
#     Start-Sleep -Seconds 10; `
#     Stop-Process -InputObject $msmqreceive;

ENTRYPOINT .\start.ps1