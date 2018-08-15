#this should run on the Host for setting up the volume

#set up folder for volume
$receivervolumepath = 'C:\msmq\receiver'
$user = "Everyone"
mkdir $receivervolumepath -Force

#set permissions

$acl = get-acl -path $receivervolumepath
$permission=$user,"FullControl","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)
$acl | Set-Acl $receivervolumepath

$acl

#set up folder for volume
$sendervolumepath = 'C:\msmq\sender'
$user = "Everyone"
mkdir $sendervolumepath -Force

#set permissions

$acl = get-acl -path $sendervolumepath
$permission=$user,"FullControl","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)
$acl | Set-Acl $sendervolumepath

$acl

#bootstrap

#set up folder
$bootstrapvolumepath = 'C:\ContainerData\msmq'
$user = "Everyone"
mkdir $bootstrapvolumepath -Force

#set permissions

$acl = get-acl -path $bootstrapvolumepath
$permission=$user,"FullControl","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)
$acl | Set-Acl $bootstrapvolumepath

$acl

$repo='myplooploops'
#run the container
docker stop persistent_volume_bootstrap
start-Sleep -Seconds 2

docker rm persistent_volume_bootstrap
start-Sleep -Seconds 2

docker run --name=persistent_volume_bootstrap -d -v c:\ContainerData\msmq:c:/volume-data "$repo/windows-ad:msmq-persistent-volume-bootstrap"

while(-Not (Test-Path -Path C:\ContainerData\MSMQ\storage) -And -Not (Test-Path -Path C:\ContainerData\MSMQ\Mapping)) { Start-Sleep -Seconds 2 }

cp -r C:\containerdata\msmq\* C:\msmq\receiver -force
cp -r C:\containerdata\msmq\* C:\msmq\sender -force

docker stop persistent_volume_bootstrap
start-Sleep -Seconds 2

docker rm persistent_volume_bootstrap
start-Sleep -Seconds 2
# #clean up bootstrap directory
Remove-Item $bootstrapvolumepath -Force -Recurse

#example runs
# docker run --name=persistent_volume_sender_test --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -it -v c:\msmq\sender:c:/Windows/System32/msmq -e QUEUE_NAME='MSMQRec\private$\testQueue' -e TRACE_LEVEL=1 "$repo/windows-ad:msmq-persistent-volume-sender-test"

#make a sender
docker run --name=persistent_volume_sender_test --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -d -v c:\msmq\sender:c:/Windows/System32/msmq -e QUEUE_NAME='MSMQRec\private$\testQueue' "$repo/windows-ad:msmq-persistent-volume-sender-test"

#make a receiver
docker run --name=persistent_volume_receiver_test --security-opt "credentialspec=file://MSMQRec.json" -h MSMQRec -it -v c:\msmq\receiver:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test"

# docker run --name=persistent_volume_sender_test -it -v c:\msmq:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-sender-test"
# docker run --name=persistent_volume_receiver_test -it -v c:\msmq:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test"
