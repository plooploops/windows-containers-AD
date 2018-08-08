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

docker stop persistent_volume_bootstrap
start-Sleep -Seconds 2

docker rm persistent_volume_bootstrap
start-Sleep -Seconds 2

# #clean up bootstrap directory
Remove-Item $bootstrapvolumepath -Force -Recurse

#example runs
docker run --name=persistent_volume_receiver_test --security-opt "credentialspec=file://MSMQReceiver.json" -h MSMQReceiver -d -v c:\msmq\receiver:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test"

# docker run --name=persistent_volume_receiver_test -it -v c:\msmq:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test"
