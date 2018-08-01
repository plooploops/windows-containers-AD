# Create a new Windows VM and create a new AD Forest, Domain and DC

This template will deploy a new VM (along with a new VNet, Storage Account and Load Balancer) and will configure it as a Domain Controller and create a new forest and domain.

az group deployment create --name addeploy -g windows-container-ad \
    --template-file "AD/active-directory-new-domain/azuredeploy.json" \
    --parameters "AD/active-directory-new-domain/azuredeploy.parameters.json" \
    --parameters adminPassword=<password>

Log in with user `win\winadmin`