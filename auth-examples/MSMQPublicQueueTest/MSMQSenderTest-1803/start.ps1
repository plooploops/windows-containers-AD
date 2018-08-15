Uninstall-windowsfeature msmq-directory
Install-windowsfeature msmq-directory
set-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup -value 0
# Restart-service msmq
get-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup
$msvsmon_folder="C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64\"
if(-not(Test-Path $msvsmon_folder)){
    #assumes that the path exists for the remote debugger.
    c:\rtools_setup_x64.exe /install /quiet
    while(-not(Test-Path $msvsmon_folder)){ start-sleep 1}
}
cd "$msvsmon_folder"

.\msvsmon.exe /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs
cd C:\sender
#this should still be checked by docker, perhaps use -e flag.
$env:queue_name='msmqhost1803\msmqhost-q-1803-TA'
$env:trace_level=3
# $env:user='MSMQsend$'
set-itemproperty HKLM:\software\microsoft\msmq\Parameters\ -name UseDSPredefinedEP -value "1"
set-itemproperty HKLM:\software\microsoft\msmq\Parameters\ -name MsmqDSRpcIpPort -value "2879"

get-msmqqueue
.\MSMQSender.exe
#spin wait for entrypoint purposes.
while($true) { Start-Sleep -Seconds 1 }; 