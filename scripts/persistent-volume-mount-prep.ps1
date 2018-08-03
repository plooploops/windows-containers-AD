#this should run on the Host for setting up the volume

#set up folder for volume
$volumepath = 'C:\msmq'
$user = "Everyone"
mkdir $volumepath -Force

#set permissions

$acl = get-acl -path $volumepath
$permission=$user,"FullControl","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)
$acl | Set-Acl $volumepath

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
docker run --name=persistent_volume_bootstrap -d -v "$bootstrapvolumepath:c:/volume-data" "$repo/windows-ad:msmq-persistent-volume-bootstrap"

cp -r "$bootstrapvolumepath\*" "$volumepath" -force

docker stop persistent_volume_bootstrap
docker rm persistent_volume_bootstrap
# #clean up bootstrap directory
# Remove-Item $volumepath -Force -Recurse

docker run --name=persistent_volume_sender_test -d -v "$volumepath:c:/Windows/System32/msmq" "$repo/windows-ad:msmq-persistent-volume-sender-test"
docker run --name=persistent_volume_receiver_test -d -v "$volumepath:c:/Windows/System32/msmq" "$repo/windows-ad:msmq-persistent-volume-receiver-test"
