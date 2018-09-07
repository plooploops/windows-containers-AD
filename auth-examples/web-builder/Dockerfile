# escape=`

FROM microsoft/dotnet-framework-build:4.7.1-windowsservercore-1709
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install web work load.  had to make sure build tools are there or it fails
RUN Invoke-WebRequest -UseBasicParsing https://download.visualstudio.microsoft.com/download/pr/100196686/e64d79b40219aea618ce2fe10ebd5f0d/vs_BuildTools.exe -OutFile vs_BuildTools.exe;
RUN setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1; 
RUN Start-Process vs_BuildTools.exe -ArgumentList '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools', '--quiet', '--norestart', '--nocache' -NoNewWindow -Wait;
RUN Start-Process vs_BuildTools.exe -ArgumentList '--add', 'Microsoft.VisualStudio.Workload.WebBuildTools', '--quiet', '--norestart', '--nocache' -NoNewWindow -Wait;

# Install WebDeploy
RUN Install-PackageProvider -Name chocolatey -RequiredVersion 2.8.5.130 -Force; `
    Install-Package -Name webdeploy -RequiredVersion 3.6.0 -Force;
