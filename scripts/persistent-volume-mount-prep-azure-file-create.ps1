#run this locally to provision an Azure File Share.

$ErrorActionPreference = "Stop"

$account_name = 'msmqsharesa'
$rgName = 'msmq-share-mount'
$share_name = 'msmq-share'
$subscriptionId = 'my sub'
#be sure the azure file share location matches the location of the host
$location = 'eastus'
$spn = 'msmq-spn-2'

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
