get-msmqqueue
.\MSMQReceiver.exe
#spin wait for entrypoint purposes.
while($true) { Start-Sleep -Seconds 1 }; 