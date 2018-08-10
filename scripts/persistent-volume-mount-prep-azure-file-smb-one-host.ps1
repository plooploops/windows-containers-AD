#this should run on the Host for setting up the volume

$repo='myplooploops'
#set up folder for volume
$receivervolumepath = 'C:\smbmappings\msmqsharesa-msmq-share\receiver'
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
$sendervolumepath = 'C:\smbmappings\msmqsharesa-msmq-share\sender'
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

#run the container
docker stop persistent_volume_bootstrap
start-Sleep -Seconds 2

docker rm persistent_volume_bootstrap
start-Sleep -Seconds 2

docker run --name=persistent_volume_bootstrap -d -v c:\ContainerData\msmq:c:/volume-data "$repo/windows-ad:msmq-persistent-volume-bootstrap"

while(-Not (Test-Path -Path C:\ContainerData\MSMQ\storage) -And -Not (Test-Path -Path C:\ContainerData\MSMQ\Mapping)) { Start-Sleep -Seconds 2 }

cp -r C:\containerdata\msmq\* C:\smbmappings\msmqsharesa-msmq-share\receiver -force
cp -r C:\containerdata\msmq\* C:\smbmappings\msmqsharesa-msmq-share\sender -force

docker stop persistent_volume_bootstrap
start-Sleep -Seconds 2

docker rm persistent_volume_bootstrap
start-Sleep -Seconds 2
# #clean up bootstrap directory
Remove-Item $bootstrapvolumepath -Force -Recurse

#example runs

#make a sender
docker run --name=persistent_volume_sender_test_azure_file --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -d -v c:\smbmappings\msmqsharesa-msmq-share\sender:c:/Windows/System32/msmq -e QUEUE_NAME='MSMQRec\private$\testQueue' "$repo/windows-ad:msmq-persistent-volume-sender-test"

#make a receiver
docker run --name=persistent_volume_receiver_test_azure_file --security-opt "credentialspec=file://MSMQRec.json" -h MSMQRec -it -v c:\smbmappings\msmqsharesa-msmq-share\receiver:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test"

#we may need to use a separate shell and docker exec -it <image id> to check on the container
#we can use get-msmqqueue to see if the queue manager relationship is established.
