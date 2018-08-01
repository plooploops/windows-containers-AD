# Domain join a VM to an existing domain

This template joins the VM to an existing domain. The template requires a domain controller to already be setup.

### REQUIREMENTS
1. Existing domain controller
2. Deploy to the resource group, VNET and Subnet of the domain controller


create a user on the domain called test2 in Organizational unit = org (was not able to use account used to create the domain):

```
New-ADOrganizationalUnit "org"
New-ADUser -Name test -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -Path "OU=org,DC=win,DC=local" -UserPrincipalName test@win.local
```

then run:

az group deployment create --name add-domain -g windows-container-ad \
    --template-file "AD/201-vm-domain-join/azuredeploy.json" \
    --parameters "AD/201-vm-domain-join/azuredeploy.parameters.json" \
    --parameters domainPassword=<password> vmAdminPassword=<password> dnsLabelPrefix=<vm-name-1>