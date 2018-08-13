#make sure to use az cli on the host
#https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest
Start-BitsTransfer https://aka.ms/installazurecliwindows .\azure-cli.msi
.\azure-cli.msi /quiet /norestart
#(we may need a restart)
shutdown -r

#be sure to login with az cli
az login
az account set --subscription 'sub id'
az account show

###run this section on the host

$ErrorActionPreference = "Stop"
$account_name = 'msmqsharesa'
$rgName = 'msmq-share-mount'
$share_name = 'msmq-share'

#https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/08/playing-with-json-and-powershell/
$res = az storage account keys list -g $rgName -n $account_name | ConvertFrom-Json
$account_key = $res[0].value

$mapping_remote_target = "\\$account_name.file.core.windows.net\$share_name"
$mapping_local_root = 'C:\smbmappings'
$mapping_local_folder = $account_name + '-' + $share_name

# Ensure root folder exists

mkdir $mapping_local_root -Force

# Only create the SMB global mapping if it doesn't already exist
#open port 445 if host isn't on Azure
# netsh advfirewall firewall add rule name="Open Port 445" dir=out action=allow protocol=TCP localport=445
$mapping = Get-SmbGlobalMapping -RemotePath $mapping_remote_target -ErrorAction SilentlyContinue

if (!$mapping) {
	$acctKey = ConvertTo-SecureString -String $account_key -AsPlainText -Force
	$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$account_name", $acctKey
	New-SmbGlobalMapping -RemotePath $mapping_remote_target -Credential $credential
}

# Creating a directory symlink from PowerShell doesn't work with absolute paths, so we'll hop into the root folder

pushd $mapping_local_root

# Link remote file share to local folder under D:\smbmappings

New-Item -ItemType SymbolicLink -Name $mapping_local_folder -Target $mapping_remote_target -Force

popd

$sharepath = "$mapping_local_root\$mapping_local_folder"
$Acl = Get-ACL $SharePath
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","full","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $SharePath $Acl
$acl

#add bootstrap folders
