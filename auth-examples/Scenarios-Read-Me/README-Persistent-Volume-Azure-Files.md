### MSMQ Persistent Volume on Host with Azure File SMB

We will mount a persistent volume to the host (could be a Windows VM, Azure Windows VM) so that the private queue (e.g. .\private$\testQueue) will have the data stored in the mount.  We will use an Azure File SMB and symlink to it from the host, and this will be the volume mount (with a subfolder) for each of the sender and receiver containers.

Note that this is just a **test** and while this can help with **lift and shift** scenarios, it would be advisable to consider **Azure Queues** or **Azure Service Bus** as well.

![Persistent volume on host with Azure File SMB for MSMQ private queue with  sender and receiver containers.](../../media/persistent-volume-azure-file/scenario.png 'Persistent Volume with Azure File SMB')

#### Links

These will describe some of the concepts that we're using in this scenario.

1. [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows)
1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest)
1. [Install Azure RM for Powershell](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-6.5.0)
1. [Powershell with JSON](https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/08/playing-with-json-and-powershell/)
1. [Windows Containers Networking](https://blogs.technet.microsoft.com/virtualization/2016/05/05/windows-container-networking/)
1. [Windows Containers Volumes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage)
1. [Using Service Principals with Az Cli](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)
1. [Check Service Principal Role Assignment](https://docs.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create)

#### Prepare environment

##### Set up Azure File Share
We can run a set up script in **.\scripts\persistent-volume-mount-prep-azure-file-create.ps1**, be sure to adapt it to the **appropriate settings**!  We'll work through the main steps of the script.

Run this script on the host with elevated permissions in PowerShell.

Connect to Azure locally.  If we already have az cli, we should still be sure to point to the **correct subscription**.
```
Start-BitsTransfer https://aka.ms/installazurecliwindows .\azure-cli.msi
.\azure-cli.msi /quiet /norestart
#(we may need a restart)
#shutdown -r

#be sure to login with az cli
az login
az account set --subscription 'sub id'
az account show
```

Create Azure File Share.  Be sure the **Azure File Share location** is in the same region / **location** as the **host vm**.
```
#az cli to create group and share
az group create -n $rgName -l $location

az storage account create --resource-group $rgName --name $account_name --location $location
$res = az storage account keys list -g $rgName -n $account_name | ConvertFrom-Json
$account_key = $res[0].value

###create a file share
az storage share create --name $share_name --account-key $account_key --account-name $account_name

#add a service principal
#https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest
$result = az ad sp create-for-rbac --name $spn --role owner --scopes "/subscriptions/$subscriptionId/resourceGroups/$rgName"

az ad sp list --spn "http://$spn"
```
##### Set up SMB Link on the *Host*

Run the SMB set up script:
**.\scripts\persistent-volume-mount-prep-azure-file-smb.ps1**, and make sure to point to the **correct locations** for the Azure File Share.
```
.\scripts\persistent-volume-mount-prep-azure-file-smb.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the host linked to an Azure File share in a local folder such as C:\smbmappings.

It will grant **permissions** for **everyone** on that folder (this is just a test).

#### Prep script

A setup script in  **.\scripts\persistent-volume-mount-prep-azure-file-smb-one-host.ps1** will help with this process, and we'll want to run it on the host.  

This will assume that we've created the gMSA accounts in the **same host**, e.g. we will have a cred spec for **MSMQRec** and **MSMQSend**.
```powershell
.\scripts\persistent-volume-mount-prep-azure-file-smb-one-host.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the host, for instance C:\smbmappings\msmqsharesa-msmq-share\.

It will grant **permissions** for **everyone** on that folder (this is just a test).

We will also want to verify the bootstrapped data will exist in the mount once we run the container.  If the script completes successfully, we'll have the **storage** and **mapping** folders in the **volume mount**.  

From the host we should see the smbmapping.
Check **C:\smbmappings\msmqsharesa-msmq-share\sender** and **C:\smbmappings\msmqsharesa-msmq-share\receiver**.

![Persistent volume data.](../../media/persistent-volume-azure-file/vm-smb-mapping.png 'Queue Data')

We can also check the Azure Portal to see mapped data.
![Persistent volume data.](../../media/persistent-volume-azure-file/azure-file-bootstrap.png 'Queue Data')

We should see the **storage** and **mapping** folders in the **receiver** folder.
![Persistent volume data.](../../media/persistent-volume-azure-file/azure-file-bootstrap-receiver.png 'Queue Data')

We should see the **storage** and **mapping** folders in the **sender** folder.
![Persistent volume data.](../../media/persistent-volume-azure-file/azure-file-bootstrap-sender.png 'Queue Data')


#### Running the scenario

We can verify the permissions on the folder in PowerShell.

```powershell
Get-ACL C:\<local volume mount>
```

![Peristent volume permissions.](../../media/persistent-volume/permissions.PNG 'Permissions')

We'll want to run the containers next and point them to the **local volume mount**.

Run the sender.

```powershell
#make a sender
docker run --name=persistent_volume_sender_test_azure_file --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -d -v c:\smbmappings\msmqsharesa-msmq-share\sender:c:/Windows/System32/msmq -e QUEUE_NAME='MSMQRec\private$\testQueue' "$repo/windows-ad:msmq-persistent-volume-sender-test"
```

Run the receiver.
```
#make a receiver
docker run --name=persistent_volume_receiver_test_azure_file --security-opt "credentialspec=file://MSMQRec.json" -h MSMQRec -it -v c:\smbmappings\msmqsharesa-msmq-share\receiver:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test"
```

![Persistent volume both containers.](../../media/persistent-volume-azure-file/result.png 'Both Containers Detached')

If we stop the sender (use docker stop), then we should see the receiver pull messages off the queue.

![Persistent volume both containers.](../../media/persistent-volume-azure-file/result-stop-sender.png 'Stopped Sender')

***
## Todo
Explore if we can reach a private queue on a separate host and other hosting mechanisms
***