# Domain join a VM to an existing domain

This template joins the VM to an existing domain. The template requires a domain controller to already be setup. it was adapted from (https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-domain-join)


### REQUIREMENTS
1. Existing domain controller
2. Deploy to the resource group, VNET and Subnet of the domain controller

For each VM you wish to create run:

```powershell
az group deployment create --name add-domain -g windows-container-ad \
    --template-file "AD/vm-domain-join/azuredeploy.json" \
    --parameters "AD/vm-domain-join/azuredeploy.parameters.json" \
    --parameters domainPassword='<password>' vmAdminPassword='<password>' dnsLabelPrefix=worker1
```

You should be able to remote into the domain joined vm using admin user to test that it is domain joined.  These machines should be added to the Worker VM OU and become members of the "container hosts" AD Group.  You must **Reboot** the container host machine (worker1 in this example) after it is added to the "Container Hosts" security group so it has access to the GMSA account passwords in the future.



