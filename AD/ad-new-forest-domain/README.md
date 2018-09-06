# Create a new Windows VM and create a new AD Forest, Domain and DC

This template will deploy a new VM (along with a new VNet, Storage Account and Load Balancer) and will configure it as a Domain Controller and create a new forest and domain. It was adapted from (https://azure.microsoft.com/en-us/resources/templates/active-directory-new-domain/)

This template will create a VNET with the 10.0.0.0/16 range with at 10.0.0.0/24 subnet.  The domain controller (Standard_D2_v2 VM) will be given the static IP address of 10.0.0.4. The Azure DNS settings for the deployment will be updated to point all VMs to the DC for DNS resolution.

The azuredeploy.parameters.json file is used to customize the domain name of the AD forest and the dnsPrefix used by deployment, as well as a few other variables.  You should review this file and edit it to align with your needs before deploying. 

The required AD roles will be installed by using DSC and calling the CerateADPDC.ps1 configuration.  Then it will run the "domainbasics.ps1" as custom script file to create users. The "domainbasics.ps1" file sets up the KDS Root Key, creates groups for Container Host machines and test users. 

### Create a Domain controller

```powershell
az group create -n windows-container-ad -l eastus

az group deployment create --name addeploy -g windows-container-ad \
    --template-file "AD/ad-new-forest-domain/azuredeploy.json" \
    --parameters "AD/ad-new-forest-domain/azuredeploy.parameters.json" \
    --parameters adminPassword=<password>
```

You can now Log in with user `win\winadmin`


### Setup OUs, Groups and GMSA Accounts on the Domain 

Log onto the DC if you haven't already. The "domainbasics.ps1" file will have already set up some users, groups and OUs and completed the steps below. If you did not edit it before deployment, use the file as a reference to review what was created in Active Directory and create any additional components you might need for your scenarios.  

If you manually promoted a VM to be a domain controller without using the deployment template, you will need to do all the steps below, using the "domainbasics.ps1" file as a guide.

#### Add KDS Root Key

> Don't do this in production.  See https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/jj128430(v=ws.11) for production deployments.

```powershell
Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))
```

#### Set up OU for Worker (Container Host) Servers

Set up OU for add VM to domain.

```powershell
New-ADOrganizationalUnit "WorkerVMs"
```

#### Create AD Group for Container Host Servers

```powershell
New-ADGroup -GroupCategory Security -DisplayName "Container Hosts" -Name containerhosts -GroupScope Universal
$group = Get-ADGroup containerhosts
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)
```

#### Create AD Users (Optional)

Create additional test users if needed.

```powershell
New-ADUser -Name User1 -PasswordNeverExpires $true -AccountPassword ("<password>" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true
$user1 = Get-ADUser User1
$usergroup = New-ADGroup -GroupCategory Security -DisplayName "Web Authorized Users" -Name WebUsers -GroupScope Universal
$usergroup | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)
```
Once the domain controller is completed, you can [join additional member servers](AD/vm-domain-join/README.md) (worker1, worker2, etc) to act as the container host machines.