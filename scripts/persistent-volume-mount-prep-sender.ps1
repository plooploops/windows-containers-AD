#this should run on the Host for setting up the volume

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

cp -r C:\containerdata\msmq\* C:\msmq\sender -force

docker stop persistent_volume_bootstrap
start-Sleep -Seconds 2

docker rm persistent_volume_bootstrap
start-Sleep -Seconds 2
# #clean up bootstrap directory
Remove-Item $bootstrapvolumepath -Force -Recurse

#example runs
docker run --name=persistent_volume_sender_test --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -d -v c:\msmq\sender:c:/Windows/System32/msmq -e QUEUE_NAME='MSMQReceiver\private$\testQueue' "$repo/windows-ad:msmq-persistent-volume-sender-test"

# docker run --name=persistent_volume_sender_test -it -v c:\msmq:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-sender-test"
