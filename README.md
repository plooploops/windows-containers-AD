# AD with Windows Containers
Examples for getting started with Windows containers and AD.  The commands below have been adopted by following basic steps in this [gist to configure AD properly](https://gist.github.com/PatrickLang/27c743782fca17b19bf94490cbb6f960).

To get started:

1. Clone this repo. The commands below where written and run from the WSL.

2. [Set up AD](#set-up-ad)
    - Create Domain Controller
    - Create Domain Joined VM
    - Create Non-Admin User for testing
    - Configure AD with gMSA
3. [Run Samples](#samples)
    - MSMQ Monolith
    - MSMQ Persistent Volume on Host

## Set up AD 

### Create a Domain contoller

Using the template's located in `AD/active-directory-new-domain`

```
az group create -n windows-container-ad -l eastus

az group deployment create --name addeploy -g windows-container-ad \
    --template-file "AD/active-directory-new-domain/azuredeploy.json" \
    --parameters "AD/active-directory-new-domain/azuredeploy.parameters.json" \
    --parameters adminPassword='<password>'
```
You can now Log in with user `win\winadmin`

### Setup OUs, Groups and GMSA Accounts on the Domain

Log onto the DC if you haven't already. Use the "usercreation.ps1" file will help you set up the OU and AD Groups needed for the container host VMs, as well as the GMSA accounts for the frontend and backend services.

#### Add KDS Root Key
Don't do in production.  See https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/jj128430(v=ws.11) for prod.
```
Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))
```
#### Set up OU for Worker (Container Host) Servers
Set up OU for add VM to domain (thought should be able to use [domain admin but need OU set up](https://github.com/Azure/azure-quickstart-templates/issues/2272)). 

#### Create AD Group for Container Host Servers
```
New-ADGroup -GroupCategory Security -DisplayName "Container Hosts" -Name containerhosts -GroupScope Universal
$group = Get-ADGroup containerhosts
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)
```
#### Create Managed Service Account
Create group to add host computers to, and create GMSA accounts to be used. In the "usercreation.ps1" file there are examples for both a frontend and backend service.


#### Create AD Users (Optional)
Create additional test users if needed.

```
New-ADUser -Name User1 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true
$user1 = Get-ADUser User1
$usergroup = New-ADGroup -GroupCategory Security -DisplayName "Web Authorized Users" -Name WebUsers -GroupScope Universal
$usergroup | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)
```

### Create a Domain joined VM

For each VM you wish to create run:

```
az group deployment create --name add-domain -g windows-container-ad \
    --template-file "AD/201-vm-domain-join/azuredeploy.json" \
    --parameters "AD/201-vm-domain-join/azuredeploy.parameters.json" \
    --parameters domainPassword='<password>' vmAdminPassword='<password>' dnsLabelPrefix=worker1
```

You should be able to remote into the domain joined vm using admin user to test that it is domain joined.  These machines should be added to the Worker VM OU and become members of the "container hosts" AD Group.

```
New-ADGroup -GroupCategory Security -DisplayName "Container Hosts" -Name containerhosts -GroupScope Universal
$group = Get-ADGroup containerhosts
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)
```
You must **Reboot** the container host machine (work1 in this example) so it has access to the GMSA account passwords. 

#### Test GMSA access from Container Host VM
Remote into worker machine (woker1 vm) and ** Switch to PowerShell**.  When you login it defaults to cmd.

Install AD componentes on worker machine:

```
Add-WindowsFeature RSAT-AD-PowerShell
Import-Module ActiveDirectory
```

Test access to  GMSA Account
```
Test-ADServiceAccount containergmsa
```
# This should return true


#### Create a spec for gMSA on the Container Host VM
Notes:
   This file needs to be accessible from where ever the the container needs to be run.  (every vm in your cluster)

Create a spec:
```
Start-BitsTransfer https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/live/windows-server-container-tools/ServiceAccounts/CredentialSpec.psm1
Import-Module .\CredentialSpec.psm1

New-CredentialSpec -Name containergmsa -AccountName containergmsa

# should output location of the file
Get-CredentialSpec
```

#### Test it

```
Set host name to the same as the name of the gmsa.  See other [debugging tips](https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/a887583835a91a27b7b1289ec6059808bd912ab1/virtualization/windowscontainers/manage-containers/walkthrough-iis-serviceaccount.md#test-a-container-using-the-service-account).

```
docker run -h containergmsa -it --security-opt "credentialspec=file://containergmsa.json" microsoft/windowsservercore:1709 cmd

#in the container run
nltest.exe /query
nltest.exe /parentdomain (should return DC)
net config workstation (this one should have some print out that shows computer name of the gmsa account)

# Advanced Debugging
Kerberos debugging - kerberos ticket check
klist

remote debugging by installing VS debugger in the container. (blog post available)

## should return success message

## Samples
To build the samples (using [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) run the commands below (be sure to use your images in commands for each example).  Alternatively you can use the provided docker images on my docker hub repo.

**WSL**
```
./auth-examples/build.sh <your-docker-repo>
```

**Powershell**
```
./auth-examples/build.ps1 <your-docker-repo>
```

To publish to a docker repository:

**WSL**
```
docker login 
./auth-examples/push.sh <your-docker-repo>
```

**Powershell**
```
docker login 
./auth-examples/push.ps1 <your-docker-repo>
```

***
### MSMQ Monolith

We will want to run the MSMQ Monolith container.  Conceptually, we're going to use a private queue that will be accessible from within the container by both the sender and receiver applications.

The queue by default will be located at .\private$\testQueue.

![Monolith with private queue.](media/monolith/scenario.png 'Monolith')

```
docker run -it <my-repo>/windows-ad:msmq-monolith-test
```

We should be able to see the private queue accessible from both the sender and receiver applications.  Since we're in interactive mode, we can also attach to the running container and run the applications separately.

```
docker run -d <my-repo>/windows-ad:msmq-monolith-test
```

```
docker exec -it <my-container-id> powershell
# run this in the container
C:\Sender\MSMQSenderTest.exe 
```

```
docker exec -it <my-container-id> powershell
# run this in the container
C:\Receiver\MSMQReceiverTest.exe
```

![Test Success.](media/monolith/successful-test.png 'Monolith test')

***
### MSMQ Persistent Volume on Host

We will mount a persistent volume to the host (could be a Windows VM, Azure Windows VM) so that the private queue (e.g. .\private$\testQueue) will have the data stored in the mount.

![Peristent volume on host for MSMQ private queue with  sender and receiver containers.](media/persistent-volume/scenario.png 'Persistent Volume')

#### Links

These will describe some of the concepts that we're using in this scenario.

1.  [Windows Containers Networking](https://blogs.technet.microsoft.com/virtualization/2016/05/05/windows-container-networking/)
2.  [Windows Containers Volumes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage)

#### Prep script
A setup script in  **.\scripts\persistent-volume-mount-prep.ps1** will help with this process, and we'll want to run it on the host.

```
.\scripts\persistent-volume-mount-prep.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the, for instance C:\msmq.

It will grant **permissions** for everyone on that folder (this is just a test).

We will also want to verify the bootstrapped data will exist in the mount once we run the container.  If the script completes successfully, we'll have the **storage** and **mapping** folders in the **volume mount**.

![Peristent volume data.](media/persistent-volume/volume-mount-data.png 'Queue Data')

#### Running the scenario

We can verify the permissions on the folder in PowerShell.

```
Get-ACL C:\<local volume mount>
```

![Peristent volume permissions.](media/persistent-volume/permissions.png 'Permissions')

We'll want to run the containers next and point them to the local volume mount.

If we're using **transparent network driver**, it might look something like this:

Run the sender.
```
docker run --security-opt "credentialspec=file://MSMQsend.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQsend --network=tlan2 --dns=10.123.80.123 --name persistent_store <my-repo>/windows-ad:msmq-sender-test powershell
```

Run the receiver.
```
docker run --security-opt "credentialspec=file://MSMQRec.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQRec --network=tlan2 --dns=10.123.80.123 --name persistent_store_receiver <my-repo>/windows-ad:msmq-receiver-test powershell
```

If we're using **NAT network driver**, it might look something like this:

Run the sender.
```
docker run --security-opt "credentialspec=file://MSMQsend.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQsend -p 80:80 -p 4020:4020 -p 4021:4021 -p 135:135/udp -p 389:389 -p 1801:1801/udp -p 2101:2101 -p 2103:2103/udp -p 2105:2105/udp -p 3527:3527 -p 3527:3527/udp -p 2879:2879 --name persistent_store <my-repo>/windows-ad:msmq-sender-test powershell
```

Run the receiver.
```
docker run --security-opt "credentialspec=file://MSMQRec.json" -it -v C:\msmq:c:/Windows/System32/msmq -h MSMQRec -p 80:80 -p 4020:4020 -p 4021:4021 -p 135:135/udp -p 389:389 -p 1801:1801/udp -p 2101:2101 -p 2103:2103/udp -p 2105:2105/udp -p 3527:3527 -p 3527:3527/udp -p 2879:2879 --ip 172.31.230.92 --name persistent_store_receiver <my-repo>/windows-ad:msmq-receiver-test powershell
```

## Other Notes

Tried these commands to set up delegation:
```
Set-ADServiceAccount -Identity frontend -TrustedForDelegation $true
Set-ADServiceAccount -Identity backend -TrustedForDelegation $true
$impersonatin = Get-ADServiceAccount -Identity frontend
Set-ADServiceAccount backend -PrincipalsAllowedToDelegateToAccount $impersonatin
Set-ADServiceAccount -identity backend -replace @{userAccountControl=16781312}
```

Can validate delegation is set up with (https://blogs.uw.edu/kool/2016/10/26/kerberos-delegation-in-active-directory/):

```
$filter = "(userAccountControl=16781312)"
$objects = Get-ADObject -LDAPFilter $filter
$objects | select Name
```

```
//This is the code to do delgation in code.  Need to have delegation setup properly otherwise it will not work.  and these calls will fail.
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
