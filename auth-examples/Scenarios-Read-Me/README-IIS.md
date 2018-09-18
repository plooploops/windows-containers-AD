## IIS Lift and Shift


#### Links

These will describe some of the concepts that we're using in this scenario.

1. [Windows Containers Networking](https://blogs.technet.microsoft.com/virtualization/2016/05/05/windows-container-networking/)
1. [Windows Containers Volumes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage)
1. [IIS on Docker Hub](https://hub.docker.com/r/microsoft/iis/)
1. [gMSA Windows Containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts)
1. [Deploying Windows Containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-server)

Set host name to the same as the name of the gmsa.  See other [debugging tips](https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/a887583835a91a27b7b1289ec6059808bd912ab1/virtualization/windowscontainers/manage-containers/walkthrough-iis-serviceaccount.md#test-a-container-using-the-service-account).

```powershell
docker run -h app1 -it --security-opt "credentialspec=file://app1.json" microsoft/windowsservercore:1709 cmd
```

in the container run

```cmd
nltest.exe /query
nltest.exe /parentdomain
```

> This should return the DC

```cmd
net config workstation
```

> This one should have some print out that shows computer name of the gmsa account)

## Advanced Debugging

Kerberos debugging - kerberos ticket check. From inside the container, run:

```powershell
klist
```

#### Test gMSA in Container

```powershell
nltest.exe /query
```

This should return the DC.

```powershell
nltest.exe /parentdomain
```

Check the connection to the DC

```powershell
nltest.exe /sc_verify:<parent domain e.g. win.local>
```

This one should have some print out that shows computer name of the gmsa account.

```powershell
net config workstation
```

# Advanced Debugging 
Kerberos debugging - kerberos ticket check

```powershell
klist
```

should return success message

## Samples

Remote debugging by installing VS debugger in the container. (blog post available)

# Samples

To build the samples (using [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) run the commands below (be sure to use your images in commands for each example).  Alternatively you can use the provided docker images on my docker hub repo.

**WSL**

```powershell
./auth-examples/build.sh <your-docker-repo>
```

**Powershell**

```powershell
./auth-examples/build.ps1 <your-docker-repo>
```

To publish to a docker repository:

**WSL**

```powershell
docker login
./auth-examples/push.sh <your-docker-repo>
```

**Powershell**

```powershell
docker login
./auth-examples/push.ps1 <your-docker-repo>
```
***
## Environment variables

* QUEUE_NAME - This will be the path for the queue.  E.g. for **private queue** .\private$\TestQueue for **public queue** worker\TestQueue
* DIRECT_FORMAT_PROTOCOL - This will be the direct format protocol.  It can be something like OS, TCP, etc.  See the direct format naming for appropriate protocols.
* USER - This will search for a UPN to try to impersonate.

-----

### MSMQ Monolith

We will want to run the MSMQ Monolith container.  Conceptually, we're going to use a private queue that will be accessible from within the container by both the sender and receiver applications.

The queue by default will be located at .\private$\testQueue.

![Monolith with private queue.](media/monolith/scenario.png 'Monolith')

```powershell
docker run -it <my-repo>/windows-ad:msmq-monolith-test
```

We should be able to see the private queue accessible from both the sender and receiver applications.  Since we're in interactive mode, we can also attach to the running container and run the applications separately.

```powershell
docker run -d <my-repo>/windows-ad:msmq-monolith-test
```

```powershell
docker exec -it <my-container-id> powershell
# run this in the container
C:\Sender\MSMQSenderTest.exe
```

```powershell
docker exec -it <my-container-id> powershell
# run this in the container
C:\Receiver\MSMQReceiverTest.exe
```

![Test Success.](media/monolith/successful-test.png 'Monolith test')

----

### MSMQ Persistent Volume on Host

We will mount a persistent volume to the host (could be a Windows VM, Azure Windows VM) so that the private queue (e.g. .\private$\testQueue) will have the data stored in the mount.

![Persistent volume on host for MSMQ private queue with  sender and receiver containers.](media/persistent-volume/scenario.png 'Persistent Volume')



#### Prep script

A setup script in  **.\scripts\persistent-volume-mount-prep.ps1** will help with this process, and we'll want to run it on the host.  We will run the containers **sequentially** as each of the containers will have their own queue manager, which will assume ownership of the file mount.  This **prevents two containers** from using the **same volume mount** and running at the **same time**.

```powershell
.\scripts\persistent-volume-mount-prep.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the host, for instance C:\msmq.

It will grant **permissions** for **everyone** on that folder (this is just a test).

We will also want to verify the bootstrapped data will exist in the mount once we run the container.  If the script completes successfully, we'll have the **storage** and **mapping** folders in the **volume mount**.

![Persistent volume data.]
(media/persistent-volume/volume-mount-data.png 'Queue Data')

#### Running the scenario

We can verify the permissions on the folder in PowerShell.

```powershell
Get-ACL C:\<local volume mount>
```

![Peristent volume permissions.](media/persistent-volume/permissions.PNG 'Permissions')

We'll want to run the containers next and point them to the local volume mount.

If we're using **transparent network driver**, it might look something like this:

Run the sender.

```powershell
docker run --security-opt "credentialspec=file://MSMQsend.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQsend --network=tlan2 --dns=10.123.80.123 --name persistent_store <my-repo>/windows-ad:msmq-sender-test powershell
```

Run the receiver.

```powershell
docker run --security-opt "credentialspec=file://MSMQRec.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQRec --network=tlan2 --dns=10.123.80.123 --name persistent_store_receiver <my-repo>/windows-ad:msmq-receiver-test powershell
```

If we're using **NAT network driver**, it might look something like this:

Run the sender.

```powershell
docker run --security-opt "credentialspec=file://MSMQsend.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQsend -p 80:80 -p 4020:4020 -p 4021:4021 -p 135:135/udp -p 389:389 -p 1801:1801/udp -p 2101:2101 -p 2103:2103/udp -p 2105:2105/udp -p 3527:3527 -p 3527:3527/udp -p 2879:2879 --name persistent_store <my-repo>/windows-ad:msmq-sender-test powershell
```

Run the receiver.

```powershell
docker run --security-opt "credentialspec=file://MSMQRec.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQRec -p 80:80 -p 4020:4020 -p 4021:4021 -p 135:135/udp -p 389:389 -p 1801:1801/udp -p 2101:2101 -p 2103:2103/udp -p 2105:2105/udp -p 3527:3527 -p 3527:3527/udp -p 2879:2879 --ip 172.31.230.92 --name persistent_store_receiver <my-repo>/windows-ad:msmq-receiver-test powershell
```

## Other Notes

Tried these commands to set up delegation:

```powershell
Set-ADServiceAccount -Identity frontend -TrustedForDelegation $true
Set-ADServiceAccount -Identity backend -TrustedForDelegation $true
$impersonation = Get-ADServiceAccount -Identity frontend
Set-ADServiceAccount backend -PrincipalsAllowedToDelegateToAccount $impersonation
Set-ADServiceAccount -identity backend -replace @{userAccountControl=16781312}
```

Can validate delegation is set up with (https://blogs.uw.edu/kool/2016/10/26/kerberos-delegation-in-active-directory/):

```powershell
$filter = "(userAccountControl=16781312)"
$objects = Get-ADObject -LDAPFilter $filter
$objects | select Name
```

```powershell
//This is the code to do delegation in code.  Need to have delegation setup properly otherwise it will not work.  and these calls will fail.
PrincipalContext ctx = new PrincipalContext(ContextType.Domain);
                UserPrincipal curUser = UserPrincipal.FindByIdentity(ctx, Request.LogonUserIdentity.Name);
                //WindowsIdentity wi = new WindowsIdentity(curUser.UserPrincipalName);
                WindowsIdentity wi = (WindowsIdentity)Request.LogonUserIdentity;
                WindowsImpersonationContext wCtx = wi.Impersonate(); 

if (wCtx != null)
{
   wCtx.Undo();
}
```
