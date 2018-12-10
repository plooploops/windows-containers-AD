## Global Managed Service Accounts with Containers

The purpose of using a gMSA with a container provides the container with a mechanism to access domain specific resources, like make LDAP calls, using a pre-created service account.  The container only knows the name of the account it is using and domain joined machine that is hosting the container is tasked with providing the password. 

### Create Managed Service Account

Creation of the GMSA accounts is primarily an AD Admin function and is unrelated to the containers themselves.  It can happen from any machine that has RSAT Tools and access to the domain controller. In the [gmsacreation.ps1 file](AD/create-gmsa/gmsacreation.ps1) there are examples for MSMQ sender and recievers, as well as the IIS scenarios. 

When you create the gMSA accounts, you will set some specific attributes that are not as common for regular user or machine accounts.

1. -ServicePrincipalNames = SPNs set on the service account which will determine what protocol requests it will listen for.  MQQB, RPC, TCP and UDP are all protocols used by MSMQ.
1. -PrincipalsAllowedToRetrieveManagedPassword = By including the "containerhosts" security group, all the worker VMS will be able to retrieve the password to the gMSA and use it on behalf of the container.
1. -{userAccountControl=16781312} = A default gMSA account has the user account control set as a WORKSTATION_TRUST_ACCT.  This change adds on the TRUSTED_TO_AUTH_FOR_DELEGATION property. You can read more about this properties at (https://support.microsoft.com/nl-nl/help/305144/how-to-use-the-useraccountcontrol-flags-to-manipulate-user-account-pro). The UAC setting is important so that the container can transfer the ability for it to be impersonated via the container host VM.
1. {msDS-AllowedToDelegateTo} = The gMSA account will be able to be used by the downstream hosts listed for additional delegation "hops".

### Test GMSA access from Container Host VM (Optional)
Remote into worker machine (worker1 VM) and **Switch to PowerShell**.  When you login it defaults to cmd.

Install AD components on worker machine and test access to the gMSA accounts. Generally, it's not recommended to add RSAT tools to the worker/container host machines unless you need to for testing. 

```powershell
Add-WindowsFeature RSAT-AD-PowerShell
Install-WindowsFeature ADLDS
Import-Module ActiveDirectory

Test-ADServiceAccount <GMSAaccount>
Test-ADServiceAccount <GMSAaccount>
```
> This should return true.

### Create a cred spec file for gMSA on the Container Host VM

Notes:
   This file needs to be accessible from where ever the the container needs to be run, thus every VM you'll be using as a stand-alone container host or every VM in your deployment cluster.  The file needs to have the same name as the gMSA account in Active Directory.  This file does not contain any secrets, it is simply a reference file used by docker when the container is run to reference the account in Active Directory. 

Create a new credential spec:

```powershell
Start-BitsTransfer https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/live/windows-server-container-tools/ServiceAccounts/CredentialSpec.psm1
Import-Module .\CredentialSpec.psm1

New-CredentialSpec -Name <GMSAaccount> -AccountName <GMSAaccount>

# should output location of the files
Get-CredentialSpec
```

> It should be the following:
> ```
>  Name          Path
> ----          ----
> <GMSAaccount> C:\ProgramData\docker\CredentialSpecs\<GMSAaccount>.json
> ```

### Examine gMSA account properties
```
get-adserviceaccount -identity <GMSAaccount> -properties 'PrincipalsAllowedToDelegateToAccount','PrincipalsAllowedToRetrieveManagedPassword','kerberosEncryptionType','ServicePrincipalName','msDS-AllowedToDelegateTo','userAccountControl','PrincipalsAllowedToDelegateToAccount'
```

You can also review the properties of the GMSA accounts using the ADSI Edit tool. 

### General Testing and Troubleshoot for a GMSA Account

When running your container, set host name to the same as the name of the gMSA. 
See other [debugging tips](https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/a887583835a91a27b7b1289ec6059808bd912ab1/virtualization/windowscontainers/manage-containers/walkthrough-iis-serviceaccount.md#test-a-container-using-the-service-account).

```powershell
docker run -h <GMSAaccount> -it --security-opt "credentialspec=file://<GMSAaccount>.json" microsoft/windowsservercore:1803 cmd
```

From in the container run:

```cmd
nltest.exe /query
nltest.exe /parentdomain
nltest.exe /sc_verify:<parent domain e.g. win.local>
```
This should return the DC name and verify connectivity.

```cmd
net config workstation
```
This one should have some print out that shows computer name of the GMSA account.

### Advanced Debugging for Kerberos

Kerberos ticket check. From inside the container, run:

```powershell
klist
```
This should return a success message and any cached kerberos tickets. 