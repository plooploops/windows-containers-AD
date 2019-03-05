$msmqsend = Start-Process .\MSMQSenderTest.exe -RedirectStandardOutput msmqsend.out -PassThru;
Start-Sleep -Seconds 2;
$msmqreceive = Start-Process .\MSMQReceiverTest.exe -RedirectStandardOutput msmqreceive.out -PassThru;
Start-Sleep -Seconds 2;
Stop-Process -InputObject $msmqsend;
Stop-Process -InputObject $msmqreceive;
