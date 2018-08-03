# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files 
WORKDIR C:\src

#testing receiver
COPY . C:\src

RUN msbuild MSMQSenderTest\MSMQSenderTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true

## final image
FROM myplooploops/windows-ad:msmq-base-1803
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /Sender
COPY --from=build-agent C:\out\ .

COPY MSMQPersistentVolume\MSMQPersistentVolumeBootstrap\copy.ps1 .

#bootstrap data
RUN $msmqsend = Start-Process MSMQSenderTest.exe -RedirectStandardOutput msmqsend.out -PassThru; `
    Start-Sleep -Seconds 2; `
    #while((Select-String -Pattern 'Sent a message' -Path C:\msmqsend.out) -eq $null) { Start-Sleep -Seconds 1 }; `
    Stop-Process -InputObject $msmqsend; `
    rm msmqsend.out; `
    mkdir C:\default -force; `
    mkdir C:\volume-data -force;

RUN cp -r C:\Windows\System32\msmq\* C:\default;

ENTRYPOINT .\copy.ps1
 