# escape=`
FROM jsturtevant/4.7-windowsservercore-1709-builder:latest as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files
WORKDIR C:\src
COPY packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY . C:\src
RUN msbuild no-auth.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true 

## final image
FROM microsoft/aspnet:4.7.2-windowsservercore-1803
WORKDIR /inetpub/wwwroot
COPY --from=build-agent C:\out\_PublishedWebsites\no-auth .
