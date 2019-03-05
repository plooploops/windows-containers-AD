# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files 
WORKDIR C:\src

#testing Sender
COPY . C:\src
RUN msbuild MSMQSenderTest\MSMQSenderTest.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true 


## final image
FROM myplooploops/windows-ad:msmq-base-1803
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /Sender
COPY --from=build-agent C:\out\ .

ENTRYPOINT .\MSMQSenderTest.exe