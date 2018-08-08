#### Create Managed Service Account

Creation of the GMSA accounts can happen from any machine that has RSAT Tools and access to the domain controller. In the [gmsacreation.ps1 file](AD/create-gmsa/gmsacreation.ps1) there are examples for MSMQ sender and recievers. Create group to add host computers to, and create GMSA accounts to be used. 

#### Test GMSA access from Container Host VM (Optional)
Remote into worker machine (woker1 vm) and ** Switch to PowerShell**.  When you login it defaults to cmd.

Install AD components on worker machine and test access to the gMSA accounts. Generally, it's not recommended to add RSAT tools to the worker/container host machines unless you need to for testing.

```powershell
Add-WindowsFeature RSAT-AD-PowerShell
Install-WindowsFeature ADLDS
Import-Module ActiveDirectory

Test-ADServiceAccount MSMQSend
Test-ADServiceAccount MSMQReceiver
```
> This should return true

#### Create a cred spec file for gMSA on the Container Host VM

Notes:
   This file needs to be accessible from where ever the the container needs to be run, thus every VM you'll be using as a stand-alone container host or every VM in your deployment cluster.  The file needs to have the same name as the gMSA account in Active Directory.  This file does not contain any secrets, it is simply a reference file used by docker when the container is run to reference the account in Active Directory. 

Create a new credential spec:

```powershell
Start-BitsTransfer https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/live/windows-server-container-tools/ServiceAccounts/CredentialSpec.psm1
Import-Module .\CredentialSpec.psm1

New-CredentialSpec -Name MSMQSend -AccountName MSMQSend
New-CredentialSpec -Name MSMQReceiver -AccountName MSMQReceiver

# should output location of the files
Get-CredentialSpec
```

> It should be the following:
> ```
>  Name          Path
> ----          ----
> app1 C:\ProgramData\docker\CredentialSpecs\MSMQSend.json
> app2 C:\ProgramData\docker\CredentialSpecs\MSMQReceiver.json
> ```