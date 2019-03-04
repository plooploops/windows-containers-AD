# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files 
WORKDIR C:\src

#testing receiver
COPY . C:\src

RUN msbuild MSMQReceiverTest\MSMQReceiverTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true 
RUN msbuild MSMQSenderTest\MSMQSenderTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true

## final image
FROM  myplooploops/windows-ad:msmq-base-1803
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /MonolithTest
COPY --from=build-agent C:\out\ .

RUN $msmqsend = Start-Process MSMQSenderTest.exe -RedirectStandardOutput msmqsend.out -PassThru; `
    Start-Sleep -Seconds 2; `
    $msmqreceive = Start-Process MSMQReceiverTest.exe -RedirectStandardOutput msmqreceive.out -PassThru; `
    Start-Sleep -Seconds 2; `
    Stop-Process -InputObject $msmqsend; `
    Stop-Process -InputObject $msmqreceive; `
    cat msmqsend.out; `
    cat msmqreceive.out; `