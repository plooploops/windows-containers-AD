### MSMQ Persistent Volume on Host with Azure File SMB with Multiple Hosts

We will mount a persistent volume to the host (could be a Windows VM, Azure Windows VM) so that the private queue (e.g. .\private$\testQueue) will have the data stored in the mount.  We will use an Azure File SMB and symlink to it from the host, and this will be the volume mount (with a subfolder) for each of the sender and receiver containers.

Note that this is just a **test** and while this can help with **lift and shift** scenarios, it would be advisable to consider **Azure Queues** or **Azure Service Bus** as well.

![Persistent volume on host with Azure File SMB for MSMQ private queue with  sender and receiver containers.](../media/persistent-volume-azure-file-multiple-hosts/scenario.png 'Persistent Volume with Azure File SMB')

#### Links

These will describe some of the concepts that we're using in this scenario.

1. [MSMQ MQQB Protocol](https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-MQQB/[MS-MQQB].pdf)
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

We can run a [Setup Script](../scripts/persistent-volume-mount-prep-azure-file-create.ps1), and be sure to adapt it to the **appropriate settings**!  We'll work through the main steps of the script.

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

This should be run on each of the hosts.  This preparation will help with the volume mount for the container.

Run the SMB [setup script](../scripts/persistent-volume-mount-prep-azure-file-smb.ps1), and make sure to point to the **correct locations** for the Azure File Share.
```
.\scripts\persistent-volume-mount-prep-azure-file-smb.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the host linked to an Azure File share in a local folder such as C:\smbmappings.

It will grant **permissions** for **everyone** on that folder (this is just a test).

#### Prep script

A [setup script](../scripts/persistent-volume-mount-prep-azure-file-smb-one-host.ps1) will help with this process, and we'll want to run it on the host.  Be sure to adapt the settings for the appropriate host (in this case, 1809). 

This will assume that we've created the gMSA accounts in the **same host**, e.g. we will have a cred spec for **MSMQRec** and **MSMQSend**.
```powershell
.\scripts\persistent-volume-mount-prep-azure-file-smb-one-host.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the host, for instance C:\smbmappings\msmqsharesa-msmq-share\.

It will grant **permissions** for **everyone** on that folder (this is just a test).

We will also want to verify the bootstrapped data will exist in the mount once we run the container.  If the script completes successfully, we'll have the **storage** and **mapping** folders in the **volume mount**.  

From each host we should see the smbmapping.
Check **C:\smbmappings\msmqsharesa-msmq-share\sender** and **C:\smbmappings\msmqsharesa-msmq-share\receiver**.

![Persistent volume data.](../media/persistent-volume-azure-file-multiple-hosts/vm-smb-mapping.png 'Queue Data')

We can also check the Azure Portal to see mapped data.
![Persistent volume data.](../media/persistent-volume-azure-file-multiple-hosts/azure-file-bootstrap.png 'Queue Data')

We should see the **storage** and **mapping** folders in the **receiver** folder.
![Persistent volume data.](../media/persistent-volume-azure-file-multiple-hosts/azure-file-bootstrap-receiver.png 'Queue Data')

We should see the **storage** and **mapping** folders in the **sender** folder.
![Persistent volume data.](../media/persistent-volume-azure-file-multiple-hosts/azure-file-bootstrap-sender.png 'Queue Data')


#### Stand up Azure CNM Plugin

For **each host**, we'll want to add additional static IPs to the NIC on the VM.  This would allow the IPs to get pulled in by the Azure CNM Plugin to allow the static IP address to be used in the network driver.  This would allow a container to use the IP address (effectively elevating the container to be at the host level from a network perspective.)

Let's add an Azure IP to the VM's Nic.  We should do this a few times to have multiple IP addresses available.

![Add IP to Nic.](../media/persistent-volume-azure-file-multiple-hosts/vnet-add-ip-nic.png 'Add IP To Nic')

The effect should resemble something like this after we're finished.

![Added IPs to Nic.](../media/persistent-volume-azure-file-multiple-hosts/vnet-ips-nic.png 'Added IPs To Nic')

Run the CNM plugin as an administrator on the host.  We have a sample in .\container-networking\cnm\azure-vnet\plugin.exe, but please check https://github.com/Azure/azure-container-networking for the actual repo and updates.

![Run CNM Plugin.](../media/persistent-volume-azure-file-multiple-hosts/run-cnm-plugin.png 'Run CNM Plugin')

Now that the driver is running, we can create a docker network for the azure-vnet.

```powershell
docker network create --driver=azure-vnet --ipam-driver=azure-vnet --subnet=10.0.0.0/24 azure
```

We can use a quick test to see if we can pull in the azure network for the container.

```powershell
docker run -it --network=azure mcr.microsoft.com/windows/servercore:1809 powershell
```

Assuming that we can hop into the container, we can validate that we get the private ip.

```powershell
ipconfig /all
```

![Validate CNM](../media/persistent-volume-azure-file-multiple-hosts/validate-cnm.png 'Validate CNM')

We could also use a ping to see if the container will respond (from the host or off box too).

```powershell
test-netconnection 10.0.x.x
```

Assuming that we have the CNM plugin set up on each host with a few extra IPs, we can then move on to validating that send and receive are working.

#### Running the scenario

We can verify the permissions on the folder in PowerShell.

```powershell
Get-ACL C:\<local volume mount>
```

![Persistent volume permissions.](../media/persistent-volume/folder-permissions.png 'Permissions')

We'll want to run the containers next and point them to the **local volume mount**.

First, let's run a **Receiver**.

Run the **receiver**.
```
#make a receiver
docker run --network=azure --name=persistent_volume_receiver_test_azure_file --security-opt "credentialspec=file://MSMQRec.json" -h MSMQRec -it -v c:\smbmappings\msmqsharesa-msmq-share\receiver:c:/Windows/System32/msmq "$repo/windows-ad:msmq-persistent-volume-receiver-test-1809"
```

We'll want to hop into the container and confirm the IP address.

```powershell
docker exec -it <id> powershell
```

```powershell
ipconfig /all
```

Refer to the container IP for the queue address.

Run the **sender**.  Be sure to update the **Container IP Address**, and we can also point to the **appropriate repo** for the image.

```powershell
#make a sender
docker run --network=azure --name=persistent_volume_sender_test_azure_file --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -d -v c:\smbmappings\msmqsharesa-msmq-share\sender:c:/Windows/System32/msmq -e DIRECT_FORMAT_PROTOCOL='TCP' -e QUEUE_NAME='10.0.x.x\private$\testQueue' "$repo/windows-ad:msmq-persistent-volume-sender-test-1809"
```

We can validate the containers are running and sending messages to each other.  We can hop into the sender and check the outgoing messages.

```powershell
get-msmqoutgoingqueue
```

We can hop into the receiver and check the queue.

```powershell
get-msmqqueue
```

![Persistent volume both containers.](../media/persistent-volume-azure-file-multiple-hosts/result.png 'Both Containers Detached')

If we stop the sender (use docker stop), then we should see the receiver pull messages off the queue.

![Persistent volume both containers.](../media/persistent-volume-azure-file-multiple-hosts/result-stop-sender.png 'Stopped Sender')

***
## Todo
Explore if we can reach a private queue with an orchestrator.
***