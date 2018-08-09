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
> MSMQSend C:\ProgramData\docker\CredentialSpecs\MSMQSend.json
> MSMQReceiver C:\ProgramData\docker\CredentialSpecs\MSMQReceiver.json
> ```

#### General Testing and Troubleshoot for a GMSA Account

When running your container, set host name to the same as the name of the gMSA. 
See other [debugging tips](https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/a887583835a91a27b7b1289ec6059808bd912ab1/virtualization/windowscontainers/manage-containers/walkthrough-iis-serviceaccount.md#test-a-container-using-the-service-account).

```powershell
docker run -h MSMQSend -it --security-opt "credentialspec=file://MSMQSend.json" microsoft/windowsservercore:1803 cmd
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

## Advanced Debugging for Kerberos

Kerberos ticket check. From inside the container, run:

```powershell
klist
```
This should return a success message.