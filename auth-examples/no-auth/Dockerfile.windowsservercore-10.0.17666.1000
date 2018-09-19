# escape=`
FROM myplooploops/web-builder:4.7.2-windowsservercore-insider-10.0.17666.1000 as build-agent
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Build files
WORKDIR C:\src
COPY packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY . C:\src
RUN msbuild no-auth.csproj /p:OutputPath=C:\out /p:DeployOnBuild=true 

## final image
FROM myplooploops/aspnet:4.7.2-windowsservercore-insider-10.0.17666.1000
WORKDIR /inetpub/wwwroot
COPY --from=build-agent C:\out\_PublishedWebsites\no-auth .
