#assumes that DNS is at 10.0.0.4 for CNM plugin
set-dnsclientserveraddress -interfaceindex (get-netadapter).IfIndex -serveraddress ("10.0.0.4")

Uninstall-windowsfeature msmq-directory
Install-windowsfeature msmq-directory
set-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup -value 0
Restart-service msmq
set-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup -value 0
get-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup
try {
    $msvsmon_folder = "C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64\"
    if (-not(Test-Path "$msvsmon_folder")) {
        #assumes that the path exists for the remote debugger.
        c:\rtools_setup_x64.exe /install /quiet
        while (-not(Test-Path "$msvsmon_folder")) { start-sleep 1}
    }
    cd "$msvsmon_folder"

    .\msvsmon.exe /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
}
#this should still be checked by docker, perhaps use -e flag.
$env:queue_name = 'msmqhost1803\msmqhost-q-1803-TA'
$env:trace_level = 3
# $env:user='MSMQsend$'
set-itemproperty HKLM:\software\microsoft\msmq\Parameters\ -name UseDSPredefinedEP -value "1"
set-itemproperty HKLM:\software\microsoft\msmq\Parameters\ -name MsmqDSRpcIpPort -value "2879"

try {
    #assumes that DNS is at 10.0.0.4 for CNM plugin
    set-dnsclientserveraddress -interfaceindex (get-netadapter).IfIndex -serveraddress ("10.0.0.4")
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
}

try {
    get-msmqqueue
    cd C:\sender
    .\MSMQSender.exe
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
}
#spin wait for entrypoint purposes.
while ($true) { Start-Sleep -Seconds 1 }; 