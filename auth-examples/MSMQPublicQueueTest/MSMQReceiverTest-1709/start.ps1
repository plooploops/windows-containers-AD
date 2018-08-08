Uninstall-windowsfeature msmq-directory
Install-windowsfeature msmq-directory
set-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup -value 0
Restart-service msmq
get-itemproperty hklm:\software\microsoft\msmq\parameters -name workgroup
Cd "C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64\"
.\msvsmon.exe /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs
Cd C:\Receiver
$env:queue_name='msmqhost1709\msmqhost-q-1709'
$env:trace_level=3
# $env:user='MSMQsend$'
set-itemproperty HKLM:\software\microsoft\msmq\Parameters\ -name UseDSPredefinedEP -value "1"
set-itemproperty HKLM:\software\microsoft\msmq\Parameters\ -name MsmqDSRpcIpPort -value "2879"

.\MSMQReceiver.exe
#spin wait for entrypoint purposes.
while($true) { Start-Sleep -Seconds 1 }; 