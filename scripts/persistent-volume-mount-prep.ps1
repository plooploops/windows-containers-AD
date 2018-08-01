#set up folder
$volumepath = "C:\msmq"

mkdir $volumepath -Force

#set permissions
$permission = "Everyone","FullControl","Allow"
$Acl = Get-ACL $volumepath
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule($permission)
$Acl.AddAccessRule($AccessRule)
Set-Acl $volumepath $Acl
$acl

#bootstrap data if needed because of file permissions