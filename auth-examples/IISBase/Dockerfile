FROM microsoft/windowsservercore-insider:10.0.17666.1000

RUN powershell -Command \
    Add-WindowsFeature Web-Server; \
    Invoke-WebRequest -UseBasicParsing -Uri "https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.3/ServiceMonitor.exe" -OutFile "C:\ServiceMonitor.exe"

EXPOSE 80
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
